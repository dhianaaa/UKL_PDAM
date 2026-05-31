import 'dart:convert';
import 'package:amerta_pay/services/url.dart';
import 'package:http/http.dart' as http;
import '../models/customer_model.dart';
import 'auth_service.dart';

class CustomerService {
  final AuthService _auth = AuthService();

  Future<Map<String, dynamic>> getAll({int page = 1, int quantity = 10, String search = ''}) async {
    try {
      final headers = await _auth.getAuthHeaders();
      final uri = Uri.parse('$baseUrl/customers?page=$page&quantity=$quantity&search=$search');
      final response = await http.get(uri, headers: headers);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final raw = data['data'] ?? data;
        List<CustomerModel> customers = [];
        if (raw is List) {
          customers = raw.map((e) => CustomerModel.fromJson(e)).toList();
        } else if (raw is Map && raw['data'] is List) {
          customers = (raw['data'] as List).map((e) => CustomerModel.fromJson(e)).toList();
        }
        return {'status': true, 'data': customers, 'meta': data['meta']};
      }
      return {'status': false, 'message': data['message'] ?? 'Gagal memuat customer'};
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getById(int id) async {
    try {
      final headers = await _auth.getAuthHeaders();
      final uri = Uri.parse('$baseUrl/customers/$id');
      final response = await http.get(uri, headers: headers);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final raw = data['data'] ?? data;
        return {'status': true, 'data': CustomerModel.fromJson(raw)};
      }
      return {'status': false, 'message': data['message'] ?? 'Gagal memuat customer'};
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> create({
    required String username,
    required String password,
    required String customerNumber,
    required String name,
    required String phone,
    required String address,
    required int serviceId,
  }) async {
    try {
      final headers = await _auth.getAuthHeaders();
      final uri = Uri.parse('$baseUrl/customers');
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'username': username,
          'password': password,
          'customer_number': customerNumber,
          'name': name,
          'phone': phone,
          'address': address,
          'service_id': serviceId,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'status': true, 'message': 'Customer berhasil ditambahkan'};
      }
      return {'status': false, 'message': data['message'] ?? 'Gagal menambah customer'};
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> body) async {
    try {
      final headers = await _auth.getAuthHeaders();
      final uri = Uri.parse('$baseUrl/customers/$id');
      final response = await http.patch(uri, headers: headers, body: jsonEncode(body));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'status': true, 'message': 'Customer berhasil diperbarui'};
      }
      return {'status': false, 'message': data['message'] ?? 'Gagal memperbarui'};
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> delete(int id) async {
    try {
      final headers = await _auth.getAuthHeaders();
      final uri = Uri.parse('$baseUrl/customers/$id');
      final response = await http.delete(uri, headers: headers);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'status': true, 'message': 'Customer berhasil dihapus'};
      }
      return {'status': false, 'message': data['message'] ?? 'Gagal menghapus'};
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }
}