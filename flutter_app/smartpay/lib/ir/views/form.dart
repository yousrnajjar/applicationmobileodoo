/// This module contains the [AppForm] Widget.
/// It is used to display a form based on a [OdooModel].
/// [AppForm] is a [StatefulWidget] that uses [AppFormState] as its state.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartpay/exceptions/api_exceptions.dart';
import 'package:smartpay/ir/data/themes.dart';

// smartpay
import 'package:smartpay/ir/model.dart';

class AppForm extends StatefulWidget {
  final List<String> fieldNames;
  final Function(Map<OdooField, dynamic>) onSaved;
  final Function()? onCancel;
  final Map<OdooField, dynamic> initial;
  final List<String> displayFieldsName;
  final String title;
  final bool? editable;
  final List<String>? editableFields;
  final int? id;
  final OdooModel? model;

  /// accept onFieldChangeFunction that is map of field name and an [async] function
  /// that take as parameter an Map<OdooField, dynamic> and return a Map<OdooField, dynamic>
  /// this function is called an field change
  final Map<OdooField, Function(Map<OdooField, dynamic>)> onFieldChanges;

  const AppForm({
    super.key,
    this.onCancel,
    required this.onSaved,
    required this.fieldNames,
    required this.initial,
    required this.onFieldChanges,
    required this.displayFieldsName,
    required this.title,
    this.editable,
    this.id,
    this.model,
    this.editableFields,
  });

  @override
  State<AppForm> createState() => AppFormState();
}

class AppFormState extends State<AppForm> {
  final formKey = GlobalKey<FormState>();
  bool initialized = false;
  late bool formEditable;
  List<String> formEditableFields = [];
  Map<OdooField, dynamic> values = {};
  Map<OdooField, TextEditingController> controllers = {};
  String message = "Votre demande a été bien enregistrée!";
  String emptyMsg = "Merci d'entrer une valeur";

  bool isSending = false;

  /// read initial values and return a Map<String, dynamic>
  Future<Map<OdooField, dynamic>> readInitial(int id) async {
    var res = await widget.model!.searchReadAsOdooField(
      domain: [
        ['id', '=', id]
      ],
      fieldNames: widget.fieldNames,
    );
    if (res.length == 0) {
      throw Exception("No record found");
    }
    return res[0];
  }

  @override
  void initState() {
    super.initState();
    formEditable = widget.editable ?? true;
    controllers = {};
    formEditableFields = widget.editableFields ?? [];
  }

  Future<void> initValues() async {
    if (widget.id != null && widget.model != null) {
      var record = await readInitial(widget.id!);
      record.forEach((field, value) {
        values[field] = value;
        var textField = [
          OdooFieldType.char,
          OdooFieldType.text,
          OdooFieldType.float,
          OdooFieldType.monetary,
          OdooFieldType.integer,
          OdooFieldType.html
        ];
        if (textField.contains(field.type)) {
          controllers[field] = TextEditingController(text: "${value ?? ""}");
        }
      });
    } else {
      widget.initial.forEach((field, value) {
        values[field] = value;
        var textField = [
          OdooFieldType.char,
          OdooFieldType.text,
          OdooFieldType.float,
          OdooFieldType.monetary,
          OdooFieldType.integer,
          OdooFieldType.html
        ];
        if (textField.contains(field.type)) {
          controllers[field] = TextEditingController(text: "${value ?? ""}");
        }
      });
    }
  }

  change(OdooField field) {
    //if (kDebugMode) {
    //print(values[field]);
    //print(values.entries.firstWhere((e) => e.key.name == field.name).value);
    //}
  }

  //@override
  //dispose() {
  //controllers.forEach((field, controller) {
  //controller.dispose();
  //});
  //super.dispose();
  //}

  Map<OdooField, dynamic> cleanValues() {
    Map<OdooField, dynamic> res = {};
    values.forEach((key, value) {
      if (value != null &&
          value.runtimeType == List &&
          [OdooFieldType.many2one].contains(key.type)) {
        res[key] = value[0];
      } else {
        res[key] = value;
      }
    });
    controllers.forEach((field, controller) {
      res[field] = controller.text;
    });
    return res;
  }

