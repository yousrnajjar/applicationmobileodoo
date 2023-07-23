from datetime import datetime, timedelta
from odoo.tests.common import TransactionCase
from odoo.exceptions import UserError, ValidationError
import logging
_logger = logging.getLogger(__name__)


class TestNotification(TransactionCase):
    def setUp(self):
        super(TestNotification, self).setUp()
        self.user_employee = self.env.ref('base.user_demo')
        self.user_manager = self.env.ref('base.user_admin')
        self.employee = self.env['hr.employee'].with_user(self.user_employee).search([('user_id', '=', self.user_employee.id)], limit=1)

    def test_notification_for_leave_request(self):
        """
            Sénario: Un employe crée une demande de congé et reçoi des notification lors du changement d'état
        """
        # 1. L'employé crée une demande de congé
        leave = self.env['hr.leave'].with_user(self.user_employee).create({
            'name': 'Congé de test',
            'holiday_status_id': self.env.ref('hr_holidays.holiday_status_cl').id,
            'employee_id': self.employee.id,
            'date_from': datetime.now().strftime('%Y-%m-%d'),
            'date_to': (datetime.now() + timedelta(days=1)).strftime('%Y-%m-%d'),
            'number_of_days': 2,
            'request_date_from': datetime.now().strftime('%Y-%m-%d'),
            'request_date_to': (datetime.now() + timedelta(days=1)).strftime('%Y-%m-%d'),
            'request_hour_from': '8',
            'request_hour_to': '17'
        })
        domain = [
            ('notification_type', '=', 'for_mobile_app'),
            ('notification_status', '=', 'ready'),
            ('res_partner_id', '=', self.user_employee.partner_id.id)
        ]
        # 2. L'employé reçoi une notification de confirmation de la demande
        notifications = self.env['mail.notification'].with_user(self.user_employee).search(domain, order='id desc', limit=1)
        current_notification = notifications.filtered(lambda n: n.mail_message_id.res_id == leave.id)
        self.assertEqual(len(current_notification), 1, 'L\'employé doit reçevoir une notification de confirmation de la demande')
        self.assertEqual(current_notification.notification_status, 'ready', 'La notification doit être prête à être envoyée')
        # 3. Le responsable valide la demande
        leave.with_user(self.user_manager).action_validate()
        # 4. L'employé reçoi une notification de validation de la demande
        notifications = self.env['mail.notification'].with_user(self.user_employee).search(domain, order='id desc', limit=1)
        current_notification = notifications.filtered(lambda n: n.mail_message_id.res_id == leave.id)
        self.assertEqual(current_notification.notification_type, 'for_mobile_app', 'La notification doit être de type mobile')
        message = current_notification.mail_message_id
        self.assertEqual(message.body, f'Votre demande de congé {leave.name} a été validée par le manager', 'Le message de la notification doit être correct')
        self.assertEqual(current_notification.notification_status, 'ready', 'La notification doit être prête à être envoyée')


        # 5. Le responsable refuse la demande
        # 6. L'employé reçoi une notification de refus de la demande
        # 7. Le responsable annule la demande
        # 8. L'employé reçoi une notification d'annulation de la demande


