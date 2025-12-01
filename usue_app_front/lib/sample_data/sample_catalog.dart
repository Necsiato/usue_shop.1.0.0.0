import 'dart:math';

import 'package:usue_app_front/models/admin_account.dart';
import 'package:usue_app_front/models/cart_item.dart';
import 'package:usue_app_front/models/category_model.dart';
import 'package:usue_app_front/models/order_model.dart';
import 'package:usue_app_front/models/product_model.dart';
import 'package:usue_app_front/models/service_model.dart';
import 'package:usue_app_front/models/user_model.dart';

class SampleCatalog {
  SampleCatalog._();

  static final categories = [
    const CategoryModel(
      id: 'smart_home',
      title: 'Умный дом',
      description: 'Датчики, хабы и сценарии для дома и дачи.',
      imageUrl: 'assets/images/categories/smart_home.png',
    ),
    const CategoryModel(
      id: 'eco_transport',
      title: 'Эко‑транспорт',
      description: 'Электробайки и самокаты.',
      imageUrl: 'assets/images/categories/eco_transport.png',
    ),
    const CategoryModel(
      id: 'water_care',
      title: 'Чистая вода',
      description: 'Фильтры, анализаторы и сервис по воде.',
      imageUrl: 'assets/images/categories/water_care.png',
    ),
  ];

  static final products = [
    ProductModel(
      id: 'hub-lite',
      title: 'Хаб умного дома',
      description: 'Управление светом, датчиками и дверными замками из одного приложения.',
      categoryId: 'smart_home',
      price: 19990,
      imageUrls: const ['assets/images/smart_home.png'],
      specs: const {
        'Связь': 'Wi‑Fi / Thread',
        'Питание': 'USB‑C',
        'Совместимость': 'iOS / Android',
      },
    ),
    ProductModel(
      id: 'smart-thermo',
      title: 'Термостат с e‑ink',
      description: 'Экономия до 30% энергии, чёткий дисплей e‑ink.',
      categoryId: 'smart_home',
      price: 24990,
      imageUrls: const ['assets/images/smart_home.png'],
      specs: const {
        'Датчики': 'Температура, влажность, CO₂',
        'Экран': 'E‑ink 4.2"',
        'Питание': 'До 1 года',
      },
    ),
    ProductModel(
      id: 'e-bike',
      title: 'Городской электровелосипед',
      description: 'Лёгкая рама, запас хода до 60 км, защита IP56.',
      categoryId: 'eco_transport',
      price: 79990,
      imageUrls: const ['assets/images/urban_bike.png'],
      specs: const {
        'Запас хода': 'до 60 км',
        'Мотор': '500 Вт',
        'Вес': '18 кг',
      },
    ),
    ProductModel(
      id: 'city-scooter',
      title: 'Электросамокат',
      description: 'Складной, до 45 км/ч, быстрая зарядка и защита от влаги.',
      categoryId: 'eco_transport',
      price: 54990,
      imageUrls: const ['assets/images/urban_bike.png'],
      specs: const {
        'Запас хода': '45 км',
        'Макс. скорость': '45 км/ч',
        'Защита': 'IP56',
      },
    ),
    ProductModel(
      id: 'water-filter',
      title: 'Система очистки воды',
      description: '4 ступени фильтрации, производительность 280 л/ч, мониторинг TDS.',
      categoryId: 'water_care',
      price: 39990,
      imageUrls: const ['assets/images/water_purifier.png'],
      specs: const {
        'Производительность': '280 л/ч',
        'Мониторинг': 'TDS‑датчик',
        'Смена картриджей': 'до 3 месяцев',
      },
    ),
    ProductModel(
      id: 'water-tester',
      title: 'Анализатор качества воды',
      description: 'Измеряет pH, TDS и жесткость, передача данных по BLE.',
      categoryId: 'water_care',
      price: 14990,
      imageUrls: const ['assets/images/water_purifier.png'],
      specs: const {
        'Связь': 'Bluetooth LE',
        'Точность': '+0.1 pH',
        'Питание': 'USB‑C',
      },
    ),
  ];

  static final services = [
    const ServiceModel(
      id: 'svc_install',
      title: 'Монтаж умного дома',
      description: 'Выезд инженера, подбор сценариев, настройка шлюзов и датчиков.',
      price: 14990,
      categoryId: 'smart_home',
    ),
    const ServiceModel(
      id: 'svc_training',
      title: 'Обучение персонала',
      description: 'Корпоративные лекции по энергосбережению и ESG‑привычкам.',
      price: 5590,
      categoryId: 'eco_transport',
      status: 'in_progress',
    ),
    const ServiceModel(
      id: 'svc_city',
      title: 'Сервис городской техники',
      description: 'Настройка электровелосипедов и самокатов, диагностика батарей.',
      price: 7990,
      categoryId: 'eco_transport',
    ),
  ];

  static final admins = [
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

  static final demoUsers = [
    const UserModel(
      id: 'USR-9182',
      username: 'user',
      email: 'user@usue.app',
      fullName: 'Анна Иванова',
      role: 'user',
      phone: '+7 900 123-45-67',
      address: 'Свердловская обл., г. Екатеринбург, 19',
    ),
    const UserModel(
      id: 'ADM-4451',
      username: 'admin',
      email: 'admin@usue.app',
      fullName: 'Алексей Смирнов',
      role: 'admin',
      phone: '+7 900 444-55-66',
      address: 'Свердловская обл., г. Тюмень, 50',
    ),
  ];

  static final adminOrders = _buildOrders();

  static List<OrderModel> _buildOrders() {
    final rnd = Random(42);
    final baseUser = demoUsers.first;
    final List<OrderModel> generated = [];
    for (var i = 0; i < 40; i++) {
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
          createdAt: DateTime.now().subtract(Duration(days: i ~/ 2)),
          total: total,
          customer: baseUser,
        ),
      );
    }
    return generated;
  }
}
