from odoo import api, fields, models, _
from odoo.exceptions import UserError
import logging

_logger = logging.getLogger(__name__)


class ResConfigSettings(models.TransientModel):
    """ Inherit res.config.settings to add attendance automation settings. """

    _inherit = "res.config.settings"

    face_verification_service_path = fields.Char(
        string="Face Verification Service Path",
        help="Face Verification Service Path",
        default="http://localhost:5000/verify",
        config_parameter="mobile_attendance_chek_image.face_verification_service_path"
    )
