import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/selectors.dart';
import '../../state/providers.dart';
import '../widgets/machine_status_card.dart';

/// Main dashboard screen displaying simulation state and machine status
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-start simulation when screen loads (if not already running)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(gameControllerProvider.notifier);
      if (!controller.isSimulationRunning) {
        controller.startSimulation();
      }
    });
  }




  @override
  Widget build(BuildContext context) {
    final cash = ref.watch(cashProvider);
    final reputation = ref.watch(reputationProvider);
    final dayCount = ref.watch(dayCountProvider);
    final alertCount = ref.watch(alertCountProvider);
    final machines = ref.watch(machinesProvider);
    
    // Format time as "Day X"
    final timeString = 'Day $dayCount';

    return Scaffold(
      // AppBar removed - managed by MainScreen
      body: CustomScrollView(
        slivers: [
          // Top Section: Status Bar
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surface,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Cash Card
                    SizedBox(
                      width: 140,
                      child: _StatusCard(
                        iconAsset: 'assets/images/cash_icon.png',
                        label: 'Cash',
                        value: '\$${cash.toStringAsFixed(2)}',
                        valueColor: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Reputation Card
                    SizedBox(
                      width: 140,
                      child: _StatusCard(
                        iconAsset: 'assets/images/star_icon.png',
                        label: 'Reputation',
                        value: reputation.toString(),
                        valueColor: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Time Card
                    SizedBox(
                      width: 140,
                      child: _StatusCard(
                        iconAsset: 'assets/images/clock_icon.png',
                        label: 'Time',
                        value: timeString,
                        valueColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Middle Section: Alerts
          if (alertCount > 0)
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.red,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Warning: $alertCount Machine${alertCount > 1 ? 's' : ''} Empty!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Bottom Section: Machine List
          if (machines.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No machines yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Go to the Map to purchase machines',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return MachineStatusCard(
                    machine: machines[index],
                  );
                },
                childCount: machines.length,
              ),
            ),
        ],
      ),
    );
  }
}

/// Reusable status card widget for the top status bar
class _StatusCard extends StatelessWidget {
  final String iconAsset;
  final String label;
  final String value;
  final Color valueColor;

  const _StatusCard({
    required this.iconAsset,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background icon
        Image.asset(
          'assets/images/status_icon.png',
          width: 140,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 140,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            );
          },
        ),
        // Content overlay
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      iconAsset,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          width: 20,
                          height: 20,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

