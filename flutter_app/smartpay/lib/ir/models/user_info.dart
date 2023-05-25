import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/attendance_models.dart';

class User {
  final Map<String, dynamic> info;
  EmployeeAllInfo? employee;
  User(this.info);

  int get uid {
    if (!info.containsKey("uid") || info["uid"] == false) return -1;
    return info['uid'];
  }

  dynamic get employeeId {
    if (!info.containsKey("employee_id") || info["employee_id"] == false) {
      return info['employee_id'];
    }
  }

  Future<List<dynamic>> getEmployeeData() async {
    var data = await OdooModel("hr.employee").searchRead(
      domain: [
        ['user_id', '=', uid]
      ],
      limit: 1,
      fieldNames: ['id', 'name']
    );
    if (data.isNotEmpty){
      return data;
    }
    return [];
  }

  get name => info['name'];

  bool get isAdmin => info['is_admin'];

  bool isAuthenticated() {
    return uid != -1;
    //return info.containsKey("uid") && (info["uid"] != null);
  }

  String getImageUrl(String baseUrl) {
    return "$baseUrl/web/image?model=res.users&id=$uid&field=image_128";
  }
}
