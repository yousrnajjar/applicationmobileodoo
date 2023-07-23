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
        'draft': 'Votre demande de congé {} a été créée',
        'confirm': 'Votre demande de congé {} a été confirmée',
        'validate1': 'Votre demande de congé {} a été validée par le manager',
        'validate': 'Votre demande de congé {} a été validée par le RH',
        'refuse': 'Votre demande de congé {} a été refusée',
        'cancel': 'Votre demande de congé {} a été annulée',
    }
    _allowed_notif_status = ['confirm', 'validate1', 'validate', 'refuse', 'cancel']


