import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:usue_app_front/controllers/catalog_controller.dart';
import 'package:usue_app_front/models/category_model.dart';
import 'package:usue_app_front/models/product_model.dart';
import 'package:usue_app_front/widgets/app_scaffold.dart';
import 'package:usue_app_front/widgets/product_card.dart';

class AllCategoriesView extends StatelessWidget {
  const AllCategoriesView({super.key});

  static const Map<String, String> _titles = {
    'smart_home': 'Наши умные дома',
    'eco_transport': 'Наш транспорт',
    'water_care': 'Наша вода',
    'zero_waste': 'Наш эко-быт',
  };

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Каталог',
      child: Consumer<CatalogController>(
        builder: (context, catalog, _) {
          final List<CategoryModel> categories = catalog.categories;
          final List<ProductModel> allProducts = catalog.products;

          if (catalog.isLoading && categories.isEmpty && allProducts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (categories.isEmpty) {
            if (allProducts.isEmpty) {
              return const Text('Товары не найдены');
            }
            return _CategorySection(
              title: 'Все товары',
              description: 'Весь ассортимент без переходов по разделам.',
              products: allProducts,
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Каталог',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Собрали все товары сразу на одной странице — выбирайте раздел и листайте предложения.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 22),
              ...categories.map(
                (category) => _CategorySection(
                  title: _titles[category.id] ?? category.title,
                  description: category.description,
                  products: catalog.productsByCategory(category.id),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.description,
    required this.products,
  });

  final String title;
  final String description;
  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(description),
          ],
          const SizedBox(height: 16),
          if (products.isEmpty)
            const Text('В этом разделе пока нет товаров.')
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1100
                    ? 4
                    : constraints.maxWidth > 800
                        ? 3
                        : constraints.maxWidth > 500
                            ? 2
                            : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.72,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: products[index]);
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
