import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartpay/core/widgets/hr_contract/contract_detail.dart';
import 'package:smartpay/core/widgets/hr_employee/hr_employee_card_detail.dart';
import 'package:smartpay/core/widgets/hr_payslip/payslip_list_detail.dart';
import 'package:smartpay/core/widgets/utils/circular_ratio_indicator.dart';
import 'package:smartpay/core/widgets/utils/pdf/pdf_view_widget.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/user.dart';

import 'main_drawer.dart';

var dateFormater = DateFormat('yyyy-MM-dd');

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
  double _nbrWorkDay = 0.0;
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
    _loadLastContract().then((value) {
      if (value.isNotEmpty) {
        if (context.mounted) {
          setState(() {
            _lastContract = value[0];
          });
        } else {
          _lastContract = value[0];
        }
      }
    });
    _loadLastPayslipInfo().then((value) {
      if (value.isNotEmpty) {
        if (context.mounted) {
          setState(() {
            _lastPay = value[0];
          });
        } else {
          _lastPay = value[0];
        }
      }
    });
    _computeNbrWorkDayThisMonth().then((value) {
      if (context.mounted) {
        setState(() {
          _nbrWorkDay = value;
        });
      } else {
        _nbrWorkDay = value;
      }
    });
  }
  Future<double> _computeNbrWorkDayThisMonth() async {
    var attModel = OdooModel('hr.attendance');
    var now = DateTime.now();
    var startDay = DateTime(now.year, now.month, 1);
    var endDay = DateTime(now.year, now.month + 1, 1);
    var domain = [
      ['employee_id', '=', widget.user.employeeId],
      ['check_in', '>=', dateFormater.format(startDay)],
      ['check_out', '<', dateFormater.format(endDay)],
    ];
    var fields = ['check_in', 'check_out'];
    var attendance = await attModel.searchRead(domain: domain, fieldNames: fields);
    print(attendance);
    var nbrWorkDay = 0.0;
    for (var att in attendance) {
      if (att['check_out'] != false) {
        nbrWorkDay += 1;
      }
    }
    return nbrWorkDay;
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
      fieldNames: [
        'name', 
        'job_id',
        'image_128',
        'allocation_count',
        'allocation_used_count'
      ],
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
    double allocationCount = 0;
    double allocationUsedCount = 0;
    for (var item in _employee.entries) {

      if (item.key.name == 'allocation_count') {
        allocationCount = item.value;
      }
      if (item.key.name == 'allocation_used_count') {
        allocationUsedCount = item.value;
      }
    }
    double nbrWorkDayRatio = 0.0;
    int nbrDayThisMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
    if (_nbrWorkDay != 0.0) {
      nbrWorkDayRatio = _nbrWorkDay / nbrDayThisMonth;
    }
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
                ratio: nbrWorkDayRatio,
                maxRatio: nbrDayThisMonth.toDouble(),
                colorText: const Color.fromARGB(255, 112, 107, 168),
                colorBackground: const Color.fromARGB(255, 191, 187, 248),
                progressColor: const Color.fromARGB(255, 212, 212, 240),
              ),
              CircularRatioIndicator(
                suffix: 'Jours',
                title: 'Nombre des jours de congé',
                // Valeur du nombre de jours de congé
                ratio: (allocationCount == 0) ? 1 : allocationUsedCount / allocationCount,
                maxRatio: (allocationCount == 0) ? 1 : allocationCount,
                /// user.info['allocation_count'],
                colorText: const Color.fromARGB(255, 165, 154, 104),
                colorBackground: const Color.fromARGB(255, 248, 237, 187),
                progressColor: const Color.fromARGB(255, 234, 232, 216),
              ),
            ],
          ),
          // Remaning leaves in progress bar
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: (10 / baseWidthDesign) * width,
                vertical: (10 / baseHeightDesign) * height),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Congés restants',
                      style: TextStyle(
                        fontSize: (15 / baseWidthDesign) * width,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$allocationUsedCount / $allocationCount',
                      style: TextStyle(
                        fontSize: (15 / baseWidthDesign) * width,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: (10 / baseHeightDesign) * height),
                LinearProgressIndicator(
                  value: (allocationCount == 0)
                      ? 0
                      : allocationUsedCount / allocationCount,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.green,
                  ),
                ),
              ],
            ),
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
