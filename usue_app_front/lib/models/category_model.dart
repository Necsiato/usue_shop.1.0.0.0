class CategoryModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        imageUrl: json['imageUrl'] as String? ??
            json['iconAsset'] as String? ??
            '/static/media/eco_pack.png',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
      };
}
