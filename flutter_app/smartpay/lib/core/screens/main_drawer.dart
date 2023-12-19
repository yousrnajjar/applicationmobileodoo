import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/session.dart';
import 'package:smartpay/core/models/side_menu.dart';
import 'package:smartpay/core/providers/session_providers.dart';
import 'package:smartpay/core/providers/user_info_providers.dart';
import 'package:smartpay/core/widgets/menu.dart';
import 'package:smartpay/ir/models/user.dart';

import 'home.dart';
import 'hr/hr_attendance.dart';
import 'hr/hr_contract_payslips.dart';
import 'hr/hr_expense.dart';
import 'hr/hr_holidays.dart';
import 'login_screen.dart';
import 'notification.dart'; // Notification Screen

class MainDrawer extends ConsumerStatefulWidget {
  final User user;

  final String? activePageName;

  final Map<String, dynamic>? dataKwargs;

  const MainDrawer({
    required this.user,
    super.key,
    this.activePageName,
    this.dataKwargs,
  });

  @override
  ConsumerState<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends ConsumerState<MainDrawer> {
  late String title;
  final List<SideMenu> _sideMenus = [];
  int _notificationCount = 0;

  String _title = '';
  late Widget _screen;

  @override
  void initState() {
    super.initState();
    listenForSideMenus();
    var page = _initPage();
    _screen = page.value;
    _title = page.key;
    _refreshNotificationCount();
  }

  Future<void> _refreshNotificationCount() async {
    var count = await getNotificationsCount(widget.user.partnerId);
    if (count == _notificationCount) return;
    setState(() {
      _notificationCount = count;
    });
  }

  MapEntry<String, Widget> _initPage() {
    Map<String, Widget> res = {_title: HomeScreen(widget.user)};
    var identifier = widget.activePageName;
    if (identifier == "employee") {
      res = {
        'Contrat':
            ContractPayslipScreen(user: widget.user, onTitleChanged: setTitle),
      };
    } else if (identifier == "attendance") {
      res = {"Pointage": InOutScreen(onTitleChanged: setTitle)};
    } else if (identifier == "leave") {
      res = {
        "Congé": HolidayScreen(
            user: widget.user,
            onTitleChanged: setTitle,
            dataKwargs: widget.dataKwargs)
      };
    } else if (identifier == "expense") {
      res = {
        "Note de frais": ExpenseScreen(
            user: widget.user,
            onTitleChanged: setTitle,
            dataKwargs: widget.dataKwargs)
      };
    }
    return res.entries.first;
  }

  void listenForSideMenus() async {
    var stream = await getSideMenus(() {});
    stream.listen((sideMenu) {
      setState(() {
        _sideMenus.add(sideMenu);
      });
    });
  }

  void _setScreen(String identifier) async {
    Navigator.of(context).pop();
    // NotifCount
    if (identifier == "dashboard") {
      setState(() {
        _title = "Tableau de bord";
        _screen = HomeScreen(widget.user);
      });
    } else if (identifier == "employee") {
      setState(() {
        _title = "Salarié";
        _screen =
            ContractPayslipScreen(user: widget.user, onTitleChanged: setTitle);
      });
    } else if (identifier == "attendance") {
      setState(() {
        _title = "Pointage";
        _screen = InOutScreen(onTitleChanged: setTitle);
      });
    } else if (identifier == "leave") {
      setState(() {
        _title = "Congés";
        _screen = HolidayScreen(user: widget.user, onTitleChanged: setTitle);
      });
    } else if (identifier == "expense") {
      setState(() {
        _title = "Notes de frais";
        _screen = ExpenseScreen(user: widget.user, onTitleChanged: setTitle);
      });
    } else if (identifier == "login") {
      ref.read(userInfoProvider.notifier).setUserInfo(User({}));
      ref.watch(sessionProvider.notifier).setSession(Session(email: '', password: ''));
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => const LoginScreen(),
        ),
      );
    }
  }

  setTitle(String title) {
    _refreshNotificationCount();
    setState(() {
      _title = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    var appBarForeground = Theme.of(context).appBarTheme.foregroundColor;
    var titleLarge = Theme.of(context).textTheme.titleLarge;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: appBarForeground,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Image.asset("assets/icons/menu.png"),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
        title: Text(
          _title,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.bold,
                color: appBarForeground,
                fontSize: 18,
              ),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => NotificationScreen(user: widget.user),
                ),
              );
            },
            child: Stack(
              children: [
                Icon(
                  Icons.notifications_none_outlined,
                  color: appBarForeground,
                  size: 40,
                ),
                //Image.asset('assets/icons/holiday/icone_notification.png'),
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_notificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _screen,
      drawer: SideMenuDrawer(
        sideMenus: _sideMenus,
        titleLarge: titleLarge,
        onSetScreen: _setScreen,
      ),
    );
  }
}
