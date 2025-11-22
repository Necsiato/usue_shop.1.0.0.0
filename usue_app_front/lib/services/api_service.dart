import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/service_model.dart';
import '../sample_data/sample_catalog.dart';
import 'http_client_factory.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? createHttpClient();

  final http.Client _client;

  static const Map<String, String> _categoryImages = {
    'smart-home': '/static/media/categories/smart_home.png',
    'eco-transport': '/static/media/categories/eco_transport.png',
    'water-care': '/static/media/categories/water_care.png',
    'zero-waste': '/static/media/categories/zero_waste.png',
    'urban-farming': '/static/media/categories/urban_farming.png',
  };

  String _slugToId(String slug) => slug.replaceAll('-', '_');

  Future<List<CategoryModel>> fetchCategories() async {
    if (!AppConfig.useBackend) {
      return SampleCatalog.categories;
    }
    final response = await _client.get(AppConfig.uri('/categories'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map(
            (item) {
              final heroImage = (item['hero_image'] ?? item['heroImage']) as String?;
              final slug = item['slug'] as String? ?? 'smart-home';
              return CategoryModel(
                id: _slugToId(slug),
                title: item['title'] as String? ?? '',
                description: item['description'] as String? ?? '',
                imageUrl: (heroImage?.trim().isNotEmpty ?? false)
                    ? heroImage!
                    : _categoryImages[slug] ?? '/static/media/eco_pack.png',
              );
            },
          )
          .toList();
    }
    throw Exception('Не удалось загрузить категории');
  }

  Future<List<ProductModel>> fetchProducts() async {
    if (!AppConfig.useBackend) {
      return SampleCatalog.products;
    }
    final response = await _client.get(AppConfig.uri('/products'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((json) => _mapBackendProduct(json as Map<String, dynamic>)).toList();
    }
    throw Exception('Не удалось загрузить товары');
  }

  ProductModel _mapBackendProduct(Map<String, dynamic> item) {
    final categories = (item['categories'] as List<dynamic>? ?? [])
        .map((value) => value.toString())
        .toList();
    final slug = categories.isNotEmpty ? categories.first : 'smart-home';
    final specs = (item['characteristics'] as Map<String, dynamic>? ?? {})
        .map((key, value) => MapEntry(key, '$value'));
    final imageList =
        (item['image_urls'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    final fallbackImage = _categoryImages[slug] ?? '/static/media/categories/smart_home.png';
    final images = imageList.isEmpty ? [fallbackImage] : imageList;
    return ProductModel(
      id: item['id'] as String,
      title: item['title'] as String? ?? '',
      description: item['description'] as String? ?? '',
      categoryId: _slugToId(slug),
      price: (item['price'] as num).toDouble(),
      imageUrls: images,
      specs: specs,
    );
  }

  Future<List<ServiceModel>> fetchServices() async {
    if (!AppConfig.useBackend) {
      return SampleCatalog.services;
    }
    final response = await _client.get(AppConfig.uri('/services'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => ServiceModel.fromJson(json as Map<String, dynamic>))
          .map(
            (service) => service.copyWith(
              categoryId: service.categoryId.replaceAll('-', '_'),
            ),
          )
          .toList();
    }
    throw Exception('Не удалось загрузить услуги');
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    if (!AppConfig.useBackend) {
      return product;
    }
    final images = await _normalizeImages(product.imageUrls);
    final payload = {
      'id': product.id,
      'title': product.title,
      'description': product.description,
      'category_id': product.categoryId,
      'price': product.price,
      'image_urls': images,
      'specs': product.specs,
    };
    final response = await _client.post(
      AppConfig.uri('/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode == 201) {
      return _mapBackendProduct(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Не удалось создать товар');
  }

  Future<ServiceModel> createService(ServiceModel payload) async {
    if (!AppConfig.useBackend) {
      return payload;
    }
    final imageUrl = await _normalizeImage(payload.imageUrl);
    final response = await _client.post(
      AppConfig.uri('/services'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': payload.id,
        'title': payload.title,
        'description': payload.description,
        'price': payload.price,
        'status': payload.status,
        'category_id': payload.categoryId.replaceAll('_', '-'),
        'image_url': imageUrl,
      }),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ServiceModel.fromJson(data).copyWith(
        categoryId: (data['category_id'] as String?)?.replaceAll('-', '_') ?? payload.categoryId,
      );
    }
    throw Exception('Не удалось создать услугу');
  }

  Future<ServiceModel> updateService(ServiceModel payload) async {
    if (!AppConfig.useBackend) {
      return payload;
    }
    final imageUrl = await _normalizeImage(payload.imageUrl);
    final response = await _client.patch(
      AppConfig.uri('/services/${payload.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': payload.title,
        'description': payload.description,
        'price': payload.price,
        'status': payload.status,
        'category_id': payload.categoryId.replaceAll('_', '-'),
        'image_url': imageUrl,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ServiceModel.fromJson(data).copyWith(
        categoryId: (data['category_id'] as String?)?.replaceAll('-', '_') ?? payload.categoryId,
      );
    }
    throw Exception('Не удалось обновить услугу');
  }

  Future<List<String>> _normalizeImages(List<String> sources) async {
    if (!AppConfig.useBackend) {
      return sources;
    }
    final result = <String>[];
    for (final source in sources) {
      result.add(await _normalizeImage(source));
    }
    return result;
  }

  Future<String> _normalizeImage(String source) async {
    if (!AppConfig.useBackend || source.isEmpty) {
      return source;
    }
    if (source.startsWith('data:image')) {
      return await uploadImage(source);
    }
    return source;
  }

  Future<String> uploadImage(String dataUrl) async {
    if (!AppConfig.useBackend) {
      return dataUrl;
    }
    final response = await _client.post(
      AppConfig.uri('/media/upload'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'dataUrl': dataUrl}),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['url'] as String;
    }
    throw Exception('Не удалось загрузить изображение');
  }
}
