from odoo import api, fields, models, _
from odoo.exceptions import UserError
from datetime import datetime, timedelta
import pytz
import logging

_logger = logging.getLogger(__name__)

def parse_float(f):
    hour = int(f)
    minute = int((f - hour) * 60)
    second = int(((f - hour) * 60 - minute) * 60)
    return "%02d:%02d:%02d" % (hour, minute, second)

class HrAttendance(models.Model):
    """ Inherit hr.attendance to add check_in_auto and check_out_notif process. """

    _inherit = "hr.attendance"

    def check_out_notif(self):
        """ Check Out Notification Process """
        # Get attendance automation settings
        config_settings = self.env["res.config.settings"].sudo().get_values()
        check_out_start_time = config_settings.get("check_out_start_time")
        check_out_start_time = parse_float(check_out_start_time)
        check_out_end_time = config_settings.get("check_out_end_time")
        check_out_end_time = parse_float(check_out_end_time)

        # Get employee with check_out_notif enabled
        employees = self.env["hr.employee"].sudo().search(
            [("check_out_notif", "=", True)]
        )
        # Get current datetime
        current_datetime = datetime.now()
        # Get current date
        current_date = current_datetime.date()
        # Get current time
        current_time = current_datetime.time()
        # Get current timezone
        current_timezone = self.env.user.tz or pytz.utc
        # Convert current datetime to current timezone
        current_datetime = pytz.utc.localize(current_datetime).astimezone(
            pytz.timezone(current_timezone)
        )
        # Convert check_out_start_time to current timezone
        check_out_start_time = datetime.strptime(
            check_out_start_time, "%H:%M:%S"
        ).time()
        check_out_start_time = pytz.utc.localize(
            datetime.combine(current_date, check_out_start_time)
        ).astimezone(pytz.timezone(current_timezone))
        # Convert check_out_end_time to current timezone
        check_out_end_time = datetime.strptime(
            check_out_end_time, "%H:%M:%S"
        ).time()
        check_out_end_time = pytz.utc.localize(
            datetime.combine(current_date, check_out_end_time)
        ).astimezone(pytz.timezone(current_timezone))
        # Check if current time is beetwen check_out_start_time and check_out_end_time
        if check_out_start_time < current_datetime < check_out_end_time:
            # Loop employees
            for employee in employees:
                # Check if employee has attendance for current date
                if employee.attendance_ids.filtered(
                        lambda r: r.check_in.date() == current_date
                ):
                    # Get employee attendance for current date
                    attendance = employee.attendance_ids.filtered(
                        lambda r: r.check_in.date() == current_date
                    )
                    # Check if employee attendance has no check_out
                    if not attendance.check_out:
                        # send check out notification
                        attendance._send_check_out_notif()

    def _send_check_out_notif(self):
        """ Send Check Out Notification """
        # Get attendance automation settings
        config_settings = self.env["res.config.settings"].sudo().get_values()
        notification_message = config_settings.get("app_check_out_notification_message")
        # Loop attendance
        for attendance in self:
            message_vals = {
                'body': notification_message,
                'model': self._name,
                'res_id': attendance.id,
                'message_type': 'notification',
                'subtype_id': self.env.ref('mail.mt_note').id,
                'author_id': self.env.ref('base.user_admin').partner_id.id,
                'date': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            }
            _ = self.env['mail.notification'].create([
                {
                    'res_partner_id': attendance.employee_id.user_id.partner_id.id,
                    'notification_type': 'for_mobile_app',
                    'notification_status': 'ready',
                    'mail_message_id': self.env['mail.message'].create(message_vals).id,
                }
            ])
            # Send notification
            # attendance.employee_id.user_id.notify_info(
                # notification_message, title="Check Out Notification"
            # )
