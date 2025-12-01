import 'package:flutter/material.dart';

import 'package:usue_app_front/models/order_model.dart';
import 'package:usue_app_front/utils/currency_formatter.dart';
import 'status_badge.dart';

class OrdersDataTable extends StatelessWidget {
  const OrdersDataTable({
    super.key,
    required this.orders,
    this.onStatusChanged,
  });

  final List<OrderModel> orders;
  final void Function(String orderId, OrderStatus status)? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable(
      header: const Text('Заказы (управление статусами)'),
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Клиент')),
        DataColumn(label: Text('Товары')),
        DataColumn(label: Text('Сумма')),
        DataColumn(label: Text('Статус')),
      ],
      source: _OrdersTableSource(
        orders,
        onStatusChanged: onStatusChanged,
      ),
      rowsPerPage: 10,
      showFirstLastButtons: true,
    );
  }
}

class _OrdersTableSource extends DataTableSource {
  _OrdersTableSource(this.orders, {this.onStatusChanged});

  final List<OrderModel> orders;
  final void Function(String orderId, OrderStatus status)? onStatusChanged;

  @override
  DataRow? getRow(int index) {
    if (index >= orders.length) return null;
    final order = orders[index];
    return DataRow(
      cells: [
        DataCell(Text(order.id)),
        DataCell(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.customer.fullName),
            Text(order.customer.email, style: const TextStyle(fontSize: 12)),
          ],
        )),
        DataCell(
          Text(order.items.map((e) => '${e.product.title} x${e.quantity}').join(', ')),
        ),
        DataCell(Text(formatCurrency(order.total))),
        DataCell(Row(
          children: [
            StatusBadge(order.status),
            const SizedBox(width: 8),
            if (onStatusChanged != null)
              DropdownButton<OrderStatus>(
                value: order.status,
                underline: const SizedBox(),
                items: OrderStatus.values
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ))
                    .toList(),
                onChanged: (status) {
                  if (status != null) {
                    onStatusChanged!(order.id, status);
                  }
                },
              ),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => orders.length;

  @override
  int get selectedRowCount => 0;
}
