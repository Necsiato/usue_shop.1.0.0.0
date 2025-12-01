import 'package:flutter/foundation.dart';

import 'package:usue_app_front/config/app_config.dart';
import 'package:usue_app_front/models/order_model.dart';
import 'package:usue_app_front/models/service_model.dart';
import 'package:usue_app_front/models/user_model.dart';
import 'package:usue_app_front/sample_data/sample_catalog.dart';
import 'package:usue_app_front/services/admin_service.dart';

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
      _customers = SampleCatalog.demoUsers
          .where((user) => !user.isAdmin)
          .toList();
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
    String? email,
    String? password,
    String? phone,
  }) async {
    if (!AppConfig.useBackend) return;
    try {
      final updated = await _adminService.updateCredentials(
        userId: user.id,
        username: username,
        email: email,
        password: password,
        phone: phone,
      );
      _applyUpdatedUser(updated);
      _infoMessage = 'Данные пользователя обновлены';
    } catch (e) {
      _infoMessage = 'Ошибка при обновлении пользователя: $e';
    }
    notifyListeners();
  }

  Future<void> updateUserRole({
    required UserModel user,
    required bool makeAdmin,
  }) async {
    final newRole = makeAdmin ? 'admin' : 'user';
    try {
      _loadingUsers = true;
      notifyListeners();
      if (!AppConfig.useBackend) {
        final updated = user.copyWith(role: newRole);
        _applyUpdatedUser(updated);
      } else {
        final updated = await _adminService.updateRole(
          userId: user.id,
          role: newRole,
        );
        _applyUpdatedUser(updated);
      }
      _infoMessage = 'Роль обновлена';
      await loadUsers();
    } catch (e) {
      _infoMessage = 'Ошибка при смене роли: $e';
    } finally {
      _loadingUsers = false;
      notifyListeners();
    }
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
    _infoMessage = 'Сервис добавлен';
    notifyListeners();
  }

  void updateService(ServiceModel updated) {
    _services = _services
        .map((service) => service.id == updated.id ? updated : service)
        .toList();
    notifyListeners();
  }

  void clearMessage() {
    _infoMessage = null;
    notifyListeners();
  }

  void _applyUpdatedUser(UserModel updated) {
    if (updated.isAdmin) {
      _admins = _upsert(_admins, updated);
      _customers = _customers.where((u) => u.id != updated.id).toList();
    } else {
      _customers = _upsert(_customers, updated);
      _admins = _admins.where((u) => u.id != updated.id).toList();
    }
  }

  List<UserModel> _upsert(List<UserModel> list, UserModel user) {
    final idx = list.indexWhere((u) => u.id == user.id);
    if (idx == -1) {
      return [user, ...list];
    }
    final copy = [...list];
    copy[idx] = user;
    return copy;
  }
}
