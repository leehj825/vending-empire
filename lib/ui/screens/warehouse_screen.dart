import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../simulation/models/product.dart';
import '../../state/providers.dart';
import '../../config.dart';
import '../widgets/market_product_card.dart';
import '../utils/screen_utils.dart';

/// Warehouse & Market Screen
class WarehouseScreen extends ConsumerWidget {
  const WarehouseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouse = ref.watch(warehouseProvider);

    // Calculate warehouse capacity
    const maxCapacity = AppConfig.warehouseMaxCapacity;
    final currentTotal = warehouse.inventory.values.fold<int>(
      0,
      (sum, qty) => sum + qty,
    );
    final capacityPercent = (currentTotal / maxCapacity).clamp(0.0, 1.0);

    return Scaffold(
      // AppBar removed - managed by MainScreen
      body: CustomScrollView(
        slivers: [
          // Top Section: Warehouse Status
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(ScreenUtils.relativeSize(context, AppConfig.spacingFactorXLarge)),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Warehouse Status',
                    style: TextStyle(
                      fontSize: ScreenUtils.relativeFontSize(
                        context,
                        AppConfig.fontSizeFactorLarge,
                        min: ScreenUtils.getSmallerDimension(context) * AppConfig.fontSizeMinMultiplier,
                        max: ScreenUtils.getSmallerDimension(context) * AppConfig.fontSizeMaxMultiplier,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: ScreenUtils.relativeSize(context, 0.02)),
                  // Capacity indicator
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Capacity: $currentTotal / $maxCapacity items',
                              style: TextStyle(
                                fontSize: ScreenUtils.relativeFontSize(
                                  context,
                                  AppConfig.fontSizeFactorNormal,
                                  min: ScreenUtils.getSmallerDimension(context) * AppConfig.fontSizeMinMultiplier,
                                  max: ScreenUtils.getSmallerDimension(context) * AppConfig.fontSizeMaxMultiplier,
                                ),
                              ),
                            ),
                            SizedBox(height: ScreenUtils.relativeSize(context, AppConfig.spacingFactorMedium)),
                            LinearProgressIndicator(
                              value: capacityPercent,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                capacityPercent > 0.9
                                    ? Colors.red
                                    : capacityPercent > 0.7
                                        ? Colors.orange
                                        : Colors.green,
                              ),
                              minHeight: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenUtils.relativeSize(context, AppConfig.spacingFactorXLarge)),
                  // Current stock grid
                  if (warehouse.inventory.isNotEmpty) ...[
                    Text(
                      'Current Stock',
                      style: TextStyle(
                        fontSize: ScreenUtils.relativeFontSize(
                          context,
                          AppConfig.fontSizeFactorLarge,
                          min: ScreenUtils.getSmallerDimension(context) * AppConfig.fontSizeMinMultiplier,
                          max: ScreenUtils.getSmallerDimension(context) * AppConfig.fontSizeMaxMultiplier,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: ScreenUtils.relativeSize(context, AppConfig.spacingFactorMedium)),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: warehouse.inventory.entries.map((entry) {
                        return Chip(
                          label: Text(
                            '${entry.key.name}: ${entry.value}',
                            style: TextStyle(
                              fontSize: ScreenUtils.relativeFontSize(
                                context,
                                AppConfig.fontSizeFactorSmall,
                                min: ScreenUtils.getSmallerDimension(context) * AppConfig.fontSizeMinMultiplier,
                                max: ScreenUtils.getSmallerDimension(context) * AppConfig.fontSizeMaxMultiplier,
                              ),
                            ),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceContainerHighest,
                        );
                      }).toList(),
                    ),
                  ] else
                    Container(
                      padding: EdgeInsets.all(ScreenUtils.relativeSize(context, AppConfig.spacingFactorXLarge)),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: ScreenUtils.relativeSizeClamped(
                              context,
                              0.08, // Match dashboard icon size
                              min: ScreenUtils.getSmallerDimension(context) * 0.06,
                              max: ScreenUtils.getSmallerDimension(context) * 0.12,
                            ),
                          ),
                          SizedBox(width: ScreenUtils.relativeSize(context, 0.01)),
                          Text(
                            'Warehouse is empty',
                            style: TextStyle(
                              fontSize: ScreenUtils.relativeFontSize(
                                context,
                                AppConfig.fontSizeFactorNormal,
                                min: ScreenUtils.getSmallerDimension(context) * AppConfig.fontSizeMinMultiplier,
                                max: ScreenUtils.getSmallerDimension(context) * AppConfig.fontSizeMaxMultiplier,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Divider(height: 1),
          ),
          // Market Header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(ScreenUtils.relativeSize(context, AppConfig.spacingFactorXLarge)),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Prices',
                          style: TextStyle(
                            fontSize: ScreenUtils.relativeFontSize(
                              context,
                              AppConfig.fontSizeFactorLarge,
                              min: ScreenUtils.getSmallerDimension(context) * AppConfig.fontSizeMinMultiplier,
                              max: ScreenUtils.getSmallerDimension(context) * AppConfig.fontSizeMaxMultiplier,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Prices update automatically',
                          style: TextStyle(
                            fontSize: ScreenUtils.relativeFontSize(
                              context,
                              AppConfig.fontSizeFactorNormal,
                              min: ScreenUtils.getSmallerDimension(context) * AppConfig.fontSizeMinMultiplier,
                              max: ScreenUtils.getSmallerDimension(context) * AppConfig.fontSizeMaxMultiplier,
                            ),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Prices update automatically',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Prices update automatically',
                            style: TextStyle(
                              fontSize: ScreenUtils.relativeFontSize(
                                context,
                                AppConfig.fontSizeFactorNormal,
                                min: ScreenUtils.getSmallerDimension(context) * AppConfig.fontSizeMinMultiplier,
                                max: ScreenUtils.getSmallerDimension(context) * AppConfig.fontSizeMaxMultiplier,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Market Product List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = Product.values[index];
                return MarketProductCard(product: product);
              },
              childCount: Product.values.length,
            ),
          ),
        ],
      ),
    );
  }
}
