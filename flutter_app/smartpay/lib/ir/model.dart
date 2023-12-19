import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartpay/api/session.dart';
import 'package:smartpay/exceptions/api_exceptions.dart';
import 'package:smartpay/ir/views/form.dart';

/// Represent an odoo Field Type
enum OdooFieldType {
  string,
  integer,
  float,
  boolean,
  date,
  datetime,
  binary,
  text,
  html,
  many2one,
  one2many,
  many2many,
  reference,
  selection,
  related,
  function,
  char,
  time,
  binaryImage,
  binaryFile,
  serialized,
  monetary,
  unknown,
}

/// Class to represent an Odoo field
class OdooField {
  dynamic id;
  dynamic name;
  dynamic displayName;
  dynamic depends;
  dynamic domain;
  dynamic fieldDescription;
  dynamic help;
  dynamic model;
  dynamic modelId;
  dynamic relation;
  dynamic readonly;
  dynamic isRequired;
  dynamic isSelectable;
  dynamic selectionIds;
  dynamic size;
  dynamic state;
  dynamic ttype;

  static List<String> allProperties() {
    return [
      "id",
      "name",
      "display_name",
      "depends",
      "domain",
      "field_description",
      "help",
      "model",
      "model_id",
      "relation",
      "readonly",
      "required",
      "selectable",
      "selection_ids",
      "size",
      "state",
      "ttype",
    ];
  }

  OdooField.fromMap(Map<String, dynamic> data)
      : id = data["id"],
        name = data["name"],
        displayName = data["display_name"],
        depends = data["depends"],
        domain = data["domain"],
        fieldDescription = data["field_description"],
        help = data["help"],
        model = data["model"],
        modelId = data["model_id"],
        relation = data["relation"],
        readonly = data["readonly"],
        isRequired = data["required"],
        isSelectable = data["selectable"],
        selectionIds = data["selection_ids"],
        size = data["size"],
        state = data["state"],
        ttype = data["ttype"];

  OdooFieldType get type {
    /// Return the type of the field
    switch (ttype) {
      case "char":
        return OdooFieldType.string;
      case "integer":
        return OdooFieldType.integer;
      case "float":
        return OdooFieldType.float;
      case "boolean":
        return OdooFieldType.boolean;
      case "date":
        return OdooFieldType.date;
      case "datetime":
        return OdooFieldType.datetime;
      case "binary":
        return OdooFieldType.binary;
      case "text":
        return OdooFieldType.text;
      case "html":
        return OdooFieldType.html;
      case "many2one":
        return OdooFieldType.many2one;
      case "one2many":
        return OdooFieldType.one2many;
      case "many2many":
        return OdooFieldType.many2many;
      case "reference":
        return OdooFieldType.reference;
      case "selection":
        return OdooFieldType.selection;
      case "related":
        return OdooFieldType.related;
      case "function":
        return OdooFieldType.function;
      case "time":
        return OdooFieldType.time;
      case "binary_image":
        return OdooFieldType.binaryImage;
      case "binary_file":
        return OdooFieldType.binaryFile;
      case "serialized":
        return OdooFieldType.serialized;
      case "monetary":
        return OdooFieldType.monetary;
      default:
        return OdooFieldType.unknown;
    }
  }

  /// Selections fields Options for selection fields
  List<dynamic> selectionOptions = [];
}

class OdooModel {
  /// Class to help with Odoo models
  /*static final Map<String, String> onchangeSpec = {};
  static final List<String> defaultFields = [];*/

  /// Odoo session
  static Session session = Session(password: '', email: '');

  /// Unique name of the model (e.g. "hr.leave")
  final String modelName;

  OdooModel(this.modelName);

  /// Get all fields Names for the model
  Future<List<Map<String, dynamic>>> getAllFieldAsString(
      {List<String>? fieldNames}) async {
    /// List of fields for the model
    var domain = [
      ["model", "=", modelName],
      if (fieldNames != null && fieldNames.isNotEmpty)
        ['name', 'in', fieldNames]
    ];
    var fields = OdooField.allProperties();
    int limit = 1000;
    int offset = 0;
    var result = await session.searchRead(
        "ir.model.fields", domain, fields, limit, offset, null);
    return result;
  }

