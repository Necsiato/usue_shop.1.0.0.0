import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:usue_app_front/widgets/app_scaffold.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'О нас',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _Intro(),
            SizedBox(height: 32),
            _Stats(),
            SizedBox(height: 32),
            _Mission(),
            SizedBox(height: 32),
            _Advantages(),
            SizedBox(height: 32),
            _WhyUs(),
            SizedBox(height: 32),
            _Testimonials(),
            SizedBox(height: 32),
            _Partners(),
            SizedBox(height: 32),
            _Certs(),
            SizedBox(height: 32),
            _ContactCta(),
          ],
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Экологичные инженерные решения из Екатеринбурга',
          style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          'Мы проектируем и внедряем системы “умный дом”, безопасность и автоматизацию для квартир, домов и бизнеса. Работаем по всей России с 2015 года, делаем проекты под ключ и сопровождаем их на всём жизненном цикле.',
          style: text.bodyLarge?.copyWith(height: 1.4),
        ),
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats();

  @override
  Widget build(BuildContext context) {
    final items = const [
      ('9 лет', 'на рынке'),
      ('120+', 'завершённых проектов'),
      ('15', 'городов присутствия'),
      ('24/7', 'служба поддержки'),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2328),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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

class _Mission extends StatelessWidget {
  const _Mission();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Миссия',
          style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Делать дома и бизнес-пространства безопасными, энергоэффективными и комфортными, снижая воздействие на окружающую среду.',
          style: text.bodyLarge?.copyWith(height: 1.4),
        ),
      ],
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
        'От аудита объекта и проектирования до монтажа, пусконаладки и сервисных контрактов.',
      ),
      (
        'Сертифицированная команда',
        'Инженеры с опытом внедрения систем безопасности, умного дома и автоматизации.',
      ),
      (
        'Прозрачность',
        'Сметы без скрытых расходов, понятные сроки, регулярные отчёты по ходу работ.',
      ),
      (
        'Экологичность',
        'Оптимизируем энергопотребление, используем энергоэффективное оборудование.',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Преимущества',
          style:
              Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map(
                (item) => SizedBox(
                  width: 360,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$1,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(item.$2),
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

class _WhyUs extends StatelessWidget {
  const _WhyUs();

  @override
  Widget build(BuildContext context) {
    final bullets = const [
      'Подбираем решения под задачи и бюджет заказчика.',
      'Работаем с проверенными брендами оборудования.',
      'Показываем демо-стенды и готовые кейсы.',
      'Берём на гарантию и постгарантийный сервис.',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Почему мы',
          style:
              Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Column(
          children: bullets
              .map(
                (b) => ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(b),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _Testimonials extends StatelessWidget {
  const _Testimonials();

  @override
  Widget build(BuildContext context) {
    final items = const [
      ('ООО “СтройГрад”',
          'Запустили систему контроля доступа и видеонаблюдения на трёх объектах, соблюдены сроки и бюджет. Сервис оперативно реагирует.'),
      ('Family Loft',
          'Собрали умный дом с климатом и светом, интеграция со смартфоном работает стабильно, экономия по электроэнергии ~15%.'),
      ('Retail Hub',
          'Автоматизировали освещение и безопасность на складе, снизили издержки и упростили контроль доступа.'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Отзывы клиентов',
          style:
              Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map(
                (item) => SizedBox(
                  width: 400,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$1,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(item.$2),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Наши партнёры',
          style:
              Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Wrap(
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

class _Certs extends StatelessWidget {
  const _Certs();

  @override
  Widget build(BuildContext context) {
    final certs = const [
      'Сертификаты KNX/Siemens',
      'Партнёрство Ajax PRO',
      'Обучение по СКУД и видеонаблюдению',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Сертификаты и награды',
          style:
              Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: certs
              .map(
                (c) => Chip(
                  label: Text(c),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ContactCta extends StatelessWidget {
  const _ContactCta();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2328),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Готовы обсудить ваш проект?',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Оставьте заявку, и инженер свяжется с вами в течение дня.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              FilledButton(
                onPressed: () => GoRouter.of(context).go('/contact'),
                child: const Text('Связаться с нами'),
              ),
              OutlinedButton(
                onPressed: () => GoRouter.of(context).go('/catalog/smart_home'),
                child: const Text('Каталог решений'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
