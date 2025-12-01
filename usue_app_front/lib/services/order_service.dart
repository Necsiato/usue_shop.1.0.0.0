import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:usue_app_front/config/app_config.dart';
import 'package:usue_app_front/models/cart_item.dart';
import 'package:usue_app_front/models/order_model.dart';
import 'package:usue_app_front/models/product_model.dart';
import 'package:usue_app_front/models/user_model.dart';
import 'package:usue_app_front/sample_data/sample_catalog.dart';
import 'http_client_factory.dart';

class OrderService {
  OrderService({http.Client? client}) : _client = client ?? createHttpClient();

  final http.Client _client;

  Future<List<OrderModel>> loadOrders({required UserModel user}) async {
    if (!AppConfig.useBackend) {
      return SampleCatalog.adminOrders.where((order) => order.customer.id == user.id).toList();
    }
    final response = await _client.get(AppConfig.uri('/orders'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((json) => _fromJson(json as Map<String, dynamic>)).toList();
    }
    throw Exception('РќРµ СѓРґР°Р»РѕСЃСЊ РїРѕР»СѓС‡РёС‚СЊ РІР°С€Рё Р·Р°РєР°Р·С‹, РїРѕРїСЂРѕР±СѓР№С‚Рµ РїРѕР·Р¶Рµ.');
  }

  Future<List<OrderModel>> loadAllOrders() async {
    if (!AppConfig.useBackend) {
      return SampleCatalog.adminOrders;
    }
    final response = await _client.get(AppConfig.uri('/orders'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((json) => _fromJson(json as Map<String, dynamic>)).toList();
    }
    throw Exception('РќРµ СѓРґР°Р»РѕСЃСЊ Р·Р°РіСЂСѓР·РёС‚СЊ СЃРїРёСЃРѕРє Р·Р°РєР°Р·РѕРІ, РїРѕРїСЂРѕР±СѓР№С‚Рµ РїРѕР·Р¶Рµ.');
  }

  Future<OrderModel> createOrder({
    required UserModel user,
    required List<CartItem> items,
  }) async {
    if (!AppConfig.useBackend) {
      final total =
          items.fold<double>(0, (sum, item) => sum + item.product.price * item.quantity);
      return OrderModel(
        id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        items: items,
        status: OrderStatus.newOrder,
        createdAt: DateTime.now(),
        total: total,
        customer: user,
      );
    }
    final response = await _client.post(
      AppConfig.uri('/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'items': items
            .map((item) => {
                  'productId': item.product.id,
                  'quantity': item.quantity,
                })
            .toList(),
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _fromJson(data);
    }
    throw Exception('РќРµ СѓРґР°Р»РѕСЃСЊ РѕС„РѕСЂРјРёС‚СЊ Р·Р°РєР°Р·.');
  }

  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    if (!AppConfig.useBackend) {
      return SampleCatalog.adminOrders
          .firstWhere((order) => order.id == orderId)
          .copyWith(status: status);
    }
    final response = await _client.patch(
      AppConfig.uri('/orders/$orderId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': _statusToApi(status)}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _fromJson(data);
    }
    throw Exception('РќРµ СѓРґР°Р»РѕСЃСЊ РёР·РјРµРЅРёС‚СЊ СЃС‚Р°С‚СѓСЃ Р·Р°РєР°Р·Р°.');
  }

  String _statusToApi(OrderStatus status) {
    switch (status) {
      case OrderStatus.inProgress:
        return 'in_progress';
      case OrderStatus.done:
        return 'completed';
      case OrderStatus.newOrder:
        return 'new';
    }
  }

  OrderModel _fromJson(Map<String, dynamic> json) {
    final customer = UserModel.fromJson(json['customer'] as Map<String, dynamic>);
    final items = (json['items'] as List<dynamic>).map((item) {
      final itemMap = item as Map<String, dynamic>;
      final product = ProductModel.fromJson(itemMap['product'] as Map<String, dynamic>);
      return CartItem(product: product, quantity: itemMap['quantity'] as int);
    }).toList();
    final statusValue = (json['status'] as String? ?? 'new').toLowerCase();
    final OrderStatus status;
    if (statusValue == 'in_progress') {
      status = OrderStatus.inProgress;
    } else if (statusValue == 'completed') {
      status = OrderStatus.done;
    } else {
      status = OrderStatus.newOrder;
    }
    final createdRaw = json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String();
    final createdAt =
        createdRaw is String ? DateTime.parse(createdRaw) : DateTime.parse(createdRaw.toString());
    final totalValue = json['total_sum'] ?? json['total'] ?? 0;
    return OrderModel(
      id: json['id'] as String,
      items: items,
      status: status,
      createdAt: createdAt,
      total: (totalValue as num).toDouble(),
      customer: customer,
    );
  }
}