  setValues(Map<OdooField, dynamic> newValues) {
    newValues.forEach((field, value) {
      if (controllers.keys.map((e) => e.name).contains(field.name) &&
          value != null) {
        setState(() {
          controllers[field]!.dispose();
          controllers[field] = TextEditingController(text: "${value ?? ""}");
          controllers[field]!.value = TextEditingValue(
            text: '$value',
            selection: TextSelection.fromPosition(
              TextPosition(offset: '$value'.length),
            ),
          );
        });
      }
      var key = values.keys.firstWhere((e) => e.name == field.name);
      setState(() {
        values[key] = newValues[field];
      });
    });
  }

  save() async {
    print(
        "===========================================Cleaned Values===========================================");
    var cleanedValues = cleanValues();
    String resMessage = "";
    cleanedValues.forEach((key, value) {});
    setState(() {
      isSending = true;
    });
    var newValues;
    try {
      print(
          "===========================================On Saved===========================================");
      newValues = await widget.onSaved(cleanedValues);
      resMessage = message;
      //print("newValues: $newValues");
    } on OdooValidationError catch (e) {
      resMessage = e.message;
      print("OdooValidationError: $e");
    } on OdooErrorException catch (e) {
      resMessage = "Veuillez contactez l'admin: ${e.message}";
      print("OdooErrorException: $e");
    } catch (e) {
      resMessage = "Erreur inconnue: $e, veuillez contactez l'admin";
      print("Erreur inconnue: $e");
    } finally {
      setState(() {
        isSending = false;
      });
    }
    if (newValues != null) {
      setState(() {
        values = newValues;
      });
    }
    if (resMessage != null) {
      print(
          "===========================================Res Message===========================================");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resMessage),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (!initialized) {
      initValues().then((value) {
        setState(() {
          initialized = true;
        });
      });
      content = const Center(child: CircularProgressIndicator());
    } else {
      final List<Widget> formFields = [];
      setFormFields(formFields);
      final List<Widget> formFieldsWidget = [];
      for (var element in formFields) {
        formFieldsWidget.add(element);
        formFieldsWidget.add(const SizedBox(
          height: 10,
        ));
      }
      var title = buildTitle();
      content = SingleChildScrollView(
        child: Column(
          children: [
            if (title != null) title,
            buildForm(formFieldsWidget),
          ],
        ),
      );
    }

    return content;
  }

