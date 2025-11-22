import 'dart:math';

import '../models/admin_account.dart';
import '../models/cart_item.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/service_model.dart';
import '../models/user_model.dart';

class SampleCatalog {
  SampleCatalog._();

  static final List<CategoryModel> categories = [
    const CategoryModel(
      id: 'smart_home',
      title: 'Умный дом',
      description: 'Гаджеты, которые экономят электроэнергию и автоматизируют быт.',
      imageUrl: 'assets/images/categories/smart_home.png',
    ),
    const CategoryModel(
      id: 'eco_transport',
      title: 'Эко транспорт',
      description: 'Легкие городские велосипеды, самокаты и аксессуары.',
      imageUrl: 'assets/images/categories/eco_transport.png',
    ),
    const CategoryModel(
      id: 'water_care',
      title: 'Чистая вода',
      description: 'Фильтры и системы очистки для дома и офиса.',
      imageUrl: 'assets/images/categories/water_care.png',
    ),
    const CategoryModel(
      id: 'zero_waste',
      title: 'Zero Waste',
      description: 'Товары многоразового использования и упаковка.',
      imageUrl: 'assets/images/categories/zero_waste.png',
    ),
    const CategoryModel(
      id: 'urban_farming',
      title: 'Городское фермерство',
      description: 'Комплекты микрозелени, лампы и умные горшки.',
      imageUrl: 'assets/images/categories/urban_farming.png',
    ),
  ];

