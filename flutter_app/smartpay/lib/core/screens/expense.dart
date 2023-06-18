import 'package:flutter/material.dart';
import 'package:smartpay/core/widgets/hr_expense/expense_form.dart';
import 'package:smartpay/core/widgets/hr_expense/expense_list.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/expense.dart';
import 'package:smartpay/ir/models/user.dart';

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
    _pages.add(ExpenseList(user: widget.user, onChangedPage: _changePage));
    // Add the holiday form page
    _pages.add(const Center(child: CircularProgressIndicator()));
  }

  // Change the page
  _changePage(int index) {
    widget.onTitleChanged(_pageTitle[index]);
    if ([1].contains(index)) {
      _buildForm(index);
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => _buildBody(),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          _changePage(index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/expense_list.png"),
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

  Widget _buildBody() {
    return Container(
        margin: const EdgeInsets.only(top: 05, left: 0, right: 0),
        child: _pages[_selectedIndex]);
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
  Future<Widget> buildExpenseForm() async {
    /*return await OdooModel("hr.expense").buildFormFields(
      fieldNames: Expense({}).allFields,
      onChangeSpec: Expense({}).onchangeSpec,
      formTitle: "Demande de congé",
      displayFieldNames: Expense({}).displayFieldNames,
    );*/
    var fieldNames = Expense({}).allFields;
    var displayFieldNames = Expense({}).displayFieldNames;
    var onChangeSpec = Expense({}).onchangeSpec;
    var formTitle = "";
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ExpenseFormWidget(
        key: ObjectKey(this),
        fieldNames: fieldNames,
        initial: initial,
        onFieldChanges: onFieldChanges,
        displayFieldsName: displayFieldNames,
        title: formTitle,
        onSaved: (Map<OdooField, dynamic> values) async {
          return await model.create(values);
        },
        onCancel: () {
          _changePage(0);
        },
      ),
    );
  }
}
