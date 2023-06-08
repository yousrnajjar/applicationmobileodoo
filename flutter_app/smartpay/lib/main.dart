import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

import 'ir/data/themes.dart';
import 'core/screens/login_screen.dart';
import 'core/widgets/main_drawer.dart';
import 'core/providers/user_info_providers.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: SmartPay()));
}

class SmartPay extends ConsumerWidget {
  const SmartPay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var userInfo = ref.watch(userInfoProvider);
    Widget activeScreen;
    if (!userInfo.isAuthenticated()) {
      activeScreen = const LoginScreen();
    } else {
      activeScreen = MainDrawer(user: userInfo);
    }
    var appTheme =  smartpayTheme;
    return MaterialApp(
      theme: appTheme,
      title: 'SmartPay',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        SfGlobalLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('fr', 'FR'),
      ],
      locale: const Locale('fr', 'FR'),
      home: activeScreen
    );
  }
}