  static final List<ProductModel> products = [
    ProductModel(
      id: 'smart-hub-lite',
      title: 'Smart Hub Lite',
      description:
          'Компактный контроллер на базе Matter. Поддерживает сценарии экономии энергии и мониторинг датчиков.',
      categoryId: 'smart_home',
      price: 19990,
      imageUrls: const [
        'assets/images/smart_home.png',
        'assets/images/eco_pack.png',
      ],
      specs: const {
        'Подключение': 'Wi-Fi / Thread',
        'Совместимость': 'iOS/Android/Web',
        'Питание': 'USB-C 15W',
      },
    ),
    ProductModel(
      id: 'smart-thermostat-pro',
      title: 'Smart Thermostat Pro',
      description:
          'Термостат с e-ink экраном и автономной логикой. Позволяет экономить до 30% энергии.',
      categoryId: 'smart_home',
      price: 24990,
      imageUrls: const ['assets/images/smart_home.png'],
      specs: const {
        'Датчики': 'Температура, влажность, CO₂',
        'Экран': 'E-ink 4.2"',
        'Сценарии': 'До 20 пользовательских',
      },
    ),
    ProductModel(
      id: 'smart-lock-wave',
      title: 'Smart Lock Wave',
      description: 'Замок с NFC-картами, резервным ключом и журналом событий в облаке.',
      categoryId: 'smart_home',
      price: 18990,
      imageUrls: const ['assets/images/smart_home.png'],
      specs: const {
        'Питание': '4xAA',
        'Материал': 'Алюминий',
        'Защита': 'IP54',
      },
    ),
    ProductModel(
      id: 'smart-air-mini',
      title: 'Smart Air Mini',
      description:
          'Компактный воздухоочиститель с датчиком PM2.5 и авто-режимом ночной работы.',
      categoryId: 'smart_home',
      price: 15990,
      imageUrls: const ['assets/images/smart_home.png'],
      specs: const {
        'Площадь': 'До 30 м²',
        'Шум': '25 дБ',
        'Фильтр': 'HEPA H13',
      },
    ),
    ProductModel(
      id: 'smart-garden-hub',
      title: 'Smart Garden Hub',
      description: 'Блок полива с датчиком влажности почвы и интеграцией HomeKit.',
      categoryId: 'smart_home',
      price: 22990,
      imageUrls: const ['assets/images/smart_home.png'],
      specs: const {
        'Каналы': '4 независимых',
        'Автономность': '6 месяцев',
        'Материал': 'УФ-стойкий пластик',
      },
    ),
    ProductModel(
      id: 'city-e-bike-lite',
      title: 'City E-Bike Lite',
      description: 'Городской электровелосипед 14 кг с запасом хода 60 км и съёмным АКБ.',
      categoryId: 'eco_transport',
      price: 89990,
      imageUrls: const ['assets/images/urban_bike.png'],
      specs: const {
        'Вес': '14 кг',
        'АКБ': '360 Вт·ч',
        'Привод': 'Задний',
      },
    ),
    ProductModel(
      id: 'commuter-scooter-pro',
      title: 'Commuter Scooter Pro',
      description: 'Складной самокат с подвеской и защитой IP56.',
      categoryId: 'eco_transport',
      price: 54990,
      imageUrls: const ['assets/images/urban_bike.png'],
      specs: const {
        'Запас хода': '45 км',
        'Скорость': '40 км/ч',
        'Тормоза': 'Двойные дисковые',
      },
    ),
    ProductModel(
      id: 'cargo-e-trike',
      title: 'Cargo E-Trike',
      description: 'Трёхколёсный грузовой велосипед до 120 кг. Подходит для курьеров.',
      categoryId: 'eco_transport',
      price: 119990,
      imageUrls: const ['assets/images/urban_bike.png'],
      specs: const {
        'Грузоподъёмность': '120 кг',
        'Колёса': '20"',
        'Передача': '1x8',
      },
    ),
    ProductModel(
      id: 'folding-bike-air',
      title: 'Folding Bike Air',
      description: 'Сверхлёгкий складной байк 9.8 кг. Идеален для квартир без лифта.',
      categoryId: 'eco_transport',
      price: 65990,
      imageUrls: const ['assets/images/urban_bike.png'],
      specs: const {
        'Складывание': '<10 секунд',
        'Материал': 'Карбон',
        'Передачи': '1x9',
      },
    ),
    ProductModel(
      id: 'smart-helmet-lite',
      title: 'Smart Helmet Lite',
      description: 'Велошлем с подсветкой, поворотниками и SOS-оповещением.',
      categoryId: 'eco_transport',
      price: 15990,
      imageUrls: const ['assets/images/urban_bike.png'],
      specs: const {
        'Вес': '320 г',
        'Автономность': '12 часов',
        'Размеры': 'M/L',
      },
    ),
    ProductModel(
      id: 'aqua-pro-4stage',
      title: 'Aqua Pro 4-stage',
      description: 'Осмос с минерализатором и мониторингом остатка ресурса.',
      categoryId: 'water_care',
      price: 39990,
      imageUrls: const ['assets/images/water_purifier.png'],
      specs: const {
        'Производительность': '280 л/сутки',
        'Контроль качества': 'TDS-метр',
        'Гарантия': '3 года',
      },
    ),
    ProductModel(
      id: 'desktop-filter-flow',
      title: 'Desktop Filter Flow',
      description: 'Настольный фильтр с УФ-лампой и авто-наполнением.',
      categoryId: 'water_care',
      price: 18990,
      imageUrls: const ['assets/images/water_purifier.png'],
      specs: const {
        'Объём': '4.5 л',
        'Материал': 'Боросиликатное стекло',
        'Индикация': 'LCD',
      },
    ),
    ProductModel(
      id: 'shower-filter-soft',
      title: 'Shower Filter Soft',
      description: 'Фильтр для душа с витамином C и сменными картриджами.',
      categoryId: 'water_care',
      price: 7990,
      imageUrls: const ['assets/images/water_purifier.png'],
      specs: const {
        'Ресурс': '6 месяцев',
        'Поток': '12 л/мин',
        'Резьба': 'G1/2',
      },
    ),
    ProductModel(
      id: 'water-quality-kit',
      title: 'Water Quality Kit',
      description: 'Набор датчиков pH, TDS и температуры с BLE и приложением.',
      categoryId: 'water_care',
      price: 16990,
      imageUrls: const ['assets/images/water_purifier.png'],
      specs: const {
        'Связь': 'Bluetooth LE',
        'Точность': '±0.1 pH',
        'Питание': 'USB-C',
      },
    ),
    ProductModel(
      id: 'sparkling-tap-pro',
      title: 'Sparkling Tap Pro',
      description: 'Умный кран с газированием и охлаждением.',
      categoryId: 'water_care',
      price: 54990,
      imageUrls: const ['assets/images/water_purifier.png'],
      specs: const {
        'Газирование': '3 уровня',
        'Температуры': '4-12°C',
        'Подключение': '3/8"',
      },
    ),
    ProductModel(
      id: 'zero-waste-kit',
      title: 'Zero Waste Kit',
      description: 'Набор стартовых многоразовых пакетов, трубочек и бутылок.',
      categoryId: 'zero_waste',
      price: 4990,
      imageUrls: const ['assets/images/zero_waste.png'],
      specs: const {
        'Материал': 'Пищевой силикон',
        'Комплект': '12 предметов',
        'Гарантия': '12 месяцев',
      },
    ),
    ProductModel(
      id: 'coffee-reuse-cup',
      title: 'Coffee Reuse Cup',
      description: 'Термокружка с NFC-бонусами и защитой от проливов.',
      categoryId: 'zero_waste',
      price: 3490,
      imageUrls: const ['assets/images/zero_waste.png'],
      specs: const {
        'Объём': '420 мл',
        'Материал': 'Нержавеющая сталь',
        'Изоляция': '6 часов',
      },
    ),
    ProductModel(
      id: 'solid-shampoo-set',
      title: 'Solid Shampoo Set',
      description: 'Твёрдый шампунь и кондиционер без пластика.',
      categoryId: 'zero_waste',
      price: 2790,
      imageUrls: const ['assets/images/zero_waste.png'],
      specs: const {
        'pH': '5.5',
        'Состав': 'Веган',
        'Упаковка': 'Крафт',
      },
    ),
    ProductModel(
      id: 'smart-trash-weigh',
      title: 'Smart Trash Weigh',
      description: 'Ведро с датчиком переработки и аналитикой отходов.',
      categoryId: 'zero_waste',
      price: 11990,
      imageUrls: const ['assets/images/zero_waste.png'],
      specs: const {
        'Объём': '18 л',
        'Связь': 'Wi-Fi',
        'Автономность': '60 дней',
      },
    ),
    ProductModel(
      id: 'wrap-beeswax-pro',
      title: 'Wrap Beeswax Pro',
      description: 'Многоразичные восковые салфетки 3 размеров.',
      categoryId: 'zero_waste',
      price: 2290,
      imageUrls: const ['assets/images/zero_waste.png'],
      specs: const {
        'Температура': 'до 90°C',
        'Комплект': 'S/M/L',
        'Срок службы': '1 год',
      },
    ),
    ProductModel(
      id: 'microgreen-lab',
      title: 'Microgreen Lab',
      description: 'Комплект для выращивания микрозелени с подсветкой.',
      categoryId: 'urban_farming',
      price: 13990,
      imageUrls: const ['assets/images/eco_pack.png'],
      specs: const {
        'Урожай': '8 дней',
        'Ряды': '3',
        'Подсветка': 'Full spectrum',
      },
    ),
    ProductModel(
      id: 'vertical-garden-pro',
      title: 'Vertical Garden Pro',
      description: 'Вертикальная ферма на 12 растений с автополивом.',
      categoryId: 'urban_farming',
      price: 48990,
      imageUrls: const ['assets/images/eco_pack.png'],
      specs: const {
        'Полив': 'Капельный',
        'Контроллер': 'BLE + Web',
        'Материал': 'Алюминий',
      },
    ),
    ProductModel(
      id: 'smart-pot-mini',
      title: 'Smart Pot Mini',
      description: 'Умный горшок с датчиком света и рекомендациями по уходу.',
      categoryId: 'urban_farming',
      price: 4990,
      imageUrls: const ['assets/images/eco_pack.png'],
      specs: const {
        'Диаметр': '18 см',
        'Аккумулятор': '3 мес.',
        'Приложение': 'iOS/Android',
      },
    ),
    ProductModel(
      id: 'grow-light-flex',
      title: 'Grow Light Flex',
      description: 'Гибкая LED-лампа для рассады с контролем спектра.',
      categoryId: 'urban_farming',
      price: 7990,
      imageUrls: const ['assets/images/eco_pack.png'],
      specs: const {
        'Мощность': '40 Вт',
        'Спектры': '3 профиля',
        'Ресурс': '50 000 ч',
      },
    ),
    ProductModel(
      id: 'soil-lab-kit',
      title: 'Soil Lab Kit',
      description: 'Набор для анализа почвы с BLE-датчиком и рекомендациями.',
      categoryId: 'urban_farming',
      price: 11990,
      imageUrls: const ['assets/images/eco_pack.png'],
      specs: const {
        'Параметры': 'pH, влажность, EC',
        'Связь': 'Bluetooth LE',
        'Питание': 'USB-C',
      },
    ),
  ];

