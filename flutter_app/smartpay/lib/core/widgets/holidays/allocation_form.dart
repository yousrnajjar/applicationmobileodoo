/// Extend AppForm to create a form. and  customize it _setFormFields() method

import 'package:flutter/material.dart';
import 'package:smartpay/ir/views/form.dart';

import 'package:smartpay/ir/model.dart';

/// Extend base form [AppForm] for customise view rendered
/// Features:
///         * Remove title on top,
///         * Add employee_id
///         * Adding Leave type
///         * Custom view rendered
class AllocationForm extends AppForm {
  const AllocationForm({
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
    return _AllocationFormState();
  }
}

/// Extend base form [AppFormState] that is state of AppForm
class _AllocationFormState extends AppFormState {
  final Map<String, bool> _allocationType = {};

  @override
  void initState() {
    super.initState();
    var allocation = widget.initial.entries.firstWhere((element) => element.key.name == 'allocation_type');
    for (var el in allocation.key.selectionOptions){
        _allocationType[el] = allocation.value == el['value'];
    }
  }
  @override
  setValues(Map<OdooField, dynamic> newValues) {
    var res = super.setValues(newValues);
    var allocation = newValues.entries.firstWhere((element) => element.key.name == 'allocation_type');
    for (var el in allocation.key.selectionOptions){
        _allocationType[el['value']] = allocation.value == el['value'];
    }
    return res;
  }

  @override
  Widget? buildTitle() {
    return null;
  }

  @override
  setFormFields(List<Widget> formFields) {
    Map<String, Widget> groupedField = {};
    Map<OdooField, dynamic> values = super.values;
    List<Widget> allocationTypeAsCheckBox = [];
    values.forEach((field, value) {
      if (!widget.displayFieldsName.contains(field.name)) {
        return;
      }
      if (field.name == 'allocation_type') {
        allocationTypeAsCheckBox = field.selectionOptions.map((e) {
          var value = _allocationType[e['value']]!;
          return CheckboxListTile(
           // key: ObjectKey(_allocationType[]),
            value: value,
            title: Text(e['display_name'], style: const TextStyle(fontSize: 12),),
            //controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            activeColor: Theme.of(context).colorScheme.primary,
            selected: value,
            onChanged: (newValue) {
              // trigger on change for the field
              setState(() {
                _allocationType[e['value']] = !(_allocationType[e['value']]!);
                values[field] = e['value'];
                Function(Map<OdooField, dynamic>) onchange =
                    widget.onFieldChanges[field]!;
                onchange(cleanValues()).then((newValues) {
                  setValues(newValues);
                });
              });
            },
            tristate: false,
          );
        }).toList();
        return;
      }
      if (field.type == OdooFieldType.boolean) {
        groupedField[field.name] = buildBooleanField(field);
      } else if (field.type == OdooFieldType.integer) {
        groupedField[field.name] = buildIntegerField(field, value);
      } else if (field.type == OdooFieldType.float) {
        groupedField[field.name] = buildFloatField(field, value, showLabel: false);
      } else if (field.type == OdooFieldType.char) {
        groupedField[field.name] = buildCharField(field, value, false);
      } else if (field.type == OdooFieldType.text) {
        groupedField[field.name] = buildTextField(field, value, showLabel: true);
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

    /// Find Holiday Mode Display
    // value : Map<OdooField, dynamic>
    var holidayMode = values.entries
        .firstWhere((element) => element.key.name == 'holiday_type')
        .value;
    holidayMode = values.keys
        .firstWhere((element) => element.name == 'holiday_type')
        .selectionOptions
        .firstWhere((element) => element['value'] == holidayMode);
    holidayMode = holidayMode != null ? holidayMode['display_name'] : '';
    // Employee Display
    var employeeId = values.entries
        .firstWhere((element) => element.key.name == 'employee_id')
        .value;
    var employeeName = values.keys
        .firstWhere((element) => element.name == 'employee_id')
        .selectionOptions
        .firstWhere((element) => element['id'] == employeeId);
    employeeName = employeeName != null ? employeeName['name'] : '';

    // TODO: Change allocation_type from select to bool field

    formFields.addAll([
      const SizedBox(height: 10),
      groupedField['notes']!,
      const SizedBox(height: 10),
      groupedField['holiday_status_id']!,
      const SizedBox(height: 10),
      Row(children: [for (var element in allocationTypeAsCheckBox) Expanded(child: element)]),
      //groupedField['allocation_type']!,
      // Nombre de jour
      const SizedBox(height: 10),
      Row(
        children: [
          const Text('Durée', style: fontBold),
          const SizedBox(width: 10),
          SizedBox(width: 90, child: groupedField['number_of_days']!),
          const SizedBox(width: 10),
          const Text('jours', style: fontBold),
        ],
      ),
      // Employee, Mode
      Container(
          margin: const EdgeInsets.only(top: 40, bottom: 40),
          child: Column(
            children: [
              // Mode:          Par Employé
              // Salarié:       Ben Ameur Mohamed
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
