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
  final int totalPrice;
  final String status; // belum_dibayar, belum_diverifikasi, lunas
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
    required this.totalPrice,
    required this.status,
    this.createdAt,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',
      customerId: json['customer_id'],
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'])
          : null,
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
      measurementNumber: json['measurement_number'],
      usageValue: json['usage_value'] ?? 0,
      totalPrice: json['total_price'] ?? 0,
      status: json['status'] ?? 'belum_dibayar',
      createdAt: json['created_at'],
    );
  }

  String get statusLabel {
    switch (status) {
      case 'belum_dibayar':
        return 'Belum Dibayar';
      case 'belum_diverifikasi':
        return 'Belum Diverifikasi';
      case 'lunas':
        return 'Dibayar';
      default:
        return status;
    }
  }

  String get monthName {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    if (month >= 1 && month <= 12) return months[month];
    return month.toString();
  }
}