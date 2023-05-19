import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/auth/session.dart';
import 'package:smartpay/api/employee/employee_api.dart';
import 'package:smartpay/api/holydays/holydays_api.dart';
import 'package:smartpay/api/models.dart';
import 'package:smartpay/core/auth/screens/login_screen.dart';
import 'package:smartpay/core/models/side_menu.dart';
import 'package:smartpay/core/screens/attendance.dart';
import 'package:smartpay/core/screens/holydays_screen.dart';
import 'package:smartpay/core/screens/home.dart';
import 'package:smartpay/providers/current_employee_provider.dart';
import 'package:smartpay/providers/models/user_info.dart';
import 'package:smartpay/providers/my_holydays_list_provider.dart';
import 'package:smartpay/providers/session_providers.dart';

class MainDrawer extends ConsumerStatefulWidget {
  final UserInfo userInfo;

  const MainDrawer({
    required this.userInfo,
    super.key,
  });

  @override
  ConsumerState<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends ConsumerState<MainDrawer> {
  late String title;
  EmployeeAllInfo _employee = EmployeeAllInfo();
  final List<SideMenu> _sideMenus = [];

  @override
  void initState() {
    super.initState();
    listenForSideMenus();
  }

  void listenForSideMenus() async {
    var stream = await getSideMenus(() {});
    stream.listen((sideMenu) {
      setState(() {
        _sideMenus.add(sideMenu);
      });
    });
  }

  Future<void> _getEmployee() async {
    Session session = ref.watch(sessionProvider);
    var api = EmployeeAPI(session);
    var employee = await api.getEmployee(widget.userInfo.uid);
    ref.read(currentEmployeeProvider.notifier).setEmployee(employee);
    if (context.mounted) {
      setState(() {
        _employee = employee;
      });
    }
  }

  Future<void> _getHolydays() async {
    Session session = ref.watch(sessionProvider);
    var api = HolydaysAPI(session);
    var myHolydays = await api.getMyHolydays(widget.userInfo.uid);
    ref.read(myHolydaysProvider.notifier).setMyHolydays(myHolydays);
  }

  void _setScreen(String identifier) async {
    Navigator.of(context).pop();
    if (identifier == "attendance") {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => const InOutScreen(),
        ),
      );
    } else if (identifier == "leave") {
      _getHolydays();
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => const HolydaysScreen(),
        ),
      );
    } else if (identifier == "login") {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _employee = ref.watch(currentEmployeeProvider);
    if (_employee.id == null) {
      _getEmployee();
    }
    Widget homeScreen = HomeScreen(_employee);
    var titleLarge = Theme.of(context).textTheme.titleLarge;
    return Scaffold(
      appBar: AppBar(title: const Text("Facilitez votre quotidien avec SmartPay App")),
      body: homeScreen,
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              DrawerHeader(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Image.asset("assets/images/logo.jpeg"),
                  )),
              for (final sideMenu in _sideMenus)
                ListTile(
                  leading:
                      CircleAvatar(backgroundImage: sideMenu.iconImage.image),
                  title: Text(sideMenu.displayName, style: titleLarge),
                  onTap: () {
                    _setScreen(sideMenu.identifier);
                  },
                ),
              const Spacer(),
              ListTile(
                leading: Image.asset("assets/icons/deconnecter.png"),
                title: Text('Se déconnecter', style: titleLarge),
                onTap: () {
                  _setScreen("login");
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
