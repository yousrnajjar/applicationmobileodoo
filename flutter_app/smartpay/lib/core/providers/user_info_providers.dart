import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/ir/models/user.dart';


class UserInfoNotifier extends StateNotifier<User> {
  UserInfoNotifier() : super(User(<String, dynamic>{}));

  void setUserInfo(User userInfo) {
    state = userInfo;
  }
}

final userInfoProvider = StateNotifierProvider<UserInfoNotifier, User >(
  (ref) => UserInfoNotifier()
);
