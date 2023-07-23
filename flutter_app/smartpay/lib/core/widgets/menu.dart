import 'package:flutter/material.dart';
import 'package:smartpay/core/models/side_menu.dart';
import 'package:smartpay/ir/data/themes.dart';

class SideMenuDrawer extends StatelessWidget {
  const SideMenuDrawer({
    super.key,
    required this.sideMenus,
    required this.titleLarge,
    required this.onSetScreen,
  });

  final Function(String identifier) onSetScreen;

  final List<SideMenu> sideMenus;
  final TextStyle? titleLarge;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            DrawerHeader(
              // remove dividers
              //padding: const EdgeInsets.all(20),
              /*decoration: BoxDecoration(
                  color: Colors.transparent,
                ),*/

              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Image.asset(
                  "assets/images/logo.jpeg",
                  width: (200 / baseWidthDesign) * width,
                  height: (110 / baseWidthDesign) * width,
                ),
              ),
            ),
            for (final sideMenu in sideMenus)
              Container(
                height: (40 / baseHeightDesign) * height,
                decoration: BoxDecoration(
                  // add border top and bottom
                  border: Border(
                    /*top: BorderSide(
                      color: Colors.grey.withOpacity(0.5),
                      width: 0.5,
                    ),*/
                    bottom: BorderSide(
                      color: Colors.grey.withOpacity(0.5),
                      width: 0.5,
                    ),
                  ),
                ),
                child: ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  leading: Image(
                    image: sideMenu.iconImage.image,
                    width: 30,
                    height: 30,
                  ),
                  //CircleAvatar(backgroundImage: sideMenu.iconImage.image)
                  title: Text(sideMenu.displayName, style: titleLarge),
                  onTap: () {
                    onSetScreen(sideMenu.identifier);
                  },
                ),
              ),
            const Spacer(),
            Container(
                decoration: BoxDecoration(
                  // add border top and bottom
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.withOpacity(0.5),
                      width: 0.5,
                    ),
                    bottom: BorderSide(
                      color: Colors.grey.withOpacity(0.5),
                      width: 0.5,
                    ),
                  ),
                ),
                child: ListTile(
                  leading: Image.asset(
                    "assets/icons/deconnecter.png",
                    width: 30,
                    height: 30,
                  ),
                  title: Text('Se déconnecter', style: titleLarge),
                  onTap: () {
                    onSetScreen("login");
                  },
                )),
          ],
        ),
      ),
    );
  }
}
