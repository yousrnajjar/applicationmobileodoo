from datetime import datetime
from odoo import models, fields, api, _
from odoo.exceptions import UserError, ValidationError
import logging
_logger = logging.getLogger(__name__)

class MobileNotificationMixins(models.AbstractModel):
    _name = 'mobile.notification.mixins'
    _description = 'Mobile Notification Mixins'

    _rec_names_attr = ['name', 'display_name']
    _status_field = 'state'
    _start_status = None
    _notif_message_by_status = {}
    _allowed_notif_status = None

    def _check_mixin(self):
        """
        Check if the mixin is correctly configured
        :return:
        """
        if self._name == 'mobile.notification.mixins':
            return
        if not self._start_status:
            raise ValidationError(_('Start status is not defined for %s' % self._name))
        if not self._notif_message_by_status:
            raise ValidationError(_('Notification message by status is not defined for %s' % self._name))
        if not self._allowed_notif_status:
            raise ValidationError(_('Allowed notification status is not defined for %s' % self._name))

    def __init__(self, pool, cr):
        """
        Init the mixin
        :param pool:
        :param cr:
        """
        super(MobileNotificationMixins, self).__init__(pool, cr)
        self._check_mixin()


    def _create_notif(self, msg, model, res_id, user):
        """
        Create a notification for a partner
        :param msg: message to display
        :param model: model name
        :param res_id: record id
        :param partner_id: partner id
        :return:
        """
        message_vals = {
            'body': msg,
            'model': model,
            'res_id': res_id,
            'message_type': 'notification',
            'subtype_id': self.env.ref('mail.mt_note').id,
            'author_id': self.env.ref('base.user_admin').partner_id.id,
            'date': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        }
        _ = self.env['mail.notification'].create([
            {
                'res_partner_id': user.partner_id.id,
                'notification_type': 'for_mobile_app',
                'notification_status': 'ready',
                'mail_message_id': self.env['mail.message'].create(message_vals).id
            }
        ])

    def _get_readable_name(self):
        res = []
        for rec in self:
            for attr in self._rec_names_attr:
                if hasattr(rec, attr) and getattr(rec, attr):
                    res.append(getattr(rec, attr))
                    break
            else:
                res.append(rec._name + ' ' + str(rec.id))
        return ', '.join(res)

    @api.model
    def create(self, vals):
        res = super(MobileNotificationMixins, self).create(vals)
        # Création de la notification de confirmation de la demande
        msg = self._notif_message_by_status.get(self._start_status, '').format(res._get_readable_name())
        self._create_notif(msg, res._name, res.id, self.env.user)
        return res

    def write(self, vals):
        """
        Vérifier si le status a changé et créer la notification
        """
        old_rec_states = self.mapped(self._status_field)
        res = super(MobileNotificationMixins, self).write(vals)
        if isinstance(vals, dict) and self._status_field not in vals:
            return res
        elif isinstance(vals, list) and self._status_field not in vals[0]:
            return res
        for old_rec_state, rec in zip(old_rec_states, self):
            new_rec_state = getattr(rec, self._status_field)
            if new_rec_state not in self._allowed_notif_status:
                continue
            # check if status has changed
            if old_rec_state != new_rec_state:
                msg = self._notif_message_by_status.get(vals[self._status_field], '').format(rec._get_readable_name())
                self._create_notif(msg, rec._name, rec.id, self.env.user)
            else:
                _logger.warning('Vous devez définir le champ _status_field dans le modèle %s' % rec._name)
        return res


