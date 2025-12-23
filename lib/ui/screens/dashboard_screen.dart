import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/selectors.dart';
import '../../state/providers.dart';
import '../widgets/machine_status_card.dart';
import '../utils/screen_utils.dart';

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
    final alertCount = ref.watch(alertCountProvider);
    final machines = ref.watch(machinesProvider);

    return Scaffold(
      // AppBar removed - managed by MainScreen
      body: CustomScrollView(
        slivers: [
          // Middle Section: Alerts
          if (alertCount > 0)
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: ScreenUtils.relativePadding(context, 0.007),
                color: Colors.red,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.white,
                      size: ScreenUtils.relativeSize(context, 0.01),
                    ),
                    SizedBox(width: ScreenUtils.relativeSize(context, 0.0034)),
                    Text(
                      'Warning: $alertCount Machine${alertCount > 1 ? 's' : ''} Empty!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtils.relativeFontSize(
                          context,
                          0.007,
                          min: ScreenUtils.getSmallerDimension(context) * 0.007,
                          max: ScreenUtils.getSmallerDimension(context) * 0.01,
                        ),
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
                      size: ScreenUtils.relativeSizeClamped(
                        context,
                        0.05, // Increased from 0.027
                        min: ScreenUtils.getSmallerDimension(context) * 0.04,
                        max: ScreenUtils.getSmallerDimension(context) * 0.08,
                      ),
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: ScreenUtils.relativeSize(context, 0.015)),
                    Text(
                      'No machines yet',
                      style: TextStyle(
                        fontSize: ScreenUtils.relativeFontSize(
                          context,
                          0.028, // Increased from 0.015
                          min: ScreenUtils.getSmallerDimension(context) * 0.022,
                          max: ScreenUtils.getSmallerDimension(context) * 0.04,
                        ),
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: ScreenUtils.relativeSize(context, 0.01)),
                    Text(
                      'Go to the Map to purchase machines',
                      style: TextStyle(
                        fontSize: ScreenUtils.relativeFontSize(
                          context,
                          0.020, // Increased from 0.012
                          min: ScreenUtils.getSmallerDimension(context) * 0.016,
                          max: ScreenUtils.getSmallerDimension(context) * 0.028,
                        ),
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

