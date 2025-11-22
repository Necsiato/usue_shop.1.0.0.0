import 'category_model.dart';

class ProductModel {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final double price;
  final bool available;
  final List<String> imageUrls;
  final Map<String, String> specs;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.price,
    required this.imageUrls,
    required this.specs,
    this.available = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final dynamic categoryJson = json['categoryId'] ?? json['category_id'];
    final List<dynamic>? categoriesList = json['categories'] as List<dynamic>?;
    final String categoryId =
        categoryJson?.toString() ?? (categoriesList?.isNotEmpty == true ? categoriesList!.first.toString() : '');

    final List<dynamic> imageList =
        (json['imageUrls'] ?? json['image_urls'] ?? const <dynamic>[]) as List<dynamic>;
    final Map<String, dynamic> specsMap =
        (json['specs'] ?? json['characteristics'] ?? const <String, dynamic>{}) as Map<String, dynamic>;

    return ProductModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      categoryId: categoryId,
      price: (json['price'] as num).toDouble(),
      imageUrls: imageList.cast<String>(),
      specs: specsMap.map((k, v) => MapEntry(k, '$v')),
      available: json['available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'categoryId': categoryId,
        'price': price,
        'imageUrls': imageUrls,
        'specs': specs,
        'available': available,
      };

  CategoryModel? resolveCategory(List<CategoryModel> categories) {
    return categories.firstWhere(
      (category) => category.id == categoryId,
      orElse: () => categories.first,
    );
  }
}
