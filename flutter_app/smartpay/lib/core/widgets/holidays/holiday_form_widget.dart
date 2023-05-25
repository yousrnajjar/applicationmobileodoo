import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartpay/api/session.dart';
import 'package:smartpay/ir/models/holidays_models.dart';
import 'package:smartpay/exceptions/api_exceptions.dart';

final dayFormatter = DateFormat('yyyy-MM-dd');

class HolidayForm extends StatefulWidget {
  final Session session;
  final int employeeId;

  final List<HolidayType> holidaysStatus;

  const HolidayForm(
      {super.key,
      required this.session,
      required this.employeeId,
      required this.holidaysStatus});

  @override
  State<HolidayForm> createState() => _HolidayFormState();
}

class _HolidayFormState extends State<HolidayForm> {
  final _formKey = GlobalKey<FormState>();

  HolidayType? _selectedHolidayType;
  DateTime _requestDateFrom = DateTime.now();
  DateTime _requestDateTo = DateTime.now();
  String? _description;

  bool _isSending = false;
  

  void _presentDatePicker(String dataContext) async {
    final now = DateTime.now();
    final lastDate =
        DateTime(now.year + 1, now.month, now.day); //TODO: LastDate
    final datePicked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: lastDate,
    );
    if (dataContext == 'date_start' && datePicked != null) {
      setState(() {
        _requestDateFrom = datePicked;
      });
    } else if (datePicked != null) {
      setState(() {
        _requestDateTo = datePicked;
      });
    }
  }

  Widget _getDatePicker(DateTime? date, String dateContext) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          date == null ? "Pas de date choisie" : dayFormatter.format(date),
        ),
        IconButton(
          onPressed: () => _presentDatePicker(dateContext),
          icon: const Icon(Icons.calendar_month),
        ),
      ],
    );
  }

  void _saveHolidays() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSending = true;
    });

    var data = {
      "holiday_type": "employee",
      "date_from": dayFormatter.format(_requestDateFrom),
      "date_to": dayFormatter.format(_requestDateTo),
      "holiday_status_id": _selectedHolidayType!.id,
      //"state": "confirm",
      "employee_id": widget.employeeId,
      "name": _description,
    };
    try {
      await widget.session.callKw({
        "model": "hr.leave",
        "method": "create",
        "args": [data],
        "kwargs": {}
      });
    } on OdooValidationError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var labelTheme = Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.w600,
        );
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DropdownButtonFormField(
                value: _selectedHolidayType,
                decoration: const InputDecoration(label: Text("Type de congés")),
                items: [
                  for (var type in widget.holidaysStatus)
                    DropdownMenuItem(
                      value: type,
                      child: Text(type.name),
                    ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedHolidayType = value;
                  });
                }),
          ),
          Text("Période", style: labelTheme),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text("Du: ", style: labelTheme),
                    const SizedBox(
                      width: 5,
                    ),
                    _getDatePicker(_requestDateFrom, 'date_start'),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Text("Au: ", style: labelTheme),
                    const SizedBox(
                      width: 5,
                    ),
                    _getDatePicker(_requestDateTo, 'date_end'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            decoration: const InputDecoration(label: Text("Description")),
            keyboardType: TextInputType.text,
            onChanged: (value) => {_description = value},
            onSaved: (value) {
              _description = value!;
            },
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isSending
                    ? null
                    : () {
                        _formKey.currentState!.reset();
                      },
                child: const Text('Réinitialiser'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSending ? null : _saveHolidays,
                child: _isSending
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(),
                      )
                    : const Text("Envoyer"),
              )
            ],
          )
        ],
      ),
    );
  }
}
