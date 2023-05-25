import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/models/holidays_models.dart';

class MyHolidaysWidgetItem extends ConsumerWidget {
  final Holiday holiday;

  const MyHolidaysWidgetItem({super.key, required this.holiday});

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
              holiday.durationDisplay!,
              style: largeText,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(holiday.holidayStatusId[1]),
                Column(
                  children: [
                    Text(
                      "Du ${holiday.dateFrom}",
                      style: smallText,
                    ),
                    Text(
                      "Au ${holiday.dateTo}",
                      style: smallText,
                    ),
                  ],
                ),
                Text((holiday.name != false) ? holiday.name : ""),
                Text(holiday.state),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
