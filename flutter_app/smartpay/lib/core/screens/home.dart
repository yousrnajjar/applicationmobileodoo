import 'package:flutter/material.dart';
import 'package:smartpay/core/data/themes.dart';
import 'package:smartpay/core/widgets/main_drawer.dart';

class HomeScreen extends StatelessWidget {
  final String title;
  const HomeScreen({super.key, required this.title});
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: smartpayTheme,
      home: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Text("Bienvenue"),
        drawer: const MainDrawer(),
      ),

    );
  }
}
