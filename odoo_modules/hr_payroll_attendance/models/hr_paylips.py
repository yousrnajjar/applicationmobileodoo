"""
@Description : Comptabilese le pointage des employés dans les bulletins de paie
               * Si le salarié en contrat par mois, le pointage n'est pas comptabilisé dans le bulletin de paie
               * Si le salarié en contrat par heure et sans heures supplémentaires,
                 le pointage est comptabilisé dans le bulletin de paie;
                 les heures supplémentaires ne sont pas comptabilisé
               * Si le salarié en contrat par heure et avec heures supplémentaires,
                 le pointage est comptabilisé dans le bulletin de paie;
                 les heures supplémentaires sont comptabilisé dans le bulletin de paie
@Version     : 1.0
@Odoo        : V13

@Author jp-sft
@Date 29/10/2023
@Time 03:57

"""
from odoo import models, fields, _
from odoo.exceptions import UserError
import logging

_logger = logging.getLogger(__name__)


class HrPayslip(models.Model):
    """
    Gestion des bulletins de paie
    """

    _inherit = "hr.payslip"

    attendance_ids = fields.One2many(
        "hr.attendance", "payslips_id", string="Pointages"
    )

    def get_worked_day_lines(self, contracts, date_from, date_to):
        """
        Calcul des jours travaillés
        """
        self.ensure_one()
        res = []

        for contract in contracts.filtered(lambda r: r.resource_calendar_id):
            contract_type = contract.contract_type
            if contract_type == "monthly":
                res += super(HrPayslip, self).get_worked_day_lines(
                    contract, date_from, date_to
                )
                continue
            line_template = {
                "name": None,
                "sequence": 5,
                "code": "POINTAGE",
                "number_of_days": 0.0,
                "number_of_hours": 0.0,
                "contract_id": contract.id,
            }
            attendances = self.env["hr.attendance"].search([
                ("employee_id", "=", self.employee_id.id),
                ("check_in", ">=", date_from),
                ("check_in", "<=", date_to),
            ]).sorted(key=lambda r: r.check_in)
            # L'heure de travail normale est pris dans le calendrier de l'employé
            dt_date_from = fields.Datetime.from_string(date_from)
            dt_date_to = fields.Datetime.from_string(date_to)
            work_duration_data = contract.resource_calendar_id.get_work_duration_data(
                dt_date_from, dt_date_to, compute_leaves=True
            )
            work_hours = work_duration_data["hours"]
            days = work_duration_data["days"]
            worked_hours_per_day = work_hours / days
            for attendance in attendances:
                self.write({"attendance_ids": [(4, attendance.id)]})
                worked_hours = attendance.worked_hours
                total_hours = min(worked_hours, worked_hours_per_day)
                line = line_template.copy()
                line_overtime = None
                line["name"] = attendance.check_in.strftime("%A %d %B %Y %H:%M:%S")
                line["number_of_hours"] = total_hours
                line["number_of_days"] = 1
                if contract_type == "hourly_without_overtime":
                    pass
                elif contract_type == "hourly_with_overtime":
                    line["number_of_days"] = 1
                    overtime = worked_hours - total_hours
                    if overtime > 0:
                        line_overtime = line.copy()
                        line_overtime["code"] = "POINTAGE_SUP"
                        line_overtime["number_of_hours"] = overtime
                        line_overtime["number_of_days"] = 0
                else:
                    raise UserError(
                        _("Le type de contrat n'est pas pris en charge")
                    )
                res.append(line)
                if line_overtime is not None:
                    res.append(line_overtime)
        return res