  /// Build the title of the form
  ///
  Widget? buildTitle() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Text(
        widget.title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Build the form
  ///
  Widget buildForm(List<Widget> formFieldsWidget) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...formFieldsWidget,
            buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// Build the action buttons of the form
  ///
  Widget buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (formEditable)
          ElevatedButton(
            onPressed: isSending
                ? null
                : () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      save();
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
            } else {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }
          },
          child: const Text("Annuler"),
        ),
      ],
    );
  }

  Widget buildComonField({
    double? labelWidth = 80,
    double? prefixWidth = 80,
    Widget? label,
    required Widget child,
    Widget? prefix,
  }) {
    return Row(
      children: [
        if (label != null)
          Container(
            width: labelWidth!,
            padding: const EdgeInsets.only(top: 15),
            child: label,
          ),
        const SizedBox(width: 10),
        SizedBox(width: 90, child: child),
        const SizedBox(width: 10),
        if (prefix != null)
          Container(
            width: prefixWidth!,
            padding: const EdgeInsets.only(top: 15),
            child: prefix,
          ),
      ],
    );
  }

  String getValueFromM2OAsReadOnly(String fieldName) {
    var valId = values.entries
        .firstWhere((element) => element.key.name == fieldName)
        .value;
    var options = values.keys
        .firstWhere((element) => element.name == fieldName)
        .selectionOptions;

    if (options == null) {
      return '';
    } else {
      //.firstWhere((element) => element['id'] == valId);
      for (var option in options) {
        if (option['id'] == valId) {
          return option['name'];
        }
      }
      return '';
    }
    //return valName != null ? valName['name'] : '';
  }

  /// Build a list of form fields based on the defaultGet of the model
  ///
  /// The defaultGet is a map of OdooField and its value.
  /// The OdooField contains the field fieldDescription, type [OdooFiedType], and other information.
  /// The value is the default value of the field.
  ///
  /// The form fields are built based on the type of the field.
  ///
  /// The form fields are returned as a list of widgets.
  setFormFields(List<Widget> formFields) {
    values.forEach((field, value) {
      if (!widget.displayFieldsName.contains(field.name)) {
        return;
      }

      if (field.type == OdooFieldType.boolean) {
        formFields.add(buildBooleanField(field));
      } else if (field.type == OdooFieldType.integer) {
        formFields.add(buildIntegerField(field, value));
      } else if (field.type == OdooFieldType.float) {
        formFields.add(buildFloatField(field, value));
      } else if (field.type == OdooFieldType.char) {
        formFields.add(buildCharField(field, value, true));
      } else if (field.type == OdooFieldType.text) {
        formFields.add(buildTextField(field, value));
      } else if (field.type == OdooFieldType.date) {
        formFields.add(buildDateField(field, value, true, true));
      } else if (field.type == OdooFieldType.datetime) {
        formFields.add(buildDateTimeField(field, value));
      } else if (field.type == OdooFieldType.selection) {
        formFields.add(buildSelectionField(field, value));
      } else if (field.type == OdooFieldType.many2one) {
        formFields.add(buildMany2oneField(field, value));
      } /*else if (field.type == OdooFieldType.one2many) {
        formFields.add(buildOne2manyField(field, value));
      } else if (field.type == OdooFieldType.many2many) {
        formFields.add(buildMany2manyField(field, value));
      }*/
    });
  }

  /// Build a boolean field
  ///
  /// The boolean field is built using a [CheckboxListTile].
  /// The value of the field is set to the [value] of the field.
  /// The [title] of the field is set to the [fieldDescription] of the field.
  /// The [subtitle] of the field is set to the [help] of the field.
  /// The [controlAffinity] of the field is set to [ListTileControlAffinity.leading].
  /// The [contentPadding] of the field is set to [EdgeInsets.symmetric(horizontal: 20.0)].
  /// The [secondary] of the field is set to [Icon(Icons.check)].
  /// The [activeColor] of the field is set to [Theme.of(context).primaryColor].
  /// The [selected] of the field is set to [value].
  /// The [onChanged] of the field is set to a function that sets the [_values[field]] to the [newValue] of the field.
  /// The [tristate] of the field is set to [false].
  ///
  /// The field is returned as a [CheckboxListTile].

  Widget buildBooleanField(OdooField field) {
    var value = values[field] ?? false;
    return CheckboxListTile(
      key: ObjectKey(field),
      enabled: formEditable &&
          (formEditableFields.contains(field.name) || !field.readonly),
      value: value,
      title: Text(field.fieldDescription),
      subtitle: Text(
        field.help == false ? "" : field.help,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 9),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 2.0),
      secondary: const Icon(Icons.check),
      activeColor: Theme.of(context).colorScheme.primary,
      selected: value,
      onChanged: (newValue) {
        // trigger on change for the field
        setState(() {
          values[field] = !(values[field] ?? false);
          Function(Map<OdooField, dynamic>) onchange =
              widget.onFieldChanges[field]!;
          onchange(cleanValues()).then((newValues) {
            setValues(newValues);
          });
        });
      },
      tristate: false,
    );
  }

  /// Build an integer field
  ///
  /// The integer field is built using a [TextFormField].
  /// The value of the field is set to the [value] of the field.
  /// The [decoration] of the field is set to a [InputDecoration] with a [labelText] of the [fieldDescription] of the field.
  /// The [validator] of the field is set to a function that returns null if the [value] of the field is not null.
  /// The [onSaved] of the field is set to a function that sets the [_values[field]] to the [newValue] of the field.
  ///
  /// The field is returned as a [TextFormField].

  Widget buildIntegerField(OdooField field, dynamic controller) {
    return TextFormField(
      key: ObjectKey(field),
      enabled: formEditable &&
          (!field.readonly || formEditableFields.contains(field.name)),
      controller: controllers.entries
          .firstWhere((element) => element.key.name == field.name)
          .value,
      decoration: InputDecoration(
        labelText: field.fieldDescription,
        contentPadding: const EdgeInsets.only(bottom: -15),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return emptyMsg;
        }
        return null;
      },
      onSaved: (newValue) {
        setState(() {
          values[field] = int.parse(newValue!);
        });
      },
    );
  }

  /// Build a float field
  ///
  /// The float field is built using a [TextFormField].
  /// The value of the field is set to the [value] of the field.
  /// The [decoration] of the field is set to a [InputDecoration] with a [labelText] of the [fieldDescription] of the field.
  /// The [validator] of the field is set to a function that returns null if the [value] of the field is not null.
  /// The [onSaved] of the field is set to a function that sets the [_values[field]] to the [newValue] of the field.
  ///
  /// The field is returned as a [TextFormField].

  Widget buildFloatField(OdooField field, dynamic val,
      {bool showLabel = true}) {
    var controller = controllers.entries
        .firstWhere((element) => element.key.name == field.name)
        .value;
    controller.addListener(
      () {
        values[field] = controller.text;
        widget.onFieldChanges.forEach((key, func) {
          if (key.name == field.name) {
            func(cleanValues()).then((newValues) {
              setValues(newValues);
            });
          }
        });
      },
    );

    return TextFormField(
      key: ObjectKey(field),
      enabled: formEditable &&
          (!field.readonly || formEditableFields.contains(field.name)),
      controller: controller,
      decoration: InputDecoration(
        labelText: showLabel ? field.fieldDescription : null,
        contentPadding: const EdgeInsets.only(bottom: -15),
      ),
      //keyboardType: TextInputType.number,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Please enter a value';
        }
        return null;
      },
      onSaved: (newValue) {
        setState(() {
          values[field] = double.parse(newValue!);
        });
      },
    );
  }

  /// Build a char field
  ///
  /// The char field is built using a [TextFormField].
  /// The value of the field is set to the [value] of the field.
  /// The [decoration] of the field is set to a [InputDecoration] with a [labelText] of the [fieldDescription] of the field.
  /// The [validator] of the field is set to a function that returns null if the [value] of the field is not null.
  /// The [onSaved] of the field is set to a function that sets the [_values[field]] to the [newValue] of the field.
  ///
  /// The field is returned as a [TextFormField].

  Widget buildCharField(OdooField field, dynamic controller, bool showLabel) {
    return TextFormField(
      key: ObjectKey(field),
      enabled: formEditable &&
          (!field.readonly || formEditableFields.contains(field.name)),
      /*initialValue: value.toString(),*/

      controller: controllers.entries
          .firstWhere((element) => element.key.name == field.name)
          .value,
      decoration: InputDecoration(
        labelText: showLabel ? field.fieldDescription : null,
        contentPadding: const EdgeInsets.only(bottom: -15),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return emptyMsg;
        }
        return null;
      },
      onSaved: (newValue) {
        setState(() {
          values[field] = newValue;
        });
      },
    );
  }

  /// Build a text field
  ///
  /// The text field is built using a [TextFormField].
  /// The value of the field is set to the [value] of the field.
  /// The [decoration] of the field is set to a [InputDecoration] with a [labelText] of the [fieldDescription] of the field.
  /// The [validator] of the field is set to a function that returns null if the [value] of the field is not null.
  /// The [onSaved] of the field is set to a function that sets the [_values[field]] to the [newValue] of the field.
  ///
  /// The field is returned as a [TextFormField].

  Widget buildTextField(
    OdooField field,
    dynamic val, {
    int maxLines = 5,
    int minLines = 1,
    bool showLabel = false,
    String errorMsg = "",
  }) {
    errorMsg = emptyMsg;
    var controller = controllers.entries
        .firstWhere((element) => element.key.name == field.name)
        .value;
    controller.addListener(
      () {
        values[field] = controller.text;
        widget.onFieldChanges.forEach((key, func) {
          if (key.name == field.name) {
            func(cleanValues()).then((newValues) {
              setValues(newValues);
            });
          }
        });
      },
    );

    return TextFormField(
      key: ObjectKey(field),
      enabled: formEditable &&
          (!field.readonly || formEditableFields.contains(field.name)),
      controller: controller,
      decoration: InputDecoration(
        labelText: showLabel ? field.fieldDescription : null,
        contentPadding: const EdgeInsets.only(bottom: -15),
      ),
      minLines: minLines,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorMsg;
        }
        return null;
      },
      onSaved: (newValue) {
        setState(() {
          values[field] = newValue;
        });
      },
    );
  }

  /// Build a date field
  ///
  /// The date field is built using a [showDatePicker].
  /// format of the field is set to [DateFormat('yyyy-MM-dd')].
  /// The [initialDate] of the field is set to the [value] of the field.
  /// The [firstDate] of the field is set to  [DateTime(1900)].
  /// The [lastDate] of the field is set to  [DateTime(2100)].
  /// The [helpText] of the field is set to the [fieldDescription] of the field.
  /// The [cancelText] of the field is set to  'Cancel'.
  /// The [confirmText] of the field is set to  'Ok'.
  /// The [fieldHintText] of the field is set to  'Year/Month/Day'.
  /// The [fieldLabelText] of the field is set to  'Enter Date'.
  /// The [errorFormatText] of the field is set to  'Enter valid date'.
  /// The [errorInvalidText] of the field is set to  'Enter date in valid range'.
  /// The [errorInvalidRangeText] of the field is set to  'Enter date in valid range'.
  /// The [locale] of the field is set to  [Locale('en', 'US')].
  /// The [useRootNavigator] of the field is set to  false.
  /// The [context] of the field is set to  [context].
  ///
  /// The field is the Widget that contains the [showDatePicker], icon of calendar, and the [value] of the field in a [Text].

  Widget buildDateField(OdooField field, dynamic valueString, bool showLabel,
      bool showCalendarIcon) {
    var dateFormat = DateFormat('yyyy-MM-dd');
    DateTime value;
    try {
      value = dateFormat.parse(valueString);
    } catch (e) {
      value = DateTime.now();
    }
    return InkWell(
      onTap: () async {
        if (!formEditable ||
            (field.readonly && !formEditableFields.contains(field.name))) {
          return;
        }
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
          helpText: field.fieldDescription,
          cancelText: 'Cancel',
          confirmText: 'Ok',
          fieldHintText: 'Year/Month/Day',
          fieldLabelText: 'Enter Date',
          errorFormatText: 'Enter valid date',
          errorInvalidText: 'Enter date in valid range',
          locale: const Locale('en', 'US'),
          useRootNavigator: false,
        );
        if (picked != null && picked != value) {
          setState(() {
            value = picked;
          });
          values[field] = dateFormat.format(picked);
          var onFieldChange = widget.onFieldChanges[field];
          if (onFieldChange != null) {
            onFieldChange(cleanValues()).then((newValues) {
              setValues(newValues);
            });
          }
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(top: 22),
          labelText: showLabel ? field.fieldDescription : null,
          icon: showCalendarIcon
              ? const Icon(Icons.calendar_today, size: 14)
              : null,
          suffixIcon: Container(
            padding: const EdgeInsets.only(top: 15),
            child: const Icon(
              // Calendar month icon.
              Icons.calendar_month,
              color: kGreen,
              size: 14,
            ),
          ),
        ),
        child: Text(dateFormat.format(value),
            style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  /// Build a date time field
  ///
  /// The date time field is built using a [showDatePicker].
  /// format of the field is set to [DateFormat('yyyy-MM-dd-HH-mm-ss')].
  /// The [initialDate] of the field is set to the [value] of the field.
  /// The [firstDate] of the field is set to  [DateTime(1900)].
  /// The [lastDate] of the field is set to  [DateTime(2100)].
  /// The [helpText] of the field is set to the [fieldDescription] of the field.
  /// The [cancelText] of the field is set to  'Cancel'.
  /// The [confirmText] of the field is set to  'Ok'.
  /// The [fieldHintText] of the field is set to  'Year/Month/Day'.
  /// The [fieldLabelText] of the field is set to  'Enter Date'.
  /// The [errorFormatText] of the field is set to  'Enter valid date'.
  /// The [errorInvalidText] of the field is set to  'Enter date in valid range'.
  /// The [errorInvalidRangeText] of the field is set to  'Enter date in valid range'.
  /// The [locale] of the field is set to  [Locale('en', 'US')].
  /// The [useRootNavigator] of the field is set to  false.
  /// The [context] of the field is set to  [context].
  ///
  /// The field is the Widget that contains the [showDatePicker], icon of calendar, and the [value] of the field in a [Text].
  Widget buildDateTimeField(OdooField field, dynamic valueString) {
    var dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime value;
    try {
      value = dateFormat.parse(valueString);
    } catch (e) {
      value = DateTime.now();
    }
    return InkWell(
      onTap: () async {
        if (!formEditable ||
            (field.readonly && !formEditableFields.contains(field.name))) {
          return;
        }
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
          helpText: field.fieldDescription,
          cancelText: 'Cancel',
          confirmText: 'Ok',
          fieldHintText: 'Year/Month/Day',
          fieldLabelText: 'Enter Date',
          errorFormatText: 'Enter valid date',
          errorInvalidText: 'Enter date in valid range',
          locale: const Locale('en', 'US'),
          useRootNavigator: true,
        );
        if (picked != null && picked != value) {
          setState(() {
            values[field] = dateFormat.format(picked);
          });

          widget.onFieldChanges.forEach((key, func) {
            if (key.name == field.name) {
              func(cleanValues()).then((newValues) {
                setValues(newValues);
              });
            }
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(bottom: -15),
          labelText: field.fieldDescription,
          icon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          dateFormat.format(value),
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  /// Build a selection field
  ///
  /// The selection field is built using a [DropdownButtonFormField].
  /// The [value] of the field is set to the [value] of the field.
  /// The [decoration] of the field is set to a [InputDecoration] with a [labelText] of the [fieldDescription] of the field.
  /// The [items] of the field is set to a [List<DropdownMenuItem<String>>] with the [selectionOptions] of the field.
  /// The [validator] of the field is set to a [validator] that checks if the value is null.
  /// The [onSaved] of the field is set to a [onSaved] that sets the [value] of the field to the [newValue].
  ///
  /// The field is the Widget that contains the [DropdownButtonFormField].
  Widget buildSelectionField(OdooField field, dynamic value) {
    var selectionOptions = field.selectionOptions;
    return DropdownButtonFormField(
      value: values[field],
      disabledHint: Text(values[field].toString() ?? ''),
      decoration: InputDecoration(
        labelText: field.fieldDescription,
      ),
      items: selectionOptions
          .map<DropdownMenuItem<String>>(
            (e) => DropdownMenuItem<String>(
              value: "${e['value']}",
              child: Text("${e['display_name']}"),
            ),
          )
          .toList(),
      validator: (value) {
        if (value == null) {
          return emptyMsg;
        }
        return null;
      },
      onSaved: (newValue) {
        setState(() {
          values[field] = newValue;
        });
      },
      onChanged: (!formEditable &&
              field.readonly &&
              !formEditableFields.contains(field.name))
          ? null
          : (Object? value) {
              setState(() {
                values[field] = value;
              });
              widget.onFieldChanges.forEach((key, func) {
                if (key.name == field.name) {
                  func(cleanValues()).then((newValues) {
                    setValues(newValues);
                  });
                }
              });
            },
    );
  }

  /// Build a many2one field
  ///
  /// The many2one field is built using a [DropdownButtonFormField].
  /// The [value] of the field is set to the [value] of the field.
  /// The [decoration] of the field is set to a [InputDecoration] with a [labelText] of the [fieldDescription] of the field.
  /// The [items] of the field is set to a [List<DropdownMenuItem<String>>] with the [selectionOptions] of the field.
  /// The [validator] of the field is set to a [validator] that checks if the value is null.
  /// The [onSaved] of the field is set to a [onSaved] that sets the [value] of the field to the [newValue].
  ///
  /// The field is the Widget that contains the [DropdownButtonFormField].
  Widget buildMany2oneField(OdooField field, dynamic value) {
    List<Map<String, dynamic>> selectionOptions =
        field.selectionOptions as List<Map<String, dynamic>>;

    var intValue = values[field];
    var displayValue = '';
    if (intValue is List) {
      intValue = intValue[0];
      try {
        displayValue = selectionOptions
            .firstWhere((element) => element['id'] == intValue)['name'];
      } catch (e) {
        displayValue = '';
      }
    } else if (intValue == false) {
      intValue = null;
    }
    return DropdownButtonFormField(
        value: intValue,
        disabledHint: Text(displayValue),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(bottom: -15),
          labelText: field.fieldDescription,
        ),
        items: selectionOptions
            .map<DropdownMenuItem<int>>((e) => DropdownMenuItem<int>(
                  value: e['id'],
                  child: Text("${e['name']}"),
                ))
            .toList(),
        validator: (value) {
          if (value == null) {
            return emptyMsg;
          }
          return null;
        },
        onSaved: (newValue) {
          setState(() {
            values[field] = newValue;
          });
        },
        onChanged: (!formEditable ||
                (field.readonly && !formEditableFields.contains(field.name)))
            ? null
            : (Object? value) {
                values[field] = value;
                widget.onFieldChanges.forEach((key, func) {
                  if (key.name == field.name) {
                    func(cleanValues()).then((newValues) {
                      setValues(newValues);
                    });
                  }
                });
              });
  }

  /// TODO: Test Me
  ///
  /// Build a many2many field that allows the user to select multiple values
  ///
  /// The many2many field is built using a [MultiSelectFormField].
  /// The [value] of the field is set to the [values] of the field.
  /// The [decoration] of the field is set to a [InputDecoration] with a [labelText] of the [fieldDescription] of the field.
  /// The [items] of the field is set to a [List<DropdownMenuItem<String>>] with the [selectionOptions] of the field.
  /// The [validator] of the field is set to a [validator] that checks if the value is null.
  /// The [onSaved] of the field is set to a [onSaved] that sets the [value] of the field to the [newValue].
  ///
  /// The field is the Widget that contains the [MultiSelectFormField].
  Widget buildMany2manyField(OdooField field, dynamic values) {
    return const Text('ToDO');
    /*return MultiSelectFormField(
      autovalidate: false,
      chipBackGroundColor: Colors.blue,
      chipLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      dialogTextStyle: TextStyle(fontWeight: FontWeight.bold),
      checkBoxActiveColor: Colors.blue,
      checkBoxCheckColor: Colors.white,
      dialogShapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      title: Text(field.fieldDescription),
      validator: (value) {
        if (value == null || value.length == 0) {
          return 'Please select one or more options';
        }
        return null;
      },
      dataSource: field.selectionOptions
          .map((e) => {
                "display": e[1],
                "value": e[0],
              })
          .toList(),
      textField: 'display',
      valueField: 'value',
      okButtonLabel: 'OK',
      cancelButtonLabel: 'CANCEL',
      hintWidget: Text('Please choose one or more'),
      initialValue: values,
      onSaved: (newValue) {
        setState(() {
          _values[field] = newValue;
        });
      },
    );*/
  }

  /// TODO: Test Me
  ///
  /// Build a one2many field that allows the user to select multiple values
  ///
  /// The one2many field is built using a [MultiSelectFormField].
  /// The [value] of the field is set to the [values] of the field.
  /// The [decoration] of the field is set to a [InputDecoration] with a [labelText] of the [fieldDescription] of the field.
  /// The [items] of the field is set to a [List<DropdownMenuItem<String>>] with the [selectionOptions] of the field.
  /// The [validator] of the field is set to a [validator] that checks if the value is null.
  /// The [onSaved] of the field is set to a [onSaved] that sets the [value] of the field to the [newValue].
  ///
  /// The field is the Widget that contains the [MultiSelectFormField].
  Widget buildOne2manyField(OdooField field, dynamic values) {
    return const Text("TOdo");
    /*MultiSelectFormField(
      autovalidate: false,
      chipBackGroundColor: Colors.blue,
      chipLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      dialogTextStyle: TextStyle(fontWeight: FontWeight.bold),
      checkBoxActiveColor: Colors.blue,
      checkBoxCheckColor: Colors.white,
      dialogShapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      title: Text(field.fieldDescription),
      validator: (value) {
        if (value == null || value.length == 0) {
          return 'Please select one or more options';
        }
        return null;
      },
      dataSource: field.selectionOptions
          .map((e) => {
                "display": e[1],
                "value": e[0],
              })
          .toList(),
      textField: 'display',
      valueField: 'value',
      okButtonLabel: 'OK',
      cancelButtonLabel: 'CANCEL',
      hintWidget: Text('Please choose one or more'),
      initialValue: values,
      onSaved: (newValue) {
        setState(() {
          _values[field] = newValue;
        });
      },
    );*/
  }
}
