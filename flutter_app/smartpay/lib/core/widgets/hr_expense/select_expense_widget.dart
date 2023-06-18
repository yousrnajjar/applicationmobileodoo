import 'package:flutter/material.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/models/expense.dart';

import 'expense_list_item.dart';

/// Return list of expenses to choose from with message that describes what to do
/// if expense is selected, color of expense is green
/// if is ok, return expense
/// else undo selection and wait for another selection
/// two buttons: cancel and ok will must be available
/// No show in scaffold
///
class SelectExpenseWidget extends StatefulWidget {
  final List<Expense> expenses;
  final Function(BuildContext context, Expense expense) onSelect;
  final Function()? onCancel;
  final String? title;

  const SelectExpenseWidget({
    super.key,
    required this.expenses,
    required this.onSelect,
    this.onCancel,
    this.title,
  });

  @override
  State<SelectExpenseWidget> createState() => _SelectExpenseWidgetState();
}

class _SelectExpenseWidgetState extends State<SelectExpenseWidget> {
  Expense? _selectedExpense;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMessageOnTop(context),
        _buildListExpenses(context),
        _buildButtons(context),
      ],
    );
  }

  /// Build Message On Top
  /// Affiche le message en haut de la page
  ///
  Widget _buildMessageOnTop(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          Text(
            widget.title ?? 'Choisissez une dépense',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (_selectedExpense != null)
            Text(
              _selectedExpense!.info['name'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kGreen,
              ),
            ),
        ],
      ),
    );
  }

  /// Build List Expenses
  /// Affiche la liste des expenses
  ///
  Widget _buildListExpenses(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.expenses.length,
        itemBuilder: (context, index) {
          return _buildExpense(context, widget.expenses[index]);
        },
      ),
    );
  }

  /// Build Expense
  /// Affiche une expense
  ///
  Widget _buildExpense(BuildContext context, Expense expense) {
    Widget expenseListItem =
        ExpenseListItem.fromMap(context, expense.info, onTap: () {
      setState(() {
        _selectedExpense = expense;
      });
    });
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedExpense = expense;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            _selectedExpense == expense
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.check_circle_outline),
            const SizedBox(width: 10),
            Expanded(child: expenseListItem),
          ],
        ),
      ),
    );
  }

  /// Build Buttons
  /// Affiche les boutons
  ///
  Widget _buildButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          OutlinedButton(
            child: const Text('Annuler'),
            onPressed: () {
              if (widget.onCancel != null) {
                widget.onCancel!();
                return;
              }
              if (context.mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          ElevatedButton(
            child: const Text('Continuer'),
            onPressed: () {
              if (_selectedExpense == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Aucune dépense n\'a été sélectionnée'),
                  ),
                );
              } else {
                widget.onSelect(context, _selectedExpense!);
              }
            },
          ),
        ],
      ),
    );
  }
}
