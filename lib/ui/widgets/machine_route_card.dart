import 'package:flutter/material.dart';
import '../../simulation/models/machine.dart';
import '../theme/zone_ui.dart';

/// Card widget that displays a machine in a route list
class MachineRouteCard extends StatelessWidget {
  final Machine machine;
  final VoidCallback onRemove;

  const MachineRouteCard({
    super.key,
    required this.machine,
    required this.onRemove,
  });

  /// Get stock level color
  Color _getStockColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock < 5) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final zoneIcon = machine.zone.type.icon;
    final zoneColor = machine.zone.type.color;
    final stock = machine.totalInventory;
    final stockColor = _getStockColor(stock);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: zoneColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(zoneIcon, color: zoneColor, size: 20),
        ),
        title: Text(
          machine.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Zone: ${machine.zone.type.name.toUpperCase()}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.inventory_2, size: 14, color: stockColor),
                const SizedBox(width: 4),
                Text(
                  'Stock: $stock items',
                  style: TextStyle(
                    color: stockColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onRemove,
          tooltip: 'Remove from route',
        ),
      ),
    );
  }
}

