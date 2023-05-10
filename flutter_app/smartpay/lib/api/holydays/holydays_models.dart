
class Holydays {
  int? id;
  String? state;
  dynamic holidayStatusId;
  String? name;
  String? dateFrom;
  String? dateTo;
  String? durationDisplay;
  dynamic payslipStatus;
  dynamic employeeId;
  dynamic userId;

  Holydays.fromJSON(Map<String, dynamic> data) {
    id = data["id"];
    state = data["state"];
    holidayStatusId = data["holiday_status_id"];
    name = data["name"];
    dateFrom = data["date_from"];
    dateTo = data["date_to"];
    durationDisplay = data["duration_display"];
    payslipStatus = data["payslip_status"];
    employeeId = data["employee_id"];
    userId = data["user_id"];
  }
  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    
    return data;
  }
}

