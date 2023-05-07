import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SideMenu {
  final IconData icon;

  final String displayName;

  final String identifier;

  final List<SideMenu> subMenus;

  SideMenu({
    required this.icon,
    required this.displayName,
    required this.identifier,
    required this.subMenus,
  });

  SideMenu.fromJson(Map<String, dynamic> data)
      : icon = IconData(int.parse(data['icon'], radix: 16), fontFamily: "MaterialIcons"),
        // https://stackoverflow.com/a/71538766
        displayName = data["display_name"],
        identifier = data['identifier'],
        subMenus = [];
}

Future<Stream<SideMenu>> getSideMenus(onTap) async {
  return Stream.fromFuture(rootBundle.loadString('assets/data/side_menus.json'))
      .transform(json.decoder)
      .expand((jsonBody) => (jsonBody as Map)['content'])
      .map((jsonPlace) => SideMenu.fromJson(jsonPlace));
}
