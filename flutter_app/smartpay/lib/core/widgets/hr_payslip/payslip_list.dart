import 'package:flutter/material.dart';
import 'package:smartpay/core/widgets/utils/pdf/pdf_view_widget.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/user.dart';

import './payslip_list_detail.dart';

/// Permet d'afficher la liste des bulletins de paie [PayslipListDetail] d'un utilisateur
/// Utilisateur doit être lié au moins un employé

class PayslipList extends StatefulWidget {
  final User user;

  const PayslipList({
    required this.user,
    super.key,
  });

  @override
  State<PayslipList> createState() => _PayslipListState();
}

class _PayslipListState extends State<PayslipList> {
  String activeScreenName = 'list';
  int? activePayslipId;

  Future<List<Map<OdooField, dynamic>>> _loadPayslips() async {
    return OdooModel('hr.payslip').searchReadAsOdooField(
      domain: [
        ['employee_id', '=', widget.user.employeeId]
      ],
      fieldNames: [
        'id',
        'name',
        'date_from',
        'date_to',
        'state',
        'employee_id'
      ],
      limit: 1000,
    );
  }

  Widget _buildPayslipList(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return FutureBuilder(
      future: _loadPayslips(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Map<OdooField, dynamic> payslip = snapshot.data![index];
              return Padding(
                padding:
                    EdgeInsets.only(bottom: (10 * baseHeightDesign) / height),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      activeScreenName = 'detail';
                      activePayslipId = payslip.entries
                          .firstWhere((e) => e.key.name == 'id')
                          .value;
                    });
                  },
                  child: PayslipListDetail(
                      pay: payslip,
                      onPrintPdf: (int id) {
                        setState(() {
                          activeScreenName = 'pdf';
                          activePayslipId = id;
                        });
                      }),
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
      return _buildPayslipList(context);
    } else {
      var reportName = "om_hr_payroll.report_payslip";
      return AppPDFView(
        reportName: reportName,
        resourceIds: [activePayslipId!],
        onReturn: () {
          setState(() {
            activeScreenName = 'list';
          });
        },
      );
    }
  }
}
