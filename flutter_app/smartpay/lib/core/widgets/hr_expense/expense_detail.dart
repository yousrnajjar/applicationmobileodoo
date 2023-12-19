import 'package:flutter/material.dart';


String parseMany2One(dynamic many2one) {
  if (many2one is List && many2one.length == 2) {
    return many2one[1].toString();
  } else if (many2one is List && many2one.length == 1) {
    return many2one[0].toString();
  } else if (many2one is String) {
    return many2one;
  } else {
    return '';
  }
}

String parse(dynamic value) {
  if (value is List) {
    return value[1].toString();
  } else if (value is String) {
    return value;
  } else {
    return '';
  }
}
/// ExpenseDetail is a widget that displays the details of an expense.
/// Arguments:
///   - expense: the expense to display
///   - onEdit: a callback function to call when the user taps the edit button
///   - onDelete: a callback function to call when the user taps the delete button
///   - onAttachment: a callback function to call when the user taps the attachment button
///
class ExpenseDetail extends StatelessWidget {
  const ExpenseDetail({
    super.key,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
    required this.onAttachment,
  });

  final Map<String, dynamic> expense;
  final Function(BuildContext, Map<String, dynamic>) onEdit;
  final Function(BuildContext, Map<String, dynamic>) onDelete;
  final Function(BuildContext, Map<String, dynamic>) onAttachment;

  @override
  Widget build(BuildContext context) {
    var textSmall = Theme.of(context).textTheme.bodySmall!.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  parse(expense['name']),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              //IconButton(
                //icon: const Icon(Icons.edit),
                //onPressed: () => onEdit(context, expense),
              //),
              //IconButton(
                //icon: const Icon(Icons.delete),
                //onPressed: () => onDelete(context, expense),
              //),
              // number of attachments
              Row(
                children: [
                  const Icon(Icons.attachment),
                  Text(
                    expense['attachment_number'].toString(),
                    style: textSmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  // expense['product_id'][1], ==> can be false
                  parseMany2One(expense['product_id']),
                  style: textSmall,
                ),
              ),
              Text(
                '${expense['total_amount']} ${expense['currency_id'][1]}',
                style: textSmall,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  parse(expense['date']),
                  style: textSmall,
                ),
              ),
              Text(
                parse(expense['state']),
                style: textSmall,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  parseMany2One(expense['category_id']),
                  style: textSmall,
                ),
              ),
              Text(
                parseMany2One(expense['partner_id']),
                style: textSmall,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  parse(expense['description']),
                  style: textSmall,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.attachment),
                onPressed: () => onAttachment(context, expense),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
