import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:smartpay/exceptions/api_exceptions.dart';
import 'package:smartpay/ir/models/user_info.dart';

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

  int? uid;
  /// The session ID returned by the Odoo server.
  String? sessionId;

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
  Future<UserInfo?> confirmToken(String token) async {
    const String path = "web/session/authenticate/token";
    try {
      var result = await callEndpoint(path, {
        "login": email,
        "password": password,
        "token": token,
        "db": dbName,
      });
      return UserInfo(result);
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
      return returnFullResponce ? result: result["result"];
    } else {
      if (kDebugMode) {
        print("Response");
        print(response.statusCode);
        print(response.reasonPhrase);
      }
    }
  }

  Future<List<dynamic>> searchRead(String model, List<dynamic> domain,
      List<dynamic> fields, int? limit, int? offset) async {
    return await callKw({
      "model": model,
      "method": "search_read",
      "args": [domain, fields],
      "kwargs": {
        if (limit != null) "limit": limit,
        if (offset != null) "offset": offset,
        "context": defaultContext
      }
    });
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
    /*valuesMap = {
      // Values
      //"id": "hr.leave(<NewId 0x7fb9d9302b00>,)", // NewId
      "state": "confirm",
      "holiday_type": "employee",
      "date_from": "2023-05-21 08:09:11",
      "date_to": "2023-05-21 08:09:11",
      "request_date_from_period": "pm",
      "user_id": 6,
      "employee_id": 7,
      "request_date_from": "2023-05-21",
      "request_date_to": "2023-05-21",
      "holiday_status_id": 1
    };
    fieldNames = ["request_date_from_period"];
    onchangeSpec = {
      // field_onchange
      "can_reset": "", "can_approve": "", "state": "1", "tz": "1",
      "tz_mismatch": "", "holiday_type": "1",
      "leave_type_request_unit": "", "display_name": "",
      "holiday_status_id": "1", "date_from": "1", "date_to": "1",
      "request_date_from": "1", "request_date_to": "1",
      "request_date_from_period": "1", "request_unit_half": "1",
      "request_unit_hours": "1", "request_unit_custom": "1",
      "request_hour_from": "1", "request_hour_to": "1",
      "number_of_days_display": "", "number_of_days": "1",
      "number_of_hours_display": "", "user_id": "",
      "employee_id": "1", "department_id": "1", "name": "1",
      "message_follower_ids": "", "activity_ids": "",
      "message_ids": "", "message_attachment_count": ""
    };

    var result = await callKw({
      "model": "hr.leave",
      "method": "onchange",
      "args": [
        [
          // self
        ],
        {
          // Values
          //"id": "hr.leave(<NewId 0x7fb9d9302b00>,)", // NewId
          "state": "confirm",
          "holiday_type": "employee",
          "date_from": "2023-05-21 08:09:11",
          "date_to": "2023-05-21 08:09:11",
          "request_date_from_period": "pm",
          "user_id": 6,
          "employee_id": 7,
          "request_date_from": "2023-05-21",
          "request_date_to": "2023-06-21",
          "holiday_status_id": 1
        },
        ["request_date_to"], // field_name
        {
          // field_onchange
          "can_reset": "", "can_approve": "", "state": "1", "tz": "1",
          "tz_mismatch": "", "holiday_type": "1",
          "leave_type_request_unit": "", "display_name": "",
          "holiday_status_id": "1", "date_from": "1", "date_to": "1",
          "request_date_from": "1", "request_date_to": "1",
          "request_date_from_period": "1", "request_unit_half": "1",
          "request_unit_hours": "1", "request_unit_custom": "1",
          "request_hour_from": "1", "request_hour_to": "1",
          "number_of_days_display": "", "number_of_days": "1",
          "number_of_hours_display": "", "user_id": "",
          "employee_id": "1", "department_id": "1", "name": "1",
          "message_follower_ids": "", "activity_ids": "",
          "message_ids": "", "message_attachment_count": ""
        }
      ],
      "kwargs": {
        "context": {"lang": "fr_FR" /*"tz":*/}
      }
    });
    return result;*/
    var result =  await callKw({
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
}
