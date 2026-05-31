import 'dart:convert';
import 'package:amerta_pay/services/url.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class PaymentService {
  final AuthService _auth = AuthService();

  Future<Map<String, dynamic>> getAll({int page = 1, int quantity = 100, String search = ''}) async {
    try {
      final headers = await _auth.getAuthHeaders();
      final uri = Uri.parse('$baseUrl/payments?page=$page&quantity=$quantity&search=$search');
      final response = await http.get(uri, headers: headers);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'status': true, 'data': data['data'] ?? data};
      }
      return {'status': false, 'message': data['message'] ?? 'Gagal memuat pembayaran'};
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getById(int id) async {
    try {
      final headers = await _auth.getAuthHeaders();
      final uri = Uri.parse('$baseUrl/payments/$id');
      final response = await http.get(uri, headers: headers);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'status': true, 'data': data['data'] ?? data};
      }
      return {'status': false, 'message': data['message'] ?? 'Gagal memuat detail'};
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  // Verifikasi pembayaran (PATCH)
  Future<Map<String, dynamic>> verify(int paymentId) async {
    try {
      final headers = await _auth.getAuthHeaders();
      final uri = Uri.parse('$baseUrl/payments/$paymentId');
      final response = await http.patch(uri, headers: headers);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'status': true, 'message': 'Pembayaran berhasil diverifikasi'};
      }
      return {'status': false, 'message': data['message'] ?? 'Gagal verifikasi'};
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  // Tolak pembayaran (DELETE)
  Future<Map<String, dynamic>> reject(int paymentId) async {
    try {
      final headers = await _auth.getAuthHeaders();
      final uri = Uri.parse('$baseUrl/payments/$paymentId');
      final response = await http.delete(uri, headers: headers);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'status': true, 'message': 'Pembayaran berhasil ditolak'};
      }
      return {'status': false, 'message': data['message'] ?? 'Gagal menolak'};
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  // Get payment proof image URL
  String getProofImageUrl(String filename) {
    return '$baseUrl/payment-proof/$filename';
  }
}