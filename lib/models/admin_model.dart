import 'package:shared_preferences/shared_preferences.dart';

class AuthModel {
  bool? status;
  String? token;
  String? message;

  int? id;
  String? namaUser;
  String? username;
  String? role;
  String? phone;

  AuthModel({
    this.status,
    this.token,
    this.message,
    this.id,
    this.namaUser,
    this.username,
    this.role,
    this.phone,
  });

  // Parsing dari API JSON
  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      status: json['status'],
      token: json['token'],
      message: json['message'],
      id: json['id'],
      namaUser: json['name'] ?? json['nama_user'],
      username: json['username'],
      role: json['role'],
      phone: json['phone'],
    );
  }

  // Convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "token": token,
      "message": message,
      "id": id,
      "name": namaUser,
      "username": username,
      "role": role,
      "phone": phone,
    };
  }

  // Simpan ke SharedPreferences
  Future<void> saveToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool("status", status ?? false);
    await prefs.setString("token", token ?? "");
    await prefs.setString("message", message ?? "");
    await prefs.setInt("id", id ?? 0);
    await prefs.setString("nama_user", namaUser ?? "");
    await prefs.setString("username", username ?? "");
    await prefs.setString("role", role ?? "");
    await prefs.setString("phone", phone ?? "");
  }

  // Ambil dari SharedPreferences
  static Future<AuthModel> getFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return AuthModel(
      status: prefs.getBool("status") ?? false,
      token: prefs.getString("token") ?? "",
      message: prefs.getString("message") ?? "",
      id: prefs.getInt("id") ?? 0,
      namaUser: prefs.getString("nama_user") ?? "",
      username: prefs.getString("username") ?? "",
      role: prefs.getString("role") ?? "",
      phone: prefs.getString("phone") ?? "",
    );
  }

  // Hapus semua data (logout)
  static Future<void> clearPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("status") ?? false;
  }
}