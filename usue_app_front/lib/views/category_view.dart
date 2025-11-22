import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/catalog_controller.dart';
import '../models/category_model.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/product_card.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Категория',
      child: Consumer<CatalogController>(
        builder: (context, catalog, _) {
          if (catalog.isLoading && catalog.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final CategoryModel category;
          try {
            category = catalog.categories.firstWhere((cat) => cat.id == categoryId);
          } catch (_) {
            return const Text('Категория не найдена');
          }
          final products = catalog.productsByCategory(categoryId);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(category.description),
              const SizedBox(height: 20),
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
          );
        },
      ),
    );
  }
}
