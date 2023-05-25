import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/ir/models/user_info.dart';


class UserInfoNotifier extends StateNotifier<UserInfo> {
  UserInfoNotifier() : super(UserInfo(<String, dynamic>{}));

  void setUserInfo(UserInfo userInfo) {
    state = userInfo;
  }
}

final userInfoProvider = StateNotifierProvider<UserInfoNotifier, UserInfo >(
  (ref) => UserInfoNotifier()
);
