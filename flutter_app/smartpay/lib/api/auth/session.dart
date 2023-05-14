import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:smartpay/exceptions/api_exceptions.dart';
import 'package:smartpay/providers/models/user_info.dart';

abstract class AuthInterface {
  ///  Sends authentication information to Odoo and token to Odoo and returns a boolean indicating if authentication succeeded.
  Future<UserInfo?> confirmToken(String token);

  /// Sends authentication information to Odoo and returns a boolean indicating if sending token succeeded.
  Future<bool> sendToken();
}

abstract class CallInterface {
  /// Calls an Odoo endpoint with the specified data and returns the response.
  Future<dynamic> callEndpoint(String path, Map<String, dynamic> data);
  Future<dynamic> callKw(Map<String, dynamic> data);
}

class Session implements AuthInterface, CallInterface {
  /// The URL of the Odoo instance.
  String? url = dotenv.env['ODOO_INSTANCE_HOST'];

  /// The name of the database to authenticate against.
  String dbName;

  /// The email address of the user to authenticate with.
  String email;

  /// The password of the user to authenticate with.
  String password;

  /// The session ID returned by the Odoo server.
  String? sessionId;

  /// Creates a new session object with the given parameters.
  Session(this.dbName, this.email, this.password);

  @override
  Future<dynamic> callEndpoint(String path, Map<String, dynamic> data) async {
    // Ajoute le token et l'identifiant de session aux headers de la requête
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Cookie': 'session_id=$sessionId',
    };
    // Envoie la requête à Odoo
    final response = await http.post(
      Uri.parse('$url/$path'),
      headers: headers,
      body: jsonEncode({'jsonrpc': '2.0', 'params': data}),
    );

    // Vérifie si la réponse est valide
    if (response.statusCode != 200) {
      throw Exception('Failed to call endpoint: ${response.statusCode}');
    }
    // récupère le cookie de session
    if (response.headers['set-cookie'] != null) {
      sessionId = response.headers['set-cookie']!
          .split(';')
          .firstWhere((cookie) => cookie.startsWith('session_id='))
          .split('=')
          .last;
    }
    final result = jsonDecode(response.body);
    if (result.containsKey('error')) {
      final error = result['error'];
      final message = error.containsKey('data')
          ? error['data']['message']
          : error['message'];
      final errorType = (error.containsKey('data')
              ? error['data']['exception_type']
              : 'UNKNOWN_ERROR') ??
          'UNKNOWN_ERROR';
      final code = error['code'] ?? -1;
      if (code == 100 && message == 'Session expired') {
        throw OdooSessionExpiredException(message);
      } else if (code == 100) {
        throw OdooAuthentificationError(message);
      } else {
        throw OdooErrorException(errorType, message, code);
      }
    }
    return result['result'];
  }

  @override
  Future<UserInfo?> confirmToken(String token) async {
    const String path = "/web/session/authenticate/token";
    try {
      var result = await callEndpoint(path, {
        "login": email,
        "password": password,
        "token": token,
      });
      return UserInfo(result);
    } on Exception {
      return null;
    }
  }

  @override
  Future<bool> sendToken() async {
    const String path = "/web/session/authenticate2";
    try {
      await callEndpoint(path, {
        "login": email,
        "password": password,
        //"db": dbName,
      });
    } on OdooAuthentificationError {
      return false;
    }
    return true;
  }

  @override
  Future callKw(Map<String, dynamic> data) async {
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'session_id=$sessionId'
    };
    var request = http.Request('POST', Uri.parse('$url/web/dataset/call_kw'));
    request.body = json.encode({
      "jsonrpc": "2.0",
      "params": data
      /*  {
        "model": "hr.employee",
        "method": "search_read",
        "args": [
          [
            ["user_id", "=", 2]
          ],
          ["attendance_state", "name", "hours_today"]
        ],
        "kwargs": {}
      } */
    });

    request.headers.addAll(headers);

    http.Response response =
        await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      return result["result"];
    } else {
      print(response.reasonPhrase);
    }
  }
}