  static final List<ServiceModel> services = [
    const ServiceModel(
      id: 'svc_energy_audit',
      title: 'Энергоаудит квартиры',
      description: 'Выезд инженера, подбор сценариев экономии и устройств.',
      price: 14990,
      categoryId: 'smart_home',
    ),
    const ServiceModel(
      id: 'svc_transport_setup',
      title: 'Настройка эко-транспорта',
      description: 'Сборка, прошивка и страховка для скутеров/байков.',
      price: 9990,
      categoryId: 'eco_transport',
      status: 'В работе',
    ),
    const ServiceModel(
      id: 'svc_water_lab',
      title: 'Лабораторный анализ воды',
      description: 'Расширенный отчёт + подбор фильтрующей системы.',
      price: 12990,
      categoryId: 'water_care',
    ),
    const ServiceModel(
      id: 'svc_zero_coach',
      title: 'Zero-waste коучинг',
      description: 'Персональный воркшоп с подбором привычек и товаров.',
      price: 6990,
      categoryId: 'zero_waste',
      status: 'Завершенная',
    ),
    const ServiceModel(
      id: 'svc_farm_install',
      title: 'Монтаж вертикальной фермы',
      description: 'Под ключ, с подключением к умному дому.',
      price: 24990,
      categoryId: 'urban_farming',
    ),
  ];

