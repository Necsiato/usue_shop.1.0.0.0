import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:usue_app_front/controllers/auth_controller.dart';
import 'package:usue_app_front/controllers/cart_controller.dart';
import 'package:usue_app_front/widgets/app_scaffold.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Профиль',
      child: Consumer2<AuthController, CartController>(
        builder: (context, auth, cart, _) {
          if (auth.isLoading) return const Center(child: CircularProgressIndicator());
          final user = auth.currentUser;
          if (user == null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Вы не авторизованы'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton(
                      onPressed: () => GoRouter.of(context).go('/login'),
                      child: const Text('Войти'),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () => GoRouter.of(context).go('/register'),
                      child: const Text('Зарегистрироваться'),
                    ),
                  ],
                ),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.fullName.isNotEmpty ? user.fullName : user.username,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Логин: ${user.username}'),
              Text('Email: ${user.email}'),
              Text('Телефон: ${user.phone}'),
              Text('Адрес: ${user.address}'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: auth.logout,
                child: const Text('Выйти из аккаунта'),
              ),
              const SizedBox(height: 16),
              Text('Текущая корзина: ${cart.items.length} позиций'),
            ],
          );
        },
      ),
    );
  }
}
