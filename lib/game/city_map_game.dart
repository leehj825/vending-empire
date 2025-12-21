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

class CityMapGame extends FlameGame with ScaleDetector, ScrollDetector, TapDetector, PanDetector {
  final WidgetRef ref;
  
  final Map<String, MapMachine> _machineComponents = {};
  final Map<String, MapTruck> _truckComponents = {};
  
  static const double mapWidth = 1000.0;
  static const double mapHeight = 1000.0;
  static final Vector2 mapCenter = Vector2(500.0, 500.0);
  
  // Camera State
  double _minZoom = 0.1;
  double _maxZoom = 5.0;
  double _startZoom = 1.0;
  bool _hasInitialized = false;
  
  // Pan state for single-finger drag
  Vector2? _lastDragPosition;
  Vector2? _panStartPosition;
  bool _isPanning = false;
  static const double _panThreshold = 30.0; // Increased threshold significantly for touch screens
  DateTime? _panStartTime; // Track when pan gesture started
  static const Duration _panDelay = Duration(milliseconds: 200); // Longer delay for touch screens
  Vector2? _panInitialPosition; // Store initial position to detect if scale might be happening
  
  // Scale state for pinch-to-zoom
  bool _isScaling = false;

  // Legacy callback
  final void Function(Machine)? onMachineTap;

  CityMapGame(this.ref, {this.onMachineTap});

  @override
  Color backgroundColor() => const Color(0xFF388E3C); // Grass Green

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Setup Camera - ensure it's properly configured
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = mapCenter;
    camera.viewfinder.zoom = 0.5; // Start zoomed out slightly
    
    // Stop any camera following to allow manual control
    camera.stop();
    
    debugPrint('[Camera Setup] position: ${camera.viewfinder.position}, zoom: ${camera.viewfinder.zoom}, anchor: ${camera.viewfinder.anchor}');
    debugPrint('[Camera Setup] viewport: ${camera.viewport.size}');

    // Add Content to world (camera will automatically transform them)
    world.add(GridComponent());

