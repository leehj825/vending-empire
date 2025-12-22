import 'dart:async';
import 'dart:math';
import 'package:state_notifier/state_notifier.dart';
import 'models/product.dart';
import 'models/machine.dart';
import 'models/truck.dart';

/// Simulation constants
class SimulationConstants {
  static const double gasPrice = 0.05; // Cost per unit distance
  static const int hoursPerDay = 24;
  static const int ticksPerHour = 6; // 1 tick = 10 minutes, so 6 ticks per hour
  static const int ticksPerDay = hoursPerDay * ticksPerHour; // 144 ticks per day
  static const int emptyMachinePenaltyHours = 4; // Hours before reputation penalty
  static const int reputationPenaltyPerEmptyHour = 5;
  static const double disposalCostPerExpiredItem = 0.50;
}

/// Game time state
class GameTime {
  final int day; // Current game day (starts at 1)
  final int hour; // Current hour (0-23)
  final int minute; // Current minute (0-59, in 10-minute increments)
  final int tick; // Current tick within the day (0-143)

  const GameTime({
    required this.day,
    required this.hour,
    required this.minute,
    required this.tick,
  });

  /// Create from tick count (absolute ticks since game start)
  factory GameTime.fromTicks(int totalTicks) {
    final day = (totalTicks ~/ SimulationConstants.ticksPerDay) + 1;
    final tickInDay = totalTicks % SimulationConstants.ticksPerDay;
    final hour = tickInDay ~/ SimulationConstants.ticksPerHour;
    final minute = (tickInDay % SimulationConstants.ticksPerHour) * 10;
    
    return GameTime(
      day: day,
      hour: hour,
      minute: minute,
      tick: tickInDay,
    );
  }

  /// Get next time after one tick
  GameTime nextTick() {
    return GameTime.fromTicks(
      (day - 1) * SimulationConstants.ticksPerDay + tick + 1,
    );
  }

  /// Format time as string
  String get timeString {
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final amPm = hour < 12 ? 'AM' : 'PM';
    return 'Day $day, $hour12:${minute.toString().padLeft(2, '0')} $amPm';
  }
}

/// Simulation engine state
class SimulationState {
  final GameTime time;
  final List<Machine> machines;
  final List<Truck> trucks;
  final double cash;
  final int reputation;
  final Random random;

  const SimulationState({
    required this.time,
    required this.machines,
    required this.trucks,
    required this.cash,
    required this.reputation,
    required this.random,
  });

  SimulationState copyWith({
    GameTime? time,
    List<Machine>? machines,
    List<Truck>? trucks,
    double? cash,
    int? reputation,
    Random? random,
  }) {
    return SimulationState(
      time: time ?? this.time,
      machines: machines ?? this.machines,
      trucks: trucks ?? this.trucks,
      cash: cash ?? this.cash,
      reputation: reputation ?? this.reputation,
      random: random ?? this.random,
    );
  }
}

/// The Simulation Engine - The Heartbeat of the Game
class SimulationEngine extends StateNotifier<SimulationState> {
  Timer? _tickTimer;
  final Random _random = Random();
  final StreamController<SimulationState> _streamController = StreamController<SimulationState>.broadcast();

  SimulationEngine({
    required List<Machine> initialMachines,
    required List<Truck> initialTrucks,
    double initialCash = 1000.0,
    int initialReputation = 100,
  }) : super(
          SimulationState(
            time: const GameTime(day: 1, hour: 8, minute: 0, tick: 48), // 8:00 AM = 8 hours * 6 ticks/hour = 48 ticks
            machines: initialMachines,
            trucks: initialTrucks,
            cash: initialCash,
            reputation: initialReputation,
            random: Random(),
          ),
        );

  /// Stream of simulation state changes
  Stream<SimulationState> get stream => _streamController.stream;

  /// Add a machine to the simulation
  void addMachine(Machine machine) {
    print('閥 ENGINE: Adding machine ${machine.name}');
    state = state.copyWith(machines: [...state.machines, machine]);
    _streamController.add(state);
  }

