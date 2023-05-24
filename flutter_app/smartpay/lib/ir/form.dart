/// This module contains the [AppForm] Widget.
/// It is used to display a form based on a [OdooModel].
/// [AppForm] is a [StatefulWidget] that uses [AppFormState] as its state.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartpay/exceptions/api_exceptions.dart';

// smartpay
import 'package:smartpay/ir/model.dart';

class AppForm extends StatefulWidget {
  final List<String> fieldNames;
  final Function(Map<OdooField, dynamic>) onSaved;
  final Map<OdooField, dynamic> initial;
  final List<String> displayFieldsName;
  final String title;

  /// accept onFieldChangeFunction that is map of field name and an [async] function
  /// that take as parameter an Map<OdooField, dynamic> and return a Map<OdooField, dynamic>
  /// this function is called an field change
  final Map<OdooField, Function(Map<OdooField, dynamic>)> onFieldChanges;

  const AppForm({
    super.key,
    required this.onSaved,
    required this.fieldNames,
    required this.initial,
    required this.onFieldChanges,
    required this.displayFieldsName,
    required this.title,
  });

  @override
  State<AppForm> createState() => _AppFormState();
}

class _AppFormState extends State<AppForm> {
  final _formKey = GlobalKey<FormState>();
  Map<OdooField, dynamic> _values = {};
  Map<OdooField, TextEditingController> _controllers = {};

  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    widget.initial.forEach((field, value) {
      _values[field] = value;
      var textField = [
        OdooFieldType.char,
        OdooFieldType.text,
        OdooFieldType.float,
        OdooFieldType.integer,
        OdooFieldType.html
      ];
      if (textField.contains(field.type)) {
        _controllers[field] = TextEditingController(text: "${value ?? ""}");
      }
    });
  }

  @override
  dispose() {
    _controllers.forEach((field, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  Map<OdooField, dynamic> _cleanValues() {
    Map<OdooField, dynamic> res = {};
    _values.forEach((key, value) {
      res[key] = value;
    });
    _controllers.forEach((field, controller) {
      res[field] = controller.text;
    });
    return res;
  }

  _setValues(Map<OdooField, dynamic> newValues) {
    newValues.forEach((field, value) {
      if (_controllers.keys.map((e) => e.name).contains(field.name) &&
          value != null) {
        setState(() {
          //_controllers[field]!.text = "$value";
           _controllers[field]!.dispose();
          _controllers[field] = TextEditingController(text: "${value ?? ""}");
        });
      }
      var key = _values.keys.firstWhere((e) => e.name == field.name);
      setState(() {
        _values[key] = newValues[field];
      });
    });
  }

  _save() async {
    var cleanedValues = _cleanValues();
    setState(() {
      _isSending = true;
    });
    var message = "Enregistrez!";
    try {
      var newValues = await widget.onSaved(cleanedValues);
      setState(() {
        _values = newValues;
      });
    } on OdooValidationError catch (e) {
      message = e.message;
    } on OdooErrorException catch (e) {
      message = "Veuillez contactez l'admin: ${e.message}";
    } finally {
      setState(() {
        _isSending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _setValues(_values);

    /// use defaultGet of the model to build an flutter Form widget
    final List<Widget> formFields = [];
    _setFormFields(formFields);
    final List<Widget> formFieldsWidget = [];
    for (var element in formFields) {
      formFieldsWidget.add(element);
      formFieldsWidget.add(const SizedBox(
        height: 10,
      ));
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
      child: Column(
        verticalDirection: VerticalDirection.up,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: _isSending
                  ? const CircularProgressIndicator()
                  : const Text("Envoyer"),
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(children: formFieldsWidget),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 18,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
          ),
        ],
      ),
    );
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
  _setFormFields(List<Widget> formFields) {
    print(widget.title);
    print(widget.displayFieldsName);
    print(widget.initial.keys.map((e) => e.name).toList());
    print(_values.keys.map((e) => e.name).toList());
    _values.forEach((field, value) {
      if (!widget.displayFieldsName.contains(field.name)) {
        return;
      }
      if (field.type == OdooFieldType.boolean) {
        formFields.add(_buildBooleanField(field));
      } else if (field.type == OdooFieldType.integer) {
        formFields.add(_buildIntegerField(field, value));
      } else if (field.type == OdooFieldType.float) {
        formFields.add(_buildFloatField(field, value));
      } else if (field.type == OdooFieldType.char) {
        formFields.add(_buildCharField(field, value));
      } else if (field.type == OdooFieldType.text) {
        formFields.add(_buildTextField(field, value));
      } else if (field.type == OdooFieldType.date) {
        formFields.add(_buildDateField(field, value));
      } else if (field.type == OdooFieldType.datetime) {
        formFields.add(_buildDateTimeField(field, value));
      } else if (field.type == OdooFieldType.selection) {
        formFields.add(_buildSelectionField(field, value));
      } /*else if (field.type == OdooFieldType.many2one) {
        formFields.add(_buildMany2oneField(field, value));
      } else if (field.type == OdooFieldType.one2many) {
        formFields.add(_buildOne2manyField(field, value));
      } else if (field.type == OdooFieldType.many2many) {
        formFields.add(_buildMany2manyField(field, value));
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

  Widget _buildBooleanField(OdooField field) {
    var value = _values[field] ?? false;
    return CheckboxListTile(
      key: ObjectKey(field),
      enabled: field.readonly,
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
          _values[field] = !(_values[field] ?? false);
          Function(Map<OdooField, dynamic>) onchange =
              widget.onFieldChanges[field]!;
          onchange(_cleanValues()).then((newValues) {
            _setValues(newValues);
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

  Widget _buildIntegerField(OdooField field, dynamic controller) {
    return TextFormField(
      controller: _controllers[field],
      decoration: InputDecoration(labelText: field.fieldDescription),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        return null;
      },
      onSaved: (newValue) {
        setState(() {
          _values[field] = int.parse(newValue!);
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

  Widget _buildFloatField(OdooField field, dynamic controller) {
    return TextFormField(
      controller: _controllers[field],
      decoration: InputDecoration(labelText: field.fieldDescription),
      keyboardType: TextInputType.number,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Please enter a value';
        }
        return null;
      },
      onSaved: (newValue) {
        setState(() {
          _values[field] = double.parse(newValue!);
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

  Widget _buildCharField(OdooField field, dynamic controller) {
    return TextFormField(
      /*initialValue: value.toString(),*/
      controller: _controllers[field],
      decoration: InputDecoration(labelText: field.fieldDescription),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        return null;
      },
      onSaved: (newValue) {
        setState(() {
          _values[field] = newValue;
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

  Widget _buildTextField(OdooField field, dynamic controller) {
    return TextFormField(
      controller: _controllers[field],
      decoration: InputDecoration(labelText: field.fieldDescription),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        return null;
      },
      onSaved: (newValue) {
        setState(() {
          _values[field] = newValue;
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

  Widget _buildDateField(OdooField field, dynamic valueString) {
    var dateFormat = DateFormat('yyyy-MM-dd');
    DateTime value;
    try {
      value = dateFormat.parse(valueString);
    } catch (e) {
      value = DateTime.now();
    }
    return InkWell(
      onTap: () async {
        if (field.readonly) {
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
          _values[field] = dateFormat.format(picked);
          var onFieldChange = widget.onFieldChanges[field];
          if (onFieldChange != null) {
            onFieldChange(_cleanValues()).then((newValues) {
              _setValues(newValues);
            });
          }
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
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
  Widget _buildDateTimeField(OdooField field, dynamic valueString) {
    var dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime value;
    try {
      value = dateFormat.parse(valueString);
    } catch (e) {
      value = DateTime.now();
    }
    return InkWell(
      onTap: () async {
        if (field.readonly) {
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
            _values[field] = dateFormat.format(picked);
          });
          var onFieldChange = widget.onFieldChanges[field];
          if (onFieldChange != null) {
            onFieldChange(_cleanValues()).then((newValues) {
              _setValues(newValues);
            });
          }
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
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
  Widget _buildSelectionField(OdooField field, dynamic value) {
    var selectionOptions = field.selectionOptions;
    return DropdownButtonFormField(
      value: _values[field],
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
          return 'Please enter a value';
        }
        return null;
      },
      onSaved: (newValue) {
        setState(() {
          _values[field] = newValue;
        });
      },
      onChanged: (Object? value) {
        setState(() {
          _values[field] = value;
        });
        var onFieldChange = widget.onFieldChanges[field];
        if (onFieldChange != null) {
          onFieldChange(_cleanValues()).then((newValues) {
            _setValues(newValues);
          });
        }
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
  Widget _buildMany2oneField(OdooField field, dynamic value) {
    var selectionOptions = field.selectionOptions;

    return DropdownButtonFormField(
      value: _values[field],
      decoration: InputDecoration(
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
          return 'Please enter a value';
        }
        return null;
      },
      onSaved: (newValue) {
        setState(() {
          _values[field] = newValue;
        });
      },
      onChanged: (Object? value) {},
    );
  }

  /// TODO:
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
  Widget _buildMany2manyField(OdooField field, dynamic values) {
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

  /// TODO:
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
  Widget _buildOne2manyField(OdooField field, dynamic values) {
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
