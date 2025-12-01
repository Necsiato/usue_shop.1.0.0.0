import 'package:flutter/foundation.dart';

import 'package:usue_app_front/models/cart_item.dart';
import 'package:usue_app_front/models/product_model.dart';
import 'package:usue_app_front/models/service_model.dart';

class CartController extends ChangeNotifier {
  final Map<String, List<CartItem>> _storage = {};
  String _ownerKey = 'guest';
  List<CartItem> _items = [];

  List<CartItem> _cloneItems(List<CartItem> source) =>
      source.map((item) => CartItem(product: item.product, quantity: item.quantity)).toList();

  void _persistSnapshot() {
    _storage[_ownerKey] = _cloneItems(_items);
  }

  void setOwner(String? userId) {
    final newKey = userId ?? 'guest';
    if (newKey == _ownerKey) return;
    _persistSnapshot();
    _ownerKey = newKey;
    final cached = _storage[_ownerKey];
    _items = cached != null ? _cloneItems(cached) : [];
    notifyListeners();
  }

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  double get total => _items.fold<double>(0, (sum, item) => sum + item.subtotal);

  void addProduct(ProductModel product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    _persistSnapshot();
    notifyListeners();
  }

  void addService(ServiceModel service) {
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
    addProduct(product);
  }

  void removeProduct(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    _persistSnapshot();
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      _items[index].quantity = quantity.clamp(1, 99);
      _persistSnapshot();
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    _persistSnapshot();
    notifyListeners();
  }
}
