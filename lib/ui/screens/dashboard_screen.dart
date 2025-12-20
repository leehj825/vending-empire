import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/selectors.dart';
import '../../state/providers.dart';
import '../../simulation/models/zone.dart';
import '../widgets/machine_status_card.dart';

/// Main dashboard screen displaying simulation state and machine status
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isSimulationRunning = false;

  void _toggleSimulation() {
    final controller = ref.read(gameControllerProvider);
    controller.toggleSimulation();
    setState(() {
      _isSimulationRunning = !_isSimulationRunning;
    });
  }

  void _buyTestMachine() {
    final controller = ref.read(gameControllerProvider);
    controller.buyMachine(ZoneType.office, x: 0.0, y: 0.0);
  }

  String _formatTime(int day, int hour) {
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final amPm = hour < 12 ? 'AM' : 'PM';
    return 'Day $day, ${hour12.toString().padLeft(2, '0')}:00 $amPm';
  }

  @override
  Widget build(BuildContext context) {
    final cash = ref.watch(cashProvider);
    final reputation = ref.watch(reputationProvider);
    final dayCount = ref.watch(dayCountProvider);
    final hourOfDay = ref.watch(hourOfDayProvider);
    final alertCount = ref.watch(alertCountProvider);
    final machines = ref.watch(machinesProvider);

    return Scaffold(
      // AppBar removed - managed by MainScreen
      body: Column(
        children: [
          // Debug/Test Button moved to top
          Container(
            padding: const EdgeInsets.all(8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.add_business),
                  tooltip: 'Buy Machine (Test)',
                  onPressed: _buyTestMachine,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                // Top Section: Status Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                // Cash Card
                Expanded(
                  child: _StatusCard(
                    icon: Icons.attach_money,
                    iconColor: Colors.green,
                    label: 'Cash',
                    value: '\$${cash.toStringAsFixed(2)}',
                    valueColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                // Reputation Card
                Expanded(
                  child: _StatusCard(
                    icon: Icons.star,
                    iconColor: Colors.amber,
                    label: 'Reputation',
                    value: reputation.toString(),
                    valueColor: Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                // Time Card
                Expanded(
                  child: _StatusCard(
                    icon: Icons.access_time,
                    iconColor: Colors.blue,
                    label: 'Time',
                    value: _formatTime(dayCount, hourOfDay),
                    valueColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          // Middle Section: Alerts
          if (alertCount > 0)
            Container(
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
          // Bottom Section: Machine List
          Expanded(
            child: machines.isEmpty
                ? Center(
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
                          'Tap the + button to buy your first machine',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: machines.length,
                    itemBuilder: (context, index) {
                      return MachineStatusCard(
                        machine: machines[index],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleSimulation,
        tooltip: _isSimulationRunning ? 'Pause Simulation' : 'Start Simulation',
        child: Icon(
          _isSimulationRunning ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}

/// Reusable status card widget for the top status bar
class _StatusCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  const _StatusCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

