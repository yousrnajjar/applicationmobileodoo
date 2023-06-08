import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smartpay/api/session.dart';
import 'package:smartpay/core/providers/user_info_providers.dart';
import 'package:smartpay/core/screens/holidays_screen.dart';
import 'package:smartpay/ir/models/user.dart';
import 'package:smartpay/core/providers/session_providers.dart';
import 'package:smartpay/core/screens/login_screen.dart';
import 'package:smartpay/core/models/side_menu.dart';
import 'package:smartpay/core/screens/attendance.dart';
import 'package:smartpay/core/screens/home.dart';

class MainDrawer extends ConsumerStatefulWidget {
  final User user;

  const MainDrawer({
    required this.user,
    super.key,
  });

  @override
  ConsumerState<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends ConsumerState<MainDrawer> {
  late String title;
  final List<SideMenu> _sideMenus = [];

  String _title = "Tableau de bord";
  late Widget _screen;

  @override
  void initState() {
    super.initState();
    listenForSideMenus();
    _screen = HomeScreen(widget.user);
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
    if (identifier == "attendance") {
      setState(() {
        _title = "Pointage";
        _screen = InOutScreen(onTitleChanged: setTitle);
      });
      /*
         await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => const InOutScreen(),
        ),
      );
      */
    } else if (identifier == "leave") {
      setState(() {
        _title = "Congés";
        _screen = HolidayScreen(user: widget.user, onTitleChanged: setTitle);
      });
      /*
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => HolidayScreen(user: widget.user),
        ),
      );
      */
    } else if (identifier == "login") {

      ref.read(userInfoProvider.notifier).setUserInfo(User({}));
      ref.watch(sessionProvider.notifier).setSession(Session("", "", ""));
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => const LoginScreen(),
        ),
      );
    }
  }
  setTitle(String title) {
    setState(() {
      _title = title;
    });
  }
  @override
  Widget build(BuildContext context) {
    var appBarForeground = Theme.of(context).appBarTheme.foregroundColor;
    //Widget homeScreen = HomeScreen(widget.user);
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
              ),
        ),
        actions: [
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification'),
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
                    child: const Text(
                      '10',
                      style: TextStyle(
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
