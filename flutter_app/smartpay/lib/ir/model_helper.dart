import 'package:intl/intl.dart';

/// All DTO should use this for communicate with server
abstract class OdooModelHelper {
  DateFormat dayFormatter = DateFormat('yyyy-MM-dd');

  List<String> get displayFieldNames;

  List<String> get defaultFieldNames;

  List<String> get allFields;

  Map<String, String> get onchangeSpec;

  final Map<String, dynamic> info;

  OdooModelHelper(this.info);

  OdooModelHelper.fromJson(Map<String, dynamic> data) : info = data;

  Map<String, dynamic> toJson();
}