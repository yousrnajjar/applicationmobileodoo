import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/auth/session.dart';
import 'package:smartpay/core/data/themes.dart';
import 'package:smartpay/core/screens/home.dart';
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

  void _confirmToken(String token) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      Session session = ref.watch(sessionProvider);
      try {
        final UserInfo userInfo = await session.confirmToken(token);
        print(userInfo.info);
        ref.read(userInfoProvider.notifier).setUserInfo(userInfo);
        if (context.mounted) {
          if (userInfo.isAuthenticated()) {
            // Token successfully confirmed, navigate to home screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else {
            // Token confirmation failed, show error message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to confirm token.'),
              ),
            );
          }
        } else {
          // User cancelled token confirmation, show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Token confirmation cancelled.'),
            ),
          );
        }
      } on Exception catch (e) {
        // An error occurred, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendToken(
      String database, String email, String password) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      Session session = ref.watch(sessionProvider);
      session.dbName = database;
      session.email = email;
      session.password = password;
      try {
        final UserInfo info = await session.sendToken();
        print(info.info);
        ref.read(userInfoProvider.notifier).setUserInfo(info);
        if (context.mounted) {
          /* Show token confirmation dialog and wait for user input
          final token = await showDialog<String>(
            context: context,
            builder: (ctx) => const TokenConfirmationDialog(),
          );*/
          setState(() {
            _isTokenSend = true;
          });
        } else {
          // Login failed, show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid email or password.'),
            ),
          );
        }
      } on Exception catch (e) {
        // An error occurred, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var loginFields = [
      TextFormField(
        controller: _databaseController,
        decoration: const InputDecoration(
          labelText: 'Base de donnés',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'La base de donnée est obligatoire.';
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
          labelText: 'Token de validation',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Le token est obligatoire.';
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
                                        final database =
                                            _databaseController.text;
                                        final email = _emailController.text;
                                        final password =
                                            _passwordController.text;
                                        if (_isTokenSend) {
                                          final token = _tokenController.text;
                                          _confirmToken(token);
                                        } else {
                                          _sendToken(database, email, password);
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
