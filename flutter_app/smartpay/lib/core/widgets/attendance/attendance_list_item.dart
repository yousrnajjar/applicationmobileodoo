import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/attendance.dart';
import 'package:smartpay/api/auth/session.dart';
import 'package:smartpay/providers/session_providers.dart';
import 'package:transparent_image/transparent_image.dart';

class AttendanceItem extends ConsumerWidget {
  final Attendance attendance;

  const AttendanceItem({super.key, required this.attendance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Session session = ref.watch(sessionProvider);
    String imgUrl = attendance.getEmployeeImageUrl(session.url!);
    var smallText = Theme.of(context).textTheme.titleSmall!.copyWith(
          fontSize: 10,
        );
    return ListTile(
      leading: FadeInImage(
        // Montre une placeholder quand l'image n'est pas disponible
        placeholder: MemoryImage(
          // Convertit des bytes en images
          kTransparentImage, // Cree une image transparente en bytes
        ),
        image: NetworkImage(
            // Recupere une image par sont url
            imgUrl),
        fit: BoxFit.contain,
        //height: 60,
        //width: 60,
      ),
      title: Text(
        attendance.employeeId![1],
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
            "De ${attendance.checkIn}",
            style: smallText,
          ),
          if (attendance.checkOut != false)
            Text(
              "À ${attendance.checkOut}",
              style: smallText,
            )
        ],
      ),
      trailing: Text(attendance.workedHours!.toStringAsFixed(3)),
    );
  }
}
