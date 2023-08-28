# -*- coding: utf-8 -*-

from odoo import models, fields


class HrAttendance(models.Model):
    """
    Permet d'ajouter :
        * une image lors d'un pointage
        * La position GPS du pointage
    """
    _inherit = 'hr.attendance'

    # Image
    image = fields.Binary(string='Image')
    # GPS
    geo_latitude = fields.Float(string='Latitude', digits=(16, 5))
    geo_longitude = fields.Float(string='Longitude', digits=(16, 5))
    geo_altitude = fields.Float(string='Altitude', digits=(16, 5))
    geo_accuracy = fields.Float(string='Accuracy', digits=(16, 5))
    geo_time = fields.Datetime(string='Time')

