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

  PaymentModel({
    required this.id,
    this.billId,
    this.bill,
    this.paymentDate,
    this.method,
    this.amount,
    this.proofImageUrl,
    required this.status,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? 0,
      billId: json['bill_id'],
      bill: json['bill'] != null ? BillModel.fromJson(json['bill']) : null,
      paymentDate: json['payment_date'],
      method: json['method'],
      amount: json['amount'],
      proofImageUrl: json['proof_image'],
      status: json['status'] ?? '',
    );
  }
}