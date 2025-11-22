import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/catalog_controller.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/category_card.dart';
import '../widgets/media_image.dart';
import '../widgets/product_card.dart';
import '../widgets/service_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'USUE eco shop',
      child: Consumer2<CatalogController, CartController>(
        builder: (context, catalog, cart, _) {
          final auth = context.read<AuthController>();
          if (catalog.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final featuredCount = catalog.products.length > 8 ? 8 : catalog.products.length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeroBanner(),
              const SizedBox(height: 24),
              Text(
                'Категории',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: catalog.categories
                    .map(
                      (category) => SizedBox(
                        width: 360,
                        child: CategoryCard(category: category),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 32),
              Text(
                'Популярные товары',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 1000
                      ? 4
                      : constraints.maxWidth > 700
                          ? 3
                          : constraints.maxWidth > 500
                              ? 2
                              : 1;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: featuredCount,
                    itemBuilder: (context, index) {
                      final product = catalog.products[index];
                      return ProductCard(product: product);
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Услуги и внедрение',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (catalog.services.isEmpty)
                const Text('Список услуг пока пуст')
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: catalog.services
                      .take(6)
                      .map(
                        (service) => SizedBox(
                          width: 360,
                          child: ServiceCard(
                            service: service,
                            onAdd: () {
                              if (!auth.isLoggedIn) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Войдите, чтобы добавить услугу в корзину'),
                                  ),
                                );
                                return;
                              }
                              final product = catalog.registerServiceProduct(service);
                              cart.addProduct(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Услуга добавлена в корзину')),
                              );
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F2328),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Умные экотовары и сервисы в USUE eco shop',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white, fontSize: 26),
                ),
                const SizedBox(height: 12),
                Text(
                  'Поддерживаем ответственное потребление. Выбирайте решения для дома, транспорта и воды — всё в одном месте.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const SizedBox(
            height: 120,
            child: AspectRatio(
              aspectRatio: 1.6,
              child: MediaImage(
                source: '/static/media/categories/smart_home.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
