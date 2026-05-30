import 'package:shared_preferences/shared_preferences.dart';

class AuthModel {
  bool? status;
  String? token;
  String? message;
  int? id;
  String? name;
  String? username;
  String? role; // "ADMIN" | "CUSTOMER"

  AuthModel({
    this.status,
    this.token,
    this.message,
    this.id,
    this.name,
    this.username,
    this.role,
  });

  /// Simpan data login ke SharedPreferences
  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('status', status ?? false);
    await prefs.setString('token', token ?? '');
    await prefs.setString('message', message ?? '');
    await prefs.setInt('id', id ?? 0);
    await prefs.setString('name', name ?? '');
    await prefs.setString('username', username ?? '');
    await prefs.setString('role', role ?? '');
  }

  /// Ambil data login dari SharedPreferences
  static Future<AuthModel> getFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    return AuthModel(
      status: prefs.getBool('status') ?? false,
      token: prefs.getString('token') ?? '',
      message: prefs.getString('message') ?? '',
      id: prefs.getInt('id') ?? 0,
      name: prefs.getString('name') ?? '',
      username: prefs.getString('username') ?? '',
      role: prefs.getString('role') ?? '',
    );
  }

  /// Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    bool status = prefs.getBool('status') ?? false;
    String token = prefs.getString('token') ?? '';

    return status && token.isNotEmpty;
  }

  /// Hapus session (logout)
  static Future<void> clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }
}