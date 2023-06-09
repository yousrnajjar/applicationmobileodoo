

import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    // cut the string to 20 characters
    var categoryDisplay = category.length > 20 ? category.substring(0, 20) + '...' : category;
    var titleDisplay = title.length > 20 ? title.substring(0, 20) + '...' : title;
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
