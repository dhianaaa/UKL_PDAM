import 'package:shared_preferences/shared_preferences.dart';

class UserLogin {
  bool? status;
  String? token;
  String? message;
  int? id;
  String? username;
  String? role;
  String? name;

  UserLogin({
    this.status,
    this.token,
    this.message,
    this.id,
    this.username,
    this.role,
    this.name,
  });

  // SIMPAN SESSION LOGIN
  Future<void> prefs() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool("status", status ?? false);

    await prefs.setString("token", token ?? "");

    await prefs.setString("message", message ?? "");

    await prefs.setInt("id", id ?? 0);

    await prefs.setString("username", username ?? "");

    await prefs.setString("role", role ?? "");

    await prefs.setString("name", name ?? "");
  }

  // AMBIL DATA LOGIN
  Future<UserLogin> getUserLogin() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    UserLogin userLogin = UserLogin(
      status: prefs.getBool("status") ?? false,
      token: prefs.getString("token") ?? "",
      message: prefs.getString("message") ?? "",
      id: prefs.getInt("id") ?? 0,
      username: prefs.getString("username") ?? "",
      role: prefs.getString("role") ?? "",
      name: prefs.getString("name") ?? "",
    );

    return userLogin;
  }

  // LOGOUT
  Future<void> logout() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.clear();
  }
}