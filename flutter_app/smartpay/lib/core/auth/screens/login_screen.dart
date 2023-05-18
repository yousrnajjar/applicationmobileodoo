import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smartpay/api/auth/session.dart';
import 'package:smartpay/core/data/themes.dart';
import 'package:smartpay/core/widgets/main_drawer.dart';
import 'package:smartpay/providers/models/user_info.dart';
import 'package:smartpay/providers/session_providers.dart';
import 'package:smartpay/providers/user_info_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _databaseController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isTokenSend = false;
  Session? _session;
  UserInfo? _userInfo;

  void _confirmToken(String token) async {
    if (!_formKey.currentState!.validate() || _session == null) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    var isAuthenticated = false;
    try {
      _userInfo = await _session!.confirmToken(token);
      isAuthenticated = _userInfo != null && _userInfo!.isAuthenticated();
      if (isAuthenticated) {
        ref.read(sessionProvider.notifier).setSession(_session!);
        ref.read(userInfoProvider.notifier).setUserInfo(_userInfo!);
        if (context.mounted) {
          // Token successfully confirmed, navigate to home screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainDrawer(userInfo: _userInfo!),
            ),
          );
        }
      } else {
        if (context.mounted) {
          // Token confirmation failed, show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Token Invalide.'),
            ),
          );
        }
      }
    } on Exception catch (e) {
      // An error occurred, show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _sendToken(String database, String email, String password) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      _session = Session(database, email, password);
      bool isTokenSend = false;
      try {
        isTokenSend = await _session!.sendToken();
      } on Exception catch (e) {
        // An error not handled occurred, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred, please contact admin: $e'),
          ),
        );
      }
      if (!isTokenSend) {
        setState(() {
          _isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Base de donnée , Login ou mots de passe incorect!'),
            ),
          );
        });
      } else if (context.mounted) {
        setState(() {
          _isLoading = false;
          _isTokenSend = isTokenSend;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Les champs pour l'authentifications
    var loginFields = [
      TextFormField(
        controller: _databaseController,
        decoration: const InputDecoration(
          labelText: 'Base de donné',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'La base de donné est obligatoire.';
          }
          return null;
        },
      ),
      const SizedBox(height: 5.0),
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Email',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Email est obligatoire .';
          }
          return null;
        },
      ),
      const SizedBox(height: 5.0),
      TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Mots de passe',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Le mots de passe est obligatire.';
          }
          return null;
        },
      ),
    ];
    var confirmTokenFields = [
      TextFormField(
        controller: _tokenController,
        decoration: const InputDecoration(
          labelText: 'Saisir votre code sécurité',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Le code de sécurité est obligatoire.';
          }
          return null;
        },
      ),
    ];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
              decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/back.jpeg"),
                fit: BoxFit.cover),
          )),
          Container(
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              gradient: LinearGradient(
                begin: FractionalOffset.topLeft,
                end: FractionalOffset.bottomRight,
                colors: [
                  kColorSchema.primary.withAlpha(155),
                  kColorSchema.primary.withOpacity(0.4),
                  kColorSchema.primary.withOpacity(0.2),
                  kColorDarkSchema.primary.withOpacity(0.1),
                ],
                stops: const [0.5, 0, 7, 1],
              ),
            ),
          ),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Form(
              key: _formKey,
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 40),
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isTokenSend)
                          ...confirmTokenFields
                        else
                          ...loginFields,
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isTokenSend)
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: () {
                                      setState(() {
                                        _isTokenSend = false;
                                      });
                                    },
                                  ),
                                  const Text("Retour"),
                                ],
                              ),
                            const SizedBox(width: 10),
                            _isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        // Perform login action here using the values from the text fields
                                        final hostUrl =
                                            _databaseController.text;
                                        final email = _emailController.text;
                                        final password =
                                            _passwordController.text;
                                        if (_isTokenSend) {
                                          final token = _tokenController.text;
                                          _confirmToken(token);
                                        } else {
                                          _sendToken(hostUrl, email, password);
                                        }
                                      }
                                    },
                                    child: Text(_isTokenSend
                                        ? 'Véfifier'
                                        : 'CONNEXION'),
                                  )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: AssetImage('assets/images/logo.jpeg'),
                          fit: BoxFit.contain),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
