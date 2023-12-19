import 'package:flutter/material.dart';
import 'package:smartpay/core/widgets/hr_expense/expense_form.dart';
import 'package:smartpay/core/widgets/hr_expense/expense_list.dart';
import 'package:smartpay/ir/models/expense.dart';
import 'package:smartpay/ir/models/user.dart';

class ExpenseScreen extends StatefulWidget {
  final User user;

  // onTitleChanged is a callback function to change the title of the page
  final Function(String) onTitleChanged;

  final Map<String, dynamic>? dataKwargs;

  const ExpenseScreen({
    super.key,
    required this.user,
    required this.onTitleChanged,
    this.dataKwargs,
  });

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  // The current page
  int _selectedIndex = 0;

  int? _expenseId;

  // List of pages
  final List<Widget> _pages = [];
  final List<String> _pageTitle = [
    'Liste des notes',
    'Ajout d\'une note de frais',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.dataKwargs != null) {
      var model = widget.dataKwargs!['model'];
      if (model == 'hr.expense') {
        _expenseId = widget.dataKwargs!['res_id'];
        if (_expenseId != null) {
          _selectedIndex = 1;
        }
      }
    }
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
    var navigationBar = BottomNavigationBar(
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
          label: (_expenseId == null) ? _pageTitle[1] : 'Note de frais',
        ),
      ],
    );
    if (_expenseId != null) {
      var future = ExpenseFormWidget.buildExpenseForm(
        id: _expenseId!,
        editable: false,
        onCancel: () {
          _changePage(0);
        },
      );
      return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          Widget content;
          if (snapshot.hasError) {
            content = const Center(child: Text('Error'));
          } else if (snapshot.hasData) {
            content = snapshot.data as Widget;
          } else {
            content = const Center(child: CircularProgressIndicator());
          }
          _expenseId = null;
          _selectedIndex = 1;
          return Scaffold(
            body: content,
            bottomNavigationBar: navigationBar,
          );
        },
      );
    } else {
      Widget body;
      if (_selectedIndex == 0) {
        body = _buildBody();
      } else {
        body = Navigator(
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => _buildBody(),
            );
          },
        );
      }
      return Scaffold(
        body: body,
        bottomNavigationBar: navigationBar,
      );
    }
  }

  Widget _buildBody() {
    return Container(
        margin: const EdgeInsets.only(top: 05, left: 0, right: 0),
        child: _pages[_selectedIndex]);
  }

  _buildForm(int index) async {
    Widget? content;
    if (index == 1) {
      content = await ExpenseFormWidget.buildExpenseForm(
        onCancel: () {
        _changePage(0);
      }, afterSave: (Expense expense) {
        _changePage(0);
      });
    }
    if (content != null) {
      setState(() {
        _pages[index] = content!;
      });
    }
  }
}
