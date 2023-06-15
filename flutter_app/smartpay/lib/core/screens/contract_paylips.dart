import 'package:flutter/material.dart';
import 'package:smartpay/core/widgets/contract/contract_list.dart';
import 'package:smartpay/core/widgets/hr_payslip/payslip_list.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/models/user.dart';

/// Affiche les informations d'un employé
/// Un menu en bas de l'écran permet de naviguer entre les différentes pages
/// Contrat [ContractList] : La liste des contrats de l'employé
/// Fiche de paie [PayslipList] : La liste des fiches de paie de l'employé

class ContractPayslipScreen extends StatefulWidget {
  final User user;
  final Function(String) onTitleChanged;

  const ContractPayslipScreen({
    required this.user,
    required this.onTitleChanged,
    super.key,
  });

  @override
  State<ContractPayslipScreen> createState() => _ContractPayslipScreenState();
}

class _ContractPayslipScreenState extends State<ContractPayslipScreen> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;
  final List<String> _titles = [
    'Liste des contrats',
    'Liste des fiches de paie',
  ];

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      ContractList(user: widget.user),
      PayslipList(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      //body: _widgetOptions.elementAt(_selectedIndex),
      body: Container(
        margin: EdgeInsets.only(
            top: (10 / baseHeightDesign) * height,
            left: 10,
            right: 10,
            bottom: 20),
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icons/contract.png'),
              size: 30,
            ),
            label: 'Contrat',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icons/payslip.png'),
              size: 30,
            ),
            label: 'Fiche de paie',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      widget.onTitleChanged(_titles[index]);
    });
  }
}
