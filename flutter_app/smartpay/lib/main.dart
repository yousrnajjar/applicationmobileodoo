import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smartpay/api/auth/session.dart';
import 'package:smartpay/core/data/themes.dart';
import 'package:smartpay/core/screens/auth/login_screen.dart';

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

  SmartPay({super.key, this.session});

  void _changeSession(Session session) {
    this.session = session;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartPay Mobile',
      theme: theme,
      home: LoginScreen(onSessionChange: _changeSession),
    );
  }
}
