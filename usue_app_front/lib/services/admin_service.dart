import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:usue_app_front/config/app_config.dart';
import 'package:usue_app_front/models/user_model.dart';
import 'http_client_factory.dart';

class AdminService {
  AdminService({http.Client? client}) : _client = client ?? createHttpClient();

  final http.Client _client;

  Future<List<UserModel>> fetchUsers({String? role}) async {
    if (!AppConfig.useBackend) {
      return [];
    }
    final path = role != null ? '/admin/users?role=$role' : '/admin/users';
    final response = await _client.get(AppConfig.uri(path));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Не удалось загрузить пользователей');
  }

  Future<UserModel> updateCredentials({
    required String userId,
    String? username,
    String? email,
    String? password,
    String? phone,
    String? role,
  }) async {
    if (!AppConfig.useBackend) {
      throw Exception('Backend отключён');
    }
    final payload = <String, dynamic>{};
    if (username != null && username.isNotEmpty) {
      payload['username'] = username;
    }
    if (email != null && email.isNotEmpty) {
      payload['email'] = email;
    }
    if (password != null && password.isNotEmpty) {
      payload['password'] = password;
    }
    if (phone != null && phone.isNotEmpty) {
      payload['phone'] = phone;
    }
    if (role != null && role.isNotEmpty) {
      payload['role'] = role;
    }
    final response = await _client.patch(
      AppConfig.uri('/admin/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return UserModel.fromJson(data);
    }
    throw Exception('Не удалось обновить пользователя');
  }

  Future<UserModel> updateRole({
    required String userId,
    required String role,
  }) async {
    return updateCredentials(userId: userId, role: role);
  }
}
