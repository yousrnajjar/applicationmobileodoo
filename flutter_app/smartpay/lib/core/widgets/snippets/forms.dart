import 'package:flutter/material.dart';

class FormSnippet extends StatelessWidget {
  final Widget mainContaint;

  final String title;

  const FormSnippet({
    super.key,
    required this.mainContaint,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(30),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 18,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
              ),
            ),
            mainContaint
          ],
        ),
      ),
    );
  }
}
