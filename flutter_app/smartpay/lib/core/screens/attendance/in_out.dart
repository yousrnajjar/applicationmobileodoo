import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InOutScreen extends ConsumerStatefulWidget {
  const InOutScreen({super.key});

  @override
  ConsumerState<InOutScreen> createState() => _InOutScreenState();
}

class _InOutScreenState extends ConsumerState<InOutScreen> {
  late bool _employeeIn;

  @override
  void initState() {
    super.initState();
    _employeeIn = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("In Out"), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.sync),
          onPressed: _checkEmployeeState,
        ),
      ]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text((_employeeIn) ? 'Se Déconnecter' : 'Se Connecter'),
            Center(
                child: Container(
              color: Theme.of(context).colorScheme.secondary,
              width: 200,
              height: 200,
              child: IconButton(
                  icon: (_employeeIn)
                      ? const Icon(Icons.login, color: Colors.white, size: 100)
                      : const Icon(Icons.logout,
                          color: Colors.white, size: 100),
                  onPressed: _sign),
            )),
          ],
        ),
      ),
    );
  }

  void _checkEmployeeState() {}

  void _sign() {}
}
