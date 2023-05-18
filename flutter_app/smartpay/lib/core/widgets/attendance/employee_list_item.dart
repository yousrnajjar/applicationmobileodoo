import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/auth/session.dart';
import 'package:smartpay/api/models.dart';
import 'package:smartpay/core/data/themes.dart';
import 'package:smartpay/providers/session_providers.dart';

class EmployeeItem extends ConsumerWidget {
  final EmployeeAllInfo employee;

  const EmployeeItem({super.key, required this.employee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Session session = ref.watch(sessionProvider);
    ThemeData theme = Theme.of(context);
    var smallText = theme.textTheme.titleSmall;
    var titleLarge = titleLargeBold(theme); 
    return ListTile(
      leading: employee.imageFrom(session.url!),
      title: Text(
        employee.name!,
        style: titleLarge,
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
