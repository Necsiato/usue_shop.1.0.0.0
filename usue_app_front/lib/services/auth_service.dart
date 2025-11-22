import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/user_model.dart';
import '../sample_data/sample_catalog.dart';
import 'http_client_factory.dart';

class AuthService {
  AuthService({http.Client? client}) : _client = client ?? createHttpClient();

  final http.Client _client;

  Future<UserModel> login(String login, String password) async {
    if (!AppConfig.useBackend) {
      if (login == 'admin' && password == 'admin') {
        return SampleCatalog.demoUsers.last;
      }
      if (login == 'user' && password == 'user') {
        return SampleCatalog.demoUsers.first;
      }
      throw Exception('Неверный логин или пароль');
    }
    final response = await _client.post(
      AppConfig.uri('/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': login, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    }
    throw Exception('Не удалось войти. Проверьте данные и попробуйте снова.');
  }

  Future<UserModel> register({
    required String login,
    required String email,
    required String password,
    required String phone,
  }) async {
    if (!AppConfig.useBackend) {
      return SampleCatalog.demoUsers.first;
    }
    final response = await _client.post(
      AppConfig.uri('/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': login,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    }
    throw Exception('Не удалось зарегистрироваться.');
  }

  Future<UserModel?> fetchCurrentUser() async {
    if (!AppConfig.useBackend) return null;
    final response = await _client.get(AppConfig.uri('/auth/me'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> logout() async {
    if (!AppConfig.useBackend) return;
    await _client.post(AppConfig.uri('/auth/logout'));
  }
}