  /// Update cash in the simulation
  void updateCash(double amount) {
    print('閥 ENGINE: Updating cash to \$${amount.toStringAsFixed(2)}');
    state = state.copyWith(cash: amount);
    _streamController.add(state);
  }

  /// Update trucks in the simulation
  void updateTrucks(List<Truck> trucks) {
    print('閥 ENGINE: Updating trucks list');
    state = state.copyWith(trucks: trucks);
    _streamController.add(state);
  }

  /// Update machines in the simulation
  ///
  /// This is used by the UI/controller to sync changes (e.g. buying a machine)
  /// so that the next engine tick doesn't overwrite local state.
  void updateMachines(List<Machine> machines) {
    print('閥 ENGINE: Updating machines list');
    state = state.copyWith(machines: machines);
    _streamController.add(state);
  }

  /// Start the simulation (ticks every 1 second)
  void start() {
    print('閥 ENGINE: Start requested');
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        // Safe check to ensure we don't tick if disposed
        if (!mounted) {
          timer.cancel();
          return;
        }
        _tick();
      },
    );
  }

  /// Stop the simulation
  void stop() {
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  /// Pause the simulation
  void pause() {
    stop();
  }

  /// Resume the simulation
  void resume() {
    start();
  }

  @override
  void dispose() {
    stop();
    if (!_streamController.isClosed) {
      _streamController.close();
    }
    // SimulationEngine is a StateNotifier, so we must call super.dispose()
    // However, if we are manually managing it inside another notifier, we need to be careful.
    super.dispose();
  }

  /// Main tick function - called every 1 second (10 minutes in-game)
  void _tick() {
    final currentState = state;
    
    // DEBUG PRINT
    print('閥 ENGINE TICK: Day ${currentState.time.day} ${currentState.time.hour}:00 | Machines: ${currentState.machines.length} | Cash: \$${currentState.cash.toStringAsFixed(2)}');

    final nextTime = currentState.time.nextTick();

    // 1. Process Sales
    var updatedMachines = _processMachineSales(currentState.machines, nextTime);
    
    // 2. Process Spoilage
    updatedMachines = _processSpoilage(updatedMachines, nextTime);
    
    // 3. Process Trucks (Movement)
    var updatedTrucks = _processTruckMovement(currentState.trucks, updatedMachines);
    
    // 4. Process Restocking (Truck arrived at machine)
    final restockResult = _processTruckRestocking(updatedTrucks, updatedMachines);
    updatedTrucks = restockResult.trucks;
    updatedMachines = restockResult.machines;

    // 5. Reputation & Cash
    final reputationPenalty = _calculateReputationPenalty(updatedMachines);
    var updatedReputation = (currentState.reputation - reputationPenalty).clamp(0, 1000);
    var updatedCash = currentState.cash;
    updatedCash = _processFuelCosts(updatedTrucks, updatedCash);

    // Update State
    final newState = currentState.copyWith(
      time: nextTime,
      machines: updatedMachines,
      trucks: updatedTrucks,
      cash: updatedCash,
      reputation: updatedReputation,
    );
    state = newState;
    
    // Notify listeners of state change via stream
    _streamController.add(newState);
  }

  /// Process machine sales based on demand math
  List<Machine> _processMachineSales(List<Machine> machines, GameTime time) {
    return machines.map((machine) {
      if (machine.isBroken || machine.isEmpty) {
        return machine.copyWith(
          hoursSinceRestock: machine.hoursSinceRestock + (10 / 60), // 10 minutes
        );
      }

      var updatedInventory = Map<Product, InventoryItem>.from(machine.inventory);
      var updatedCash = machine.currentCash;
      var salesCount = machine.totalSales;
      var hoursSinceRestock = machine.hoursSinceRestock;

      // Process each product type
      for (final product in Product.values) {
        final stock = machine.getStock(product);
        if (stock == 0) continue;

        // Calculate sale chance using the demand formula
        final baseDemand = product.baseDemand;
        final zoneMultiplier = machine.zone.getDemandMultiplier(time.hour);
        final trafficMultiplier = machine.zone.trafficMultiplier;
        
        final saleChance = baseDemand * zoneMultiplier * trafficMultiplier;
        
        // Clamp to reasonable range (0.0 to 1.0)
        final clampedChance = saleChance.clamp(0.0, 1.0);

        // Roll for sale
        if (_random.nextDouble() < clampedChance) {
          // Sale occurred!
          final item = updatedInventory[product]!;
          final newQuantity = item.quantity - 1;
          
          if (newQuantity > 0) {
            updatedInventory[product] = item.copyWith(quantity: newQuantity);
          } else {
            updatedInventory.remove(product);
          }

          updatedCash += product.basePrice;
          salesCount++;
        }
      }

      // Update hours since restock
      hoursSinceRestock += (10 / 60);

      return machine.copyWith(
        inventory: updatedInventory,
        currentCash: updatedCash,
        totalSales: salesCount,
        hoursSinceRestock: hoursSinceRestock,
      );
    }).toList();
  }

  /// Process spoilage
  List<Machine> _processSpoilage(List<Machine> machines, GameTime time) {
    return machines.map((machine) {
      var updatedInventory = Map<Product, InventoryItem>.from(machine.inventory);
      var disposalCost = 0.0;

      final itemsToRemove = <Product>[];
      for (final entry in updatedInventory.entries) {
        final item = entry.value;
        if (item.isExpired(time.day)) {
          disposalCost += SimulationConstants.disposalCostPerExpiredItem * item.quantity;
          itemsToRemove.add(entry.key);
        }
      }

      for (final product in itemsToRemove) {
        updatedInventory.remove(product);
      }

      final updatedCash = machine.currentCash - disposalCost;

      return machine.copyWith(
        inventory: updatedInventory,
        currentCash: updatedCash,
      );
    }).toList();
  }


  /// Calculate reputation penalty based on empty machines
  int _calculateReputationPenalty(List<Machine> machines) {
    int totalPenalty = 0;
    
    for (final machine in machines) {
      if (machine.isEmpty && machine.hoursEmpty >= SimulationConstants.emptyMachinePenaltyHours) {
        final hoursOverLimit = machine.hoursEmpty - SimulationConstants.emptyMachinePenaltyHours;
        totalPenalty += (SimulationConstants.reputationPenaltyPerEmptyHour * hoursOverLimit).round();
      }
    }
    
    return totalPenalty;
  }

  /// Helper to find the nearest valid road line to a target coordinate
  /// Based on TileCityScreen generation, roads are at indices 3 and 6
  double _getNearestRoad(double target) {
    // These specific coordinates match the _generateRoadGrid logic in TileCityScreen
    // starting at 3, stepping by 3, up to gridSize 10 -> [3.0, 6.0]
    const validRoads = [3.0, 6.0];
    
    double nearest = validRoads[0];
    double minDiff = (target - nearest).abs();
    
    for (int i = 1; i < validRoads.length; i++) {
      final diff = (target - validRoads[i]).abs();
      if (diff < minDiff) {
        minDiff = diff;
        nearest = validRoads[i];
      }
    }
    return nearest;
  }

  /// Process truck movement and route logic
  List<Truck> _processTruckMovement(
    List<Truck> trucks,
    List<Machine> machines,
  ) {
    return trucks.map((truck) {
      if (!truck.hasRoute || truck.isRouteComplete) {
        return truck.copyWith(status: TruckStatus.idle);
      }

      // Get current destination
      final destinationId = truck.currentDestination;
      if (destinationId == null) {
        return truck.copyWith(status: TruckStatus.idle);
      }

      // Find destination machine
      final destination = machines.firstWhere(
        (m) => m.id == destinationId,
        orElse: () => machines.first,
      );

      // Get machine position
      final machineX = destination.zone.x;
      final machineY = destination.zone.y;
      
      // Calculate direct distance to machine (not road)
      final dxToMachine = machineX - truck.currentX;
      final dyToMachine = machineY - truck.currentY;
      final distanceToMachine = (dxToMachine * dxToMachine + dyToMachine * dyToMachine) * 0.5; // Euclidean distance
      
      // If truck is very close to machine, mark as arrived
      if (distanceToMachine < 0.2) {
        return truck.copyWith(
          status: TruckStatus.restocking,
          currentX: machineX,
          currentY: machineY,
          targetX: machineX,
          targetY: machineY,
        );
      }
      
      // Calculate the nearest valid road coordinates to the target machine
      // This is the "Parking Spot" on the road nearest to the machine
      final roadTargetX = _getNearestRoad(machineX);
      final roadTargetY = _getNearestRoad(machineY);

      // We want to navigate to the point on the road network closest to the machine
      // This point will share either the X or Y coordinate of a road line
      // And the other coordinate will be the machine's projected coordinate onto that road
      
      // Determine if we should target the X-road or Y-road
      // Logic: Pick the road line that is physically closer to the machine
      final distToXRoad = (machineX - roadTargetX).abs();
      final distToYRoad = (machineY - roadTargetY).abs();
      
      double targetPathX, targetPathY;
      
      if (distToXRoad <= distToYRoad) {
        // Target is on the vertical road (x = roadTargetX)
        // Y coordinate is the machine's Y (projected onto the road)
        targetPathX = roadTargetX;
        targetPathY = machineY; // Stay on road at this Y? No, roads are grid.
        
        // Wait, roads are a Grid.
        // Vertical roads are at x=3, x=6. They exist for ALL Y.
        // So (3, 4.5) IS a valid point on the road network? Yes.
        // It's effectively on the "Vertical Road" at Y=4.5.
        // However, movement logic moves in integers (1.0).
        // If we move to Y=4.5, we might get stuck if we need to turn.
        // Let's stick to integer movement for pathfinding until the final approach.
        
        // Target the nearest integer point on the road grid?
        // Or simply: Navigate to (roadTargetX, machineY)
        targetPathY = machineY;
      } else {
        // Target is on the horizontal road (y = roadTargetY)
        targetPathX = machineX;
        targetPathY = roadTargetY;
      }
      
      // Check distance to this "Parking Spot" on the road
      final dxToSpot = targetPathX - truck.currentX;
      final dyToSpot = targetPathY - truck.currentY;
      final distToSpot = dxToSpot.abs() + dyToSpot.abs(); // Manhattan to parking spot

      // If we are AT the parking spot (or very close), initiate final approach
      if (distToSpot < 0.2) {
        // Final approach: Move directly from road to machine (off-road driving)
        final approachSpeed = 0.5;
        double newX = truck.currentX;
        double newY = truck.currentY;
        
        final normalizedDx = dxToMachine / distanceToMachine;
        final normalizedDy = dyToMachine / distanceToMachine;
        newX += normalizedDx * approachSpeed;
        newY += normalizedDy * approachSpeed;
        
        // Snap if close
        if ((dxToMachine > 0 && newX > machineX) || (dxToMachine < 0 && newX < machineX)) newX = machineX;
        if ((dyToMachine > 0 && newY > machineY) || (dyToMachine < 0 && newY < machineY)) newY = machineY;
        
        return truck.copyWith(
          status: TruckStatus.traveling,
          currentX: newX,
          currentY: newY,
          targetX: machineX,
          targetY: machineY,
        );
      }

      // Grid-based pathfinding: move along valid roads
      double currentX = truck.currentX;
      double currentY = truck.currentY;
      
      // Manhattan movement logic: Prioritize the axis with larger distance
      // But constrain movement to the road network
      
      double newX = currentX;
      double newY = currentY;
      
      // Are we currently on a road?
      // Helper to check if a coordinate is "on a road line"
      bool onVerticalRoad(double x) => (x - 3.0).abs() < 0.1 || (x - 6.0).abs() < 0.1;
      bool onHorizontalRoad(double y) => (y - 3.0).abs() < 0.1 || (y - 6.0).abs() < 0.1;
      
      bool currentlyOnVert = onVerticalRoad(currentX);
      bool currentlyOnHorz = onHorizontalRoad(currentY);
      
      // If we are off-road (and not near machine), we should panic/snap? 
      // Assuming we start on road.
      
      // Determine movement direction
      // We want to reduce dxToSpot and dyToSpot
      
      if (dxToSpot.abs() > dyToSpot.abs()) {
        // Wants to move Horizontal
        if (currentlyOnHorz) {
          // Safe to move Horizontal
           newX += dxToSpot > 0 ? 1.0 : -1.0;
        } else if (currentlyOnVert) {
          // We are on a vertical road, but want to move horizontal.
          // We must move Vertical to reach a Horizontal intersection.
          // Find nearest horizontal road line
          final nearestH = _getNearestRoad(currentY);
          final dyToH = nearestH - currentY;
          if (dyToH.abs() > 0.1) {
             newY += dyToH > 0 ? 1.0 : -1.0;
          } else {
            // We are at an intersection! Now we can move Horizontal.
             newX += dxToSpot > 0 ? 1.0 : -1.0;
          }
        }
      } else {
        // Wants to move Vertical
        if (currentlyOnVert) {
          // Safe to move Vertical
          newY += dyToSpot > 0 ? 1.0 : -1.0;
        } else if (currentlyOnHorz) {
          // On horizontal road, want to move vertical.
          // Move Horizontal to reach Vertical intersection.
          final nearestV = _getNearestRoad(currentX);
          final dxToV = nearestV - currentX;
          if (dxToV.abs() > 0.1) {
            newX += dxToV > 0 ? 1.0 : -1.0;
          } else {
             newY += dyToSpot > 0 ? 1.0 : -1.0;
          }
        }
      }
      
      // Fallback: If we didn't move (e.g. alignment issues), force a step towards target
      if (newX == currentX && newY == currentY) {
         if (dxToSpot.abs() > dyToSpot.abs()) newX += dxToSpot > 0 ? 1.0 : -1.0;
         else newY += dyToSpot > 0 ? 1.0 : -1.0;
      }

      return truck.copyWith(
        status: TruckStatus.traveling,
        currentX: newX,
        currentY: newY,
        targetX: destination.zone.x,
        targetY: destination.zone.y,
      );
    }).toList();
  }

  /// Process fuel costs for trucks
  double _processFuelCosts(List<Truck> trucks, double currentCash) {
    double totalFuelCost = 0.0;

    for (final truck in trucks) {
      if (truck.status == TruckStatus.traveling) {
        final distance = truck.distanceToTarget;
        final fuelCost = distance * SimulationConstants.gasPrice;
        totalFuelCost += fuelCost;
      }
    }

    return currentCash - totalFuelCost;
  }

  /// Calculate total distance for a truck route
  double calculateRouteDistance(
    List<String> machineIds,
    List<Machine> machines,
  ) {
    if (machineIds.length < 2) return 0.0;

    double totalDistance = 0.0;
    
    for (int i = 0; i < machineIds.length - 1; i++) {
      final machine1 = machines.firstWhere(
        (m) => m.id == machineIds[i],
      );
      final machine2 = machines.firstWhere(
        (m) => m.id == machineIds[i + 1],
      );

      final dx = machine2.zone.x - machine1.zone.x;
      final dy = machine2.zone.y - machine1.zone.y;
      totalDistance += (dx * dx + dy * dy) * 0.5; // Euclidean distance
    }

    return totalDistance;
  }

  /// Manually trigger a tick (for testing or manual control)
  void manualTick() {
    _tick();
  }

  /// Process a single tick with provided machines and trucks, returning updated lists
  /// This method is used by GameController to sync state
  ({List<Machine> machines, List<Truck> trucks}) tick(
    List<Machine> machines,
    List<Truck> trucks,
  ) {
    final currentTime = state.time;
    final nextTime = currentTime.nextTick();

    // Process all simulation systems
    var updatedMachines = _processMachineSales(machines, nextTime);
    updatedMachines = _processSpoilage(updatedMachines, nextTime);
    
    // Process truck movement and restocking
    var updatedTrucks = _processTruckMovement(trucks, updatedMachines);
    
    // Handle automatic restocking when trucks arrive at machines
    final restockResult = _processTruckRestocking(updatedTrucks, updatedMachines);
    updatedTrucks = restockResult.trucks;
    updatedMachines = restockResult.machines;

    return (machines: updatedMachines, trucks: updatedTrucks);
  }

  /// Process truck restocking when trucks arrive at machines
  ({List<Machine> machines, List<Truck> trucks}) _processTruckRestocking(
    List<Truck> trucks,
    List<Machine> machines,
  ) {
    var updatedMachines = List<Machine>.from(machines);
    var updatedTrucks = List<Truck>.from(trucks);
    final currentDay = state.time.day;

    for (int i = 0; i < updatedTrucks.length; i++) {
      final truck = updatedTrucks[i];
      
      // Only process trucks that are restocking
      if (truck.status != TruckStatus.restocking) continue;
      
      final destinationId = truck.currentDestination;
      if (destinationId == null) continue;

      // Find the machine being restocked
      final machineIndex = updatedMachines.indexWhere((m) => m.id == destinationId);
      if (machineIndex == -1) continue;

      final machine = updatedMachines[machineIndex];
      var machineInventory = Map<Product, InventoryItem>.from(machine.inventory);
      var truckInventory = Map<Product, int>.from(truck.inventory);

      // Transfer items from truck to machine (up to machine capacity)
      final maxMachineCapacity = 100; // Max items a machine can hold
      final currentMachineTotal = machineInventory.values.fold<int>(
        0,
        (sum, item) => sum + item.quantity,
      );
      final availableSpace = maxMachineCapacity - currentMachineTotal;

      if (availableSpace > 0 && truckInventory.isNotEmpty) {
        var itemsToTransfer = <Product, int>{};
        var totalTransferred = 0;

        // Transfer items from truck to machine
        for (final entry in truckInventory.entries) {
          if (totalTransferred >= availableSpace) break;
          
          final product = entry.key;
          final truckQuantity = entry.value;
          if (truckQuantity <= 0) continue;

          final transferAmount = (truckQuantity < availableSpace - totalTransferred)
              ? truckQuantity
              : availableSpace - totalTransferred;

          // Update machine inventory
          final existingItem = machineInventory[product];
          if (existingItem != null) {
            machineInventory[product] = existingItem.copyWith(
              quantity: existingItem.quantity + transferAmount,
            );
          } else {
            machineInventory[product] = InventoryItem(
              product: product,
              quantity: transferAmount,
              dayAdded: currentDay,
            );
          }

          // Update truck inventory
          final remainingTruckQuantity = truckQuantity - transferAmount;
          if (remainingTruckQuantity > 0) {
            itemsToTransfer[product] = remainingTruckQuantity;
          }

          totalTransferred += transferAmount;
        }

        // Update truck inventory
        final updatedTruckInventory = itemsToTransfer;
        updatedTrucks[i] = truck.copyWith(
          inventory: updatedTruckInventory,
          status: TruckStatus.traveling, // Done restocking, continue route
          currentRouteIndex: truck.currentRouteIndex + 1,
        );

        // Update machine
        updatedMachines[machineIndex] = machine.copyWith(
          inventory: machineInventory,
          hoursSinceRestock: 0.0,
        );
      } else {
        // No space or no items, still advance route so the truck doesn't get stuck.
        updatedTrucks[i] = truck.copyWith(
          status: TruckStatus.traveling,
          currentRouteIndex: truck.currentRouteIndex + 1,
        );
      }
    }

    return (machines: updatedMachines, trucks: updatedTrucks);
  }
}