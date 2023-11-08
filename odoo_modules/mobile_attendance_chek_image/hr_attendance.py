# -*- coding: utf-8 -*-

import logging

from odoo import models, fields, api

from .utils import compare_faces_using_service

_logger = logging.getLogger(__name__)

ATTENDANCE_STATE = [
    ('invalid', 'Invalide'),
    ('check_in_image_invalid', 'Image d\'entrée non valide'),
    ('check_out_image_invalid', 'Image de sortie non valide'),
    ('valid', 'Valide'),
]


class HrAttendance(models.Model):
    """
    Permet d'ajouter :
        * un statué de verification de l'image
    """
    _inherit = 'hr.attendance'

    employee_image = fields.Binary(
        string='Employee Image',
        related='employee_id.image_512',
        readonly=True,
        help="Employee Image",
    )
    # Check In
    is_check_in_image_valid = fields.Boolean(
        string='Check In Image Valid',
        compute='_check_in_image_valid',
        store=True,
        help="Check In Image Valid",
        readonly=False,
    )
    # Check Out
    is_check_out_image_valid = fields.Boolean(
        string='Check Out Image Valid',
        compute='_check_out_image_valid',
        store=True,
        help="Check Out Image Valid",
        readonly=False,
    )

    # Statut Regroupement la vérification de l'image
    state = fields.Selection(
        ATTENDANCE_STATE,
        string='Statut',
        default='invalid',
        readonly=True, copy=False, index=True,
        help="Statut de la vérification de l'image",
        compute='_compute_state',
        store=True,
    )

    @api.depends('is_check_in_image_valid', 'is_check_out_image_valid')
    def _compute_state(self):
        """
        Permet de regrouper la vérification de l'image
        """
        for attendance in self:
            is_check_in_image_valid = attendance.is_check_in_image_valid
            is_check_out_image_valid = attendance.is_check_out_image_valid
            if is_check_in_image_valid and is_check_out_image_valid:
                attendance.state = 'valid'
            elif is_check_in_image_valid:
                attendance.state = 'check_out_image_invalid'
            elif is_check_out_image_valid:
                attendance.state = 'check_in_image_invalid'
            else:
                attendance.state = 'invalid'

    @api.depends('employee_image', 'check_in_image')
    def _check_in_image_valid(self):
        """
        Permet de vérifier l'image lors du pointage
        """
        res_config = self.env['res.config.settings'].sudo().get_values()
        if not res_config.get('mobile_attendance_chek_image.face_verification_service_path'):
            _logger.warning('No face verification service path')
        face_verification_service_path = res_config.get(
            'mobile_attendance_chek_image.face_verification_service_path'
        )
        for attendance in self:
            check_in_image = attendance.check_in_image
            employee_images = attendance.get_know_employee_images(use_check_in=True)
            if not employee_images:
                _logger.warning('No employee image: %s', attendance.id)
                continue
            if check_in_image:
                attendance.is_check_in_image_valid = compare_faces_using_service(
                    employee_images, check_in_image, service_url=face_verification_service_path
                )
            else:
                _logger.warning('No check in image: %s', attendance.id)

    @api.depends('employee_image', "check_out_image")
    def _check_out_image_valid(self):
        """
        Permet de vérifier l'image lors du pointage
        """
        res_config = self.env['res.config.settings'].sudo().get_values()
        if not res_config.get('mobile_attendance_chek_image.face_verification_service_path'):
            _logger.warning('No face verification service path')
        face_verification_service_path = res_config.get(
            'mobile_attendance_chek_image.face_verification_service_path'
        )
        for attendance in self:
            employee_images = attendance.get_know_employee_images(use_check_in=False)
            check_out_image = attendance.check_out_image

            if not employee_images:
                _logger.warning('No employee image: %s', attendance.id)
                continue
            if check_out_image:
                attendance.is_check_out_image_valid = compare_faces_using_service(
                    employee_images, check_out_image, service_url=face_verification_service_path
                )
            else:
                _logger.warning('No check out image: %s', attendance.id)

    def get_know_employee_images(self, use_check_in=False, limit=10):
        """
        Permet de récupérer les images de l'employé qui sont connues et qui sont valides
        """
        self.ensure_one()
        res = []
        profil = self.employee_image
        if profil:
            res.append(profil)
        domain = [
            ('employee_id', '=', self.employee_id.id),
            ('state', '=', 'valid'),
        ]
        if use_check_in:
            images = self.search(domain, order='check_in desc', limit=limit).mapped('check_in_image')
        else:
            images = self.search(domain, order='check_out desc', limit=limit).mapped('check_out_image')
        res.extend(images)
        return res
