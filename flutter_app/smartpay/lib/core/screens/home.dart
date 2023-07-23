import 'package:flutter/material.dart';

import 'package:smartpay/core/widgets/hr_payslip/payslip_list_detail.dart';
import 'package:smartpay/core/widgets/utils/circular_ratio_indicator.dart';
import 'package:smartpay/core/widgets/hr_contract/contract_detail.dart';
import 'package:smartpay/core/widgets/hr_employee/hr_employee_card_detail.dart';
import 'package:smartpay/core/widgets/utils/pdf_view_widget.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/user.dart';

import 'main_drawer.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen(
    this.user, {
    super.key,
  });

  @override
  State<HomeScreen> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomeScreen> {
  Map<OdooField, dynamic> _lastContract = {};
  Map<OdooField, dynamic> _lastPay = {};
  Map<OdooField, dynamic> _employee = {};
  String activeScreenName = 'dashboard';
  int? activeObjectId;
  String? objectName;
  var reports = {
    'contract': "hr_contract.report_contract",
    'payslip': 'om_hr_payroll.report_payslip',
  };

  @override
  void initState() {
    super.initState();
    _loadEmployeeInfo().then((value) {
      if (value.isNotEmpty) {
        setState(() {
          _employee = value[0];
        });
      }
    });
    _loadLastContract().then((value) => {
          if (value.isNotEmpty)
            {
              setState(() {
                _lastContract = value[0];
              })
            }
        });
    _loadLastPayslipInfo().then((value) {
      if (value.isNotEmpty) {
        setState(() {
          _lastPay = value[0];
        });
      }
    });
  }

  Future<List<Map<OdooField, dynamic>>> _loadLastPayslipInfo() {
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
      limit: 1,
    );
  }

  Future<List<Map<OdooField, dynamic>>> _loadEmployeeInfo() {
    return OdooModel('hr.employee').searchReadAsOdooField(
      domain: [
        ['id', '=', widget.user.employeeId]
      ],
      fieldNames: ['name', 'job_id', 'image_128'],
      limit: 1,
    );
  }

  Future<List<Map<OdooField, dynamic>>> _loadLastContract() async {
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
      limit: 1,
    );
    return res;
  }

  Widget _buildDashboard(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var user = widget.user;
    return Scaffold(
      body: ListView(
        children: [
          if (_employee.isNotEmpty)
            EmployeeCard(
              employee: _employee,
              user: user,
              showDetails: true,
            ),
          Row(
            children: [
              CircularRatioIndicator(
                suffix: 'Jours',
                title: 'Nombre des jours travaillés',
                // Valeur du nombre de jours travaillé
                ratio: user.info['hours_last_month'] / 24,
                colorText: const Color.fromARGB(255, 112, 107, 168),
                colorBackground: const Color.fromARGB(255, 191, 187, 248),
                progressColor: const Color.fromARGB(255, 212, 212, 240),
              ),
              CircularRatioIndicator(
                suffix: 'Jours',
                title: 'Nombre des jours de congé',
                // Valeur du nombre de jours de congé
                ratio: user.info['allocation_used_count'],

                /// user.info['allocation_count'],
                colorText: const Color.fromARGB(255, 165, 154, 104),
                colorBackground: const Color.fromARGB(255, 248, 237, 187),
                progressColor: const Color.fromARGB(255, 234, 232, 216),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: (10 / baseWidthDesign) * width,
                vertical: (10 / baseHeightDesign) * height),
            child: Column(
              children: [
                ContractDetail(
                  contract: _lastContract,
                  onPrintPdf: (int id) {
                    setState(
                      () {
                        activeScreenName = 'pdf';
                        objectName = 'contract';
                        activeObjectId = id;
                      },
                    );
                  },
                ),
                SizedBox(height: (10 / baseHeightDesign) * height),
                //PayslipDetail(pay: _lastPay),
                PayslipListDetail(
                    pay: _lastPay,
                    onPrintPdf: (int id) {
                      setState(() {
                        activeScreenName = 'pdf';
                        objectName = 'payslip';
                        activeObjectId = id;
                      });
                    }),
              ],
            ),
          ),
        ],
      ),
      // bottomNavigationBar: Salarié, Congé, Présence, Notes de frais
      bottomNavigationBar: BottomNavigationBar(
        onTap: _setPage,
        currentIndex: 0,
        // show more than 3 items
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/employee.jpeg',
                width: 30, height: 30),
            label: 'Salarié',
          ),
          BottomNavigationBarItem(
            icon:
                Image.asset('assets/icons/holiday.jpeg', width: 30, height: 30),
            label: 'Congés',
          ),
          BottomNavigationBarItem(
            icon:
                Image.asset('assets/icons/pointage.png', width: 30, height: 30),
            label: 'Présences',
          ),
          BottomNavigationBarItem(
            icon:
                Image.asset('assets/icons/expense.jpeg', width: 30, height: 30),
            label: 'Notes de frais',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (activeScreenName == 'dashboard') {
      return _buildDashboard(context);
    } else {
      var reportName = reports[objectName!]!;
      return AppPDFView(
        reportName: reportName,
        resourceIds: [activeObjectId!],
        onReturn: () {
          setState(
            () {
              activeScreenName = 'dashboard';
            },
          );
        },
      );
    }
  }

  void _setPage(int identifier) {
    String page = 'dashboard';
    Navigator.of(context).pop();
    if (identifier == 0) {
      page = 'employee';
    } else if (identifier == 1) {
      page = "leave";
    } else if (identifier == 2) {
      page = "attendance";
    } else if (identifier == 3) {
      page = "expense";
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MainDrawer(
        user: widget.user,
        activePageName: page,
      );
    }));
  }
}
