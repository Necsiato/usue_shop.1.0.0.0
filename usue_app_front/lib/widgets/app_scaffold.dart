import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:usue_app_front/config/app_config.dart';
import 'package:usue_app_front/controllers/auth_controller.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.title = AppConfig.brandTitle,
    this.actions,
    this.floatingActionButton,
  });

  final Widget child;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final router = GoRouter.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 92,
        leadingWidth: 0,
        leading: const SizedBox.shrink(),
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton.icon(
              onPressed: () => router.go('/'),
              icon: const Icon(Icons.home_outlined),
              label: const Text('Главная'),
            ),
            OutlinedButton.icon(
              onPressed: () => router.go('/catalog'),
              icon: const Icon(Icons.category_outlined),
              label: const Text('Каталог'),
            ),
            OutlinedButton.icon(
              onPressed: () => router.go('/about'),
              icon: const Icon(Icons.info_outline),
              label: const Text('О нас'),
            ),
            OutlinedButton.icon(
              onPressed: () => router.go('/contact'),
              icon: const Icon(Icons.mail_outline),
              label: const Text('Контакты'),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Корзина',
            onPressed: () {
              if (auth.isLoggedIn) {
                router.go('/cart');
                return;
              }
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Доступ к корзине'),
                  content: const Text(
                    'Зарегистрируйтесь или войдите, чтобы оформлять заказы.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Позже'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        router.go('/register');
                      },
                      child: const Text('Регистрация'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
          if (auth.isLoggedIn)
            IconButton(
              tooltip: 'Профиль',
              onPressed: () => router.go('/profile'),
              icon: const Icon(Icons.person_outline),
            ),
          if (auth.isAdmin)
            IconButton(
              tooltip: 'Админка',
              onPressed: () => router.go('/admin'),
              icon: const Icon(Icons.admin_panel_settings_outlined),
            ),
          const SizedBox(width: 8),
          if (auth.isLoggedIn) ...[
            OutlinedButton(onPressed: auth.logout, child: const Text('Выйти')),
          ] else ...[
            TextButton(
              onPressed: () => router.go('/register'),
              child: const Text('Регистрация'),
            ),
            FilledButton(
              onPressed: () => router.go('/login'),
              child: const Text('Войти'),
            ),
          ],
          const SizedBox(width: 12),
          ...?actions,
        ],
      ),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1800),
              child: child,
            ),
          ),
        ),
      ),
      bottomNavigationBar: const _ContactsFooter(),
    );
  }
}

class _ContactsFooter extends StatelessWidget {
  const _ContactsFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1D1F23),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            AppConfig.brandTitle,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          Text(
            'Позвонить нам: +7 982 647-29-65',
            style: TextStyle(color: Colors.white70),
          ),
          Text(
            'deniskleinnn@gmail.com',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

