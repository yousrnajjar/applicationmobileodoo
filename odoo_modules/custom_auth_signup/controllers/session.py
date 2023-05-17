"""
Author    : Jessy Pango
Github    : @jp-sft
Date      : 30/04/2023
Purpose   : Accepter le token de l'utilisateur et le sauvegarder dans la session
"""
import logging
import os

import odoo.exceptions
from odoo import http
from odoo.http import request
from odoo.addons.web.controllers.main import Home, ensure_db, SIGN_UP_REQUEST_PARAMS
_logger = logging.getLogger(__name__)


class TokenSession(http.Controller):
    """
    Ajoute le l'authentification pas token
    """
    @http.route('/web/session/authenticate/token', type='json', auth="none", cors="*")
    def authenticate_with_token(self, login, password, token):
        """
        JSON Authentication via default database
        :param login: User login
        :param password: User password
        :param token: User Confirm Token
        :param base_location:
        :return:
        """
        request.session['token'] = token
        request.session['check_token'] = True
        try:
            request.session.authenticate(request.db, login, password)
        except http.AuthenticationError as exception:
            request.session.uid = False
            if not hasattr(request, "is_valid_token") or not request.token_send:
                # Raise authentification error if token is not send
                raise http.AuthenticationError("Token incorrect") from exception
        return request.env['ir.http'].session_info()

    @http.route('/web/session/authenticate2', type='json', auth="none", cors="*")
    def authenticate(self, login, password):
        """
        JSON Authentication via default database
        :param login: User login
        :param password: User password
        :return:
        :raise: AuthenticationError if token is not send
        """
        request.session['check_token'] = False
        try:
            request.session.authenticate(request.db, login, password)
        except odoo.exceptions.AccessDenied as exception:
            if not hasattr(request, "token_send") or not request.token_send:
                raise http.AuthenticationError("Login ou mot de passe incorrect") from exception
        return request.env['ir.http'].session_info()
