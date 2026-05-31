import 'dart:convert';
import 'package:amerta_pay/models/response_data_map.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_model.dart';
import 'url.dart';

class AuthService {

  // ==========================================================
  // LOGIN
  // ==========================================================
  Future<ResponseDataMap> login(
    String username,
    String password,
  ) async {
    try {
      var uri = Uri.parse('$baseUrl/auth');

      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'app-key': appKey,
        },
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      var body = jsonDecode(response.body);

      if ((response.statusCode == 201 ||
              response.statusCode == 201) &&
          (body['token'] != null ||
              body['data']?['token'] != null)) {
        String role = body['data']?['role'] ??
            body['role'] ??
            '';

        String token = body['token'] ??
            body['data']?['token'] ??
            '';

        int id = body['data']?['id'] ?? 0;

        String nama =
            body['data']?['name'] ??
                body['data']?['username'] ??
                username;

        String uname =
            body['data']?['username'] ??
                username;

        // Simpan ke AuthModel
        AuthModel authModel = AuthModel(
          status: true,
          token: token,
          message: body['message'] ?? 'Login berhasil',
          id: id,
          name: nama,
          username: uname,
          role: role,
        );

        await authModel.saveToPrefs();

        // Simpan manual ke SharedPreferences
        final prefs =
            await SharedPreferences.getInstance();

        await prefs.setString('token', token);
        await prefs.setString('role', role);
        await prefs.setString(
          'user_data',
          jsonEncode(body['data'] ?? {}),
        );

        return ResponseDataMap(
          status: true,
          message: body['message'] ??
              'Login berhasil',
          data: body,
        );
      }

      return ResponseDataMap(
        status: false,
        message: body['message'] ??
            'Username atau password salah',
      );
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message:
            'Koneksi gagal: ${e.toString()}',
      );
    }
  }

  // ==========================================================
  // GET TOKEN
  // ==========================================================
  Future<String?> getToken() async {
    final prefs =
        await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ==========================================================
  // CEK LOGIN
  // ==========================================================
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null &&
        token.isNotEmpty;
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================
  Future<void> logout() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('user_data');
  }

  // ==========================================================
  // AUTH HEADER
  // ==========================================================
  Future<Map<String, String>>
      getAuthHeaders() async {
    final token = await getToken();

    return {
      'Content-Type': 'application/json',
      'app-key': appKey,
      'Authorization': 'Bearer $token',
    };
  }

  // ==========================================================
  // REGISTER ADMIN
  // ==========================================================
  Future<ResponseDataMap> registerAdmin({
    required String username,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/admins');

      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'app-key': appKey,
        },
        body: jsonEncode({
          "username": username,
          "password": password,
          "name": name,
          "phone": phone,
        }),
      );

      var body = jsonDecode(response.body);

      if (response.statusCode == 201 ||
          response.statusCode == 201) {
        return ResponseDataMap(
          status: true,
          message: body['message'] ??
              'Registrasi admin berhasil',
          data: body,
        );
      }

      return ResponseDataMap(
        status: false,
        message:
            body['message'] ?? 'Registrasi gagal',
      );
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message:
            'Koneksi gagal: ${e.toString()}',
      );
    }
  }

  // ==========================================================
  // REGISTER CUSTOMER
  // ==========================================================
  Future<ResponseDataMap> registerCustomer({
    required String token,
    required String username,
    required String password,
    required String customerNumber,
    required String address,
    required int serviceId,
    required String name,
    required String phone,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/customers');

      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'app-key': appKey,
          'Authorization':
              'Bearer $token',
        },
        body: jsonEncode({
          "username": username,
          "password": password,
          "customer_number":
              customerNumber,
          "address": address,
          "service_id": serviceId,
          "name": name,
          "phone": phone,
        }),
      );

      var body = jsonDecode(response.body);

      if (response.statusCode == 201 ||
          response.statusCode == 201) {
        return ResponseDataMap(
          status: true,
          message: body['message'] ??
              'Customer berhasil didaftarkan',
          data: body,
        );
      }

      return ResponseDataMap(
        status: false,
        message: body['message'] ??
            'Registrasi customer gagal',
      );
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message:
            'Koneksi gagal: ${e.toString()}',
      );
    }
  }
}