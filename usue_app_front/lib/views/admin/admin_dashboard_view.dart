import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:usue_app_front/controllers/admin_controller.dart';
import 'package:usue_app_front/controllers/catalog_controller.dart';
import 'package:usue_app_front/controllers/order_controller.dart';
import 'package:usue_app_front/models/service_model.dart';
import 'package:usue_app_front/models/user_model.dart';
import 'package:usue_app_front/utils/currency_formatter.dart';
import 'package:usue_app_front/utils/validators.dart';
import 'package:usue_app_front/widgets/app_scaffold.dart';
import 'package:usue_app_front/widgets/media_image.dart';
import 'package:usue_app_front/widgets/order_table.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadUsers();
      context.read<OrderController>().loadAdminOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Админ-панель',
      actions: [
        TextButton(
          onPressed: () => GoRouter.of(context).go('/'),
          child: const Text('На сайт'),
        ),
      ],
      child: Consumer3<AdminController, OrderController, CatalogController>(
        builder: (context, admin, orders, catalog, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStats(admin, orders, catalog),
              if (admin.infoMessage != null) ...[
                const SizedBox(height: 8),
                Card(
                  color: Colors.green.withOpacity(0.1),
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(admin.infoMessage!),
                    trailing: IconButton(
                      onPressed: admin.clearMessage,
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _sectionTitle('Пользователи', Icons.people_alt_outlined),
              if (admin.isLoadingUsers)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                _UsersTable(
                  admins: admin.administrators,
                  users: admin.customers,
                  onMakeAdmin: (user) =>
                      admin.updateUserRole(user: user, makeAdmin: true),
                  onMakeUser: (user) =>
                      admin.updateUserRole(user: user, makeAdmin: false),
                  onEditUser: (user) => _openEditUser(context, user, admin),
                ),
              const SizedBox(height: 24),
              _sectionTitle('Услуги', Icons.design_services_outlined),
              _ServicesGrid(services: admin.services),
              const SizedBox(height: 24),
              _sectionTitle('Заказы', Icons.receipt_long_outlined),
              if (orders.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                OrdersDataTable(
                  orders: orders.adminOrders,
                  onStatusChanged: (id, status) =>
                      orders.updateAdminOrderStatus(id, status),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStats(
    AdminController admin,
    OrderController orders,
    CatalogController catalog,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _InfoCard(
          icon: Icons.shopping_bag_outlined,
          label: 'Товары',
          value: catalog.products.length.toString(),
        ),
        _InfoCard(
          icon: Icons.design_services,
          label: 'Услуги',
          value: admin.services.length.toString(),
        ),
        _InfoCard(
          icon: Icons.receipt_long_outlined,
          label: 'Заказы',
          value: orders.adminOrders.length.toString(),
        ),
        _InfoCard(
          icon: Icons.people_outline,
          label: 'Пользователи',
          value: admin.customers.length.toString(),
        ),
        _InfoCard(
          icon: Icons.admin_panel_settings,
          label: 'Админы',
          value: admin.administrators.length.toString(),
        ),
      ],
    );
  }

  Future<void> _openEditUser(
    BuildContext context,
    UserModel user,
    AdminController admin,
  ) async {
    final formKey = GlobalKey<FormState>();
    final loginCtrl = TextEditingController(text: user.username);
    final emailCtrl = TextEditingController(text: user.email);
    final phoneCtrl = TextEditingController(text: user.phone);
    final passCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Редактировать ${user.username}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: loginCtrl,
                decoration: const InputDecoration(labelText: 'Логин'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => Validators.login(value, allowEmpty: true),
              ),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => Validators.email(value, allowEmpty: true),
              ),
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Телефон'),
                keyboardType: TextInputType.phone,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => Validators.phone(value, allowEmpty: true),
              ),
              TextFormField(
                controller: passCtrl,
                decoration: const InputDecoration(
                  labelText: 'Новый пароль (необязательно)',
                ),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) =>
                    Validators.password(value, allowEmpty: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await admin.updateUserCredentials(
                user: user,
                username:
                    loginCtrl.text.trim().isEmpty ? null : loginCtrl.text.trim(),
                email:
                    emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                phone:
                    phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                password:
                    passCtrl.text.trim().isEmpty ? null : passCtrl.text.trim(),
              );
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );

    loginCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
  }
}

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid({required this.services});

  final List<ServiceModel> services;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const Text('Услуги пока не добавлены');
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: services
          .map(
            (service) => SizedBox(
              width: 360,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (service.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: MediaImage(
                            source: service.imageUrl,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        service.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatCurrency(service.price),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Chip(label: Text(_statusToText(service.status))),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  String _statusToText(String status) {
    switch (status) {
      case 'in_progress':
        return 'В работе';
      case 'completed':
        return 'Завершена';
      default:
        return 'Новая';
    }
  }
}

class _UsersTable extends StatelessWidget {
  const _UsersTable({
    required this.admins,
    required this.users,
    required this.onMakeAdmin,
    required this.onMakeUser,
    required this.onEditUser,
  });

  final List<UserModel> admins;
  final List<UserModel> users;
  final Future<void> Function(UserModel) onMakeAdmin;
  final Future<void> Function(UserModel) onMakeUser;
  final Future<void> Function(UserModel) onEditUser;

  @override
  Widget build(BuildContext context) {
    final combined = [...admins, ...users];
    if (combined.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Пользователей нет'),
        ),
      );
    }
    return PaginatedDataTable(
      header: Text('Всего пользователей: ${combined.length}'),
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Логин')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Телефон')),
        DataColumn(label: Text('Роль')),
        DataColumn(label: Text('Действия')),
      ],
      source: _UsersDataSource(
        users: combined,
        onMakeAdmin: onMakeAdmin,
        onMakeUser: onMakeUser,
        onEditUser: onEditUser,
      ),
      rowsPerPage: 8,
      showFirstLastButtons: true,
    );
  }
}

class _UsersDataSource extends DataTableSource {
  _UsersDataSource({
    required this.users,
    required this.onMakeAdmin,
    required this.onMakeUser,
    required this.onEditUser,
  });

  final List<UserModel> users;
  final Future<void> Function(UserModel) onMakeAdmin;
  final Future<void> Function(UserModel) onMakeUser;
  final Future<void> Function(UserModel) onEditUser;

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;
    final user = users[index];
    final isAdmin = user.isAdmin;
    return DataRow(
      cells: [
        DataCell(Text(user.id)),
        DataCell(Text(user.username)),
        DataCell(Text(user.email)),
        DataCell(Text(user.phone.isEmpty ? '-' : user.phone)),
        DataCell(Text(isAdmin ? 'Админ' : 'Пользователь')),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () => onEditUser(user),
                child: const Text('Редактировать'),
              ),
              const SizedBox(width: 8),
              if (!isAdmin)
                TextButton(
                  onPressed: () => onMakeAdmin(user),
                  child: const Text('Сделать админом'),
                )
              else
                TextButton(
                  onPressed: () => onMakeUser(user),
                  child: const Text('Сделать пользователем'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 12),
              Text(label),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _sectionTitle(String text, IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
