import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:usue_app_front/controllers/auth_controller.dart';
import 'package:usue_app_front/controllers/cart_controller.dart';
import 'package:usue_app_front/controllers/catalog_controller.dart';
import 'package:usue_app_front/utils/currency_formatter.dart';
import 'package:usue_app_front/widgets/app_scaffold.dart';
import 'package:usue_app_front/widgets/media_image.dart';

class ProductView extends StatelessWidget {
  const ProductView({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Товар',
      child: Consumer3<AuthController, CatalogController, CartController>(
        builder: (context, auth, catalog, cart, _) {
          final product = catalog.getProduct(productId);
          if (product == null) {
            return const Text('Товар не найден');
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => GoRouter.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Назад',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    product.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: MediaImage(
                        source: product.imageUrls.isNotEmpty
                            ? product.imageUrls.first
                            : '',
                        height: 400,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.description),
                        const SizedBox(height: 16),
                        Text(
                          formatCurrency(product.price),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            if (!auth.isLoggedIn) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Войдите, чтобы добавить товар в корзину',
                                  ),
                                ),
                              );
                              return;
                            }
                            cart.addProduct(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Товар добавлен в корзину'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Добавить в корзину'),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Характеристики',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        ...product.specs.entries.map(
                          (entry) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(entry.key),
                            trailing: Text(entry.value),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
