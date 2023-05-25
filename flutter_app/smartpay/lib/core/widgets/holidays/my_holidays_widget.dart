import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/attendance_models.dart';
import 'package:smartpay/ir/models/holidays_models.dart';
import 'package:smartpay/ir/models/user_info.dart';
import 'package:transparent_image/transparent_image.dart';

import 'my_holidays_widget_item.dart';

class HolidaysWidget extends StatefulWidget {
  final List<Holiday> list;
  final User user;
  const HolidaysWidget(this.user, {super.key, required this.list});
  @override
  State<HolidaysWidget> createState() => _MyHolidaysWidgetState();
}

class _MyHolidaysWidgetState extends State<HolidaysWidget> {
  EmployeeAllInfo? _employee;

  _loadEmployee() async {
    var data = await OdooModel("hr.employee").searchRead(
      domain: [
        ['user_id', '=', widget.user.uid]
      ],
      fieldNames: ['id', 'name']
    );
    if (data.isNotEmpty) {
      setState(() {
        _employee = EmployeeAllInfo.fromJson(data[0]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.user.isAdmin) {
      _loadEmployee();
    }
    String imgUrl = widget.user.getImageUrl(OdooModel.session.url!);
    return Container(
      padding: const EdgeInsets.all(10),
      child: (widget.list.isEmpty)
          ? const Center(
              child: Text("Vous n'apez aucune demande de congé!"),
            )
          : Column(
              children: [
                Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FadeInImage(
                          // Montre une placeholder quand l'image n'est pas disponible
                          placeholder: MemoryImage(
                            // Convertit des bytes en images
                            kTransparentImage, // Cree une image transparente en bytes
                          ),
                          image: (_employee != null &&
                                  _employee!.image_128 != null)
                              ? Image.memory(base64Decode(_employee!.image_128))
                                  .image
                              : NetworkImage(
                                  // Recupere une image par sont url
                                  imgUrl),
                          fit: BoxFit.contain,
                          //height: 60,
                          //width: 60,
                        ),
                      ),
                      Text(
                        widget.user.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.list.length,
                    itemBuilder: (context, index) => Dismissible(
                        key: ValueKey(index),
                        child:
                            MyHolidaysWidgetItem(holiday: widget.list[index])),
                  ),
                ),
              ],
            ),
    );
  }
}
