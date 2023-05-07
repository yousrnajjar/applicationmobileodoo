import 'package:flutter/material.dart';

class CheckInOut extends StatelessWidget {
  const CheckInOut({super.key});

  @override
  Widget build(BuildContext context) {
    bool employeeIn = true;
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text((employeeIn) ? 'Se Déconnecter' : 'Se Connecter'),
            Center(
                child: Container(
              color: Theme.of(context).colorScheme.secondary,
              width: 200,
              height: 200,
              child: IconButton(
                  icon: (employeeIn)
                      ? const Icon(Icons.login, color: Colors.white, size: 100)
                      : const Icon(Icons.logout, color: Colors.white, size: 100),
                  onPressed: _sign),
            )),
          ],
        ),
      );
  }

  void _sign() {
  }
}