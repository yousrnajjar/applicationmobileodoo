from odoo import models, fields, api, _
from odoo.exceptions import UserError, ValidationError
import logging
_logger = logging.getLogger(__name__)

class MailNotification(models.Model):
    _inherit = 'mail.notification'

    notification_type = fields.Selection(selection_add=[('for_mobile_app', 'For Mobile App')])


