import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import '../views/about_view.dart';
import '../views/admin/admin_dashboard_view.dart';
import '../views/cart_view.dart';
import '../views/category_view.dart';
import '../views/home_view.dart';
import '../views/login_view.dart';
import '../views/product_view.dart';
import '../views/profile_view.dart';
import '../views/register_view.dart';

GoRouter buildRouter(AuthController authController) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: authController,
    redirect: (context, state) {
      final loggedIn = authController.isLoggedIn;
      final isAdmin = authController.isAdmin;
      final loggingIn = state.matchedLocation == '/login';
      final registering = state.matchedLocation == '/register';
      final requiresAuth = state.uri.path == '/cart' || state.uri.path == '/profile';
      final wantsAdmin = state.uri.path.startsWith('/admin');

      if (!loggedIn && (requiresAuth || wantsAdmin)) {
        return '/login';
      }
      if (loggedIn && (loggingIn || registering)) {
        return '/profile';
      }
      if (wantsAdmin && !isAdmin) {
        return '/profile';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutView(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartView(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileView(),
      ),
      GoRoute(
        path: '/catalog/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CategoryView(categoryId: id);
        },
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductView(productId: id);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardView(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Страница не найдена: ${state.error}')),
    ),
  );
}
