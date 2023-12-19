import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/models/holidays.dart';
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
    var datas = _getDataSource();
    return SfCalendar(
      backgroundColor: kLightGrey,
      // frensh TimeZone
      timeZone: 'Europe/Paris',
      view: CalendarView.month,
      headerDateFormat: 'MMMM',
      dataSource: HolidayDataSource(datas),
      headerStyle: const CalendarHeaderStyle(
        textAlign: TextAlign.center,
        textStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      viewHeaderStyle: const ViewHeaderStyle(
        dayTextStyle: TextStyle(
          color: kGrey,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        dateTextStyle: TextStyle(
          color: kGrey,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      appointmentBuilder: buildHolidayCellDetail,
      monthCellBuilder: (context, details) =>
          buildMonthCell(context, details, datas),
      timeRegionBuilder: buildTimeRegion,
      resourceViewHeaderBuilder: buildResourceViewHeader,
      scheduleViewMonthHeaderBuilder: buildScheduleViewMonthHeader,
      monthViewSettings: const MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        showAgenda: false,
        numberOfWeeksInView: 6,
        agendaViewHeight: 100,
        appointmentDisplayCount: 1,
        agendaStyle: AgendaStyle(
          backgroundColor: kLightGrey,
        ),
      ),
    );
  }

  List<HolidayToDisplay> _getDataSource() {
    final List<HolidayToDisplay> holidaysToDisplay =
        widget.holidays.map((e) => HolidayToDisplay.fromHoliday(e)).toList();
    return holidaysToDisplay;
  }

  Color sumColor(Color c1, Color c2) {
    return Color.fromARGB(
      255,
      (c1.red + c2.red) ~/ 2,
      (c1.green + c2.green) ~/ 2,
      (c1.blue + c2.blue) ~/ 2,
    );
  }

  Widget buildMonthCell(BuildContext context, MonthCellDetails details,
      List<HolidayToDisplay> datas) {
    Color meanColor = Colors.transparent;
    Color textColor = kGrey;
    String dayDisplay = '';
    bool isThisMonth = details.date.month != details.visibleDates[0].month &&
        details.date.month !=
            details.visibleDates[details.visibleDates.length - 1].month;
    if (isThisMonth) {
      // remove day of another month
      dayDisplay = details.date.day.toString();
      // left justify the day of the month with 0
      if (dayDisplay.length == 1) {
        dayDisplay = '0$dayDisplay';
      }
      if (datas.isNotEmpty) {
        var holidays = datas.where((element) =>
            element.from.day == details.date.day &&
            element.from.month == details.date.month &&
            element.from.year == details.date.year);
        if (holidays.isNotEmpty) {
          textColor = Colors.white;
          // Compute the mean color of the holidays
          meanColor = holidays
              .map((e) => e.background)
              .reduce((value, element) => sumColor(value, element));
        }
      }
    }
    return Container(
      color: meanColor,
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.all(6),
      child: Center(
        child: Text(
          dayDisplay,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildHolidayCellDetail(
      BuildContext context, CalendarAppointmentDetails details) {
    return const Text('');
  }

  Widget buildTimeRegion(BuildContext context, TimeRegionDetails details) {
    return const Text('');
  }

  Widget buildResourceViewHeader(
      BuildContext context, ResourceViewHeaderDetails details) {
    return const Text('');
  }

  Widget buildScheduleViewMonthHeader(
      BuildContext context, ScheduleViewMonthHeaderDetails details) {
    return const Text('');
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

  static HolidayToDisplay fromHoliday(Holiday holiday) {
    final dayFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    //var eventName =   "${holiday.employeeId[1]}, ${holiday.holidayStatusId[1]}, ${holiday.durationDisplay}";
    var eventName = holiday.employeeId[1].substring(0, 2);
    var from = dayFormatter.parse(holiday.dateFrom);
    var to = dayFormatter.parse(holiday.dateTo);
    var background = holiday.color;
    if (kDebugMode) {
      print(background);
      print(from);
      print(to);
    }
    var isAllDay = false;
    return HolidayToDisplay(eventName, from, to, background, isAllDay);
  }
}
