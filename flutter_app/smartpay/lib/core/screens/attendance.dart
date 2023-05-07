import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/core/widgets/attendance/check_in_out.dart';

class InOutScreen extends ConsumerStatefulWidget {
  const InOutScreen({super.key});

  @override
  ConsumerState<InOutScreen> createState() => _InOutScreenState();
}

class _InOutScreenState extends ConsumerState<InOutScreen> {
  int _selectedPageIndex = 0;
  Widget? _activePage;
  @override
  void initState() {
    super.initState();
  }

  void _selectPage(int index) {
    if (index == 0) {
      setState(() {
        _activePage = const CheckInOut();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("In Out"), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.sync),
          onPressed: _checkEmployeeState,
        ),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          _selectPage(index);
        },
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sync),
            label: 'Check In / Check Out',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: "Employé",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.present_to_all),
            label: "Présences",
          ),
        ],
      ),
      body: _activePage,
    );
  }

  void _checkEmployeeState() {}
}
