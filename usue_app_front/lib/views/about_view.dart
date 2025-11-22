import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'О проекте',
      child: Text(
        'USUE eco shop — демо витрина. Здесь можно просматривать товары без авторизации, '
        'а корзина, профиль, заказы и админ-панель доступны после входа.',
      ),
    );
  }
}
