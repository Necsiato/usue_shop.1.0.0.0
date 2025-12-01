import 'package:flutter/foundation.dart';

import 'package:usue_app_front/config/app_config.dart';
import 'package:usue_app_front/models/category_model.dart';
import 'package:usue_app_front/models/product_model.dart';
import 'package:usue_app_front/models/service_model.dart';
import 'package:usue_app_front/sample_data/sample_catalog.dart';
import 'package:usue_app_front/services/api_service.dart';

class CatalogController extends ChangeNotifier {
  CatalogController(this._apiService);

  final ApiService _apiService;

  List<CategoryModel> _categories = const [];
  List<ProductModel> _products = const [];
  List<ServiceModel> _services = const [];
  final List<ProductModel> _localCreatedProducts = [];
  bool _loading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => [..._products, ..._localCreatedProducts];
  List<ServiceModel> get services => _services;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> loadCatalog() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _apiService.fetchCategories(),
        _apiService.fetchProducts(),
        _apiService.fetchServices(),
      ]);
      _categories = results[0] as List<CategoryModel>;
      _products = results[1] as List<ProductModel>;
      _services = results[2] as List<ServiceModel>;
    } catch (e) {
      _error = e.toString();
      _categories = SampleCatalog.categories;
      _products = SampleCatalog.products;
      _services = SampleCatalog.services;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  List<ProductModel> productsByCategory(String categoryId) {
    return products.where((product) => product.categoryId == categoryId).toList();
  }

  ProductModel? getProduct(String id) {
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<ProductModel> addProduct(ProductModel product) async {
    final created = await _apiService.createProduct(product);
    if (AppConfig.useBackend) {
      _products = [created, ..._products];
    } else {
      _localCreatedProducts.add(created);
    }
    notifyListeners();
    return created;
  }

  ProductModel registerServiceProduct(ServiceModel service) {
    final existing = getProduct(service.id);
    if (existing != null) return existing;
    final product = ProductModel(
      id: service.id,
      title: service.title,
      description: service.description,
      categoryId: service.categoryId.isEmpty ? 'services' : service.categoryId,
      price: service.price,
      imageUrls: [
        if (service.imageUrl.isNotEmpty) service.imageUrl,
      ],
      specs: const {'Услуга': 'Добавлено из сервиса'},
    );
    _localCreatedProducts.add(product);
    notifyListeners();
    return product;
  }

  Future<ServiceModel> addService(ServiceModel payload) async {
    final created = await _apiService.createService(payload);
    _services = [created, ..._services];
    notifyListeners();
    return created;
  }

  Future<ServiceModel> updateService(ServiceModel updated) async {
    final saved = await _apiService.updateService(updated);
    _services = _services.map((service) {
      if (service.id == saved.id) {
        return saved;
      }
      return service;
    }).toList();
    notifyListeners();
    return saved;
  }
}
