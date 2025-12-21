import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/events.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import 'components/map_machine.dart';
import 'components/map_truck.dart';
import '../simulation/models/machine.dart';

class CityMapGame extends FlameGame with ScaleDetector, TapDetector {
  final WidgetRef ref;
  
  // Game State Containers
  final Map<String, MapMachine> _machineComponents = {};
  final Map<String, MapTruck> _truckComponents = {};
  
  // Constants
  static const double mapWidth = 1000.0;
  static const double mapHeight = 1000.0;
  static final Vector2 mapCenter = Vector2(500.0, 500.0);
  
  // Camera State
  double _minZoom = 0.1;
  double _maxZoom = 4.0;
  double _lastScale = 1.0;

  // Legacy callback for backward compatibility (can be removed if no longer used)
  final void Function(Machine)? onMachineTap;

  CityMapGame(this.ref, {this.onMachineTap});

  @override
  Color backgroundColor() => const Color(0xFF388E3C); // Grass Green

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // 1. Setup Camera
    // Anchor to center makes zooming/scaling much easier
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = mapCenter;

    // 2. Add Background Grid
    add(GridComponent());

    // 3. Initial Sync
    _syncMachines();
    _syncTrucks();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // When screen resizes (or loads), calculate the zoom to fit the map
    _fitMapToScreen();
  }

  void _fitMapToScreen() {
    if (size.x <= 0 || size.y <= 0) return;

    // Calculate ratio to fit width and height
    final zoomX = size.x / mapWidth;
    final zoomY = size.y / mapHeight;

    // Use the smaller zoom to ensure the WHOLE map is visible
    // "0.9" gives a 10% padding margin
    final fitZoom = math.min(zoomX, zoomY) * 0.9;
    
    // Update camera and constraints
    _minZoom = fitZoom; // Don't let user zoom out further than "fit"
    camera.viewfinder.zoom = fitZoom;
    
    // Re-center
    camera.viewfinder.position = mapCenter;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Constant sync loop for positions
    _syncMachines();
    _syncTrucks();
  }

  // --- GESTURE HANDLING ---

  @override
  void onScaleStart(ScaleStartInfo info) {
    // Reset the incremental scale tracker
    _lastScale = 1.0;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    // 1. Handle Zoom (Pinch)
    final currentScale = info.scale.global.x;
    if (!currentScale.isNaN && currentScale > 0) {
      final scaleDelta = currentScale / _lastScale;
      final newZoom = (camera.viewfinder.zoom * scaleDelta).clamp(_minZoom, _maxZoom);
      camera.viewfinder.zoom = newZoom;
      _lastScale = currentScale;
    }

    // 2. Handle Pan (Drag)
    // Divide delta by zoom to keep movement 1:1 with finger
    final delta = info.delta.global / camera.viewfinder.zoom;
    camera.viewfinder.position -= delta;

    // 3. Apply Clamp
    _clampCamera();
  }

  void _clampCamera() {
    // Calculate visible area
    final visibleSize = size / camera.viewfinder.zoom;
    
    // If map fits on screen, lock to center
    if (visibleSize.x >= mapWidth) {
      camera.viewfinder.position.x = mapCenter.x;
    } else {
      // Otherwise, clamp edges
      final halfW = visibleSize.x / 2;
      camera.viewfinder.position.x = camera.viewfinder.position.x.clamp(halfW, mapWidth - halfW);
    }

    if (visibleSize.y >= mapHeight) {
      camera.viewfinder.position.y = mapCenter.y;
    } else {
      final halfH = visibleSize.y / 2;
      camera.viewfinder.position.y = camera.viewfinder.position.y.clamp(halfH, mapHeight - halfH);
    }
  }

  // --- ENTITY SYNC LOGIC ---

  @override
  void onTapUp(TapUpInfo info) {
    // Handle Taps
    final touched = componentsAtPoint(info.eventPosition.widget);
    bool hit = false;
    for (final c in touched) {
      if (c is MapMachine) {
        hit = true; 
        break; // MapMachine handles its own onTap via TapCallbacks
      }
    }
    // Deselect if background tapped
    if (!hit) {
      try {
        ref.read(selectedMachineIdProvider.notifier).state = null;
      } catch (_) {}
    }
  }

  void _syncMachines() {
    try {
      final machines = ref.read(machinesProvider);
      
      final machineIds = machines.map((m) => m.id).toSet();
      _machineComponents.keys.where((id) => !machineIds.contains(id)).toList().forEach((id) {
         _machineComponents.remove(id)?.removeFromParent();
      });
      for (final m in machines) {
         if (_machineComponents.containsKey(m.id)) {
            _machineComponents[m.id]!.updateMachine(m);
            // Update pos
            _machineComponents[m.id]!.position = Vector2(m.zone.x * 100, m.zone.y * 100);
         } else {
            final c = MapMachine(machine: m, position: Vector2(m.zone.x * 100, m.zone.y * 100));
            _machineComponents[m.id] = c;
            add(c);
         }
      }
    } catch (_) {}
  }

  void _syncTrucks() {
    try {
      final trucks = ref.read(trucksProvider);
      final truckIds = trucks.map((t) => t.id).toSet();
      _truckComponents.keys.where((id) => !truckIds.contains(id)).toList().forEach((id) {
         _truckComponents.remove(id)?.removeFromParent();
      });
      for (final t in trucks) {
        final pos = Vector2(t.currentX * 100, t.currentY * 100);
        if (_truckComponents.containsKey(t.id)) {
           _truckComponents[t.id]!.updateTruck(t);
           // Lerp/Move truck
           _truckComponents[t.id]!.position = pos;
        } else {
           final c = MapTruck(truck: t, position: pos);
           _truckComponents[t.id] = c;
           add(c);
        }
      }
    } catch (_) {}
  }
}

class GridComponent extends PositionComponent {
  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF757575)..strokeWidth = 20;
    // Draw Border
    canvas.drawRect(Rect.fromLTWH(0,0,1000,1000), Paint()..style=PaintingStyle.stroke..color=Colors.white..strokeWidth=10);
    // Draw Grid
    for (double i = 0; i <= 1000; i += 100) {
      canvas.drawLine(Offset(i, 0), Offset(i, 1000), paint);
      canvas.drawLine(Offset(0, i), Offset(1000, i), paint);
    }
  }
}
