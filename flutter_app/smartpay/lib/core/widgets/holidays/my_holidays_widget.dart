import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/auth/session.dart';
import 'package:smartpay/providers/current_employee_provider.dart';
import 'package:smartpay/providers/my_holidays_list_provider.dart';
import 'package:smartpay/providers/session_providers.dart';
import 'package:transparent_image/transparent_image.dart';

import 'my_holidays_widget_item.dart';

class MyHolidaysWidget extends ConsumerStatefulWidget {
  const MyHolidaysWidget({super.key});

  @override
  ConsumerState<MyHolidaysWidget> createState() => _MyHolidaysWidgetState();
}

class _MyHolidaysWidgetState extends ConsumerState<MyHolidaysWidget> {
  @override
  Widget build(BuildContext context) {
    Session session = ref.watch(sessionProvider);
    var employee = ref.watch(currentEmployeeProvider);
    String imgUrl = employee.getEmployeeImageUrl(session.url!);
    var holidays = ref.watch(myHolidaysProvider);
    return Container(
      padding: const EdgeInsets.all(10),
      child: (holidays.isEmpty)
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
                          image: (employee.image_128 != null)
                              ? Image.memory(base64Decode(employee.image_128))
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
                        employee.name,
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
                    itemCount: holidays.length,
                    itemBuilder: (context, index) => Dismissible(
                        key: ValueKey(index),
                        child: MyHolidaysWidgetItem(holiday: holidays[index])),
                  ),
                ),
              ],
            ),
    );
  }
}
