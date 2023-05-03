import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smartpay/api/auth/session.dart';
import 'package:smartpay/core/data/themes.dart';
import 'package:smartpay/core/auth/screens/login_screen.dart';
import 'package:smartpay/core/screens/home.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SmartPay();
  }
}

class SmartPay extends StatelessWidget {
  Session? session;
  final Widget _activeScreen = const HomeScreen(title: "SmartPay");

  SmartPay({super.key, this.session});

  void _changeSession(Session session) {
    this.session = session;
  }

  Widget _getLoginScreen() {
    return  MaterialApp(
      title: 'SmartPay Mobile',
      theme: smartpayTheme,
      home: LoginScreen(onSessionChange: _changeSession),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _activeScreen;
  }
}
