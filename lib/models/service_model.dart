class ServiceModel {
  final int id;
  final String name;
  final int minUsage;
  final int maxUsage;
  final int price;
  final String? createdAt;
  final String? updatedAt;

  ServiceModel({
    required this.id,
    required this.name,
    required this.minUsage,
    required this.maxUsage,
    required this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] is String
          ? int.tryParse(json['id']) ?? 0
          : (json['id'] ?? 0),

      name: json['name'] ?? '',

      minUsage: json['min_usage'] is String
          ? int.tryParse(json['min_usage']) ?? 0
          : (json['min_usage'] ?? 0),

      maxUsage: json['max_usage'] is String
          ? int.tryParse(json['max_usage']) ?? 0
          : (json['max_usage'] ?? 0),

      price: json['price'] is String
          ? int.tryParse(json['price']) ?? 0
          : (json['price'] ?? 0),

      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'min_usage': minUsage,
        'max_usage': maxUsage,
        'price': price,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}