import 'dart:convert';
import 'package:amerta_pay/models/response_data_list.dart';
import 'package:amerta_pay/models/response_data_map.dart';
import 'package:http/http.dart' as http;

import '../models/bill_model.dart';
import 'auth_service.dart';
import 'url.dart';

class BillService {
  final AuthService _auth = AuthService();

  // ==========================================================
  // GET ALL BILLS (ADMIN)
  // ==========================================================
  Future<Map<String, dynamic>> getAll({
    int page = 1,
    int quantity = 10,
    String search = '',
  }) async {
    try {
      final headers = await _auth.getAuthHeaders();

      final uri = Uri.parse(
        '$baseUrl/bills?page=$page&quantity=$quantity&search=$search',
      );

      final response = await http.get(
        uri,
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final raw = data['data'] ?? data;

        List<BillModel> bills = [];

        if (raw is List) {
          bills = raw
              .map((e) => BillModel.fromJson(e))
              .toList();
        } else if (raw is Map &&
            raw['data'] is List) {
          bills = (raw['data'] as List)
              .map((e) => BillModel.fromJson(e))
              .toList();
        }

        return {
          'status': true,
          'data': bills,
          'meta': data['meta'],
        };
      }

      return {
        'status': false,
        'message':
            data['message'] ??
                'Gagal memuat tagihan',
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }

  // ==========================================================
  // GET BILL BY ID (ADMIN)
  // ==========================================================
  Future<Map<String, dynamic>> getById(
    int id,
  ) async {
    try {
      final headers = await _auth.getAuthHeaders();

      final uri =
          Uri.parse('$baseUrl/bills/$id');

      final response = await http.get(
        uri,
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final raw = data['data'] ?? data;

        return {
          'status': true,
          'data': raw,
        };
      }

      return {
        'status': false,
        'message':
            data['message'] ??
                'Gagal memuat detail',
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }

  // ==========================================================
  // CREATE BILL (ADMIN)
  // ==========================================================
  Future<Map<String, dynamic>> create({
    required int customerId,
    required int month,
    required int year,
    required String measurementNumber,
    required int usageValue,
  }) async {
    try {
      final headers = await _auth.getAuthHeaders();

      final uri =
          Uri.parse('$baseUrl/bills');

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'customer_id': customerId,
          'month': month,
          'year': year,
          'measurement_number':
              measurementNumber,
          'usage_value': usageValue,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return {
          'status': true,
          'message':
              'Tagihan berhasil ditambahkan',
        };
      }

      return {
        'status': false,
        'message':
            data['message'] ??
                'Gagal menambah tagihan',
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }

  // ==========================================================
  // UPDATE BILL (ADMIN)
  // ==========================================================
  Future<Map<String, dynamic>> update(
    int id,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _auth.getAuthHeaders();

      final uri =
          Uri.parse('$baseUrl/bills/$id');

      final response = await http.patch(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message':
              'Tagihan berhasil diperbarui',
        };
      }

      return {
        'status': false,
        'message':
            data['message'] ??
                'Gagal memperbarui',
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }

  // ==========================================================
  // DELETE BILL (ADMIN)
  // ==========================================================
  Future<Map<String, dynamic>> delete(
    int id,
  ) async {
    try {
      final headers = await _auth.getAuthHeaders();

      final uri =
          Uri.parse('$baseUrl/bills/$id');

      final response =
          await http.delete(
        uri,
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message':
              'Tagihan berhasil dihapus',
        };
      }

      return {
        'status': false,
        'message':
            data['message'] ??
                'Gagal menghapus',
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }

  // ==========================================================
  // GET MY BILLS (CUSTOMER)
  // ==========================================================
  Future<ResponseDataList> getMyBills({
    int page = 1,
    int quantity = 10,
    String search = '',
  }) async {
    try {
      final headers = await _auth.getAuthHeaders();

      final uri = Uri.parse(
        '$baseUrl/bills/me?page=$page&quantity=$quantity&search=$search',
      );

      final response = await http.get(
        uri,
        headers: headers,
      );

      final data =
          jsonDecode(response.body);

      if (response.statusCode == 200) {
        final raw =
            data['data'] ?? [];

        List<BillModel> bills =
            [];

        if (raw is List) {
          bills = raw
              .map((e) =>
                  BillModel.fromJson(e))
              .toList();
        }

        return ResponseDataList(
          status: true,
          message: 'Sukses',
          data: bills,
        );
      }

      return ResponseDataList(
        status: false,
        message:
            data['message'] ??
                'Gagal mengambil tagihan',
      );
    } catch (e) {
      return ResponseDataList(
        status: false,
        message: 'Error: $e',
      );
    }
  }

  // ==========================================================
  // GET MY BILL DETAIL
  // ==========================================================
  Future<ResponseDataMap>
      getMyBillDetail(
    int billId,
  ) async {
    try {
      final headers = await _auth.getAuthHeaders();

      final uri = Uri.parse(
        '$baseUrl/bills/me/$billId',
      );

      final response = await http.get(
        uri,
        headers: headers,
      );

      final data =
          jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ResponseDataMap(
          status: true,
          message: 'Sukses',
          data: Map<String, dynamic>.from(
            data['data'] ?? data,
          ),
        );
      }

      return ResponseDataMap(
        status: false,
        message:
            data['message'] ??
                'Gagal mengambil detail tagihan',
      );
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message: 'Error: $e',
      );
    }
  }

  // ==========================================================
  // GET UNPAID BILLS
  // ==========================================================
  Future<ResponseDataList>
      getUnpaidBills() async {
    try {
      final result =
          await getMyBills(
        quantity: 100,
      );

      if (!result.status) {
        return result;
      }

      final List<BillModel> bills =
          List<BillModel>.from(
        result.data ?? [],
      );

      final unpaidBills =
          bills.where((bill) {
        return !bill.paid;
      }).toList();

      return ResponseDataList(
        status: true,
        message: 'Sukses',
        data: unpaidBills,
      );
    } catch (e) {
      return ResponseDataList(
        status: false,
        message: 'Error: $e',
      );
    }
  }
}