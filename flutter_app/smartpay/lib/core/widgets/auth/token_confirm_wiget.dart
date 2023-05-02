import 'package:flutter/material.dart';

class TokenConfirmationDialog extends StatefulWidget {
  const TokenConfirmationDialog({Key? key}) : super(key: key);

  @override
  State<TokenConfirmationDialog> createState() =>
      _TokenConfirmationDialogState();
}

class _TokenConfirmationDialogState extends State<TokenConfirmationDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tokenController;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmation du Token'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Veuillez entrer le Token envoyé par email'),
              TextFormField(
                controller: _tokenController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un Token valide';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Annuler'),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        ),
        ElevatedButton(
          child: const Text('Confirmer'),
          onPressed: () {
            Navigator.of(context).pop(_tokenController.text);
          },
        ),
      ],
    );
  }
}
