from odoo import models, fields, api, _
from odoo.exceptions import UserError, ValidationError

class HrPayslip(models.Model):
    """
    Ajouter le mixin MobileNotificationMixins dans hr.payslip
    """
    _name = 'hr.payslip'
    _inherit = ['hr.payslip', 'mobile.notification.mixins']
    _description = 'Hr Payslip'

    # Champ pour le mixin
    _rec_names_attr = ['name', 'display_name']
    _status_field = 'state'
    _start_status = 'draft'
    _notif_message_by_status = {
        'draft': 'Votre bulletin de paie {} a été créé',
        'verify': 'Votre bulletin de paie {} a été vérifié',
        'done': 'Votre bulletin de paie {} a été validé',
        'cancel': 'Votre bulletin de paie {} a été annulé',
    }
    _allowed_notif_status = ['verify', 'done', 'cancel']

