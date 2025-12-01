import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:usue_app_front/controllers/auth_controller.dart';
import 'package:usue_app_front/controllers/cart_controller.dart';
import 'package:usue_app_front/controllers/catalog_controller.dart';
import 'package:usue_app_front/config/app_config.dart';
import 'package:usue_app_front/widgets/app_scaffold.dart';
import 'package:usue_app_front/widgets/category_card.dart';
import 'package:usue_app_front/widgets/media_image.dart';
import 'package:usue_app_front/widgets/product_card.dart';
import 'package:usue_app_front/widgets/service_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppConfig.brandTitle,
      child: Consumer2<CatalogController, CartController>(
        builder: (context, catalog, cart, _) {
          final auth = context.read<AuthController>();
          if (catalog.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final featuredCount = catalog.products.length > 8
              ? 8
              : catalog.products.length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeroBanner(),
              const SizedBox(height: 20),
              _CategorySlider(categories: catalog.categories),
              const SizedBox(height: 20),
              _NavTiles(),
              const SizedBox(height: 24),
              Text(
                'Популярные категории',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: catalog.categories
                    .map(
                      (category) => SizedBox(
                        width: 420,
                        child: CategoryCard(category: category),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 32),
              Text(
                'Лучшие предложения',
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
                      return ProductCard(
                        product: product,
                        onAdd: () {
                          if (!auth.isLoggedIn) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Войдите, чтобы добавить товар'),
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
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Услуги и сервисы',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (catalog.services.isEmpty)
                const Text('Услуги пока не добавлены')
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: catalog.services
                      .take(6)
                      .map(
                        (service) => SizedBox(
                          width: 420,
                          child: ServiceCard(
                            service: service,
                            onAdd: () {
                              if (!auth.isLoggedIn) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Войдите, чтобы оформить услугу',
                                    ),
                                  ),
                                );
                                return;
                              }
                              final product = catalog.registerServiceProduct(
                                service,
                              );
                              cart.addProduct(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Услуга добавлена в корзину'),
                                ),
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

class _CategorySlider extends StatefulWidget {
  const _CategorySlider({required this.categories});

  final List categories;

  @override
  State<_CategorySlider> createState() => _CategorySliderState();
}

class _CategorySliderState extends State<_CategorySlider> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    final next = (_page + 1) % widget.categories.length;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _prev() {
    final prev = _page == 0 ? widget.categories.length - 1 : _page - 1;
    _controller.animateToPage(
      prev,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: widget.categories.length,
            itemBuilder: (context, index) {
              final category = widget.categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () =>
                      GoRouter.of(context).go('/catalog/${category.id}'),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF303640), Color(0xFF1A1D23)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      border: Border.all(color: Colors.white12),
                    ),
                    padding: const EdgeInsets.all(22),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                category.title,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(fontSize: 24),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                category.description,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Подробно о категории и лучших предложениях — заходите в каталог.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              height: 260,
                              child: MediaImage(
                                source: category.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 8,
            child: Row(
              children: List.generate(widget.categories.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: active ? 36 : 18,
                  decoration: BoxDecoration(
                    color: active
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }),
            ),
          ),
          Positioned(
            left: 4,
            child: IconButton.filled(
              onPressed: _prev,
              icon: const Icon(Icons.arrow_back_ios_new),
            ),
          ),
          Positioned(
            right: 4,
            child: IconButton.filled(
              onPressed: _next,
              icon: const Icon(Icons.arrow_forward_ios),
            ),
          ),
        ],
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
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Экотовары и сервисы для дома и города',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Умные устройства и услуги: от умного дома до эко-транспорта. Быстрая доставка и установка под ключ.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: const SizedBox(
              height: 140,
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

class _NavTiles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _NavCard(
            title: 'Перейти к категориям',
            subtitle: 'Смотреть все разделы каталога',
            icon: Icons.category_outlined,
            onTap: () => GoRouter.of(context).go('/catalog/smart_home'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _NavCard(
            title: 'Лучшие предложения',
            subtitle: 'Скидки и популярные товары',
            icon: Icons.star_border_rounded,
            onTap: () => GoRouter.of(context).go('/offers'),
          ),
        ),
      ],
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1E23),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}
