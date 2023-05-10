
class Holyday {
  int? id;
  dynamic state;
  dynamic holidayStatusId;
  dynamic name;
  dynamic dateFrom;
  dynamic dateTo;
  dynamic durationDisplay;
  dynamic payslipStatus;
  dynamic employeeId;
  dynamic userId;

  Holyday.fromJSON(Map<String, dynamic> data) {
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

