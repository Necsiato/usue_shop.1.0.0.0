import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/order_controller.dart';
import '../utils/currency_formatter.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/media_image.dart';
import '../widgets/status_badge.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Профиль',
      child: Consumer2<AuthController, OrderController>(
        builder: (context, auth, orders, _) {
          final user = auth.currentUser;
          if (user == null) {
            return const Text('Авторизуйтесь, чтобы увидеть профиль.');
          }
          final orderList = orders.orders;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Логин: ${user.username}'),
                      Text('Email: ${user.email}'),
                      Text('Телефон: ${user.phone.isEmpty ? '-' : user.phone}'),
                      Text('Адрес: ${user.address.isEmpty ? '-' : user.address}'),
                      Text('Роль: ${user.role}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Заказы', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (orders.isLoading)
                const CircularProgressIndicator()
              else if (orderList.isEmpty)
                const Text('Заказов пока нет')
              else
                ...orderList.map(
                  (order) => Card(
                    child: ExpansionTile(
                      title: Text('Заказ ${order.id} - ${order.items.length} позиций'),
                      subtitle: Text('Итого: ${formatCurrency(order.total)}'),
                      trailing: StatusBadge(order.status),
                      children: order.items
                          .map(
                            (item) => ListTile(
                              onTap: () => GoRouter.of(context).go('/product/${item.product.id}'),
                              leading: SizedBox(
                                width: 56,
                                height: 56,
                                child: MediaImage(
                                  source: item.product.imageUrls.isNotEmpty
                                      ? item.product.imageUrls.first
                                      : '',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(item.product.title),
                              subtitle: Text('x${item.quantity} - ${formatCurrency(item.product.price)}'),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
