"""
Author    : Jessy Pango
Github    : @jp-sft
Date      : 30/04/2023
Purpose   : Gestion de l'authentification web à deux facteurs
"""

import logging
import odoo
import werkzeug

from odoo import exceptions
from odoo import http, _
from odoo.addons.web.controllers.main import Home, ensure_db, SIGN_UP_REQUEST_PARAMS
from odoo.http import request
_logger = logging.getLogger(__name__)


class TwoFactorAuthController(Home):
    """
    Controller pour gérer l'authentification à deux facteur
    """

    @http.route('/web/login', type='http', auth="none", website=True)
    def web_login(self, redirect=None, **kw):
        """
        Login avec authentification à deux facteurs
        """
        ensure_db()
        request.params['login_success'] = False
        if request.httprequest.method == 'GET' and redirect and request.session.uid:
            return request.redirect(redirect)

        if not request.uid:
            request.uid = odoo.SUPERUSER_ID

        values = {k: v for k, v in request.params.items() if k in SIGN_UP_REQUEST_PARAMS}
        try:
            values['databases'] = http.db_list()
        except odoo.exceptions.AccessDenied:
            values['databases'] = None

        if request.httprequest.method == 'POST':
            old_uid = request.uid
            try:
                wsgienv = request.httprequest.environ
                env = dict(
                    interactive=True,
                    base_location=request.httprequest.url_root.rstrip('/'),
                    HTTP_HOST=wsgienv['HTTP_HOST'],
                    REMOTE_ADDR=wsgienv['REMOTE_ADDR'],
                )
                request.session['check_token'] = False
                try:
                    odoo.registry(request.session.db)['res.users'].authenticate(
                        request.session.db,
                        request.params['login'],
                        request.params['password'],
                        env
                    )
                except exceptions.AccessDenied as exc:
                    if not request.token_send:
                        raise exc

                if request.uid_2fa:
                    request.session["uid_2fa"] = request.uid
                    request.session["login"] = request.params['login']
                    request.session["password"] = request.params['password']
                    # request.session["uid"] = request.uid
                    request.session['redirect'] = redirect if redirect is not None else "/web"
                    return werkzeug.utils.redirect('/two_factor_auth')
                raise odoo.exceptions.AccessDenied
            except odoo.exceptions.AccessDenied as exc:
                request.uid = old_uid
                if exc.args == odoo.exceptions.AccessDenied().args:
                    values['error'] = _("Wrong login/password")
                else:
                    values['error'] = exc.args[0]
        else:
            if 'error' in request.params and request.params.get('error') == 'access':
                values['error'] = _(
                    'Only employees can access this database. Please contact the administrator.'
                )

        if 'login' not in values and request.session.get('auth_login'):
            values['login'] = request.session.get('auth_login')

        if not odoo.tools.config['list_db']:
            values['disable_database_manager'] = True

        response = request.render('web.login', values)
        response.headers['X-Frame-Options'] = 'DENY'
        return response

    @http.route('/two_factor_auth', auth='none')
    def show_2fa_form(self, **kw):
        """
        Affiche le formulaire de saisie du code à deux facteurs
        """
        uid = request.session.get("uid_2fa", None)
        if not uid:
            return werkzeug.utils.redirect('/web/login')
        return request.render('custom_auth_signup.two_factor_auth_form')

    @http.route('/two_factor_auth/verify', type='http', auth='none', website=True)
    def verify_2fa_token(self, token=None, redirect=None, **kw):
        """
        Vérifie le code à deux facteurs
        """
        request.session['token'] = token
        request.session['check_token'] = True
        login = request.session['login']
        password = request.session['password']
        try:
            request.session.authenticate(request.session.db, login, password)
            request.params['login_success'] = True
            return werkzeug.utils.redirect("/web" if redirect is None else redirect)
        except http.AuthenticationError:
            return request.render(
                'custom_auth_signup.two_factor_auth_form', {
                    'error': 'Code Invalide',
                }
            )
