import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/auth/session.dart';
import 'package:smartpay/api/models.dart';
import 'package:smartpay/providers/session_providers.dart';
import 'package:transparent_image/transparent_image.dart';

class EmployeeItem extends ConsumerWidget {
  final EmployeeAllInfo employee;

  const EmployeeItem({super.key, required this.employee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Session session = ref.watch(sessionProvider);
    String imgUrl = employee.getEmployeeImageUrl(session.url!);
    var smallText = Theme.of(context).textTheme.titleSmall!;
    return ListTile(
      leading: FadeInImage(
        // Montre une placeholder quand l'image n'est pas disponible
        placeholder: MemoryImage(
          // Convertit des bytes en images
          kTransparentImage, // Cree une image transparente en bytes
        ),
        image: (employee.image_128 != null)
            ? Image.memory(base64Decode(employee.image_128)).image
            : NetworkImage(
                // Recupere une image par sont url
                imgUrl),
        fit: BoxFit.contain,
        //height: 60,
        //width: 60,
      ),
      title: Text(
        employee.name!,
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dernier entré: ${employee.lastCheckIn}",
            style: smallText,
          ),
          if (employee.lastCheckOut != false)
            Text(
              "Dernier Sortie: ${employee.lastCheckOut}",
              style: smallText,
            )
        ],
      ),
      trailing: Text(employee.hoursToday!.toStringAsFixed(3)),
    );
  }
}
