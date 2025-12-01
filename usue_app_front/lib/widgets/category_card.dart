import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:usue_app_front/models/category_model.dart';
import 'media_image.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final translated = _translate(category);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => GoRouter.of(context).go('/catalog/${category.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipOval(
                child: MediaImage(
                  source: category.imageUrl,
                  width: 56,
                  height: 56,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
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
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  _CategoryText _translate(CategoryModel cat) {
    final map = {
      'smart_home': (
        'Умный дом',
        'Датчики, контроллеры, сценарии и безопасность.',
      ),
      'eco_transport': (
        'Эко-транспорт',
        'Электробайки, самокаты и городской транспорт.',
      ),
      'water_care': ('Чистая вода', 'Фильтры, анализаторы и сервис воды.'),
    };
    final data = map[cat.id];
    if (data != null) {
      return _CategoryText(title: data.$1, description: data.$2);
    }
    return _CategoryText(title: cat.title, description: cat.description);
  }
}

class _CategoryText {
  const _CategoryText({required this.title, required this.description});
  final String title;
  final String description;
}