  static final List<AdminAccount> admins = [
    AdminAccount(
      id: 'admin_1',
      login: 'eco_admin',
      email: 'eco@usue.app',
      createdAt: DateTime.now().subtract(const Duration(days: 140)),
      superAdmin: true,
    ),
    AdminAccount(
      id: 'admin_2',
      login: 'sales_lead',
      email: 'sales@usue.app',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    AdminAccount(
      id: 'admin_3',
      login: 'support_mod',
      email: 'support@usue.app',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
  ];

  static final List<UserModel> demoUsers = [
    const UserModel(
      id: 'USR-9182',
      username: 'user',
      email: 'user@usue.app',
      fullName: 'Eco User',
      role: 'user',
      phone: '+7 900 123-45-67',
      address: 'Екатеринбург, ул. Мира, 19',
    ),
    const UserModel(
      id: 'ADM-4451',
      username: 'admin',
      email: 'admin@usue.app',
      fullName: 'Admin Demo',
      role: 'admin',
      phone: '+7 900 444-55-66',
      address: 'Екатеринбург, ул. Малышева, 50',
    ),
  ];

  static final List<OrderModel> adminOrders = _buildOrders();

  static List<OrderModel> _buildOrders() {
    final rnd = Random(42);
    final baseUser = demoUsers.first;
    final List<OrderModel> generated = [];
    for (var i = 0; i < 120; i++) {
      final items = List<CartItem>.generate(
        rnd.nextInt(3) + 1,
        (index) {
          final product = products[rnd.nextInt(products.length)];
          return CartItem(product: product, quantity: rnd.nextInt(3) + 1);
        },
      );
      final total = items.fold<double>(0, (sum, item) => sum + item.subtotal);
      final statusIndex = i % OrderStatus.values.length;
      generated.add(
        OrderModel(
          id: 'ORD-${5800 + i}',
          items: items,
          status: OrderStatus.values[statusIndex],
          createdAt: DateTime.now().subtract(Duration(days: i ~/ 3)),
          total: total,
          customer: baseUser,
        ),
      );
    }
    return generated;
  }
}
