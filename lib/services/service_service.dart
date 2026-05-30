import 'dart:convert';
import 'package:amerta_pay/models/response_data_map.dart';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';
import '../models/auth_model.dart';
import 'url.dart';

class ServiceService {
  // ── Helper: get auth headers ─────────────────────────────────
  Future<Map<String, String>> _headers() async {
    final auth = await AuthModel.getFromPrefs();
    return {
      'Content-Type': 'application/json',
      'app-key': appKey,
      'Authorization': 'Bearer ${auth.token}',
    };
  }

  // ── GET ALL SERVICES  GET /services ──────────────────────────
  Future<ResponseDataList> getAll() async {
    try {
      final headers = await _headers();
      final res = await http.get(Uri.parse('$baseUrl/services'), headers: headers);
      final body = jsonDecode(res.body);

      if (res.statusCode == 200) {
        final List raw = body['data'] ?? [];
        final list = raw.map((e) => ServiceModel.fromJson(e)).toList();
        return ResponseDataList(status: true, message: 'Berhasil', data: list);
      }
      return ResponseDataList(
          status: false, message: body['message'] ?? 'Gagal memuat layanan');
    } catch (e) {
      return ResponseDataList(status: false, message: 'Koneksi gagal: $e');
    }
  }

  // ── GET BY ID  GET /services/:id ─────────────────────────────
  Future<ResponseDataMap> getById(int id) async {
    try {
      final headers = await _headers();
      final res =
          await http.get(Uri.parse('$baseUrl/services/$id'), headers: headers);
      final body = jsonDecode(res.body);

      if (res.statusCode == 200) {
        final svc = ServiceModel.fromJson(body['data'] ?? body);
        return ResponseDataMap(
            status: true, message: 'Berhasil', data: body);
      }
      return ResponseDataMap(
          status: false, message: body['message'] ?? 'Gagal');
    } catch (e) {
      return ResponseDataMap(status: false, message: 'Koneksi gagal: $e');
    }
  }

  // ── CREATE  POST /services ────────────────────────────────────
  Future<ResponseDataMap> create({
    required String name,
    required int minUsage,
    required int maxUsage,
    required int price,
  }) async {
    try {
      final headers = await _headers();
      final res = await http.post(
        Uri.parse('$baseUrl/services'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'min_usage': minUsage,
          'max_usage': maxUsage,
          'price': price,
        }),
      );
      final body = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        return ResponseDataMap(
            status: true,
            message: body['message'] ?? 'Layanan berhasil ditambahkan',
            data: body);
      }
      return ResponseDataMap(
          status: false, message: body['message'] ?? 'Gagal menambah layanan');
    } catch (e) {
      return ResponseDataMap(status: false, message: 'Koneksi gagal: $e');
    }
  }

  // ── UPDATE  PATCH /services/:id ──────────────────────────────
  Future<ResponseDataMap> update({
    required int id,
    String? name,
    int? minUsage,
    int? maxUsage,
    int? price,
  }) async {
    try {
      final headers = await _headers();
      final Map<String, dynamic> payload = {};
      if (name != null) payload['name'] = name;
      if (minUsage != null) payload['min_usage'] = minUsage;
      if (maxUsage != null) payload['max_usage'] = maxUsage;
      if (price != null) payload['price'] = price;

      final res = await http.patch(
        Uri.parse('$baseUrl/services/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      final body = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return ResponseDataMap(
            status: true,
            message: body['message'] ?? 'Layanan berhasil diupdate',
            data: body);
      }
      return ResponseDataMap(
          status: false, message: body['message'] ?? 'Gagal update layanan');
    } catch (e) {
      return ResponseDataMap(status: false, message: 'Koneksi gagal: $e');
    }
  }

  // ── DELETE  DELETE /services/:id ─────────────────────────────
  Future<ResponseDataMap> delete(int id) async {
    try {
      final headers = await _headers();
      final res = await http.delete(
          Uri.parse('$baseUrl/services/$id'), headers: headers);
      final body = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return ResponseDataMap(
            status: true,
            message: body['message'] ?? 'Layanan berhasil dihapus',
            data: body);
      }
      return ResponseDataMap(
          status: false, message: body['message'] ?? 'Gagal menghapus');
    } catch (e) {
      return ResponseDataMap(status: false, message: 'Koneksi gagal: $e');
    }
  }
}