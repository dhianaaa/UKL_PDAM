import 'dart:convert';
import 'dart:io';

import 'package:amerta_pay/models/response_data_list.dart';
import 'package:amerta_pay/models/response_data_map.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/payment_model.dart';
import 'auth_service.dart';
import 'url.dart';

class PaymentService {
  final AuthService _auth = AuthService();

  // ==========================================================
  // GET ALL PAYMENTS (ADMIN)
  // ==========================================================
  Future<Map<String, dynamic>> getAll({
    int page = 1,
    int quantity = 100,
    String search = '',
  }) async {
    try {
      final headers = await _auth.getAuthHeaders();

      final uri = Uri.parse(
        '$baseUrl/payments?page=$page&quantity=$quantity&search=$search',
      );

      final response = await http.get(
        uri,
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'data': data['data'] ?? data,
        };
      }

      return {
        'status': false,
        'message':
            data['message'] ??
                'Gagal memuat pembayaran',
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }

  // ==========================================================
  // GET PAYMENT BY ID (ADMIN)
  // ==========================================================
  Future<Map<String, dynamic>> getById(
    int id,
  ) async {
    try {
      final headers = await _auth.getAuthHeaders();

      final uri = Uri.parse(
        '$baseUrl/payments/$id',
      );

      final response = await http.get(
        uri,
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'data': data['data'] ?? data,
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
  // VERIFY PAYMENT (ADMIN)
  // ==========================================================
  Future<Map<String, dynamic>> verify(
    
    int paymentId,
  ) async {
    try {
      final headers = await _auth.getAuthHeaders();

      final uri = Uri.parse(
        '$baseUrl/payments/$paymentId',
      );

      final response = await http.patch(
        uri,
        headers: headers,
      );

      final data = jsonDecode(response.body);
      print('VERIFY PAYMENT RESPONSE: $data');

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message':
              'Pembayaran berhasil diverifikasi',
        };
      }

      return {
        'status': false,
        'message':
            data['message'] ??
                'Gagal verifikasi',
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
    
  }

  // ==========================================================
  // REJECT PAYMENT (ADMIN)
  // ==========================================================
  Future<Map<String, dynamic>> reject(
    int paymentId,
  ) async {
    try {
      final headers = await _auth.getAuthHeaders();

      final uri = Uri.parse(
        '$baseUrl/payments/$paymentId',
      );

      final response = await http.delete(
        uri,
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message':
              'Pembayaran berhasil ditolak',
        };
      }

      return {
        'status': false,
        'message':
            data['message'] ??
                'Gagal menolak',
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }

  // ==========================================================
  // CREATE PAYMENT (CUSTOMER)
  // ==========================================================
  Future<ResponseDataMap> createPayment({
    required int billId,
    required File file,
  }) async {
    try {
      final headers = await _auth.getAuthHeaders();

      final uri =
          Uri.parse('$baseUrl/payments');

      final request =
          http.MultipartRequest(
        'POST',
        uri,
      );

      request.headers.addAll(headers);

      request.fields['bill_id'] =
          billId.toString();

      final ext = file.path
          .split('.')
          .last
          .toLowerCase();

      MediaType mediaType;

      if (ext == 'pdf') {
        mediaType =
            MediaType(
          'application',
          'pdf',
        );
      } else if (ext == 'png') {
        mediaType =
            MediaType(
          'image',
          'png',
        );
      } else {
        mediaType =
            MediaType(
          'image',
          'jpeg',
        );
      }

      request.files.add(
        await http.MultipartFile
            .fromPath(
          'file',
          file.path,
          contentType:
              mediaType,
        ),
      );

      final streamedResponse =
          await request.send();

      final response =
          await http.Response
              .fromStream(
        streamedResponse,
      );

      final data =
          jsonDecode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return ResponseDataMap(
          status: true,
          message:
              'Pembayaran berhasil dikirim',
          data: data is Map
              ? Map<String, dynamic>.from(
                  data)
              : null,
        );
      }

      return ResponseDataMap(
        status: false,
        message:
            data['message'] ??
                'Gagal mengirim pembayaran',
      );
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message: 'Error: $e',
      );
    }
  }

  // ==========================================================
  // GET MY PAYMENTS (CUSTOMER)
  // ==========================================================
  Future<ResponseDataList> getMyPayments({
    
    int page = 1,
    int quantity = 100,
  }) async {
    try {
      final headers = await _auth.getAuthHeaders();

      final uri = Uri.parse(
        '$baseUrl/payments/me?page=$page&quantity=$quantity',
      );

      final response = await http.get(
        uri,
        headers: headers,
      );

      final data =
          jsonDecode(response.body);
          print('GET MY PAYMENTS RESPONSE: $data');

      if (response.statusCode == 200) {
        final raw =
            data['data'] ?? [];

        List<PaymentModel>
            payments = [];

        if (raw is List) {
          payments = raw
              .map(
                (e) =>
                    PaymentModel
                        .fromJson(e),
              )
              .toList();
        }

        return ResponseDataList(
          status: true,
          message: 'Sukses',
          data: payments,
        );
      }

      return ResponseDataList(
        status: false,
        message:
            data['message'] ??
                'Gagal mengambil riwayat',
      );
    } catch (e) {
      return ResponseDataList(
        status: false,
        message: 'Error: $e',
      );
    }
  }

  // ==========================================================
  // GET MY PAYMENT DETAIL
  // ==========================================================
  Future<ResponseDataMap>
      getMyPaymentDetail(
    int paymentId,
  ) async {
    try {
      final headers = await _auth.getAuthHeaders();

      final uri = Uri.parse(
        '$baseUrl/payments/me/$paymentId',
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
                'Gagal mengambil detail',
      );
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message: 'Error: $e',
      );
    }
  }

  // ==========================================================
  // PAYMENT PROOF URL
  // ==========================================================
  String getProofImageUrl(
    String filename,
  ) {
    return '$baseUrl/payment-proof/$filename';
  }
}