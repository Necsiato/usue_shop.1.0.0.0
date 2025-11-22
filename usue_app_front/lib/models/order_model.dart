import 'cart_item.dart';
import 'user_model.dart';

enum OrderStatus { newOrder, inProgress, done }

extension OrderStatusExt on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.newOrder:
        return 'Новый';
      case OrderStatus.inProgress:
        return 'В работе';
      case OrderStatus.done:
        return 'Завершен';
    }
  }
}

class OrderModel {
  final String id;
  final List<CartItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final double total;
  final UserModel customer;

  const OrderModel({
    required this.id,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.total,
    required this.customer,
  });

  OrderModel copyWith({
    OrderStatus? status,
    List<CartItem>? items,
  }) =>
      OrderModel(
        id: id,
        items: items ?? this.items,
        status: status ?? this.status,
        createdAt: createdAt,
        total: total,
        customer: customer,
      );
}
