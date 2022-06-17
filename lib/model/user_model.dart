class user_model {
  String? userName;
  String? password;

  user_model.fromJson(var jsonData) {
    password = jsonData['password'];
    userName = jsonData['userName'];
  }
}
