import 'package:flutter/material.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/user.dart';

import 'contract_detail.dart';

/// Permet d'afficher la liste des contrats [ContractDetail] d'un utilisateur
/// Utilisateur doit être lié au moins un employé

class ContractList extends StatefulWidget {
  final User user;

  const ContractList({
    required this.user,
    super.key,
  });

  @override
  State<ContractList> createState() => _ContractListState();
}

class _ContractListState extends State<ContractList> {
  Future<List<Map<OdooField, dynamic>>> _loadContracts() async {
    List<Map<OdooField, dynamic>> res =
        await OdooModel("hr.contract").searchReadAsOdooField(
      domain: [
        ["employee_id", "=", widget.user.employeeId]
      ],
      fieldNames: [
        "id",
        "name",
        "date_start",
        "date_end",
        "wage",
        "employee_id",
        "state",
        "trial_date_end",
        "resource_calendar_id",
        "hr_responsible_id"
      ],
      limit: 1000,
    );
    return res;
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return FutureBuilder(
      future: _loadContracts(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Map<OdooField, dynamic> contract = snapshot.data![index];
              return Padding(
                  padding:
                      EdgeInsets.only(bottom: (10 * baseHeightDesign) / height),
                  child: ContractDetail(contract: contract));
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
