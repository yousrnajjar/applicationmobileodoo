class UserInfo {
  final Map<String, dynamic> info;

  UserInfo(this.info);

  int get uid {
    if (!info.containsKey("uid") || info["uid"] == false) return -1;
    return info['uid'];
  }

  bool isAuthenticated() {
    return uid != -1;
    //return info.containsKey("uid") && (info["uid"] != null);
  }
}
