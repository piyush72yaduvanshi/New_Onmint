class Medicine {
  final String id;
  final String name;
  final String genericName;
  final String manufacturer;
  final String description;
  final double price;
  final double? discountedPrice;
  final int stock;
  final String category;
  final bool requiresPrescription;
  final String dosageForm;
  final String strength;
  final String packaging;
  final DateTime expiryDate;
  final String? imageUrl;
  final bool isActive;
  final String? pharmacist;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medicine({
    required this.id,
    required this.name,
    required this.genericName,
    required this.manufacturer,
    required this.description,
    required this.price,
    this.discountedPrice,
    required this.stock,
    required this.category,
    required this.requiresPrescription,
    required this.dosageForm,
    required this.strength,
    required this.packaging,
    required this.expiryDate,
    this.imageUrl,
    required this.isActive,
    this.pharmacist,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      genericName: json['genericName'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountedPrice: json['discountedPrice']?.toDouble(),
      stock: json['stock'] ?? 0,
      category: json['category'] ?? '',
      requiresPrescription: json['requiresPrescription'] ?? false,
      dosageForm: json['dosageForm'] ?? '',
      strength: json['strength'] ?? '',
      packaging: json['packaging'] ?? '',
      expiryDate: DateTime.parse(json['expiryDate'] ?? DateTime.now().toIso8601String()),
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
      pharmacist: json['pharmacist'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'genericName': genericName,
      'manufacturer': manufacturer,
      'description': description,
      'price': price,
      if (discountedPrice != null) 'discountedPrice': discountedPrice,
      'stock': stock,
      'category': category,
      'requiresPrescription': requiresPrescription,
      'dosageForm': dosageForm,
      'strength': strength,
      'packaging': packaging,
      'expiryDate': expiryDate.toIso8601String(),
      if (imageUrl != null) 'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }

  double get effectivePrice => discountedPrice ?? price;
  bool get hasDiscount => discountedPrice != null && discountedPrice! < price;
  double get discountPercentage => hasDiscount ? ((price - discountedPrice!) / price * 100) : 0;
  bool get isInStock => stock > 0;
  bool get isExpired => expiryDate.isBefore(DateTime.now());
  bool get isExpiringSoon => expiryDate.difference(DateTime.now()).inDays < 30;
}
