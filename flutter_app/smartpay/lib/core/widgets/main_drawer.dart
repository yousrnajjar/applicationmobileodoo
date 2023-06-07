import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/session.dart';
import 'package:smartpay/core/providers/user_info_providers.dart';
import 'package:smartpay/core/screens/holidays_screen_v2.dart';
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

  void _setScreen(String identifier) async {
    Navigator.of(context).pop();
    if (identifier == "attendance") {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => const InOutScreen(),
        ),
      );
    } else if (identifier == "leave") {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => HolidayScreen(user: widget.user),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    var appBarForeground = Theme.of(context).appBarTheme.foregroundColor;
    Widget homeScreen = HomeScreen(widget.user);
    var titleLarge = Theme.of(context).textTheme.titleLarge;
    return Scaffold(
      appBar: AppBar(
        title: Text(_title)
      ),
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
