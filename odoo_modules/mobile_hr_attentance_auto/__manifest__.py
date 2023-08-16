{
    'name': 'Attendance Automation',
    'version': '1.0',
    'category': 'Human Resources',
    'summary': 'Attendance Automation',
    'description': """
Automate attendance check in and check out process.
=====================

This module allows you to automate attendance check in and check out process.


""",

    'author': '@jp-sft',
    'depends': ['hr', 'hr_attendance', 'mail'],
    'data': [
        'data/config_data.xml',
        'data/cron.xml',
        'views/hr_employee_views.xml',
    ],
    'installable': True,
    'auto_install': False,
    'application': True,
}
