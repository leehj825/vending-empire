import 'package:flutter/material.dart';
import '../../simulation/models/machine.dart';
import '../theme/zone_ui.dart';

/// Widget that displays a machine's status in a card format
class MachineStatusCard extends StatelessWidget {
  final Machine machine;

  const MachineStatusCard({
    super.key,
    required this.machine,
  });

  /// Calculate stock level percentage (0.0 to 1.0)
  /// Assuming max capacity of 50 items for visualization
  double _getStockLevel() {
    const maxCapacity = 50.0;
    final currentStock = machine.totalInventory.toDouble();
    return (currentStock / maxCapacity).clamp(0.0, 1.0);
  }

  /// Get color for stock level indicator
  Color _getStockColor() {
    final level = _getStockLevel();
    if (level > 0.5) return Colors.green;
    if (level > 0.2) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final stockLevel = _getStockLevel();
    final stockColor = _getStockColor();
    final zoneIcon = machine.zone.type.icon;
    final zoneColor = machine.zone.type.color;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Left: Zone Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: zoneColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                zoneIcon,
                color: zoneColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Center: Machine Info and Stock Level
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    machine.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Stock Level Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stock: ${machine.totalInventory} items',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: stockLevel,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(stockColor),
                        minHeight: 6,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right: Cash Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Cash',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '\$${machine.currentCash.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

