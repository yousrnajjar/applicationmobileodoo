"""
@Description: 

@Author jp-sft
@Date 30/10/2023
@Time 02:20

"""
from odoo import models, fields

_CONTRACT_TYPE = [
    ("hourly_without_overtime", "Heures sans heures supplémentaires"),
    ("hourly_with_overtime", "Heures avec heures supplémentaires"),
    ("monthly", "Mensuel"),
]


class HrContract(models.Model):
    """
    Gestion des contrats
    """
    _inherit = "hr.contract"

    contract_type = fields.Selection(
        selection=_CONTRACT_TYPE, string="Type de contrat", required=True,
        default="monthly"
    )
