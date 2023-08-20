/// Extend AppForm to create a form. and  customize it _setFormFields() method

import 'package:flutter/material.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/expense.dart';
import 'package:smartpay/ir/views/form.dart';

/// Extend base form [AppForm] for customise view rendered
/// Features:
///         * Remove title on top,
///         * Add employee_id
///         * Adding Leave type
///         * Custom view rendered
class ExpenseFormWidget extends AppForm {
  const ExpenseFormWidget({
    super.key,
    super.onCancel,
    required super.onSaved,
    required super.fieldNames,
    required super.initial,
    required super.onFieldChanges,
    required super.displayFieldsName,
    required super.title,
    super.editable,
    super.editableFields,
    super.id,
    super.model,
  });

  @override
  State<AppForm> createState() {
    return _ExpenseFormState();
  }

  static Future<Widget> buildExpenseForm(
      {required dynamic Function() onCancel,
      Function(Expense)? afterSave,
      int? id,
      bool? editable}) async {
    var fieldNames = Expense({}).allFields;
    var displayFieldNames = Expense({}).displayFieldNames;
    var onChangeSpec = Expense({}).onchangeSpec;
    var formTitle = "";
    var model = OdooModel("hr.expense");

    Map<OdooField, dynamic> initial =
        await model.defaultGet(fieldNames, onChangeSpec);
    Map<OdooField,
            Future<Map<OdooField, dynamic>> Function(Map<OdooField, dynamic>)>
        onFieldChanges = {};
    for (OdooField field in initial.keys) {
      onFieldChanges[field] = (Map<OdooField, dynamic> currentValues) async {
        return await model.onchange([field], currentValues, onChangeSpec);
      };
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ExpenseFormWidget(
        fieldNames: fieldNames,
        initial: initial,
        onFieldChanges: onFieldChanges,
        displayFieldsName: displayFieldNames,
        title: formTitle,
        editableFields: Expense({}).editableFields,
        id: id,
        model: model,
        editable: editable,
        onSaved: (Map<OdooField, dynamic> values) async {
          //return await model.create(values);
          return await model.create(values).then((value) {
            if (afterSave != null) {
              // convert value to  expense object
              Map<String, dynamic> data = {};
              for (var entry in value.entries) {
                data[entry.key.name] = entry.value;
              }
              afterSave(Expense.fromJson(data));
            }
          });
        },
        onCancel: () => onCancel(),
      ),
    );
  }
}

/// Extend base form [AppFormState] that is state of AppForm
class _ExpenseFormState extends AppFormState {
  final Map<String, bool> _paymentMode = {};
  String _currencySymbol = '';

  @override
  String get message => "Votre demande d'expense a été bien enregistrée!";

  @override
  void initState() {
    super.initState();
    var expense = widget.initial.entries
        .firstWhere((element) => element.key.name == 'payment_mode');
    for (var el in expense.key.selectionOptions) {
      _paymentMode[el['value']] = expense.value == el['value'];
    }
    var currencyId = widget.initial.entries
        .firstWhere((element) => element.key.name == 'currency_id')
        .value;
    OdooModel('res.currency').searchRead(domain: [
      ['id', '=', currencyId]
    ], fieldNames: [
      'id',
      'name',
      'symbol'
    ], limit: 1).then((curr) {
      setState(() {
        _currencySymbol = curr[0]['symbol'];
      });
    });
  }

  @override
  setValues(Map<OdooField, dynamic> newValues) {
    var res = super.setValues(newValues);
    var expense = newValues.entries
        .firstWhere((element) => element.key.name == 'payment_mode');
    for (var el in expense.key.selectionOptions) {
      _paymentMode[el['value']] = expense.value == el['value'];
    }
    return res;
  }

  @override
  Widget buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (super.formEditable)
          ElevatedButton(
            onPressed: isSending
                ? null
                : () {
                    if (super.formKey.currentState!.validate()) {
                      super.formKey.currentState!.save();
                      super.save();
                    }
                  },
            child: isSending
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : const Text("Enregistrer"),
          ),
        OutlinedButton(
          onPressed: () {
            if (widget.onCancel != null) {
              widget.onCancel!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          child: const Text("Annuler"),
        ),
      ],
    );
  }

  @override
  Widget? buildTitle() {
    return null;
  }

  @override
  setFormFields(List<Widget> formFields) {
    Map<String, Widget> groupedField = {};
    List<Widget> paymentModeAsCheckBox = [];
    values.forEach((field, value) {
      if (!widget.displayFieldsName.contains(field.name)) {
        return;
      }
      if (field.name == 'payment_mode') {
        paymentModeAsCheckBox = field.selectionOptions.map((e) {
          var value = _paymentMode[e['value']]!;
          return CheckboxListTile(
            enabled: formEditable &&
                (formEditableFields.contains(field.name) || !field.readonly),
            value: value,
            title: Text(
              e['display_name'],
              style: const TextStyle(fontSize: 12),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            activeColor: Theme.of(context).colorScheme.primary,
            selected: value,
            checkboxShape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onChanged: (newValue) {
              // trigger on change for the field
              setState(() {
                _paymentMode[e['value']] = !(_paymentMode[e['value']]!);
                values[field] = e['value'];
                widget.onFieldChanges.forEach((key, func) {
                  if (key.name == field.name) {
                    func(cleanValues()).then((newValues) {
                      setValues(newValues);
                    });
                  }
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
      } else if ([OdooFieldType.float, OdooFieldType.monetary]
          .contains(field.type)) {
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

    // Date
    var date = values.entries
        .firstWhere((element) => element.key.name == 'date')
        .value;
    // Attachment Count
    var attachmentCountField = values.entries
        .firstWhere((element) => element.key.name == 'attachment_number');
    // Account Display
    var account = getValueFromM2OAsReadOnly("account_id");
    // Employee Display
    var employee = getValueFromM2OAsReadOnly("employee_id");
    // Devise
    var currency = getValueFromM2OAsReadOnly("currency_id");

    var attCountDisplay = attachmentCountField.value > 9
        ? attachmentCountField.value.toString()
        : attachmentCountField.value.toString().padLeft(2, '0');
    formFields.addAll([
      groupedField['description']!,
      groupedField['product_id']!,
      buildComonField(
        label: const Text('Prix unitaire', style: fontBold),
        child: groupedField['unit_amount']!,
        prefix: Text(_currencySymbol, style: fontBold),
      ),
      buildComonField(
        label: const Text('Quantité', style: fontBold),
        child: groupedField['quantity']!,
      ),
      buildComonField(
        label: const Text('Total', style: fontBold),
        child: groupedField['total_amount']!,
        prefix: Text(_currencySymbol, style: fontBold),
      ),
      const SizedBox(height: 5),
      const Text('Payé par', style: fontBold),
      Row(children: [
        for (var element in paymentModeAsCheckBox) Expanded(child: element)
      ]),
      //
      Container(
        margin: const EdgeInsets.only(top: 20, bottom: 20),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 100,
                  child: Text('Date:', style: fontBold),
                ),
                Text(date),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(
                  width: 100,
                  child: Text('Compte:', style: fontBold),
                ),
                Text(account),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(
                  width: 100,
                  child: Text('Salarié:', style: fontBold),
                ),
                Text(employee),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(
                  width: 100,
                  child: Text('Devise:', style: fontBold),
                ),
                Text(currency),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(
                  width: 150,
                  child: Text("Pièces jointe:", style: fontBold),
                ),
                Text(attCountDisplay),
              ],
            ),
          ],
        ),
      ),
    ]);
  }
}
