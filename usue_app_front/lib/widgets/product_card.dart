import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:usue_app_front/models/product_model.dart';
import 'package:usue_app_front/utils/currency_formatter.dart';
import 'media_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.onAdd, this.onTap});

  final ProductModel product;
  final VoidCallback? onAdd;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final translated = _translateProduct(product);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => GoRouter.of(context).go('/product/${product.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: MediaImage(
                  source: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translated.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    translated.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatCurrency(product.price),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                      IconButton.outlined(
                        onPressed: onAdd ??
                            () => GoRouter.of(context).go('/product/${product.id}'),
                        icon: const Icon(Icons.add_shopping_cart_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ProductText _translateProduct(ProductModel p) {
    final hasLatin = RegExp(r'[A-Za-z]').hasMatch('${p.title} ${p.description}');
    if (hasLatin) {
      return const _ProductText(
        title: 'Товар',
        description: 'Описание недоступно на русском. Скоро обновим.',
      );
    }
    return _ProductText(title: p.title, description: p.description);
  }
}

class _ProductText {
  const _ProductText({required this.title, required this.description});
  final String title;
  final String description;
}
