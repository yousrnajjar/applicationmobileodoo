/// Extend AppForm to create a form. and  customize it _setFormFields() method

import 'package:flutter/material.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/views/form.dart';

/// Extend base form [AppForm] for customise view rendered
/// Features:
///         * Remove title on top,
///         * Add employee_id
///         * Adding Leave type
///         * Custom view rendered
class HolidayForm extends AppForm {
  const HolidayForm({
    super.key,
    required super.onSaved,
    required super.fieldNames,
    required super.initial,
    required super.onFieldChanges,
    required super.displayFieldsName,
    required super.title,
  });

  @override
  State<AppForm> createState() {
    return _HolidayFormState();
  }
}

/// Extend base form [AppFormState] that is state of AppForm
class _HolidayFormState extends AppFormState {
  @override
  Widget? buildTitle() {
    return null;
  }

  @override
  String get message => "Votre demande de congé a été bien enregistrée!";

  @override
  setFormFields(List<Widget> formFields) {
    // TODO: implement setFormFields
    Map<String, Widget> groupedField = {};
    Map<OdooField, dynamic> values = super.values;
    values.forEach((field, value) {
      if (!widget.displayFieldsName.contains(field.name)) {
        return;
      }
      if (field.type == OdooFieldType.boolean) {
        groupedField[field.name] = buildBooleanField(field);
      } else if (field.type == OdooFieldType.integer) {
        groupedField[field.name] = buildIntegerField(field, value);
      } else if (field.type == OdooFieldType.float) {
        groupedField[field.name] =
            buildFloatField(field, value, showLabel: false);
      } else if (field.type == OdooFieldType.char) {
        groupedField[field.name] = buildCharField(field, value, false);
      } else if (field.type == OdooFieldType.text) {
        groupedField[field.name] =
            buildTextField(field, value, showLabel: true);
      } else if (field.type == OdooFieldType.date) {
        groupedField[field.name] = buildDateField(field, value, false, false);
      } else if (field.type == OdooFieldType.datetime) {
        groupedField[field.name] = buildDateTimeField(field, value);
      } else if (field.type == OdooFieldType.selection) {
        groupedField[field.name] = buildSelectionField(field, value);
      } else if (field.type == OdooFieldType.many2one) {
        groupedField[field.name] = buildMany2oneField(field, value);
      } /*else if (field.type == OdooFieldType.one2many) {
         groupedField[field.name] =  _buildOne2manyField(field, value);
      } else if (field.type == OdooFieldType.many2many) {
         groupedField[field.name] =  _buildMany2manyField(field, value);
      }*/
    });
    const fontBold = TextStyle(fontWeight: FontWeight.bold);
    // value : Map<OdooField, dynamic>
    var holidayMode = values.entries
        .firstWhere((element) => element.key.name == 'holiday_type')
        .value;
    holidayMode = values.keys
        .firstWhere((element) => element.name == 'holiday_type')
        .selectionOptions
        .firstWhere((element) => element['value'] == holidayMode);
    holidayMode = holidayMode != null ? holidayMode['display_name'] : '';
    var employeeId = values.entries
        .firstWhere((element) => element.key.name == 'employee_id')
        .value;
    var employeeNames = values.keys
        .firstWhere((element) => element.name == 'employee_id')
        .selectionOptions;
    String employeeName = '';
    for (var employeeName in employeeNames) {
      if (employeeName['id'] == employeeId) {
        employeeName = employeeName;
        break;
      }
    }

    formFields.addAll([
      groupedField['holiday_status_id']!,
      const SizedBox(height: 10),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Période', style: fontBold),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.only(top: 15),
                        child: const Text('De', style: fontBold)),
                    const SizedBox(width: 10),
                    SizedBox(
                        width: 120, child: groupedField['request_date_from']!),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.only(top: 15),
                        child: const Text('À', style: fontBold)),
                    const SizedBox(width: 10),
                    SizedBox(
                        width: 120, child: groupedField['request_date_to']!),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 10),
      buildComonField(
        labelWidth: 35,
        label: const Text('Durée', style: fontBold),
        child: groupedField['number_of_days']!,
        prefix: const Text('jours', style: fontBold),
      ),
      /*Row(
        children: [
          const Text('Durée', style: fontBold),
          const SizedBox(width: 10),
          SizedBox(width: 90, child: groupedField['number_of_days']!),
          const SizedBox(width: 10),
          const Text('jours', style: fontBold),
        ],
      ),*/
      groupedField['notes']!,
      Container(
          margin: const EdgeInsets.only(top: 40, bottom: 40),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 100,
                    child: Text('Mode:', style: fontBold),
                  ),
                  Text(holidayMode),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(
                    width: 100,
                    child: Text('Salarié:', style: fontBold),
                  ),
                  Text(employeeName),
                ],
              ),
            ],
          )),
    ]);
  }
}