    _syncMachines();
    _syncTrucks();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Only fit to screen on first resize, not on every resize
    // This prevents interfering with user gestures
    if (!_hasInitialized) {
      _fitMapToScreen();
      _hasInitialized = true;
    }
  }

  void _fitMapToScreen() {
    if (size.x <= 0 || size.y <= 0) return;

    final scaleX = size.x / mapWidth;
    final scaleY = size.y / mapHeight;
    
    // Fit map to screen with margin
    final fitZoom = math.min(scaleX, scaleY) * 0.9;
    
    camera.viewfinder.zoom = fitZoom;
    camera.viewfinder.position = mapCenter;
    
    // Set minimum zoom so user can't zoom out past the full map
    _minZoom = fitZoom;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _syncMachines();
    _syncTrucks();
  }

  // --- GESTURES ---

  @override
  void onScaleStart(ScaleStartInfo info) {
    // Pinch-to-zoom gesture started (2 fingers)
    // Cancel any active pan gesture immediately - this is critical for touch screens
    _isPanning = false;
    _lastDragPosition = null;
    _panStartPosition = null;
    _panStartTime = null;
    _panInitialPosition = null;
    
    _isScaling = true;
    _startZoom = camera.viewfinder.zoom;
    
    debugPrint('[Scale] ⚡ STARTED - initial zoom: $_startZoom, cancelled pan');
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    // Always cancel pan when scale is detected - critical for touch screens
    _isPanning = false;
    _lastDragPosition = null;
    _panStartPosition = null;
    _panStartTime = null;
    _panInitialPosition = null;
    
    // Always process scale updates - if scale gesture is happening, prioritize it
    if (!_isScaling) {
      _isScaling = true;
      _startZoom = camera.viewfinder.zoom;
      debugPrint('[Scale] ⚡ DETECTED during update - cancelling pan, scale: ${info.scale.global}');
    }
    
    // Handle pinch-to-zoom (2 fingers)
    // The scale.global represents cumulative scale from gesture start
    // Use .y component which is typically used for pinch gestures
    final scaleFactor = info.scale.global.y;
    
    // Process zoom if scale factor is valid
    if (!scaleFactor.isNaN && scaleFactor > 0) {
      final newZoom = (_startZoom * scaleFactor).clamp(_minZoom, _maxZoom);
      // Only update if zoom actually changed to avoid unnecessary updates
      if ((newZoom - camera.viewfinder.zoom).abs() > 0.001) {
        camera.viewfinder.zoom = newZoom;
        debugPrint('[Scale] ⚡ UPDATE - scale: $scaleFactor, zoom: $newZoom (from $_startZoom)');
      }
    } else {
      debugPrint('[Scale] ⚠️ Invalid scale factor: $scaleFactor, global: ${info.scale.global}');
    }

    // Also handle panning during pinch (when fingers move while pinching)
    final delta = info.delta.global;
    if (delta.x != 0 || delta.y != 0) {
      final worldDelta = delta / camera.viewfinder.zoom;
      camera.viewfinder.position -= worldDelta;
    }
    
    // Clamp camera position
    _clampCamera();
  }

  @override
  void onScaleEnd(ScaleEndInfo info) {
    _isScaling = false;
    debugPrint('[Scale] ⚡ ENDED - final zoom: ${camera.viewfinder.zoom}');
  }

  void _clampCamera() {
    // Basic clamping to keep map in view
    // Allow viewing slightly outside the map (padding)
    const padding = 200.0;
    
    final x = camera.viewfinder.position.x;
    final y = camera.viewfinder.position.y;
    
    camera.viewfinder.position.x = x.clamp(-padding, mapWidth + padding);
    camera.viewfinder.position.y = y.clamp(-padding, mapHeight + padding);
  }

  @override
  void onScroll(PointerScrollInfo info) {
    // Mouse wheel zoom
    final scrollDelta = info.scrollDelta.global.y;
    
    // Invert scroll direction: scroll up (negative) zooms in, scroll down (positive) zooms out
    // Use a smaller divisor for more responsive zoom
    final zoomFactor = 1.0 - (scrollDelta / 500.0);
    final oldZoom = camera.viewfinder.zoom;
    final newZoom = (oldZoom * zoomFactor).clamp(_minZoom, _maxZoom);
    
    if (newZoom != oldZoom) {
      camera.viewfinder.zoom = newZoom;
      debugPrint('[Mouse Wheel Zoom] scrollDelta: $scrollDelta, zoomFactor: $zoomFactor, oldZoom: $oldZoom, newZoom: $newZoom');
      _clampCamera();
    }
  }

  @override
  void onPanStart(DragStartInfo info) {
    // Only handle pan if not currently scaling (single finger drag)
    // If scale is active, don't start pan
    if (_isScaling) {
      _isPanning = false;
      _lastDragPosition = null;
      _panStartPosition = null;
      _panStartTime = null;
      _panInitialPosition = null;
      debugPrint('[Pan] Start cancelled - scale is active');
      return;
    }
    
    // Store initial position and time but don't activate pan yet
    // Wait for threshold movement AND delay to distinguish from potential pinch
    // This gives scale gesture time to be detected on touch screens
    _panStartPosition = info.eventPosition.widget;
    _panInitialPosition = info.eventPosition.widget;
    _lastDragPosition = info.eventPosition.widget;
    _panStartTime = DateTime.now();
    _isPanning = false; // Not active until threshold AND delay are met
    debugPrint('[Pan] Start detected - waiting for threshold and delay (touch screen mode)');
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    // If scale is active, cancel pan immediately - critical for touch screens
    // This is the key: scale gesture takes priority
    if (_isScaling) {
      _isPanning = false;
      _lastDragPosition = null;
      _panStartPosition = null;
      _panStartTime = null;
      _panInitialPosition = null;
      return;
    }
    
    final currentPosition = info.eventPosition.widget;
    
    // Check if movement pattern suggests a pinch gesture (fingers moving apart/together)
    // If initial position and current position suggest radial movement, might be pinch
    if (_panInitialPosition != null && !_isPanning) {
      final totalMovement = (currentPosition - _panInitialPosition!).length;
      // If movement is very small, might be waiting for second finger
      if (totalMovement < 15.0) {
        _lastDragPosition = currentPosition;
        return; // Wait longer, might be starting pinch
      }
    }
    
    // If pan hasn't been activated yet, check both threshold AND delay
    // This gives scale gesture time to be detected on touch screens before pan activates
    if (!_isPanning && _panStartPosition != null && _panStartTime != null) {
      final movement = (currentPosition - _panStartPosition!).length;
      final timeSinceStart = DateTime.now().difference(_panStartTime!);
      
      // Require BOTH sufficient movement AND time delay before activating pan
      // This prevents pan from starting when user is about to add second finger
      if (movement >= _panThreshold && timeSinceStart >= _panDelay) {
        // Enough movement AND enough time - this is a pan, not a pinch
        _isPanning = true;
        _lastDragPosition = _panStartPosition;
        debugPrint('[Pan] Activated after threshold ($movement) and delay (${timeSinceStart.inMilliseconds}ms)');
      } else {
        // Not enough movement or time yet - might be starting a pinch
        _lastDragPosition = currentPosition;
        return;
      }
    }
    
    // Only handle pan if it's active and we have a valid last position
    if (!_isPanning || _lastDragPosition == null) {
      return;
    }
    
    // Calculate drag delta (incremental from last position)
    final delta = currentPosition - _lastDragPosition!;
    
    // Skip if delta is too small (avoid jitter)
    if (delta.length < 0.5) return;
    
    // Convert screen delta to world space for panning
    // Divide by zoom so movement is 1:1 with screen
    final worldDelta = delta / camera.viewfinder.zoom;
    camera.viewfinder.position -= worldDelta;
    
    _lastDragPosition = currentPosition;
    
    // Clamp camera to keep map in view
    _clampCamera();
  }

  @override
  void onPanEnd(DragEndInfo info) {
    _isPanning = false;
    _lastDragPosition = null;
    _panStartPosition = null;
    _panStartTime = null;
    _panInitialPosition = null;
  }

  @override
  void onPanCancel() {
    _isPanning = false;
    _lastDragPosition = null;
    _panStartPosition = null;
    _panStartTime = null;
    _panInitialPosition = null;
  }

  @override
  void onTapUp(TapUpInfo info) {
    final touched = componentsAtPoint(info.eventPosition.widget);
    bool hit = false;
    for (final c in touched) {
      if (c is MapMachine) { hit = true; break; }
    }
    if (!hit) {
      try { ref.read(selectedMachineIdProvider.notifier).state = null; } catch (_) {}
    }
  }

  // --- SYNC LOGIC ---

  void _syncMachines() {
    try {
      final machines = ref.read(machinesProvider);
      final machineIds = machines.map((m) => m.id).toSet();
      _machineComponents.keys.where((id) => !machineIds.contains(id)).toList().forEach((id) {
         _machineComponents.remove(id)?.removeFromParent();
      });
      for (final m in machines) {
         // Zone coordinates are in 1.0-9.0 range, map is 1000x1000 with 100px grid cells
         // Grid lines are drawn at 0, 100, 200, 300, ..., 1000 (gray roads)
         // Green blocks are BETWEEN grid lines:
         //   Block 1: 0-100 (center at 50) - NOT on grid line at 0 or 100
         //   Block 2: 100-200 (center at 150) - NOT on grid line at 100 or 200
         //   Block 3: 200-300 (center at 250) - NOT on grid line at 200 or 300
         //   etc.
         // Zone x=1.0 should map to block 1 (center at 50), zone x=2.0 to block 2 (center at 150)
         // Formula: (zone.x - 1) * 100 + 50 centers in the correct block
         // Ensure we're centering in blocks, not placing on grid lines
         final blockX = (m.zone.x - 1.0).floor();
         final blockY = (m.zone.y - 1.0).floor();
         // Center in block: block * 100 + 50 (this ensures position is NOT a multiple of 100)
         final posX = blockX * 100.0 + 50.0;
         final posY = blockY * 100.0 + 50.0;
         final pos = Vector2(posX, posY);
         
         // Debug: verify position is not on a grid line
         if (posX % 100 == 0 || posY % 100 == 0) {
           debugPrint('[Machine Position] WARNING: Machine ${m.name} at ($posX, $posY) is on grid line! Zone: (${m.zone.x}, ${m.zone.y})');
         }
         if (_machineComponents.containsKey(m.id)) {
            _machineComponents[m.id]!.updateMachine(m);
            _machineComponents[m.id]!.position = pos;
         } else {
            final c = MapMachine(machine: m, position: pos);
            _machineComponents[m.id] = c;
            world.add(c);
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
        // Trucks must be on roads (integer coordinates in zone space)
        // Roads are at integer coordinates, which map to multiples of 100 in pixel space
        // Ensure truck coordinates are integers (snap to road if needed)
        final roadX = t.currentX.round().toDouble();
        final roadY = t.currentY.round().toDouble();
        // Roads are at pixel positions: 0, 100, 200, 300, ..., 1000
        // Integer zone coordinates map to these road positions
        final pos = Vector2(roadX * 100, roadY * 100);
        if (_truckComponents.containsKey(t.id)) {
           _truckComponents[t.id]!.updateTruck(t);
           _truckComponents[t.id]!.position = pos;
        } else {
           final c = MapTruck(truck: t, position: pos);
           _truckComponents[t.id] = c;
           world.add(c);
        }
      }
    } catch (_) {}
  }
}

class GridComponent extends PositionComponent {
  GridComponent() : super(
    position: Vector2.zero(),
    size: Vector2(CityMapGame.mapWidth, CityMapGame.mapHeight),
  );

  @override
  void render(Canvas canvas) {
    // Normal Grid
    final paint = Paint()..color = const Color(0xFF757575)..strokeWidth = 20;
    for (double i = 0; i <= 1000; i += 100) {
      canvas.drawLine(Offset(i, 0), Offset(i, 1000), paint);
      canvas.drawLine(Offset(0, i), Offset(1000, i), paint);
    }
  }
}