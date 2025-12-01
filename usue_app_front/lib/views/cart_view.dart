import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:usue_app_front/controllers/cart_controller.dart';
import 'package:usue_app_front/utils/currency_formatter.dart';
import 'package:usue_app_front/widgets/app_scaffold.dart';
import 'package:usue_app_front/widgets/media_image.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Корзина',
      child: Consumer<CartController>(
        builder: (context, cart, _) {
          if (cart.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Корзина пуста'),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => GoRouter.of(context).go('/'),
                  child: const Text('Перейти в каталог'),
                ),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cart.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: MediaImage(
                              source: item.product.imageUrls.isNotEmpty
                                  ? item.product.imageUrls.first
                                  : '',
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product.title,
                                    style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text(formatCurrency(item.product.price)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => cart.updateQuantity(
                                  item.product.id,
                                  item.quantity - 1,
                                ),
                                icon: const Icon(Icons.remove),
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                onPressed: () => cart.updateQuantity(
                                  item.product.id,
                                  item.quantity + 1,
                                ),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Text(formatCurrency(item.subtotal)),
                          IconButton(
                            tooltip: 'Удалить',
                            onPressed: () => cart.removeProduct(item.product.id),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Итого', style: Theme.of(context).textTheme.titleLarge),
                  Text(
                    formatCurrency(cart.total),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Заказ оформлен (демо)')),
                  );
                  cart.clear();
                },
                child: const Text('Оформить заказ'),
              ),
            ],
          );
        },
      ),
    );
  }
}
