{
    'name': 'Attendance Automation',
    'version': '1.0',
    'category': 'Human Resources',
    'summary': 'Attendance Automation',
    'description': """
Automate attendance check in and check out process.
=====================

Odoo 13 Module to automate attendance marking for mobile users.
Scenario:
    1. Process "check_in_auto" time run at *check_in_start_time*
    2. Process "check_out_notif" time is beetwen *check_out_start_time* and *check_out_end_time*.

Configuration:
    1. Enable "Check In Auto" and "Check Out Notification" in Settings > General Settings > Attendance Automation.
    2. Configure check_in_start_time, check_out_start_time, check_out_end_time in Settings > General Settings > Attendance Automation.

Technical:
    1. Create cron job to run "check_in_auto" and "check_out_notif" process.

""",

    'author': '@jp-sft',
    'depends': ['hr', 'hr_attendance', 'mobile_notification','mail'],
    'data': [
        'data/config_data.xml',
        'data/cron.xml',
        'views/hr_employee_views.xml',
        'views/res_config_settings.xml',
    ],
    'installable': True,
    'auto_install': False,
    'application': True,
}
