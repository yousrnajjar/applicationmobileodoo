/// Ce module permet d'afficher les notifications de l'application [NotificationScreen].
///
/// Les notifications sont affichées dans un [ListView] et sont récupérées
/// depuis la base de données odoo grace à la fonction [getNotifications]
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/user.dart'; // OdooModel

import 'main_drawer.dart';

Future<List<Map<String, dynamic>>> getNotifications(int resPartnerId) async {
  OdooModel model = OdooModel('mail.notification');
  List<Map<String, dynamic>> result = await model.searchRead(
    domain: [
      ['res_partner_id', '=', resPartnerId], //TODO: By partner
      ["notification_type", "=", "for_mobile_app"],
      ["is_read", "=", false],
    ],
    fieldNames: [
      'id',
      'display_name',
      'notification_type',
      'notification_status',
      'is_read',
      'res_partner_id',
      'mail_message_id',
      'sms_id',
      'sms_number',
      'mail_id',
      'failure_type',
      'read_date',
      '__last_update',
    ],
  );
  List<Map<String, dynamic>> res = [];
  for (var element in result) {
    var res2 = await OdooModel('mail.message').searchRead(
      domain: [
        ['id', '=', element['mail_message_id'][0]],
      ],
      fieldNames: [
        'body',
        'res_id',
        'model',
        'message_type',
        'subtype_id',
        'author_id',
        'date',
      ],
    );
    if (res2.isNotEmpty) {
      // remove tag from body
      String body = res2[0]['body'];
      body = body.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ');
      res2[0]['body'] = body;
      element['mail_message'] = res2[0];
      res.add(element);
    }
  }
  return res;
}

// count
Future<int> getNotificationsCount(int resPartnerId) async {
  return await OdooModel.session.callKw({
    'model': 'mail.notification',
    'method': 'search_count',
    'args': [
      [
        ['res_partner_id', '=', resPartnerId],
        ["notification_type", "=", "for_mobile_app"],
        ["is_read", "=", false],
      ]
    ],
    'kwargs': {
      'context': OdooModel.session.defaultContext,
    },
  });
}

Future<dynamic> markAsRead(int id) async {
  return OdooModel.session.write('mail.notification', [id], {'is_read': true});
}

class NotificationScreen extends StatefulWidget {

  final User user;

  const NotificationScreen({super.key, required this.user});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final Map<String, String> modelImages = {
    'hr.leave': 'assets/icons/holiday.jpeg'
  };

  void onNotificationTap(String model, int resId) {
    String page = 'dashboard';
    Map<String, dynamic> dataKwargs = {
      'model': model,
      'res_id': resId,
    };
    Navigator.of(context).pop();
    if (model == 'hr.employee') {
      page = 'employee';
    } else if (model == 'hr.leave') {
      page = "leave";
    } else if (model == 'hr.attendance') {
      page = "attendance";
    } else if (model == 'hr.expense') {
      page = "expense";
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MainDrawer(
        user: widget.user,
        activePageName: page,
        dataKwargs: dataKwargs,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: FutureBuilder(
        future: getNotifications(widget.user.partnerId),
        builder: (context, snapshot) {
          if (kDebugMode) {
            print(snapshot);
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur de connexion ${snapshot.error}'),
            );
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data == null) {
            return const Center(
              child: Text('Pas de notifications'),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> notification = snapshot.data![index];
                if (notification['mail_message'] == null) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                      Image
                          .asset('assets/icons/notif.jpeg')
                          .image,
                    ),
                    title: const Text('Notification'),
                    subtitle: const Text('Notification'),
                  );
                }
                Map<String, dynamic> message = notification['mail_message'];
                String model = message['model'];
                String image;
                if (modelImages.containsKey(model)) {
                  image = modelImages[model]!;
                } else {
                  image = 'assets/icons/notif.jpeg';
                }
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(image),
                  ),
                  title: Text(message['body']),
                  subtitle: Text(message['date']),
                  // button to mark as read
                  trailing: IconButton(
                    icon: const Icon(Icons.mark_email_read),
                    onPressed: () async {
                      await markAsRead(notification['id']);
                      setState(() {
                        notification['is_read'] = true;
                      });
                    },
                  ),
                  onTap: () {
                    onNotificationTap(model, message['res_id']);
                  },
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
