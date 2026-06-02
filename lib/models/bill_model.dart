import 'customer_model.dart';

class BillModel {
  final int id;
  final String invoiceNumber;
  final int? customerId;
  final CustomerModel? customer;

  final int month;
  final int year;

  final String? measurementNumber;
  final int usageValue;
  final int amount;

  final bool paid;
  final bool verifiedPayment;

  // tambahan baru
  final String? paymentMethod;
  final String? paymentDate;
  final String? paymentStatus;
  final String? rejectionReason;

  final String? createdAt;

  BillModel({
    required this.id,
    required this.invoiceNumber,
    this.customerId,
    this.customer,
    required this.month,
    required this.year,
    this.measurementNumber,
    required this.usageValue,
    required this.amount,
    required this.paid,
    required this.verifiedPayment,
    this.paymentMethod,
    this.paymentDate,
    this.paymentStatus,
    this.rejectionReason,
    this.createdAt,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
  final paymentObj = _getPaymentObj(json['payments']);

final paymentStatus = paymentObj?['status']?.toString() ??
    json['payment_status']?.toString();

final statusUpper = paymentStatus?.toUpperCase();

final rejected = statusUpper == 'REJECTED' ||
    statusUpper == 'DITOLAK' ||
    statusUpper == 'FAILED' ||
    statusUpper == 'CANCELED' ||
    statusUpper == 'CANCELLED' ||
    statusUpper == 'DECLINED' ||
    statusUpper == 'DENIED';

final verified = !rejected &&
    (json['verified_payment'] == true ||
        statusUpper == 'VERIFIED' ||
        statusUpper == 'SUCCESS' ||
        statusUpper == 'LUNAS' ||
        statusUpper == 'PAID' ||
        statusUpper == 'APPROVED');

  return BillModel(
    id: _toInt(json['id']) ?? 0,
    invoiceNumber: json['invoice_number']?.toString() ?? '',
    customerId: _toInt(json['customer_id']),

    customer: json['customer'] is Map<String, dynamic>
        ? CustomerModel.fromJson(Map<String, dynamic>.from(json['customer']))
        : null,

    month: _toInt(json['month']) ?? 0,
    year: _toInt(json['year']) ?? 0,

    measurementNumber: json['measurement_number']?.toString(),

    usageValue: _toInt(json['usage_value']) ?? 0,

    amount: _toInt(json['amount']) ??
        ((_toInt(json['usage_value']) ?? 0) * (_toInt(json['price']) ?? 0)),

    paid: rejected ? false : (json['paid'] == true || verified),

    verifiedPayment: verified,

    paymentMethod: json['payment_method']?.toString() ??
        paymentObj?['method']?.toString(),

    paymentDate: json['payment_date']?.toString() ??
        paymentObj?['payment_date']?.toString() ??
        paymentObj?['created_at']?.toString(),

    paymentStatus: paymentStatus,

    rejectionReason: json['rejection_reason']?.toString() ??
        paymentObj?['rejection_note']?.toString(),

    createdAt: json['created_at']?.toString(),
  );
}
static Map<String, dynamic>? _getPaymentObj(dynamic payments) {
  if (payments is Map<String, dynamic>) {
    return payments;
  }

  if (payments is List && payments.isNotEmpty) {
    final list = payments
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    if (list.isEmpty) return null;

    list.sort((a, b) {
      final aId = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
      final bId = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
      return bId.compareTo(aId);
    });

    return list.first;
  }

  return null;
}

static int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

  String get status {
  final s = paymentStatus?.toUpperCase();

  if (s == 'REJECTED' ||
      s == 'DITOLAK' ||
      s == 'FAILED' ||
      s == 'CANCELED' ||
      s == 'CANCELLED' ||
      s == 'DECLINED' ||
      s == 'DENIED') {
    return 'ditolak';
  }

  if (verifiedPayment ||
      s == 'VERIFIED' ||
      s == 'SUCCESS' ||
      s == 'LUNAS' ||
      s == 'PAID' ||
      s == 'APPROVED') {
    return 'lunas';
  }

  if (s == 'PENDING' ||
      s == 'WAITING' ||
      s == 'BELUM_DIVERIFIKASI') {
    return 'belum_diverifikasi';
  }

  if (!paid) {
    return 'belum_dibayar';
  }

  return 'belum_diverifikasi';
}
  String get statusLabel {
  switch (status) {
    case 'belum_dibayar':
      return 'Belum Dibayar';
    case 'belum_diverifikasi':
      return 'Menunggu Verifikasi';
    case 'ditolak':
      return 'Ditolak';
    case 'lunas':
      return 'Dibayar';
    default:
      return 'Belum Dibayar';
  }
}

  String get monthName {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    if (month >= 1 && month <= 12) {
      return months[month];
    }

    return month.toString();
  }
}