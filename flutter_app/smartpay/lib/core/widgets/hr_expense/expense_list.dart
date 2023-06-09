
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/models/user.dart';
import 'package:smartpay/ir/models/expense.dart';

import 'package:smartpay/core/widgets/hr_expense/expense_list_item.dart';


class ExpenseList extends StatefulWidget {
  final User user;

  const ExpenseList({super.key, required this.user});

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  List<Expense> _expenses = [];
  
  Future<List<Expense>> listenForExpenses() async {
    var result = await OdooModel('hr.expense').searchRead(
      domain: [
        ['employee_id', '=', widget.user.info['employee_id'][0]]
      ],
      fieldNames: Expense({}).allFields,
      limit: 1000,
    );
    return result.map((e) => Expense.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder(
          future: listenForExpenses(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var expenses = snapshot.data!.map((e) => e.info).toList();
              return ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  var dateFormatter = DateFormat('yyyy-MM-dd');
                  var date =  dateFormatter.format(dateFormatter.parse(expenses[index]['date']));
                  return ExpenseListItem(
                    title: expenses[index]['name'],
                    amount: expenses[index]['total_amount'].toString(),
                    date: date,
                    category: expenses[index]['product_id'][1],
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/expense_detail',
                        arguments: expenses[index],
                      );
                    },
                  );
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
            },
            child: const Icon(Icons.add),
            backgroundColor: kGreen,
          ),
        ),
      ],
    );
  }
}




