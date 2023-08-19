from datetime import datetime

import pytz
from odoo import api, fields, models, _
import logging

from odoo.exceptions import ValidationError

_logger = logging.getLogger(__name__)


class HrEmployee(models.Model):
    """ Inherit hr.employee to add check_in_auto process. """

    _inherit = "hr.employee"

    check_in_auto = fields.Boolean(string="Check In Auto", default=True)
    check_out_notif = fields.Boolean(string="Check Out Notif", default=True)

    @api.model
    def do_check_in_auto(self):
        """ Check In Auto Process """
        # Get attendance automation settings
        config_settings = self.env["res.config.settings"].sudo().get_values()
        check_in_start_time = config_settings.get("check_in_start_time") # type: float, 4.435
        hour = int(check_in_start_time)
        minute = int((check_in_start_time - hour) * 60)
        second = int(((check_in_start_time - hour) * 60 - minute) * 60)
        check_in_start_time = "%02d:%02d:%02d" % (hour, minute, second)
        # Get employee with check_in_auto enabled
        employees = self.env["hr.employee"].sudo().search(
            [("check_in_auto", "=", True)]
        )
        notification_message = config_settings.get("app_check_out_notification_message")
        # Get current datetime
        current_datetime = fields.Datetime.now()
        # Get current date
        current_date = fields.Date.today()
        # Get current time
        current_time = current_datetime.strftime("%H:%M:%S")
        # Loop for each employee
        for employee in employees:

            # Get employee's timezone
            employee_tz = pytz.timezone(employee.tz or 'UTC')
            # Convert current datetime to employee's timezone
            current_datetime_tz = pytz.utc.localize(current_datetime).astimezone(
                employee_tz
            )
            # Get current time in employee's timezone
            current_time_tz = current_datetime_tz.strftime("%H:%M:%S")
            # Check if current time is greater than check_in_start_time
            if current_time_tz >= check_in_start_time:
                # Check if employee has no attendance today
                hr_attendance = "hr.attendance"
                attendance = self.env[hr_attendance].sudo().search(
                    [
                        ("employee_id", "=", employee.id),
                        ("check_in", ">=", current_date),
                        ("check_out", "=", False),
                    ]
                )
                if not attendance:
                    # Create attendance
                    try:
                        attendance = self.env[hr_attendance].sudo().create(
                            {"employee_id": employee.id, "check_in": current_datetime}
                        )
                    except ValidationError as e:
                        last_attendance = self.env[hr_attendance].sudo().search(
                            [("employee_id", "=", employee.id)],
                            order="check_in desc",
                            limit=1,
                        )
                        try:
                            last_attendance.sudo().write(
                                {"check_out": current_datetime}
                            )
                            attendance = self.env[hr_attendance].sudo().create(
                                {"employee_id": employee.id, "check_in": current_datetime}
                            )
                        except ValidationError as e:
                            _logger.error(e.name)
                            continue

                    # Send notification
                    message_vals = {
                        'body': notification_message,
                        'model': hr_attendance,
                        'res_id': attendance.id,
                        'message_type': 'notification',
                        'subtype_id': self.env.ref('mail.mt_note').id,
                        'author_id': self.env.ref('base.user_admin').partner_id.id,
                        'date': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                    }
                    _ = self.env['mail.notification'].create([
                        {
                            'res_partner_id': employee.user_id.partner_id.id,
                            'notification_type': 'for_mobile_app',
                            'notification_status': 'ready',
                            'mail_message_id': self.env['mail.message'].create(message_vals).id,
                        }
                    ])
