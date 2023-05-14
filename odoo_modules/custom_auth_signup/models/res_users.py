"""
Author    : Jessy Pango
Github    : @jp-sft
Date      : 27/04/2023
Purpose   : Adding two-factor authentication when user login
"""

import logging
import random
import string

from odoo import models, fields
from odoo.exceptions import AccessDenied
from odoo.http import request, AuthenticationError


_logger = logging.getLogger(__name__)


class ResUsers(models.Model):
    """
    Ajout de deux facteurs d'authentification pour les utilisateurs Odoo.
    """
    _inherit = "res.users"
    _description = "Adding Two factor authentication"

    enable_two_fact = fields.Boolean(default=True)
    auth_token = fields.Char()

    def generate_token(self):
        """
        Génère un token de 6 caractères aléatoires et l'enregistre dans la base de données.
        """
        token = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
        self.sudo().write({"auth_token": token})
        request.session['true_token'] = token
        _logger.info("Création d'un token pour l'utilisateur %s!", self)
        return True

    def generate_token_and_send(self):
        """Crée un nouveau token et l'envoie."""
        self.generate_token()
        self.sent_auth_code_mail()
        return True

    def sent_auth_code_mail(self):
        """
        Envoie un mail contenant le token de l'utilisateur.
        """
        template = self.env.ref('custom_auth_signup.two_factor_auth_mail_template')
        ip_address = request.httprequest.environ['REMOTE_ADDR']
        rendered_template = template.render({
            'token': request.session['true_token'],
            'user': self,
            'ip': ip_address,
        }, engine="ir.qweb")
        smpt = self.env['ir.mail_server'].search([])[0]
        self.env['mail.mail'].create({
            'subject': 'Your 2FA token',
            'body_html': rendered_template,
            'email_to': self.email_formatted,
            'email_from': smpt.smtp_user,
            'auto_delete': True,
        }).send()
        _logger.info("Token d'authentification Envoyé pour l'utilisateur avec id=%s.", self)
        return True

    def _check_credentials(self, password):
        """
        Check that user has been provided correct information.
        This will send token by email when send_email_token is set to true
        :param password:
        :return:
        """
        super()._check_credentials(password)
        check_token = request.session.get("check_token")
        if not check_token:
            self.generate_token_and_send()
            request.token_send = True
            request.uid_2fa = self.id
            raise AccessDenied("Veuillez confirmer le token.")
        provided_token = request.session.get("provided_token")
        true_token = request.session.get('true_token')
        if provided_token != true_token:
            request.is_valid_token = False
            raise AuthenticationError("Invalid Token")

    @classmethod
    def authenticate(cls, database, login, password, user_agent_env):
        """
        Méthode d'authentification pour les utilisateurs Odoo.
        :param db: Nom de la base de donnée
        :param login: Nom d'utilisateur
        :param password: Mot de passe
        :param user_agent_env: Dictionnaire contenant les autres informations
        :return: la méthode parente
        """
        _logger.info("%s , try to logging via two-fact method in db: %s", login, database)
        check_token = request.session.get("check_token")
        if check_token:
            request.session["provided_token"] = user_agent_env.get(
                'token',
                request.session.get("token")
            )
        return super().authenticate(database, login, password, user_agent_env)
