import 'package:flutter/material.dart';
import 'package:smartpay/core/widgets/utils/pdf_view_widget.dart';
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
  String activeScreenName = 'list';

  int? activeContractId;

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

  Widget _buildContractList(BuildContext context) {
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
                child: InkWell(
                  onTap: () {
                    setState(() {
                      activeScreenName = 'detail';
                      activeContractId = contract.entries
                          .firstWhere((element) => element.key.name == 'id')
                          .value;
                    });
                  },
                  child: ContractDetail(
                    contract: contract,
                    onPrintPdf: (int id) {
                      setState(
                        () {
                          activeScreenName = 'pdf';
                          activeContractId = id;
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (activeScreenName == 'list') {
      return _buildContractList(context);
    } else {
      var reportName = "om_hr_payroll.report_payslip";
      return AppPDFView(
        reportName: reportName,
        resourceIds: [activeContractId!],
        onReturn: () {
          setState(
            () {
              activeScreenName = 'list';
            },
          );
        },
      );
    }
  }
}
