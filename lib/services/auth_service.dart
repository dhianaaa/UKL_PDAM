import 'dart:convert';
import 'package:amerta_pay/models/response_data_map.dart';
import 'package:http/http.dart' as http;
import '../models/auth_model.dart';
import 'url.dart';

class AuthService {
  // ─────────────────────────────────────────────────────────────
  //  LOGIN (Admin & Customer pakai endpoint yang sama: POST /auth)
  //  Body: { "username": "...", "password": "..." }
  //  Header: app-key
  // ─────────────────────────────────────────────────────────────
  Future<ResponseDataMap> login(String username, String password) async {
    try {
      var uri = Uri.parse('$baseUrl/auth');
      var response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json', 'app-key': appKey},
        body: jsonEncode({"username": username, "password": password}),
      );

      var body = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Respons sukses dari backend PDAM
        // Sesuaikan field sesuai response API kamu
        String role = body['data']?['role'] ?? body['role'] ?? '';
        String token = body['token'] ?? body['data']?['token'] ?? '';
        int id = body['data']?['id'] ?? 0;
        String nama =
            body['data']?['name'] ?? body['data']?['username'] ?? username;
        String uname = body['data']?['username'] ?? username;

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

        return ResponseDataMap(
          status: true,
          message: 'Login berhasil',
          data: body,
        );
      } else {
        String msg = body['message'] ?? 'Username atau password salah';
        return ResponseDataMap(status: false, message: msg);
      }
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message: 'Koneksi gagal: ${e.toString()}',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  REGISTER ADMIN  (POST /admins)
  //  Header: app-key
  //  Body: { username, password, name, phone }
  // ─────────────────────────────────────────────────────────────
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
        headers: {'Content-Type': 'application/json', 'app-key': appKey},
        body: jsonEncode({
          "username": username,
          "password": password,
          "name": name,
          "phone": phone,
        }),
      );

      var body = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ResponseDataMap(
          status: true,
          message: body['message'] ?? 'Registrasi admin berhasil',
          data: body,
        );
      } else {
        String msg = body['message'] ?? 'Registrasi gagal';
        return ResponseDataMap(status: false, message: msg);
      }
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message: 'Koneksi gagal: ${e.toString()}',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  REGISTER CUSTOMER  (POST /customers)
  //  Hanya bisa dilakukan ADMIN (bearer token + app-key)
  //  Body: { username, password, customer_number(NIK), address,
  //          service_id, name, phone }
  // ─────────────────────────────────────────────────────────────
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
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "username": username,
          "password": password,
          "customer_number": customerNumber,
          "address": address,
          "service_id": serviceId,
          "name": name,
          "phone": phone,
        }),
      );

      var body = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ResponseDataMap(
          status: true,
          message: body['message'] ?? 'Customer berhasil didaftarkan',
          data: body,
        );
      } else {
        String msg = body['message'] ?? 'Registrasi customer gagal';
        return ResponseDataMap(status: false, message: msg);
      }
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message: 'Koneksi gagal: ${e.toString()}',
      );
    }
  }
}
