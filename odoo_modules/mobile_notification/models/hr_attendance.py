"""
Purpose: Permet d'envoyer une notification chez l'administrateur et le responsable lors du pointage d'un employé
Author: @jp-sft
Date: 2022-08-05
Update: 2022-08-05
"""
from odoo import models, fields, api, _


class HrAttendance(models.Model):
    """
    Ajouter le mixin MobileNotificationMixins dans hr.attendance
    """
    _name = 'hr.attendance'
    _inherit = ['hr.attendance', 'mobile.notification.mixins']
    _description = 'Hr Attendance'

    # Champ pour le mixin
    _rec_names_attr = ['name', 'display_name']
    _status_field = 'status'
    _start_status = 'check_in'
    _notif_message_by_status = {
        'check_in': 'Votre pointage {} a été créé',
        'check_out': 'Votre pointage {} a été cloturé',
    }
    _allowed_notif_status = ['check_in', 'check_out']

    # Champ statut: depend des champs check_in et check_out
    status = fields.Selection([
        ('draft', 'Draft'),
        ('check_in', 'Check In'),
        ('check_out', 'Check Out'),
    ], string='Status',
    store=True,
    compute='_compute_status',
    readonly=True,
    copy=False,
    tracking=True,
    default='draft')

    def _compute_status(self):
        """
        Calculer le statut
        """
        for attendance in self:
            if attendance.check_in and attendance.check_out:
                attendance.status = 'check_out'
            elif attendance.check_in:
                attendance.status = 'check_in'
            else:
                attendance.status = 'draft'




