import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:usue_app_front/controllers/catalog_controller.dart';
import 'package:usue_app_front/widgets/app_scaffold.dart';
import 'package:usue_app_front/widgets/product_card.dart';

class OffersView extends StatelessWidget {
  const OffersView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Лучшие предложения',
      child: Consumer<CatalogController>(
        builder: (context, catalog, _) {
          final products = [...catalog.products]..sort((a, b) => a.price.compareTo(b.price));
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Топ товаров и сервисов', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
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
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) => ProductCard(product: products[index]),
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