  /// Get all fields for the model
  Future<List<OdooField>> getAllFields({List<String>? fieldNames}) async {
    var records = await getAllFieldAsString(fieldNames: fieldNames);
    var result = <OdooField>[];
    for (var record in records) {
      var field = OdooField.fromMap(record);
      if (field.type == OdooFieldType.selection) {
        field.selectionOptions = await session.searchRead(
            "ir.model.fields.selection",
            [
              ['field_id', "=", field.id]
            ],
            ['id', 'display_name', 'name', 'value'],
            1000,
            0,
            null);
      } else if (field.type == OdooFieldType.many2one) {
        try {
          field.selectionOptions = await session.searchRead(
              field.relation,
              [if (field.domain != false) field.domain],
              ['id', 'name'],
              1000,
              0,
              null);
        } on OdooErrorException catch (e) {
          if (e.errorType == "access_error") {
            field.selectionOptions = []; //FixMe: Why?
          } else {
            rethrow;
          }
        }
      }
      result.add(field);
    }

    return result;
  }

  /// Search and read records (all fields) from the model
  Future<List<Map<String, dynamic>>> searchRead(
      {required List<dynamic> domain,
      int limit = 1000,
      int offset = 1,
      String? order,
      List<String>? fieldNames}) async {
    if (fieldNames == null) {
      var allFieldRaw = await getAllFieldAsString(fieldNames: fieldNames);
      fieldNames = allFieldRaw.map((e) => e['name'].toString()).toList();
    }
    var result = await session.searchRead(
        modelName, domain, fieldNames, limit, null, order);
    return result;
  }

  /// Search and read records (all fields) from the model
  /// and return a list of Map<Odoofield, dynamic> using  [searchRead]
  Future<List<Map<OdooField, dynamic>>> searchReadAsOdooField(
      {required List<dynamic> domain,
      int limit = 1000,
      int offset = 1,
      List<String>? fieldNames}) async {
    var result = await searchRead(
        domain: domain, limit: limit, offset: offset, fieldNames: fieldNames);
    var allFields = await getAllFields(fieldNames: fieldNames);
    List<OdooField> odooFields =
        allFields.where((field) => fieldNames!.contains(field.name)).toList();
    List<Map<OdooField, dynamic>> resultAsOdooField = [];
    for (var record in result) {
      Map<OdooField, dynamic> recordAsOdooField = {};
      for (var field in odooFields) {
        var value = record[field.name];
        recordAsOdooField[field] = value;
      }
      resultAsOdooField.add(recordAsOdooField);
    }
    return resultAsOdooField;
  }

  /// It should return a map with the default values for the model
  /// Key is the field [OdooField] and value is the default value
  Future<Map<OdooField, dynamic>> defaultGet(
      List<String> fieldNames, Map<String, String> onChangeSpec) async {
    Map<String, dynamic> defaultValue =
        await session.defaultGet(modelName, fieldNames);
    var allFields = await getAllFields(fieldNames: fieldNames);
    List<OdooField> odooFields =
        allFields.where((field) => fieldNames.contains(field.name)).toList();
    Map<OdooField, dynamic> result = {};
    for (var field in odooFields) {
      var value = defaultValue[field.name];
      result[field] = value;
    }
    // Trigger onchange if onchangeSpec is not empty
    result = await onchange(odooFields, result, onChangeSpec);
    return result;
  }

  /// Create a new record
  Future<Map<OdooField, dynamic>> create(Map<OdooField, dynamic> values) async {
    Map<String, dynamic> valuesMap = {};
    for (var field in values.keys) {
      if ([OdooFieldType.many2one].contains(field.type)) {
        try {
          valuesMap[field.name] = values[field][0];
        } catch (e) {
          valuesMap[field.name] = values[field];
        }
      } else {
        valuesMap[field.name] = values[field];
      }
    }
    int id = await session.create(modelName, valuesMap);
    if (kDebugMode) {
      print("OdooModel.create: id = $id");
    }
    List<dynamic> datas = await session.searchRead(
        modelName,
        [
          ["id", "=", id],
        ],
        valuesMap.keys.toList(),
        1,
        0,
        null);
    bool idExists = false;
    // Update values with the new data
    for (var field in values.keys) {
      values[field] = datas[0][field.name];
      if (field.name == "id") {
        idExists = true;
      }
    }
    //values[OdooField.fromMap({"name": "id", "ttype": "integer", "readonly": true})] = id;
    if (!idExists) {
      values[OdooField.fromMap({
        "name": "id",
        "ttype": "integer",
        "readonly": true
      })] = id;
    }
    return values;
  }

