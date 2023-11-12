import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:smartpay/exceptions/api_exceptions.dart';
import 'package:smartpay/ir/models/user.dart';

abstract class AuthInterface {
  ///  Sends authentication information to Odoo and token to Odoo and returns a boolean indicating if authentication succeeded.
  Future<User?> confirmToken(String token);

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

  int? uid;

  /// The session ID returned by the Odoo server.
  String? sessionId;

  String? serverTimezoneName;
  String? serverTimeZoneOffset; // '+0200'

  /// Get the language from current platform
  String get lang {
    return "fr_FR";
  }

  /// Get current timezone from current platform
  String get tz {
    return DateTime.now().timeZoneName;
  }

  Map<String, dynamic> get defaultContext {
    return {
      'lang': lang,
      'tz': tz,
    };
  }

  /// Creates a new session object with the given parameters.
  Session(this.dbName, this.email, this.password);

  @override
  Future<dynamic> callEndpoint(String path, Map<String, dynamic> data) async {
    // Ajoute le token et l'identifiant de session aux headers de la requête
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Cookie': 'session_id=$sessionId',
    };
    //FixMe: add context to data
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
  Future<User?> confirmToken(String token) async {
    const String path = "web/session/authenticate/token";
    try {
      var result = await callEndpoint(path, {
        "login": email,
        "password": password,
        "token": token,
        "db": dbName,
      });
      return User(result);
    } on Exception {
      return null;
    }
  }

  @override
  Future<bool> sendToken() async {
    const String path = "web/session/authenticate2";
    try {
      await callEndpoint(path, {
        "login": email,
        "password": password,
        "db": dbName,
      });
    } on OdooAuthentificationError {
      return false;
    }
    return true;
  }

  @override
  Future callKw(Map<String, dynamic> data, {returnFullResponce=false}) async {
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'session_id=$sessionId'
    };
    var request = http.Request('POST', Uri.parse('$url/web/dataset/call_kw'));
    request.body = json.encode({"jsonrpc": "2.0", "params": data});

    request.headers.addAll(headers);

    http.Response response =
        await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      Map<String, dynamic> result = jsonDecode(response.body);
      if (result.containsKey('error')) {
        final error = result['error'];
        final message = error.containsKey('data')
            ? error['data']['message']
            : error['message'];
        final errorType = (error.containsKey('data')
                ? error['data']['exception_type']
                : 'UNKNOWN_ERROR') ??
            'UNKNOWN_ERROR';
        if (errorType == 'validation_error') {
          throw OdooValidationError(errorType, message, 200);
        } else {
          
          throw OdooErrorException(errorType, message, 200);
        }
      }
      return returnFullResponce ? result : result["result"];
    } else {
      if (kDebugMode) {
        print("Response");
        print(response.statusCode);
        print(response.reasonPhrase);
      }
    }
  }

  Future<List<Map<String, dynamic>>> searchRead(
      String model,
      List<dynamic> domain,
      List<dynamic> fields,
      int? limit,
      int? offset,
      String? order) async {
    var res = await callKw({
      "model": model,
      "method": "search_read",
      "args": [domain, fields],
      "kwargs": {
        if (limit != null) "limit": limit,
        if (offset != null) "offset": offset,
        if (order != null) "order": order,
        "context": defaultContext
      }
    });
    return [for (var r in res) r as Map<String, dynamic>];
  }

  Future<dynamic> searchCount(String model, List<dynamic> domain) async {
    return await callKw({
      "model": model,
      "method": "search_count",
      "args": [domain],
      "kwargs": {"context": defaultContext}
    });
  }

  /// Each odoo model has an default_get method that returns the default values for the fields.
  Future<Map<String, dynamic>> defaultGet(
      String model, List<dynamic> fields) async {
    var result = await callKw({
      "model": model,
      "method": "default_get",
      "args": [fields],
      "kwargs": {"context": defaultContext}
    });
    return result;
  }

  /// handle onchange method of odoo model
  /// args: modelName, idList, valuesMap, fieldNames, onchangeSpec)
  Future<dynamic> onchange(
      String model,
      List<dynamic> idList,
      Map<String, dynamic> valuesMap,
      List<dynamic> fieldNames,
      Map<String, dynamic> onchangeSpec) async {
    var result = await callKw({
      "model": model,
      "method": "onchange",
      "args": [idList, valuesMap, fieldNames, onchangeSpec],
      "kwargs": {"context": defaultContext}
    }); 
    return result;
  }

  /// create a new record
  Future<dynamic> create(String model, Map<String, dynamic> values) async {
    var result =  await callKw({
      "model": model,
      "method": "create",
      "args": [values],
      "kwargs": {"context": defaultContext}
    }, returnFullResponce: true);
    return result["result"];
  }

  /// update a records
  Future<dynamic> write(
      String model, List<dynamic> idList, Map<String, dynamic> values) async {
    return await callKw({
      "model": model,
      "method": "write",
      "args": [idList, values],
      "kwargs": {"context": defaultContext}
    });
  }

  /// Convert a DateTime to the server timezone
  DateTime toServerTime(DateTime dateTime) {
    if (kDebugMode) {
      print(
          "Server Time Zone: $serverTimeZoneOffset, Current Time Zone: ${dateTime.timeZoneOffset}");
      print(
          "Server Time Zone Name: $serverTimezoneName, Current Time Zone Name: ${dateTime.timeZoneName}");
    }
    String offset = serverTimeZoneOffset ?? '+0000';
    int hours = int.parse(offset.substring(1, 3));
    int minutes = int.parse(offset.substring(3, 5));
    if (offset.startsWith('-')) {
      hours = -hours;
      minutes = -minutes;
    }
    // Check current timezone
    var now = DateTime.now();
    var localOffset = now.timeZoneOffset;
    var diff = localOffset - Duration(hours: hours, minutes: minutes);
    return dateTime.subtract(diff);
  }

  // Convert a DateTime from the server timezone to the local timezone
  DateTime fromServerTime(DateTime dateTime) {
    if (kDebugMode) {
      print(
          "Server Time Zone: $serverTimeZoneOffset, Current Time Zone: ${dateTime.timeZoneOffset}");
      print(
          "Server Time Zone Name: $serverTimezoneName, Current Time Zone Name: ${dateTime.timeZoneName}");
    }
    String offset = serverTimeZoneOffset ?? '+0000';
    int hours = int.parse(offset.substring(1, 3));
    int minutes = int.parse(offset.substring(3, 5));
    if (offset.startsWith('-')) {
      hours = -hours;
      minutes = -minutes;
    }
    // Check current timezone
    var now = DateTime.now();
    var localOffset = now.timeZoneOffset;
    var diff = localOffset - Duration(hours: hours, minutes: minutes);
    return dateTime.add(diff);
  }
  
  DateTime toLocalTime(DateTime dateTimeUtc) {
    var now = DateTime.now();
    var localOffset = now.timeZoneOffset;
    var diff = localOffset - const Duration(hours: 0, minutes: 0);
    return dateTimeUtc.add(diff);
  }
}
