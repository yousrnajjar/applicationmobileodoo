# -*- coding: utf-8 -*-

import requests
import io
import uuid

import typing

import base64

import logging

from odoo import models, fields, api, exceptions
from odoo.http import request

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
        # compute='_check_in_image_valid',
        # store=True,
        help="Check In Image Valid",
        readonly=False,
    )
    # Check Out
    is_check_out_image_valid = fields.Boolean(
        string='Check Out Image Valid',
        # compute='_check_out_image_valid',
        # store=True,
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

    face_verification_service_id = fields.Many2one(
        comodel_name='face_verification.service',
        string='Service de vérification',
        default=lambda self: self.env['face_verification.service'].search([], limit=1)[0].id
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

    def do_check_image_valid(self, image_field_name, use_check_in=False):
        """
        Permet de vérifier l'image lors du pointage
        """
        self.ensure_one()
        image = getattr(self, image_field_name)  # type: fields.Image
        if not image:
            raise exceptions.UserError(f'{image_field_name} non présent: {self}')

        employee_images = self._get_know_employee_images(use_check_in=use_check_in)
        if not employee_images:
            raise exceptions.UserError(f'No employee image: {self}')
        check_out_image = self._read_image(image_field_name)
        return self.face_verification_service_id.compare_faces(
            employee_images, check_out_image
        )

    def doc_check_out_image_valid(self):
        if self.check_out_image:
            self.is_check_out_image_valid = self.do_check_image_valid(image_field_name='check_out_image')
        else:
            self.is_check_out_image_valid = False

    def do_check_in_image_valid(self):
        if self.check_in_image:
            self.is_check_in_image_valid = self.do_check_image_valid(image_field_name='check_in_image')
        else:
            self.is_check_in_image_valid = False

    def action_check_image(self):
        for record in self:
            record.doc_check_out_image_valid()
            record.do_check_in_image_valid()

    def _get_know_employee_images(self, use_check_in=False, limit=5):
        """
        Permet de récupérer les images de l'employé qui sont connues et qui sont valides
        """
        self.ensure_one()
        res = []
        profil = self.employee_image
        if profil:
            res.append(self._read_image('employee_image'))
        domain = [
            ('employee_id', '=', self.employee_id.id),
            ('state', '=', 'valid'),
        ]
        if use_check_in:
            images = self.search(domain, order='check_in desc', limit=limit).mapped(
                lambda x: self._read_image('check_in_image')
            )

        else:
            images = self.search(domain, order='check_out desc', limit=limit).mapped(
                lambda x: self._read_image('check_out_image')
            )
        res.extend(images)
        return res

    def _read_image(self, field):
        status, headers, image_base64 = request.env['ir.http'].binary_content(
            xmlid=None, model=self._name, id=self.id, field=field, unique=None, filename="employee.png",
            filename_field=None, default_mimetype='image/png')
        return image_base64, [v for k, v in headers if k == 'Content-Type'][0]

    def write(self, vals):
        res = super().write(vals)
        if 'check_in_image' in vals:
            self.do_check_in_image_valid()
        if 'check_out_image' in vals:
            self.doc_check_out_image_valid()
        return res

    @api.model
    def create(self, vals_list):
        res = super().create(vals_list)
        if res.check_in_image:
            self.do_check_in_image_valid()
        if res.check_out_image:
            self.doc_check_out_image_valid()
        return res
