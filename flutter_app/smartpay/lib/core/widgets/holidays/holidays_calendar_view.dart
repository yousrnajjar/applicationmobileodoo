import 'package:flutter/material.dart';
import 'package:smartpay/ir/models/holidays_models.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class HolidayCalendar extends StatefulWidget {
  final List<Holiday> holidays;

  const HolidayCalendar({super.key, required this.holidays});

  @override
  State<HolidayCalendar> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HolidayCalendar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SfCalendar(
      view: CalendarView.month,
      dataSource: HolidayDataSource(_getDataSource()),
      // by default the month appointment display mode set as Indicator, we can
      // change the display mode as appointment using the appointment display
      // mode property
      monthViewSettings: const MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
    ));
  }

  List<HolidayToDisplay> _getDataSource() {
    final List<HolidayToDisplay> holidaysToDisplay = widget.holidays
        // .where((element) => element.state == 'validate')
        .map((e) => HolidayToDisplay.fromHoliday(e))
        .toList();
    /*
    final List<HolidayToDisplay> holidays = <HolidayToDisplay>[];
    final DateTime today = DateTime.now();
    final DateTime startTime = DateTime(today.year, today.month, today.day, 9);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    holidays.add(HolidayToDisplay(
        'Conference', startTime, endTime, const Color(0xFF0F8644), false));

     */
    return holidaysToDisplay;
  }
}

/// An object to set the appointment collection data source to calendar, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class HolidayDataSource extends CalendarDataSource {
  /// Creates a holiday data source, which used to set the appointment
  /// collection to the calendar
  HolidayDataSource(List<HolidayToDisplay> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getHolidayData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getHolidayData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getHolidayData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getHolidayData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getHolidayData(index).isAllDay;
  }

  HolidayToDisplay _getHolidayData(int index) {
    final dynamic holiday = appointments![index];
    late final HolidayToDisplay holidayData;
    if (holiday is HolidayToDisplay) {
      holidayData = holiday;
    }

    return holidayData;
  }
}

/// Custom business object class which contains properties to hold the detailed
/// information about the event data which will be rendered in calendar.
class HolidayToDisplay {
  /// Creates a holiday class with required details.
  HolidayToDisplay(
      this.eventName, this.from, this.to, this.background, this.isAllDay);

  /// Event name which is equivalent to subject property of [Appointment].
  String eventName;

  /// From which is equivalent to start time property of [Appointment].
  DateTime from;

  /// To which is equivalent to end time property of [Appointment].
  DateTime to;

  /// Background which is equivalent to color property of [Appointment].
  Color background;

  /// IsAllDay which is equivalent to isAllDay property of [Appointment].
  bool isAllDay;

  HolidayToDisplay.fromHoliday(Holiday holiday)
      : eventName =
            "${holiday.employeeId[1]}, ${holiday.holidayStatusId[1]}, ${holiday.durationDisplay}",
        from = holiday.from!,
        to = holiday.to!,
        background = Colors.greenAccent,
        isAllDay = false;
}
