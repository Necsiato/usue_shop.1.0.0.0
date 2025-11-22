import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/order_model.dart';
import '../models/service_model.dart';
import '../models/user_model.dart';
import '../sample_data/sample_catalog.dart';
import '../services/admin_service.dart';

class AdminController extends ChangeNotifier {
  AdminController(this._adminService);

  final AdminService _adminService;

  List<UserModel> _customers = const [];
  List<UserModel> _admins = const [];
  List<ServiceModel> _services = SampleCatalog.services;
  List<OrderModel> _orders = SampleCatalog.adminOrders;
  String? _infoMessage;
  bool _loadingUsers = false;

  List<UserModel> get customers => _customers;
  List<UserModel> get administrators => _admins;
  List<ServiceModel> get services => _services;
  List<OrderModel> get orders => _orders;
  String? get infoMessage => _infoMessage;
  bool get isLoadingUsers => _loadingUsers;

  Future<void> loadUsers() async {
    if (!AppConfig.useBackend) {
      _customers = SampleCatalog.demoUsers.where((user) => !user.isAdmin).toList();
      _admins = SampleCatalog.demoUsers.where((user) => user.isAdmin).toList();
      notifyListeners();
      return;
    }
    _loadingUsers = true;
    notifyListeners();
    try {
      final users = await _adminService.fetchUsers(role: 'user');
      final admins = await _adminService.fetchUsers(role: 'admin');
      _customers = users;
      _admins = admins;
    } catch (e) {
      _infoMessage = 'Не удалось загрузить пользователей: $e';
    } finally {
      _loadingUsers = false;
      notifyListeners();
    }
  }

  Future<void> updateUserCredentials({
    required UserModel user,
    String? username,
    String? password,
    String? phone,
  }) async {
    if (!AppConfig.useBackend) return;
    try {
      final updated = await _adminService.updateCredentials(
        userId: user.id,
        username: username,
        password: password,
        phone: phone,
      );
      if (updated.isAdmin) {
        _admins = _admins.map((item) => item.id == updated.id ? updated : item).toList();
      } else {
        _customers = _customers.map((item) => item.id == updated.id ? updated : item).toList();
      }
      _infoMessage = 'Профиль пользователя обновлён';
    } catch (e) {
      _infoMessage = 'Ошибка при обновлении профиля: $e';
    }
    notifyListeners();
  }

  void syncServices(List<ServiceModel> data) {
    _services = data;
    notifyListeners();
  }

  void syncOrders(List<OrderModel> data) {
    _orders = data;
    notifyListeners();
  }

  void addService(ServiceModel service) {
    _services = [service, ..._services];
    _infoMessage = 'Новая услуга добавлена';
    notifyListeners();
  }

  void updateService(ServiceModel updated) {
    _services = _services.map((service) => service.id == updated.id ? updated : service).toList();
    notifyListeners();
  }

  void clearMessage() {
    _infoMessage = null;
    notifyListeners();
  }
}
