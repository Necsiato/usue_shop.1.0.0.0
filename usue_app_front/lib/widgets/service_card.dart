import 'package:flutter/material.dart';
import 'package:usue_app_front/utils/currency_formatter.dart';

import 'package:usue_app_front/models/service_model.dart';
import 'media_image.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service, this.onAdd});

  final ServiceModel service;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final translated = _translate(service);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (service.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: MediaImage(
                  source: service.imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),
            Text(
              translated.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              translated.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Text(
              formatCurrency(service.price),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(label: Text(_statusToText(service.status))),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Добавить в корзину'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusToText(String status) {
    switch (status) {
      case 'in_progress':
        return 'В работе';
      case 'completed':
        return 'Выполнено';
      default:
        return 'Доступно';
    }
  }

  _ServiceText _translate(ServiceModel svc) {
    var title = svc.title;
    var desc = svc.description;
    title = title.replaceAll('Smart Home', 'Умный дом');
    title = title.replaceAll('Urban', 'Городской');
    desc = desc.replaceAll('training', 'обучение');
    return _ServiceText(title: title, description: desc);
  }
}

class _ServiceText {
  const _ServiceText({required this.title, required this.description});
  final String title;
  final String description;
}
