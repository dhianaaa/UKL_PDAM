import 'dart:convert';
import 'package:amerta_pay/models/response_data_map.dart';
import 'package:amerta_pay/services/url.dart';
import 'package:http/http.dart' as http;
import '../models/admin_model.dart';
import '../models/auth_model.dart' hide AuthModel;

class AdminService {
  Future<Map<String, String>> _headers() async {
    final auth = await AuthModel.getFromPrefs();
    return {
      'Content-Type': 'application/json',
      'app-key': appKey,
      'Authorization': 'Bearer ${auth.token}',
    };
  }

  // ── GET /admins/me ────────────────────────────────────────────
  Future<ResponseDataMap> getMe() async {
    try {
      final headers = await _headers();
      final res =
          await http.get(Uri.parse('$baseUrl/admins/me'), headers: headers);
      final body = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return ResponseDataMap(status: true, message: 'OK', data: body['data'] ?? body);
      }
      return ResponseDataMap(
          status: false, message: body['message'] ?? 'Gagal memuat profil');
    } catch (e) {
      return ResponseDataMap(status: false, message: 'Koneksi gagal: $e');
    }
  }

  // ── GET /customers?page=1&quantity=10 ────────────────────────
  Future<ResponseDataMap> getDashboardStats() async {
    try {
      final headers = await _headers();

      // Total customers
      final custRes = await http.get(
          Uri.parse('$baseUrl/customers?page=1&quantity=1'),
          headers: headers);
      final custBody = jsonDecode(custRes.body);
      final totalCustomer = custBody['total'] ?? custBody['meta']?['total'] ?? 0;

      // Services
      final svcRes = await http.get(
          Uri.parse('$baseUrl/services'), headers: headers);
      final svcBody = jsonDecode(svcRes.body);
      final List svcList = svcBody['data'] ?? [];

      // Bills (unverified payments)
      final billRes = await http.get(
          Uri.parse('$baseUrl/bills?page=1&quantity=100'),
          headers: headers);
      final billBody = jsonDecode(billRes.body);
      final List billList = billBody['data'] ?? [];
      final unverified = billList
          .where((b) => b['status'] == false || b['status'] == 'BELUM')
          .length;

      return ResponseDataMap(
        status: true,
        message: 'OK',
        data: {
          'total_customer': totalCustomer,
          'total_layanan': svcList.length,
          'pembayaran_belum': unverified,
          'recent_bills': billList.take(4).toList(),
          'recent_customers': [], // filled separately if needed
        },
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: 'Gagal memuat dashboard: $e');
    }
  }

  // ── GET recent customers ──────────────────────────────────────
  Future<List> getRecentCustomers() async {
    try {
      final headers = await _headers();
      final res = await http.get(
          Uri.parse('$baseUrl/customers?page=1&quantity=5'),
          headers: headers);
      final body = jsonDecode(res.body);
      return body['data'] ?? [];
    } catch (_) {
      return [];
    }
  }

  // ── UPDATE admin profile  PATCH /admins/:id ───────────────────
  Future<ResponseDataMap> updateProfile({
    required int id,
    String? name,
    String? phone,
    String? password,
  }) async {
    try {
      final headers = await _headers();
      final Map<String, dynamic> payload = {};
      if (name != null && name.isNotEmpty) payload['name'] = name;
      if (phone != null && phone.isNotEmpty) payload['phone'] = phone;
      if (password != null && password.isNotEmpty) payload['password'] = password;

      final res = await http.patch(
        Uri.parse('$baseUrl/admins/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      final body = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return ResponseDataMap(
            status: true,
            message: body['message'] ?? 'Profil berhasil diupdate',
            data: body);
      }
      return ResponseDataMap(
          status: false, message: body['message'] ?? 'Gagal update');
    } catch (e) {
      return ResponseDataMap(status: false, message: 'Koneksi gagal: $e');
    }
  }
}