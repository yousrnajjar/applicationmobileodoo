import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ir/data/themes.dart';
import 'core/screens/holidays_screen_v2.dart' as holidays_v2;
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
    
    return MaterialApp(theme: smartpayTheme, home: activeScreen);
  }
}
