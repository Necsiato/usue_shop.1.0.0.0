import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:usue_app_front/config/app_config.dart';
import 'package:usue_app_front/controllers/catalog_controller.dart';
import 'package:usue_app_front/widgets/app_scaffold.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppConfig.brandTitle,
      child: Consumer<CatalogController>(
        builder: (context, catalog, _) {
          if (catalog.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              SizedBox(height: 98),
              _HeroSection(),
              SizedBox(height: 64),
              _StatsStrip(),
              SizedBox(height: 98),
              _Advantages(),
              SizedBox(height: 98),
              
              _Partners(),
            ],
          );
        },
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 128,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.eco_outlined, color: Colors.black, size: 120),
            ),
            const SizedBox(width: 48),
            Text(
              'Экологичные технологии',
              style: textTheme.titleLarge?.copyWith(
                fontSize: (textTheme.titleLarge?.fontSize ?? 32) * 2.6,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 42),
        Text(
          'Инженерные решения для дома и бизнеса: умные системы, безопасность и автоматизация с заботой о природе.',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 42),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          children: [
            FilledButton(
              onPressed: () => GoRouter.of(context).go('/catalog/smart_home'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
              ),
              child: const Text(
                'Каталог решений',
                style: TextStyle(fontSize: 64),
              ),
            ),
            OutlinedButton(
              onPressed: () => GoRouter.of(context).go('/contact'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
              ),
              child: const Text(
                'Связаться с нами',
                style: TextStyle(fontSize: 64),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
class _StatsStrip extends StatelessWidget {
  const _StatsStrip();

  @override
  Widget build(BuildContext context) {
    final items = const [
      ('9 лет', 'на рынке'),
      ('120+', 'проектов'),
      ('15', 'городов'),
      ('24/7', 'поддержка'),
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 32,
      runSpacing: 32,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2328),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.$1,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(item.$2),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Advantages extends StatelessWidget {
  const _Advantages();

  @override
  Widget build(BuildContext context) {
    final items = const [
      (
        'Комплексный подход',
        'От обследования объекта и проектирования до монтажа, пусконаладки и сервиса.',
      ),
      (
        'Сертифицированная команда',
        'Инженеры с опытом внедрения систем безопасности и автоматизации.',
      ),
      (
        'Прозрачный бюджет',
        'Сметы без скрытых расходов, понятные сроки и отчётность.',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Наши преимущества',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: items
              .map(
                (item) => SizedBox(
                  width: 420,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            item.$1,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.$2,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _Partners extends StatelessWidget {
  const _Partners();

  @override
  Widget build(BuildContext context) {
    final partners = const ['Hikvision', 'Ajax', 'Dahua', 'KNX', 'Schneider', 'ZKTeco'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Наши партнёры',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: partners
              .map(
                (p) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2328),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(p),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

