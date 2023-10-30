
{
    'name': 'Pointage dans la paie',
    'summary': 'Pointage dans la paie',
    'description': """
Pointage dans la paie
=====================

Ce module permet de prendre en compte le pointage dans le calcul de la paie.

* Il ajoute un type de contrat "Horaire avec heures supplémentaires" et "Horaire sans heures supplémentaires".

* Il ajoute un champ "Bulletin de paie" dans les pointages.

* Il ajoute un champ "Pointage" et "Pointage supplémentaire" dans les jours travaillés.

* Il ajoute un champ "Pointages" dans les bulletins de paie.

Ainsi, le montant du contrat est calculé en fonction du type de contrat et du pointage.

Exemple d'utilisation dans le code de calcul du montant de contrat:

```python

plus = 0

if contract.contract_type == 'hourly_with_overtime':

   plus = worked_days.POINTAGE.number_of_hours + worked_days.POINTAGE_SUP.number_of_hours

elif contract.contract_type == 'hourly_without_overtime':

   plus = worked_days.POINTAGE.number_of_hours

elif contract.contract_type == 'monthly':

   plus = 1

result = contract.wage * plus

```
""",
    'version': '1.0',
    'author': '@jp-sft',
    'category': 'Tools',
    'depends': ['base', 'hr', 'hr_attendance', 'om_hr_payroll', 'resource'],
    'data': [
        "views/hr_payslips.xml",
        # "views/hr_attendance.xml",
        "views/hr_contract.xml",
    ],
    'installable': True,
    'url': '',
}