  /// Handle onchange events
  /// [idList]: list of ids of the record
  /// [values]: map of values to change
  /// [fields]: list of fields that are changed
  /// It use [onchangeSpec] to handle onchange events
  /// It returns a map of changed values
  Future<Map<OdooField, dynamic>> onchange(
      List<OdooField> changedFields,
      Map<OdooField, dynamic> currentValues,
      Map<String, dynamic> onchangeSpec) async {
    // Check if onchangeSpec is empty
    if (onchangeSpec.isEmpty) {
      return {};
    }

    // Build valuesMap that contains only the field name and its value
    Map<String, dynamic> valuesMap = {};
    for (var field in currentValues.keys) {
      valuesMap[field.name] = currentValues[field];
    }
    // Build fieldNames that contains only the field name
    List<String> fieldNames =
        changedFields.map((field) => "${field.name}").toList();
    // Call onchange
    List<int> idList = [];
    Map<String, dynamic> result = await session.onchange(
        modelName, idList, valuesMap, fieldNames, onchangeSpec);
    // Map result to OdooField
    /*var allFields = await getAllFields();
    List<OdooField> odooFields =
        allFields.where((field) => fieldNames.contains(field.name)).toList();*/
    for (var field in currentValues.keys) {
      for (var name in result['value'].keys) {
        if (field.name == name) {
          currentValues[field] = result['value'][name];
        }
      }
    }
    return currentValues;
  }

  /// Build the form fields for editing the holiday
  ///
  Future<Widget> buildFormFields(
      {required List<String> fieldNames,
      required List<String> displayFieldNames,
      required Map<String, String> onChangeSpec,
      required String formTitle}) async {
    Map<OdooField, dynamic> initial =
        await defaultGet(fieldNames, onChangeSpec);
    Map<OdooField,
            Future<Map<OdooField, dynamic>> Function(Map<OdooField, dynamic>)>
        onFieldChanges = {};
    for (OdooField field in initial.keys) {
      onFieldChanges[field] = (Map<OdooField, dynamic> currentValues) async {
        return await onchange([field], currentValues, onChangeSpec);
      };
    }

    return AppForm(
      key: ObjectKey(this),
      fieldNames: fieldNames,
      initial: initial,
      onFieldChanges: onFieldChanges,
      displayFieldsName: displayFieldNames,
      title: formTitle,
      onSaved: (Map<OdooField, dynamic> values) async {
        return await create(values);
      },
    );
  }

  /// FixMe : Remove This
  Future<Widget> getForm(
      {required OdooModel odooModel,
      required List<String> fieldNames,
      required Map<OdooField, dynamic> initial,
      required Map<OdooField,
              Future<Map<OdooField, dynamic>> Function(Map<OdooField, dynamic>)>
          onFieldChanges,
      required List<String> displayFieldsName,
      required String title,
      required Future<Map<OdooField, dynamic>> Function(
              Map<OdooField, dynamic> values)
          onSaved}) async {
    return const Text("No form yet");
  }

  /// Render PDF report
  static Future<dynamic> renderPdfReport({
    required String reportName,
    required List<int> resourceIds,
  }) async {
    var reportIds = await OdooModel('ir.actions.report').searchRead(
      domain: [
        ['report_name', '=', reportName]
      ],
      fieldNames: ['id'],
      limit: 1,
    );
    if (reportIds.isEmpty) {
      throw Exception("Report $reportName not found");
    }
    var reportId = reportIds[0]['id'];
    var result = await OdooModel.session.callKw({
      'model': 'ir.actions.report',
      'method': 'render_qweb_pdf',
      'args': [
        [reportId]
      ],
      'kwargs': {'res_ids': resourceIds}
    });
    // print type of data
    if (result[1] != 'pdf') {
      throw Exception("PDF Report $reportName not found");
    }
    var bytes = result[0];
    return bytes;
  }
}
