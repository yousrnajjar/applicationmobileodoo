
import 'package:flutter/material.dart';

import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/user.dart';
import 'package:smartpay/core/widgets/hr_expense/expense_list.dart';


class ExpenseScreen extends StatefulWidget {
  final User user;
  // onTitleChanged is a callback function to change the title of the page
  final Function(String) onTitleChanged;

  const ExpenseScreen({super.key, required this.user, required this.onTitleChanged});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  // The current page
  int _selectedIndex = 0;

  // List of pages
  final List<Widget> _pages = [];
  final List<String> _pageTitle = [
    'Liste de notes',
    'Ajout d\'une note de frais',
  ];

  @override
  void initState() {
    super.initState();
    // Add the holiday list page
    _pages.add(ExpenseList(user: widget.user));
    // Add the holiday form page
    _pages.add(const Center(child: CircularProgressIndicator()));
  }

  @override
  Widget build(BuildContext context) {
    var appBarForeground = Theme.of(context).appBarTheme.foregroundColor;
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 30, left: 15, right: 15),
        child: _pages[_selectedIndex]
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          widget.onTitleChanged(_pageTitle[index]);
          if ([1].contains(index)) {
            _buildForm(index);
          }
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon:
                Image.asset("assets/icons/expense_list.png"),
            label: _pageTitle[0],
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/expense_add.png"),
            label: _pageTitle[1],
          ),
        ],
      ),
    );
  }

  _buildForm(int index) async {
    Widget? content;
    if (index == 1) {
      content = await buildExpenseForm();
    }
    if (content != null) {
      setState(() {
        _pages[index] = content!;
      });
    }
  }
// Vim : replace Expense by Expense command :%s/Expense/Expense/g
  Future<Widget> buildExpenseForm() async {
    /*return await OdooModel("hr.expense").buildFormFields(
      fieldNames: Expense.defaultFields,
      onChangeSpec: Expense.onchangeSpec,
      formTitle: "Demande de congé",
      displayFieldNames: Expense.displayFieldNames,
    );*/
    /*var fieldNames = Expense.defaultFields;
    var displayFieldNames = Expense.displayFieldNames;
    var onChangeSpec = Expense.onchangeSpec;
    var formTitle = "Demande de congé";
    var model = OdooModel("hr.expense");

    Map<OdooField, dynamic> initial =
        await model.defaultGet(fieldNames, onChangeSpec);
    Map<OdooField,
            Future<Map<OdooField, dynamic>> Function(Map<OdooField, dynamic>)>
        onFieldChanges = {};
    for (OdooField field in initial.keys) {
      onFieldChanges[field] = (Map<OdooField, dynamic> currentValues) async {
        return await model.onchange([field], currentValues, onChangeSpec);
      };
    }

    return ExpenseForm(
      key: ObjectKey(this),
      fieldNames: fieldNames,
      initial: initial,
      onFieldChanges: onFieldChanges,
      displayFieldsName: displayFieldNames,
      title: formTitle,
      onSaved: (Map<OdooField, dynamic> values) async {
        return await model.create(values);
      },
    );*/
    return const Center(child: CircularProgressIndicator());
   }


  }
