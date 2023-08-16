from odoo import api, fields, models, _
from odoo.exceptions import UserError
import logging

_logger = logging.getLogger(__name__)


class ResConfigSettings(models.TransientModel):
    """ Inherit res.config.settings to add attendance automation settings. """

    _inherit = "res.config.settings"

    check_in_start_time = fields.Char(
        string="Check In Start Time",
        help="Time to run check_in_auto process.",
        default="08:00:00",
    )
    check_out_start_time = fields.Char(
        string="Check Out Start Time",
        help="Time to run check_out_notif process.",
        default="16:00:00",
    )
    check_out_end_time = fields.Char(
        string="Check Out End Time",
        help="Time to run check_out_notif process.",
        default="18:00:00",
    )
    app_check_out_forget_notification_message = fields.Char(
        string="Check Out Forget Notification Message",
        help="Notification message for check out forget.",
        default="Please check out your attendance.",
    )
    app_check_in_auto_notification_message = fields.Char(
        string="Check In Auto Notification Message",
        help="Notification message for check in auto.",
        default="Welcome to work.",
    )

    @api.model
    def get_values(self):
        """ Override to add attendance automation settings. """
        res = super(ResConfigSettings, self).get_values()
        config_settings = self.env["res.config.settings"].sudo().search(
            [], limit=1, order="id desc"
        )
        res.update(
            {
                "check_in_start_time": config_settings.check_in_start_time,
                "check_out_start_time": config_settings.check_out_start_time,
                "check_out_end_time": config_settings.check_out_end_time,
                "app_check_out_forget_notification_message": config_settings.app_check_out_forget_notification_message,
                "app_check_in_auto_notification_message": config_settings.app_check_in_auto_notification_message,
            }
        )
        return res

    def set_values(self):
        """ Override to add attendance automation settings. """
        super(ResConfigSettings, self).set_values()
        config_settings = self.env["res.config.settings"].sudo().search(
            [], limit=1, order="id desc"
        )
        config_settings.write(
            {
                "check_in_start_time": self.check_in_start_time,
                "check_out_start_time": self.check_out_start_time,
                "check_out_end_time": self.check_out_end_time,
                "app_check_out_forget_notification_message": self.app_check_out_forget_notification_message,
                "app_check_in_auto_notification_message": self.app_check_in_auto_notification_message,
            }
        )
