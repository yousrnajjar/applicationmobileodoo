{
    'name': 'Module de notification pour les taches',
    'version': '1.0',
    'category': 'Tools',
    'summary': 'Module de notification pour les taches',
    'description': """
Module de notification pour les taches
======================================
Ce module permet d'enregistrer les notifications quand certaines actions ou changements d'etat se produisent.
- notif lors d un changement d etat du congé de la part du responsable
- notif lors d existance du fiche de paie à consulter
- notif lors de reception des messages
Ce module est developpé par @jp-sft pour permettre l'integration des notifications dans l'app mobile @SmartPay où les utilisateurs peuvent consulter les notifications.
""",
    'author': '@jp-sft',
    'depends': ['base', 'hr', 'hr_holidays', 'mail', 'om_hr_payroll', 'hr_attendance'],
    'data': [
    ],
    'installable': True,
    'application': True,
    'auto_install': False,
}
