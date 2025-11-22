import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._service);

  final AuthService _service;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  String _loginName = 'user';

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get loginName => _loginName;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<bool> login({required String login, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _service.login(login, password);
      _currentUser = user;
      _loginName = user.username;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String login,
    required String email,
    required String password,
    required String phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _service.register(
        login: login,
        email: email,
        password: password,
        phone: phone,
      );
      _currentUser = user;
      _loginName = user.username;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _service.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> restoreSession() async {
    if (!AppConfig.useBackend) return;
    try {
      final user = await _service.fetchCurrentUser();
      if (user != null) {
        _currentUser = user;
        _loginName = user.username;
        notifyListeners();
      }
    } catch (_) {
      // ignore restoration errors
    }
  }

  Future<void> updateCredentials({
    required String newLogin,
    required String newPassword,
  }) async {
    _loginName = newLogin;
    _error = null;
    notifyListeners();
  }
}
