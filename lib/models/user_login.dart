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
  Future prefs() async {

    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    prefs.setBool("status", status ?? false);

    prefs.setString("token", token ?? "");

    prefs.setString("message", message ?? "");

    prefs.setInt("id", id ?? 0);

    prefs.setString("username", username ?? "");

    prefs.setString("role", role ?? "");

    prefs.setString("name", name ?? "");
  }

  // AMBIL DATA LOGIN
  Future getUserLogin() async {

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
  Future logout() async {

    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.clear();
  }
}