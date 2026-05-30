class ServiceModel {
  int? id;
  String? name;
  int? minUsage;
  int? maxUsage;
  int? price;
  String? createdAt;
  String? updatedAt;

  ServiceModel({
    this.id,
    this.name,
    this.minUsage,
    this.maxUsage,
    this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      minUsage: json['min_usage'],
      maxUsage: json['max_usage'],
      price: json['price'] is String
          ? int.tryParse(json['price'])
          : json['price'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}