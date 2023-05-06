class UserInfo {
  final Map<String, dynamic> info;

  UserInfo(this.info);

  bool isAuthenticated() {
    return info.containsKey("uid") && (info["uid"] != null);
  }
}
