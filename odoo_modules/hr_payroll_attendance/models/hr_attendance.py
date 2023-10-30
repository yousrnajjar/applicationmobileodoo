"""
@Description: 

@Author jp-sft
@Date 30/10/2023
@Time 02:20

"""
from odoo import models, fields, api, _
from odoo.exceptions import UserError


class HrAttendance(models.Model):
    """
    Utilisation du module hr_attendance pour la gestion des pointages
    """

    _inherit = "hr.attendance"

    payslips_id = fields.Many2one("hr.payslip", string="Bulletin de paie")

    @api.model
    def create(self, vals):
        """
        Création des pointages
        """
        res = super(HrAttendance, self).create(vals)
        res._compute_payslips_id()
        return res

    def write(self, vals):
        """
        Modification des pointages
        """
        res = super(HrAttendance, self).write(vals)
        self._compute_payslips_id()
        return res

    def unlink(self):
        """
        Suppression des pointages
        """
        if self.payslips_id:
            raise UserError(
                _("Impossible de supprimer un pointage lié à un bulletin de paie")
            )
        return super(HrAttendance, self).unlink()

    def _compute_payslips_id(self):
        """
        Calcul du bulletin de paie
        """
        for attendance in self:
            if attendance.payslips_id:
                continue
            payslip = self.env["hr.payslip"].search(
                [
                    ("employee_id", "=", attendance.employee_id.id),
                    ("date_from", "<=", attendance.check_in),
                    ("date_to", ">=", attendance.check_out),
                    ("state", "=", "draft"),
                ],
                limit=1,
            )
            if payslip:
                attendance.payslips_id = payslip.id
        return True
