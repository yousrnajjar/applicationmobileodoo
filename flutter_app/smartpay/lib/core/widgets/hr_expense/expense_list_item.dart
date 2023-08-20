import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartpay/ir/data/themes.dart';

class ExpenseListItem extends StatelessWidget {
  final bool textWrap;

  const ExpenseListItem({
    super.key,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.onTap,
    required this.subTitle,
    required this.textWrap,
  });

  final String title;
  final String subTitle;
  final String amount;
  final String date;
  final String category;
  final Function() onTap;

  static fromMap(BuildContext context, Map<String, dynamic> expense,
      {Function()? onTap, bool textWrap = false}) {
    var dateFormatter = DateFormat('yyyy-MM-dd');
    var date = dateFormatter.format(dateFormatter.parse(expense['date']));
    return ExpenseListItem(
      textWrap: textWrap,
      title: [null, '', false].contains(expense['description'])
          ? expense['name']
          : expense['description'],
      subTitle: expense['name'],
      amount: '${expense['total_amount']} ${expense['currency_id']}',
      date: date,
      category: (expense['product_id'] is List)
          ? expense['product_id'][1]
          : "${expense['product_id'] == false ? '' : expense['product_id']}",
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
    var textSmall = Theme.of(context).textTheme.bodySmall!.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
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
        child: ListTile(
          leading: textWrap
              ? null
              : const CircleAvatar(
                  backgroundColor: kGreen,
                  foregroundColor: Colors.white,
                  child: Icon(Icons.local_drink),
                ),
          title: Text(
            titleDisplay,
            overflow: textWrap ? TextOverflow.ellipsis : TextOverflow.clip,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Nom: ", style: textSmall),
                  Flexible(
                    child: Text(
                      subTitle,
                      overflow:
                          textWrap ? TextOverflow.ellipsis : TextOverflow.clip,
                      style: textSmall,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text("Date: ", style: textSmall),
                  Text(
                    date,
                    style: textSmall,
                  ),
                ],
              )
            ],
          ),
          trailing: Text(amount, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}
