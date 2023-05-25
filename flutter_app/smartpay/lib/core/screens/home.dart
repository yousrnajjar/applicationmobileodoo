import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/ir/models/user_info.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final User user;
  const HomeScreen(
    this.user, {
    super.key,
  });

  @override
  ConsumerState<HomeScreen> createState() {
    return _HomeState();
  }
}

class _HomeState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Bienvenue ${widget.user.name}", style: Theme.of(context).textTheme.bodyLarge,));
  }
}
