import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/holydays/holydays_models.dart';

class MyHolydaysWidgetItem extends ConsumerWidget {
  final Holyday holyday;

  const MyHolydaysWidgetItem({super.key, required this.holyday});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var largeText = Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.bold,
        );
    var smallText = Theme.of(context).textTheme.titleSmall!.copyWith(
          fontWeight: FontWeight.normal,
          fontStyle: FontStyle.italic,
          fontSize: 10,
        );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              holyday.durationDisplay!,
              style: largeText,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(holyday.holidayStatusId[1]),
                Column(
                  children: [
                    Text(
                      "Du ${holyday.dateFrom}",
                      style: smallText,
                    ),
                    Text(
                      "Au ${holyday.dateTo}",
                      style: smallText,
                    ),
                  ],
                ),
                Text((holyday.name != false) ? holyday.name : ""),
                Text(holyday.state),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
