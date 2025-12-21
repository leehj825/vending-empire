import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import 'components/map_machine.dart';
import 'components/map_truck.dart';

import '../simulation/models/machine.dart';

/// Main game class for the city map visualization
class CityMapGame extends FlameGame with HasGameReference, ScaleDetector {
  final WidgetRef ref;
  final void Function(Machine)? onMachineTap;
  final Map<String, MapMachine> _machineComponents = {};
  final Map<String, MapTruck> _truckComponents = {};
  
  // Map bounds (1000x1000 grid)
  static const double mapWidth = 1000.0;
  static const double mapHeight = 1000.0;
  static final Vector2 mapCenter = Vector2(500.0, 500.0);
  
  // Camera constraints
  double _minZoom = 0.05; // Allow zooming out more
  double _maxZoom = 5.0; // Allow zooming in more
  double _currentZoom = 1.0;
  double _startZoom = 1.0;
  Vector2 _cameraPosition = mapCenter;

  CityMapGame(this.ref, {this.onMachineTap});

  @override
  Color backgroundColor() => const Color(0xFF388E3C);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Setup camera for 1000x1000 grid
    camera.viewfinder.anchor = Anchor.center;
    // Don't use FixedResolutionViewport - let it be responsive

    // Center camera on map
    camera.viewfinder.position = mapCenter;
    
    // Calculate initial zoom to fit map width
    _updateZoom();

    // Add grid background
    add(GridComponent());

    // Initial load of machines and trucks
    _syncMachines();
    _syncTrucks();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Recalculate zoom when screen size changes
    _updateZoom();
  }

  /// Calculate zoom level to fit the map width on screen
  void _updateZoom() {
    if (size.x == 0 || size.y == 0) return;
    
    // Calculate zoom based on screen size.
    // Fit the whole map on screen by default
    final widthZoom = size.x / mapWidth;
    final heightZoom = size.y / mapHeight;
    
    // Start from the smaller fit to ensure the whole map is visible
    final baseZoom = math.min(widthZoom, heightZoom);
    _currentZoom = baseZoom * 0.95; // Add a small margin
    
    // Clamp zoom
    _currentZoom = _currentZoom.clamp(_minZoom, _maxZoom);
    
    // Apply zoom
    camera.viewfinder.zoom = _currentZoom;
    
    // Ensure camera stays centered on map
    _clampCameraPosition();
  }

  /// Clamp camera position to keep map visible
  void _clampCameraPosition() {
    final viewportSize = size / _currentZoom;
    final halfViewport = viewportSize / 2;
    
    // Calculate bounds
    final minX = halfViewport.x;
    final maxX = mapWidth - halfViewport.x;
    final minY = halfViewport.y;
    final maxY = mapHeight - halfViewport.y;
    
    // If viewport is larger than map, center the camera
    if (minX >= maxX) {
      _cameraPosition.x = mapCenter.x;
    } else {
      _cameraPosition.x = _cameraPosition.x.clamp(minX, maxX);
    }

    if (minY >= maxY) {
      _cameraPosition.y = mapCenter.y;
    } else {
      _cameraPosition.y = _cameraPosition.y.clamp(minY, maxY);
    }
    
    camera.viewfinder.position = _cameraPosition;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Sync machines and trucks every frame to update positions
    _syncMachines();
    _syncTrucks();
  }

  // Zoom (pinch) and Pan (drag) handling
  @override
  void onScaleStart(ScaleStartInfo info) {
    _startZoom = _currentZoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final scaleVector = info.scale.global;
    final scaleFactor = (scaleVector.x + scaleVector.y) / 2.0;
    
    // Zoom
    // Handle both 1-finger (drag) and 2-finger (pinch) interactions
    // If pointerCount is 2, we update zoom
    // We check raw pointer count from the underlying event
    final pointerCount = info.raw.pointerCount;

    if (pointerCount == 2) {
      // Calculate new zoom
      // Use the relative scale change from the start of the gesture
      final newZoom = _startZoom * scaleFactor;
      _currentZoom = newZoom.clamp(_minZoom, _maxZoom);
      camera.viewfinder.zoom = _currentZoom;
    }

    // Pan
    // Always pan based on delta
    final deltaScreen = info.delta.global;
    
    // Check if there is actual movement to avoid jitter
    if (deltaScreen.length2 > 0.1) {
       // Apply pan
       final delta = deltaScreen / _currentZoom;
       _cameraPosition -= delta;
       _clampCameraPosition();
    }
  }

  @override
  void onScaleEnd(ScaleEndInfo info) {
    // Nothing needed
  }

  /// Sync machine components with provider state
  void _syncMachines() {
    try {
      final machines = ref.read(machinesProvider);

      // Remove machines that no longer exist
      final machineIds = machines.map((m) => m.id).toSet();
      final componentsToRemove = _machineComponents.keys
          .where((id) => !machineIds.contains(id))
          .toList();

      for (final id in componentsToRemove) {
        final component = _machineComponents.remove(id);
        component?.removeFromParent();
      }

      // Add or update machines
      for (final machine in machines) {
        if (_machineComponents.containsKey(machine.id)) {
          // Update existing component
          final component = _machineComponents[machine.id]!;
          component.updateMachine(machine);
          // Update position if zone changed
          final newPosition = Vector2(machine.zone.x * 100, machine.zone.y * 100);
          if (component.position != newPosition) {
            component.position = newPosition;
          }
        } else {
          // Create new component at machine's zone position
          final component = MapMachine(
            machine: machine,
            position: Vector2(machine.zone.x * 100, machine.zone.y * 100),
          );
          _machineComponents[machine.id] = component;
          add(component);
        }
      }
    } catch (e) {
      // Provider might not be available yet
      // Ignore for now
    }
  }

  /// Sync truck components with provider state
  void _syncTrucks() {
    try {
      final trucks = ref.read(trucksProvider);

      // Remove trucks that no longer exist
      final truckIds = trucks.map((t) => t.id).toSet();
      final componentsToRemove = _truckComponents.keys
          .where((id) => !truckIds.contains(id))
          .toList();

      for (final id in componentsToRemove) {
        final component = _truckComponents.remove(id);
        component?.removeFromParent();
      }

      // Add or update trucks
      for (final truck in trucks) {
        if (_truckComponents.containsKey(truck.id)) {
          // Update existing component
          final component = _truckComponents[truck.id]!;
          component.updateTruck(truck);
        } else {
          // Create new component at truck's current position
          final component = MapTruck(
            truck: truck,
            position: Vector2(truck.currentX * 100, truck.currentY * 100),
          );
          _truckComponents[truck.id] = component;
          add(component);
        }
      }
    } catch (e) {
      // Provider might not be available yet
      // Ignore for now
    }
  }
}

/// Grid component that draws grid lines
class GridComponent extends PositionComponent {
  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF757575)..strokeWidth = 20;
    for (double i = 0; i <= 1000; i += 100) {
      canvas.drawLine(Offset(i, 0), Offset(i, 1000), paint);
      canvas.drawLine(Offset(0, i), Offset(1000, i), paint);
    }
  }
}

