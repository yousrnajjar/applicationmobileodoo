import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/core/data/themes.dart';
import 'package:smartpay/core/auth/screens/login_screen.dart';
import 'package:smartpay/core/screens/home.dart';
import 'package:smartpay/providers/user_info_providers.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: SmartPay()));
}

class SmartPay extends ConsumerWidget {
  const SmartPay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget activeScreen = const HomeScreen();
    var userInfo = ref.watch(userInfoProvider);
    if (!userInfo.isAuthenticated()) {
      activeScreen = const LoginScreen();
    }
    return MaterialApp(theme: smartpayTheme, home: activeScreen);
  }
}
