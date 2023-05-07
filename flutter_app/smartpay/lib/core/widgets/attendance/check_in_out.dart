import 'package:flutter/material.dart';

class CheckInOut extends StatelessWidget {
  const CheckInOut({super.key});

  @override
  Widget build(BuildContext context) {
    bool employeeIn = true;
    double boxWith = 350;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 80,
                    width: boxWith,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      gradient: LinearGradient(
                          begin: FractionalOffset.topLeft,
                          end: FractionalOffset.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.secondary,
                            Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.5),
                          ]),
                    ),
                  ),
                  Center(
                    child: Container(
                      color: Theme.of(context).colorScheme.background,
                      width: boxWith,
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 30),
                      child: Column(
                        children: [
                          Text(
                            "Micheal Admin",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            "Vous souhaitez partir?",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Heure de travail aujourd'hui: 05:00",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .color!
                                        .withAlpha(100)),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color:
                                  employeeIn ? Colors.amber : Colors.redAccent,
                            ),
                            child: IconButton(
                              icon: (employeeIn)
                                  ? const Icon(Icons.logout,
                                      color: Colors.black, size: 50)
                                  : const Icon(Icons.login,
                                      color: Colors.black, size: 50),
                              onPressed: _sign,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 60,
                margin: const EdgeInsets.only(top: 40),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: AssetImage('assets/images/admin.jpeg'),
                      fit: BoxFit.contain),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _sign() {}
}
