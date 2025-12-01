import 'package:flutter/material.dart';

import 'package:usue_app_front/models/order_model.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});

  final OrderStatus status;

  Color _statusColor(BuildContext context) {
    switch (status) {
      case OrderStatus.newOrder:
        return Colors.orange.shade400;
      case OrderStatus.inProgress:
        return Colors.blue.shade400;
      case OrderStatus.done:
        return Colors.green.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
