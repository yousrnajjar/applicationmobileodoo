import 'package:flutter/material.dart';
import 'package:smartpay/core/models/side_menu.dart';
import 'package:smartpay/core/screens/attendance/in_out.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({
    super.key,
  });
  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  late String title;

  List<SideMenu> _sideMenus = [];
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SmartPay")),
      body: const Text("Bienvenue"),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    child: Image.asset("assets/images/logo.jpeg"),
                  ),
                  const SizedBox(width: 18),
                  Text(
                    "Smart Pay",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  )
                ],
              ),
            ),
            for (final sideMenu in _sideMenus)
              ListTile(
                leading: Icon(
                  sideMenu.icon,
                  size: 26,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                title: Text(
                  sideMenu.displayName,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 24,
                      ),
                ),
                onTap: () {
                  _setScreen(sideMenu.identifier);
                },
              ),
          ],
        ),
      ),
    );
  }
}
