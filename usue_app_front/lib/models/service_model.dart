class ServiceModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String categoryId;
  final String status;
  final String imageUrl;

  const ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.categoryId,
    this.status = 'new',
    this.imageUrl = '',
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        categoryId: (json['category_id'] ?? json['categoryId'] ?? 'smart_home') as String,
        status: json['status'] as String? ?? 'new',
        imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'category_id': categoryId,
        'status': status,
        'image_url': imageUrl,
      };

  ServiceModel copyWith({
    String? title,
    String? description,
    double? price,
    String? categoryId,
    String? status,
    String? imageUrl,
  }) =>
      ServiceModel(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        price: price ?? this.price,
        categoryId: categoryId ?? this.categoryId,
        status: status ?? this.status,
        imageUrl: imageUrl ?? this.imageUrl,
      );
}
