

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseListItem extends StatelessWidget {
  const ExpenseListItem({
    super.key,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.onTap,
  });

  final String title;
  final String amount;
  final String date;
  final String category;
  final Function() onTap;

  static fromMap(BuildContext context, Map<String, dynamic> expense,
      {Function()? onTap}) {
    var dateFormatter = DateFormat('yyyy-MM-dd');
    var date = dateFormatter.format(dateFormatter.parse(expense['date']));
    return ExpenseListItem(
      title: expense['name'],
      amount: expense['total_amount'].toString(),
      date: date,
      category: (expense['product_id'] is List)
          ? expense['product_id'][1]
          : "${expense['product_id']}",
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // cut the string to 20 characters
    var categoryDisplay =
        category.length > 20 ? '${category.substring(0, 20)}...' : category;
    var titleDisplay =
        title.length > 20 ? '${title.substring(0, 20)}...' : title;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
            bottom: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
        ),
        child: 
        ListTile(
          title: Text(titleDisplay, style: Theme.of(context).textTheme.bodyLarge),
          subtitle: Row(
            children: [
              Text("Le ", style: Theme.of(context).textTheme.bodySmall),
              Text(date, style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(width: 10),
              Text(categoryDisplay, style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
          trailing: Text(amount, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}
