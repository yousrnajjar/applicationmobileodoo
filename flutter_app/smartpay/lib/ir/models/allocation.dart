import 'package:intl/intl.dart';

class AllocationType {
  final Map<String, dynamic> data;

  AllocationType(this.data);

  get id => data["id"] ?? -1;

  String get name {
    return data["name"] ?? "Sans nom";
  }
}

final dayFormatter = DateFormat('yyyy-MM-dd');

class Allocation {
  /// model from hr.leave in odoo build for flutter app
  ///
  static List<String> defaultFields = [
    "can_reset",
    "can_approve",
    "holiday_type",
    "state",
    "leaves_taken",
    "max_leaves",
    "display_name",
    "type_request_unit",
    "name",
    "holiday_status_id",
    "allocation_type",
    "number_of_days",
    "number_of_days_display",
    "number_of_hours_display",
    "employee_id",
    "department_id",
    "notes",
  ];

  static List<String> allFields = [
    ...defaultFields,
    "id",
    "message_attachment_count",
    "message_follower_ids",
    "activity_ids",
    "message_ids",
  ];

  static List<String> displayFieldNames = [
      'holiday_status_id', // Type de congé
      'number_of_days', // Durée 
      //'holiday_type', // Mode
      'allocation_type', // Type d'allocation
      'notes', // Description
      //'employee_id', // Salarié
    ];
  List<String> get editableFields => [
      'holiday_status_id', // Type de congé
      'number_of_days', // Durée 
      //'holiday_type', // Mode
      'allocation_type', // Type d'allocation
      'notes', // Description
      //'employee_id', // Salarié
    ];
  ///Onchange spec for hr.leave
  static Map<String, String> onchangeSpec = {
    'can_reset': '',
    'can_approve': '',
    'holiday_type': '1',
    'state': '1',
    'leaves_taken': '',
    'max_leaves': '',
    'display_name': '',
    'type_request_unit': '',
    'name': '1',
    'holiday_status_id': '1',
    'allocation_type': '',
    'number_of_days': '1',
    'number_of_days_display': '1',
    'number_of_hours_display': '1',
    'employee_id': '1',
    'department_id': '1',
    'notes': '',
    'message_follower_ids': '',
    'activity_ids': '',
    'message_ids': '',
    'message_attachment_count': ''
  };

  Allocation();
}
