# -*- coding: utf-8 -*-
from odoo import models, fields, api, _
from odoo.exceptions import UserError, ValidationError
import logging
_logger = logging.getLogger(__name__)

class HrLeave(models.Model):
    """
    Ajouter le mixin MobileNotificationMixins dans hr.leave
    """
    _name = 'hr.leave'
    _inherit = ['hr.leave', 'mobile.notification.mixins']
    _description = 'Hr Leave'

    # Champ pour le mixin
    _rec_names_attr = ['name', 'display_name']
    _status_field = 'state'
    _start_status = 'draft'
    _notif_message_by_status = {
        'draft': {
            'current_user': 'Votre demande de congé a été enregistrée',
            'manager': 'Une demande de congé a été lancée',
        },
        'confirm': {
            'current_user': 'Votre demande de congé a été confirmée',
        },
        'validate1': {
            'current_user': 'Votre demande de congé a été validée par le manager',
        },
        'validate': {
            'current_user': 'Votre demande de congé a été validée par le RH',
        },
        'refuse': {
            'current_user': 'Votre demande de congé a été refusée',
        },
        'cancel': {
            'current_user': 'Votre demande de congé a été annulée',
        },
    }
    _allowed_notif_status = ['confirm', 'validate1', 'validate', 'refuse', 'cancel']

    def _get_user_role(self, user_id: int) -> str:
        """
        Renvoyer le role de l'utilisateur courant
        """
        if self.employee_id and self.employee_id.user_id.id != user_id:
            return 'manager'
        return 'current_user'

    def _get_target_users(self):
        """
        Renvoyer la liste des utilisateurs à notifier
        """
        res = self.env['res.users']
        current_user = self.employee_id and self.employee_id.user_id
        if current_user:
            res |= current_user
        manager = self.employee_id.parent_id and self.employee_id.parent_id.user_id
        if manager:
            res |= manager
        return res


