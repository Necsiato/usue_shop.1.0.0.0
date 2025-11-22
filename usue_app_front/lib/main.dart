import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'controllers/admin_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/catalog_controller.dart';
import 'controllers/order_controller.dart';
import 'routes/app_router.dart';
import 'services/admin_service.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/order_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final authController = AuthController(AuthService());
  runApp(UsueApp(authController: authController));
}

class UsueApp extends StatefulWidget {
  const UsueApp({super.key, required this.authController});

  final AuthController authController;

  @override
  State<UsueApp> createState() => _UsueAppState();
}

class _UsueAppState extends State<UsueApp> {
  late final router = buildRouter(widget.authController);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.authController.restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: widget.authController),
        ChangeNotifierProvider(
          create: (_) => CatalogController(ApiService())..loadCatalog(),
        ),
        ChangeNotifierProxyProvider<AuthController, CartController>(
          create: (_) => CartController(),
          update: (_, auth, cart) {
            final ctrl = cart ?? CartController();
            ctrl.setOwner(auth.currentUser?.id);
            if (!auth.isLoggedIn) {
              ctrl.clear();
            }
            return ctrl;
          },
        ),
        ChangeNotifierProxyProvider<AuthController, OrderController>(
          create: (_) => OrderController(OrderService()),
          update: (_, auth, controller) {
            final ctrl = controller ?? OrderController(OrderService());
            ctrl.attachUser(auth.currentUser);
            return ctrl;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => AdminController(AdminService()),
        ),
      ],
      child: MaterialApp.router(
        title: 'USUE eco shop',
        theme: buildAppTheme(),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
