import 'package:flutter/foundation.dart';

import 'package:usue_app_front/models/cart_item.dart';
import 'package:usue_app_front/models/order_model.dart';
import 'package:usue_app_front/models/user_model.dart';
import 'package:usue_app_front/services/order_service.dart';

class OrderController extends ChangeNotifier {
  OrderController(this._service);

  final OrderService _service;

  List<OrderModel> _orders = const [];
  List<OrderModel> _adminOrders = const [];
  UserModel? _currentUser;
  bool _loading = false;
  bool _saving = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  List<OrderModel> get adminOrders => _adminOrders;
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  String? get error => _error;

  void attachUser(UserModel? user) {
    _currentUser = user;
    if (user != null) {
      loadOrders();
    } else {
      _orders = const [];
      notifyListeners();
    }
  }

  Future<void> loadOrders() async {
    final user = _currentUser;
    if (user == null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _service.loadOrders(user: user);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadAdminOrders() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _adminOrders = await _service.loadAllOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<OrderModel?> createOrder(List<CartItem> items) async {
    final user = _currentUser;
    if (user == null) return null;
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      final order = await _service.createOrder(
        user: user,
        items: items
            .map((item) => CartItem(product: item.product, quantity: item.quantity))
            .toList(),
      );
      _orders = [order, ..._orders];
      return order;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<void> updateAdminOrderStatus(String orderId, OrderStatus status) async {
    try {
      final updated = await _service.updateOrderStatus(orderId: orderId, status: status);
      _adminOrders = _adminOrders
          .map((order) => order.id == orderId ? updated : order)
          .toList();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }
}
