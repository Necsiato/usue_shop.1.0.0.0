import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.title = 'USUE eco shop',
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
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () => router.go('/'),
            child: const Text('Главная'),
          ),
          TextButton(
            onPressed: () => router.go('/catalog/smart_home'),
            child: const Text('Каталог'),
          ),
          TextButton(
            onPressed: () => router.go('/about'),
            child: const Text('О нас'),
          ),
          IconButton(
            tooltip: 'Корзина',
            onPressed: () => router.go('/cart'),
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
            OutlinedButton(
              onPressed: auth.logout,
              child: const Text('Выйти'),
            ),
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
              constraints: const BoxConstraints(maxWidth: 1200),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
