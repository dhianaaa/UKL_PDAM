import 'service_model.dart';

class CustomerModel {
  final int id;
  final String username;
  final String customerNumber;
  final String name;
  final String phone;
  final String address;
  final int? serviceId;
  final ServiceModel? service;

  CustomerModel({
    required this.id,
    required this.username,
    required this.customerNumber,
    required this.name,
    required this.phone,
    required this.address,
    this.serviceId,
    this.service,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      customerNumber: json['customer_number'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      serviceId: json['service_id'],
      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'])
          : null,
    );
  }
}