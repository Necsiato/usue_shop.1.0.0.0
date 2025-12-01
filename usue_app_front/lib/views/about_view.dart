import 'package:flutter/material.dart';

import 'package:usue_app_front/widgets/app_scaffold.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'О магазине',
      child: Text(
        'Магазин эко товаров — это витрина демо-товаров и сервисов. Мы показываем, как выглядит каталог, '
        'оформление заказа и личный кабинет в рамках учебного проекта.',
      ),
    );
  }
}
