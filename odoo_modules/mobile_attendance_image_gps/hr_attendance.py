# -*- coding: utf-8 -*-

from odoo import models, fields


class HrAttendance(models.Model):
    """
    Permet d'ajouter :
        * une image lors d'un pointage
        * La position GPS du pointage
    """
    _inherit = 'hr.attendance'

    # Check In
    check_in_image = fields.Binary(string='Image de pointage d\'entrée')
    check_in_geo_latitude = fields.Float(string='Latitude (Entrée)', digits=(16, 5))
    check_in_geo_longitude = fields.Float(string='Longitude (Entrée)', digits=(16, 5))
    check_in_geo_altitude = fields.Float(string='Altitude (Entrée)', digits=(16, 5))
    check_in_geo_accuracy = fields.Float(string='Accuracy (Entrée)', digits=(16, 5))
    check_in_geo_time = fields.Datetime(string='Time (Entrée)')

    # Check Out
    check_out_image = fields.Binary(string='Image de pointage de sortie')
    check_out_geo_latitude = fields.Float(string='Latitude (Sortie)', digits=(16, 5))
    check_out_geo_longitude = fields.Float(string='Longitude (Sortie)', digits=(16, 5))
    check_out_geo_altitude = fields.Float(string='Altitude (Sortie)', digits=(16, 5))
    check_out_geo_accuracy = fields.Float(string='Accuracy (Sortie)', digits=(16, 5))
    check_out_geo_time = fields.Datetime(string='Time (Sortie)')



