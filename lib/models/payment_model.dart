import 'bill_model.dart';

class PaymentModel {
  final int id;
  final int? billId;
  final BillModel? bill;

  final String? paymentDate;
  final String? method;
  final int? amount;
  final String? proofImageUrl;

  final String status;

  final String? createdAt;
  final String? rejectionNote;
  final String? fileName;

  PaymentModel({
    required this.id,
    this.billId,
    this.bill,
    this.paymentDate,
    this.method,
    this.amount,
    this.proofImageUrl,
    required this.status,
    this.createdAt,
    this.rejectionNote,
    this.fileName,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: _toInt(json['id']) ?? 0,

      billId: _toInt(json['bill_id']) ?? _toInt(json['bill']?['id']),

      bill: json['bill'] is Map<String, dynamic>
          ? BillModel.fromJson(Map<String, dynamic>.from(json['bill']))
          : null,

      paymentDate: json['payment_date']?.toString() ??
          json['paid_at']?.toString() ??
          json['verified_at']?.toString(),

      method: json['method']?.toString() ??
          json['payment_method']?.toString() ??
          'Transfer Bank',

      amount: _toInt(json['total_amount']) ??
          _toInt(json['amount']) ??
          _toInt(json['bill']?['amount']),

      proofImageUrl: json['payment_proof']?.toString() ??
          json['proof_image']?.toString() ??
          json['proofImageUrl']?.toString() ??
          json['file_name']?.toString() ??
          json['filename']?.toString(),

      status: _parseStatus(json),

      createdAt: json['created_at']?.toString(),

      rejectionNote: json['rejection_note']?.toString() ??
          json['rejection_reason']?.toString() ??
          json['note']?.toString(),

      fileName: json['file_name']?.toString() ??
          json['filename']?.toString() ??
          json['payment_proof']?.toString(),
    );
  }

  static String _parseStatus(Map<String, dynamic> json) {
    final raw = (json['status'] ??
            json['payment_status'] ??
            json['verification_status'] ??
            json['bill']?['payment_status'])
        ?.toString()
        .toUpperCase();

    final verifiedPayment = json['verified_payment'] == true ||
        json['is_verified'] == true ||
        json['verified'] == true ||
        json['bill']?['verified_payment'] == true;

    if (raw != null && raw.isNotEmpty) {
      if (raw == 'VERIFIED' ||
          raw == 'SUCCESS' ||
          raw == 'LUNAS' ||
          raw == 'PAID' ||
          raw == 'APPROVED' ||
          raw == 'DIBAYAR') {
        return 'VERIFIED';
      }

      if (raw == 'REJECTED' || raw == 'DITOLAK' || raw == 'FAILED') {
        return 'REJECTED';
      }

      if (raw == 'PENDING' ||
          raw == 'WAITING' ||
          raw == 'BELUM_DIVERIFIKASI') {
        return 'PENDING';
      }
    }

    if (verifiedPayment) {
      return 'VERIFIED';
    }

    return 'PENDING';
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  String get statusLabel {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Menunggu Verifikasi';
      case 'VERIFIED':
        return 'Diverifikasi';
      case 'REJECTED':
        return 'Ditolak';
      default:
        return status;
    }
  }
}