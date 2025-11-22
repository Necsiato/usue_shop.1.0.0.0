import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/admin_controller.dart';
import '../../controllers/catalog_controller.dart';
import '../../controllers/order_controller.dart';
import '../../models/product_model.dart';
import '../../models/service_model.dart';
import '../../models/user_model.dart';
import '../../utils/file_picker_stub.dart'
    if (dart.library.html) '../../utils/file_picker_web.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/order_table.dart';
import '../../widgets/media_image.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  final _serviceNameCtrl = TextEditingController();
  final _serviceDescCtrl = TextEditingController();
  final _servicePriceCtrl = TextEditingController();
  final _serviceImageCtrl =
      TextEditingController(text: '/static/media/services/install_smart_home.jpg');
  final _productNameCtrl = TextEditingController();
  final _productDescCtrl = TextEditingController();
  final _productPriceCtrl = TextEditingController();
  String? _selectedCategory;
  String _serviceStatus = 'new';
  String? _productImageDataUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadUsers();
      context.read<OrderController>().loadAdminOrders();
    });
  }

  Future<void> _pickProductImage() async {
    try {
      final dataUrl = await pickPngDataUrl();
      if (!mounted) return;
      if (dataUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Файл не выбран или функция недоступна на этой платформе')),
        );
        return;
      }
      setState(() => _productImageDataUrl = dataUrl);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка выбора файла: $e')),
      );
    }
  }

  @override
  void dispose() {
    _serviceNameCtrl.dispose();
    _serviceDescCtrl.dispose();
    _servicePriceCtrl.dispose();
    _serviceImageCtrl.dispose();
    _productNameCtrl.dispose();
    _productDescCtrl.dispose();
    _productPriceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Админ-панель',
      child: Consumer3<AdminController, OrderController, CatalogController>(
        builder: (context, admin, orders, catalog, _) {
          _selectedCategory ??= catalog.categories.isNotEmpty ? catalog.categories.first.id : null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStats(admin, orders, catalog),
              if (admin.infoMessage != null) ...[
                Card(
                  color: Colors.green.withValues(alpha: 0.1),
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(admin.infoMessage!),
                    trailing: IconButton(
                      onPressed: admin.clearMessage,
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              _sectionTitle('Пользователи', Icons.people_alt_outlined),
              if (admin.isLoadingUsers)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                _UsersTable(users: admin.customers, onEdit: (user) => _openUserDialog(user)),
              const SizedBox(height: 24),
              _sectionTitle('Администраторы', Icons.shield_moon_outlined),
              _UsersTable(users: admin.administrators, onEdit: (user) => _openUserDialog(user)),
              const SizedBox(height: 32),
              _sectionTitle('Добавить товар', Icons.inventory_2_outlined),
              _buildProductForm(catalog),
              const SizedBox(height: 32),
              _sectionTitle('Услуги и внедрение', Icons.design_services_outlined),
              _buildServiceForm(catalog, admin),
              const SizedBox(height: 16),
              _ServicesGrid(
                services: catalog.services,
                onEdit: (service) => _openServiceDialog(service),
              ),
              const SizedBox(height: 32),
              _sectionTitle('Заказы (join)', Icons.dataset_outlined),
              if (orders.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                OrdersDataTable(
                  orders: orders.adminOrders,
                  onStatusChanged: (id, status) => orders.updateAdminOrderStatus(id, status),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStats(AdminController admin, OrderController orders, CatalogController catalog) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _InfoCard(
          icon: Icons.shopping_bag_outlined,
          label: 'Товаров',
          value: catalog.products.length.toString(),
        ),
        _InfoCard(
          icon: Icons.pending_actions_outlined,
          label: 'Заказы',
          value: orders.adminOrders.length.toString(),
        ),
        _InfoCard(
          icon: Icons.people_outline,
          label: 'Покупатели',
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

  Widget _buildProductForm(CatalogController catalog) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _productNameCtrl,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _productDescCtrl,
              decoration: const InputDecoration(labelText: 'Описание'),
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _productPriceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Цена, ₽'),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _pickProductImage,
                icon: const Icon(Icons.upload_file),
                label: const Text('Выбрать PNG с ПК'),
              ),
            ),
            if (_productImageDataUrl != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _productImageDataUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              items: catalog.categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category.id,
                      child: Text(category.title),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value),
              decoration: const InputDecoration(labelText: 'Категория'),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => _submitProduct(catalog),
                icon: const Icon(Icons.add),
                label: const Text('Создать товар'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceForm(CatalogController catalog, AdminController admin) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _serviceNameCtrl,
              decoration: const InputDecoration(labelText: 'Название услуги'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _serviceDescCtrl,
              decoration: const InputDecoration(labelText: 'Описание'),
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _servicePriceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Стоимость, ₽'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _serviceImageCtrl,
              decoration: const InputDecoration(labelText: 'Путь к изображению'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _serviceStatus,
              onChanged: (value) => setState(() => _serviceStatus = value ?? 'new'),
              decoration: const InputDecoration(labelText: 'Статус'),
              items: const [
                DropdownMenuItem(value: 'new', child: Text('Новая')),
                DropdownMenuItem(value: 'in_progress', child: Text('В работе')),
                DropdownMenuItem(value: 'completed', child: Text('Завершена')),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => _submitService(catalog, admin),
                icon: const Icon(Icons.add_business),
                label: const Text('Добавить услугу'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitProduct(CatalogController catalog) async {
    final title = _productNameCtrl.text.trim();
    if (title.isEmpty || _selectedCategory == null) return;
    final slug = title
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '-')
        .replaceAll(RegExp('-+'), '-')
        .replaceAll(RegExp('^-|-\$'), '');
    final product = ProductModel(
      id: slug.isEmpty ? 'product-${DateTime.now().millisecondsSinceEpoch}' : slug,
      title: title,
      description: _productDescCtrl.text.trim(),
      categoryId: _selectedCategory!,
      price: double.tryParse(_productPriceCtrl.text) ?? 0,
      imageUrls: [
        _productImageDataUrl ?? 'assets/images/eco_pack.png',
      ],
      specs: const {'Происхождение': 'Админка'},
    );
    await catalog.addProduct(product);
    _productNameCtrl.clear();
    _productDescCtrl.clear();
    _productPriceCtrl.clear();
    setState(() => _productImageDataUrl = null);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Товар сохранён')),
    );
  }

  Future<void> _submitService(CatalogController catalog, AdminController admin) async {
    final title = _serviceNameCtrl.text.trim();
    if (title.isEmpty || _selectedCategory == null) return;
    final service = ServiceModel(
      id: 'svc-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: _serviceDescCtrl.text.trim(),
      price: double.tryParse(_servicePriceCtrl.text) ?? 0,
      categoryId: _selectedCategory!,
      status: _serviceStatus,
      imageUrl: _serviceImageCtrl.text.trim(),
    );
    final created = await catalog.addService(service);
    admin.addService(created);
    _serviceNameCtrl.clear();
    _serviceDescCtrl.clear();
    _servicePriceCtrl.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Услуга добавлена')),
    );
  }

  Future<void> _openUserDialog(UserModel user) async {
    final loginCtrl = TextEditingController(text: user.username);
    final passCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: user.phone);
    final admin = context.read<AdminController>();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Редактирование ${user.username}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: loginCtrl,
              decoration: const InputDecoration(labelText: 'Логин'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Телефон'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: 'Новый пароль'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Отмена')),
          FilledButton(
            onPressed: () async {
              await admin.updateUserCredentials(
                user: user,
                username: loginCtrl.text.trim().isEmpty ? null : loginCtrl.text.trim(),
                password: passCtrl.text.trim().isEmpty ? null : passCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
              );
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    loginCtrl.dispose();
    passCtrl.dispose();
    phoneCtrl.dispose();
  }

  Future<void> _openServiceDialog(ServiceModel service) async {
    final titleCtrl = TextEditingController(text: service.title);
    final descCtrl = TextEditingController(text: service.description);
    final priceCtrl = TextEditingController(text: service.price.toStringAsFixed(0));
    final imageCtrl = TextEditingController(text: service.imageUrl);
    String category = service.categoryId;
    String status = service.status;
    final catalog = context.read<CatalogController>();
    final admin = context.read<AdminController>();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Услуга ${service.id}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Описание'),
                minLines: 2,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Стоимость'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imageCtrl,
                decoration: const InputDecoration(labelText: 'Изображение'),
              ),
              const SizedBox(height: 12),
            DropdownButtonFormField<String>(
                initialValue: category,
                items: catalog.categories
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.title),
                      ),
                    )
                    .toList(),
                onChanged: (value) => category = value ?? category,
                decoration: const InputDecoration(labelText: 'Категория'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: status,
                items: const [
                  DropdownMenuItem(value: 'new', child: Text('Новая')),
                  DropdownMenuItem(value: 'in_progress', child: Text('В работе')),
                  DropdownMenuItem(value: 'completed', child: Text('Завершена')),
                ],
                onChanged: (value) => status = value ?? status,
                decoration: const InputDecoration(labelText: 'Статус'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Закрыть')),
          FilledButton(
            onPressed: () async {
              final updated = service.copyWith(
                title: titleCtrl.text.trim(),
                description: descCtrl.text.trim(),
                price: double.tryParse(priceCtrl.text) ?? service.price,
                categoryId: category,
                status: status,
                imageUrl: imageCtrl.text.trim(),
              );
              final saved = await catalog.updateService(updated);
              admin.updateService(saved);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    titleCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    imageCtrl.dispose();
  }
}

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid({required this.services, required this.onEdit});

  final List<ServiceModel> services;
  final ValueChanged<ServiceModel> onEdit;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const Text('Услуги отсутствуют');
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
                      Text(service.title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        service.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${service.price.toStringAsFixed(0)} ₽',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(label: Text(_statusToText(service.status))),
                          IconButton(
                            tooltip: 'Редактировать',
                            onPressed: () => onEdit(service),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                        ],
                      ),
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
  const _UsersTable({required this.users, required this.onEdit});

  final List<UserModel> users;
  final ValueChanged<UserModel> onEdit;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Нет записей'),
        ),
      );
    }
    return PaginatedDataTable(
      header: Text('Всего: ${users.length}'),
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Логин')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Телефон')),
        DataColumn(label: Text('Действия')),
      ],
      source: _UsersDataSource(users: users, onEdit: onEdit),
      rowsPerPage: 8,
      showFirstLastButtons: true,
    );
  }
}

class _UsersDataSource extends DataTableSource {
  _UsersDataSource({required this.users, required this.onEdit});

  final List<UserModel> users;
  final ValueChanged<UserModel> onEdit;

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;
    final user = users[index];
    return DataRow(
      cells: [
        DataCell(Text(user.id)),
        DataCell(Text(user.username)),
        DataCell(Text(user.email)),
        DataCell(Text(user.phone.isEmpty ? '—' : user.phone)),
        DataCell(
          IconButton(
            onPressed: () => onEdit(user),
            icon: const Icon(Icons.edit_outlined),
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
  const _InfoCard({required this.icon, required this.label, required this.value});

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
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
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
        Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}
