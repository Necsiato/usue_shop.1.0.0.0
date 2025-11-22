import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controllers/cart_controller.dart';
import '../controllers/order_controller.dart';
import '../utils/currency_formatter.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/media_image.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Корзина',
      child: Consumer2<CartController, OrderController>(
        builder: (context, cart, orders, _) {
          if (cart.isEmpty) {
            return Column(
              children: [
                const SizedBox(height: 40),
                const Text('Корзина пока пуста'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => GoRouter.of(context).go('/'),
                  child: const Text('Перейти в каталог'),
                ),
              ],
            );
          }
          return Column(
            children: [
              ...cart.items.map(
                (item) => Card(
                  child: ListTile(
                    onTap: () => GoRouter.of(context).go('/product/${item.product.id}'),
                    leading: SizedBox(
                      width: 64,
                      height: 64,
                      child: MediaImage(
                        source: item.product.imageUrls.isNotEmpty ? item.product.imageUrls.first : '',
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(item.product.title),
                    subtitle: Text(formatCurrency(item.product.price)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => cart.updateQuantity(
                            item.product.id,
                            (item.quantity - 1).clamp(1, 99),
                          ),
                          icon: const Icon(Icons.remove),
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          onPressed: () => cart.updateQuantity(
                            item.product.id,
                            (item.quantity + 1).clamp(1, 99),
                          ),
                          icon: const Icon(Icons.add),
                        ),
                        IconButton(
                          onPressed: () => cart.removeProduct(item.product.id),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Итого (без доставки)'),
                      Text('Сумма: ${formatCurrency(cart.total)}'),
                    ],
                  ),
                  FilledButton(
                    onPressed:
                        orders.isSaving ? null : () => _showPaymentDialog(context, cart, orders),
                    child: orders.isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Оформить заказ'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showPaymentDialog(
    BuildContext context,
    CartController cart,
    OrderController orders,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Оформление заказа'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Сумма к оплате: ${formatCurrency(cart.total)}'),
            const SizedBox(height: 12),
            const Text(
              'Оплата производится при получении. Наш менеджер свяжется с вами для уточнения деталей.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () async {
              final order = await orders.createOrder(cart.items);
              cart.clear();
              if (context.mounted) {
                Navigator.of(context).pop();
                GoRouter.of(context).go('/profile');
                if (order != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Заказ ${order.id} оформлен')),
                  );
                }
              }
            },
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
  }
}
