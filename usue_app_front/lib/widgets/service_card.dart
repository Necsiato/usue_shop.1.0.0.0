import 'package:flutter/material.dart';

import '../models/service_model.dart';
import 'media_image.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service, this.onAdd});

  final ServiceModel service;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
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
            Text(service.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              service.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Text(
              '${service.price.toStringAsFixed(0)} ₽',
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
                  label: const Text('В корзину'),
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
        return 'Завершена';
      default:
        return 'Новая';
    }
  }
}
