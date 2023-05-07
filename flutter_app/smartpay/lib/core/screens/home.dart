import 'package:flutter/material.dart';
import 'package:smartpay/core/widgets/main_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SmartPay")),
      body: const Text("Bienvenue"),
      drawer: const MainDrawer(),
    );
  }
}
