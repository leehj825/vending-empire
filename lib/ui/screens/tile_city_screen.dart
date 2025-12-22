import 'dart:math' as math;
import 'package:flutter/material.dart';

enum TileType {
  grass,
  road,
  shop,
  gym,
  office,
  school,
}

enum RoadDirection {
  vertical, // Connects (X, Y-1) and (X, Y+1) in isometric view
  horizontal, // Connects (X-1, Y) and (X+1, Y) in isometric view
  intersection,
}

class TileCityScreen extends StatefulWidget {
  const TileCityScreen({super.key});

  @override
  State<TileCityScreen> createState() => _TileCityScreenState();
}

class _TileCityScreenState extends State<TileCityScreen> {
  static const int gridSize = 20;
  
  // Isometric tile dimensions (tweakable constants)
  static const double tileWidth = 64.0;
  static const double tileHeight = 32.0;
  
  // Building image height (assumed taller than ground tiles)
  static const double buildingImageHeight = 80.0; // Adjust based on actual building image height
  
  late List<List<TileType>> _grid;
  late List<List<RoadDirection?>> _roadDirections;

  @override
  void initState() {
    super.initState();
    _generateMap();
  }

  void _generateMap() {
    // Initialize grid with grass
    _grid = List.generate(
      gridSize,
      (_) => List.filled(gridSize, TileType.grass),
    );
    _roadDirections = List.generate(
      gridSize,
      (_) => List.filled(gridSize, null),
    );

    // Random walker algorithm to generate roads
    _generateRoads();

    // Place buildings adjacent to roads
    _placeBuildings();
  }

  void _generateRoads() {
    final random = math.Random();
    final int targetRoadCount = 80 + random.nextInt(21); // 80-100 roads
    int roadCount = 0;

    // Start at center
    int x = gridSize ~/ 2;
    int y = gridSize ~/ 2;

    // Mark starting position as road
    _grid[y][x] = TileType.road;
    _roadDirections[y][x] = RoadDirection.intersection;
    roadCount++;

    // Random walker
    while (roadCount < targetRoadCount) {
      // Get valid neighbors (within bounds)
      final neighbors = <List<int>>[];
      if (x > 0) neighbors.add([x - 1, y]);
      if (x < gridSize - 1) neighbors.add([x + 1, y]);
      if (y > 0) neighbors.add([x, y - 1]);
      if (y < gridSize - 1) neighbors.add([x, y + 1]);

      // Prefer unvisited neighbors, but allow revisiting to create intersections
      final unvisited = neighbors.where((n) => _grid[n[1]][n[0]] != TileType.road).toList();
      final candidates = unvisited.isNotEmpty ? unvisited : neighbors;

      if (candidates.isEmpty) break;

      // Randomly select next position
      final next = candidates[random.nextInt(candidates.length)];
      final nextX = next[0];
      final nextY = next[1];

      // Mark as road
      if (_grid[nextY][nextX] != TileType.road) {
        _grid[nextY][nextX] = TileType.road;
        roadCount++;
      }

      // Move to next position
      x = nextX;
      y = nextY;
    }

    // Determine road directions after all roads are placed
    _updateRoadDirections();
  }

  void _updateRoadDirections() {
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        if (_grid[y][x] == TileType.road) {
          _roadDirections[y][x] = _getRoadDirection(x, y);
        }
      }
    }
  }

  RoadDirection _getRoadDirection(int x, int y) {
    // In isometric view:
    // Vertical: connects (X, Y-1) and (X, Y+1)
    // Horizontal: connects (X-1, Y) and (X+1, Y)
    final bool hasNorth = y > 0 && _grid[y - 1][x] == TileType.road;
    final bool hasSouth = y < gridSize - 1 && _grid[y + 1][x] == TileType.road;
    final bool hasEast = x < gridSize - 1 && _grid[y][x + 1] == TileType.road;
    final bool hasWest = x > 0 && _grid[y][x - 1] == TileType.road;

    final int connections = (hasNorth ? 1 : 0) +
        (hasSouth ? 1 : 0) +
        (hasEast ? 1 : 0) +
        (hasWest ? 1 : 0);

    // Intersection or corner (3+ connections)
    if (connections >= 3) {
      return RoadDirection.intersection;
    }

    // Straight roads
    if (hasNorth && hasSouth) {
      return RoadDirection.vertical;
    }
    if (hasEast && hasWest) {
      return RoadDirection.horizontal;
    }

    // Default to intersection for corners and dead ends
    return RoadDirection.intersection;
  }

  void _placeBuildings() {
    final random = math.Random();
    final buildingTypes = [
      TileType.shop,
      TileType.gym,
      TileType.office,
      TileType.school,
    ];

    // Find all grass tiles adjacent to roads
    final validSpots = <List<int>>[];
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        if (_grid[y][x] == TileType.grass && _isAdjacentToRoad(x, y)) {
          validSpots.add([x, y]);
        }
      }
    }

    // Shuffle valid spots
    validSpots.shuffle(random);

    // Place buildings randomly
    int buildingIndex = 0;
    for (final spot in validSpots) {
      if (buildingIndex >= buildingTypes.length * 10) break; // Limit building count
      _grid[spot[1]][spot[0]] = buildingTypes[buildingIndex % buildingTypes.length];
      buildingIndex++;
    }
  }

  bool _isAdjacentToRoad(int x, int y) {
    if (x > 0 && _grid[y][x - 1] == TileType.road) return true;
    if (x < gridSize - 1 && _grid[y][x + 1] == TileType.road) return true;
    if (y > 0 && _grid[y - 1][x] == TileType.road) return true;
    if (y < gridSize - 1 && _grid[y + 1][x] == TileType.road) return true;
    return false;
  }

  /// Convert grid coordinates to isometric screen coordinates
  Offset _gridToScreen(int gridX, int gridY) {
    final screenX = (gridX - gridY) * (tileWidth / 2);
    final screenY = (gridX + gridY) * (tileHeight / 2);
    return Offset(screenX, screenY);
  }

  String _getTileAssetPath(TileType tileType, RoadDirection? roadDir) {
    switch (tileType) {
      case TileType.grass:
        return 'assets/images/tiles/grass.png';
      case TileType.road:
        if (roadDir == RoadDirection.intersection) {
          return 'assets/images/tiles/road_4way.png';
        } else {
          return 'assets/images/tiles/road_2way.png';
        }
      case TileType.shop:
        return 'assets/images/tiles/shop.png';
      case TileType.gym:
        return 'assets/images/tiles/gym.png';
      case TileType.office:
        return 'assets/images/tiles/office.png';
      case TileType.school:
        return 'assets/images/tiles/school.png';
    }
  }

  double _getRoadRotation(RoadDirection? roadDir) {
    // In isometric view, vertical roads (North-South) may need rotation
    // Adjust based on how the sprite is oriented
    if (roadDir == RoadDirection.vertical) {
      return math.pi / 2; // 90 degrees
    }
    return 0.0; // Horizontal or intersection (default)
  }

  bool _isBuilding(TileType tileType) {
    return tileType == TileType.shop ||
        tileType == TileType.gym ||
        tileType == TileType.office ||
        tileType == TileType.school;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate map bounds for centering
    final topLeft = _gridToScreen(0, 0);
    final topRight = _gridToScreen(gridSize - 1, 0);
    final bottomLeft = _gridToScreen(0, gridSize - 1);
    final bottomRight = _gridToScreen(gridSize - 1, gridSize - 1);
    
    final minX = math.min(math.min(topLeft.dx, topRight.dx), math.min(bottomLeft.dx, bottomRight.dx));
    final maxX = math.max(math.max(topLeft.dx, topRight.dx), math.max(bottomLeft.dx, bottomRight.dx));
    final minY = math.min(math.min(topLeft.dy, topRight.dy), math.min(bottomLeft.dy, bottomRight.dy));
    final maxY = math.max(math.max(topLeft.dy, topRight.dy), math.max(bottomLeft.dy, bottomRight.dy));
    
    final mapWidth = maxX - minX + tileWidth;
    final mapHeight = maxY - minY + tileHeight + buildingImageHeight; // Add extra height for buildings
    
    // Center offset to position map in viewport
    final centerOffset = Offset(
      (MediaQuery.of(context).size.width - mapWidth) / 2 - minX,
      (MediaQuery.of(context).size.height - mapHeight) / 2 - minY,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tile City Map'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _generateMap();
              });
            },
            tooltip: 'Refresh Map',
          ),
        ],
      ),
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(100),
        minScale: 0.5,
        maxScale: 3.0,
        child: SizedBox(
          width: mapWidth,
          height: mapHeight,
          child: Stack(
            children: _buildTiles(centerOffset),
          ),
        ),
      ),
    );
  }

  /// Build all tiles in correct render order (Y loop, then X loop for painter's algorithm)
  List<Widget> _buildTiles(Offset centerOffset) {
    final tiles = <Widget>[];

    // Render in depth order: Y from 0 to max, then X from 0 to max
    // This ensures tiles "further back" (lower X+Y) are drawn before tiles "in front"
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        final tileType = _grid[y][x];
        final roadDir = _roadDirections[y][x];
        final screenPos = _gridToScreen(x, y);
        final positionedX = screenPos.dx + centerOffset.dx;
        final positionedY = screenPos.dy + centerOffset.dy;

        // Ground tile (grass or road)
        tiles.add(
          Positioned(
            left: positionedX,
            top: positionedY,
            width: tileWidth,
            height: tileHeight,
            child: _buildGroundTile(tileType, roadDir),
          ),
        );

        // Building tile (if applicable) - anchored at bottom-center
        if (_isBuilding(tileType)) {
          final buildingTop = positionedY - (buildingImageHeight - tileHeight);
          tiles.add(
            Positioned(
              left: positionedX + (tileWidth / 2) - (tileWidth / 2), // Center horizontally
              top: buildingTop,
              width: tileWidth,
              height: buildingImageHeight,
              child: _buildBuildingTile(tileType),
            ),
          );
        }
      }
    }

    return tiles;
  }

  Widget _buildGroundTile(TileType tileType, RoadDirection? roadDir) {
    final isRoad = tileType == TileType.road;
    final rotation = isRoad ? _getRoadRotation(roadDir) : 0.0;

    return Transform.rotate(
      angle: rotation,
      child: Image.asset(
        _getTileAssetPath(tileType, roadDir),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: _getFallbackColor(tileType),
            child: Center(
              child: Text(
                _getTileLabel(tileType),
                style: const TextStyle(fontSize: 8),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBuildingTile(TileType tileType) {
    return Image.asset(
      _getTileAssetPath(tileType, null),
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: _getFallbackColor(tileType),
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              _getTileLabel(tileType),
              style: const TextStyle(fontSize: 10),
            ),
          ),
        );
      },
    );
  }

  Color _getFallbackColor(TileType tileType) {
    switch (tileType) {
      case TileType.grass:
        return Colors.green.shade300;
      case TileType.road:
        return Colors.grey.shade600;
      case TileType.shop:
        return Colors.blue.shade300;
      case TileType.gym:
        return Colors.red.shade300;
      case TileType.office:
        return Colors.orange.shade300;
      case TileType.school:
        return Colors.purple.shade300;
    }
  }

  String _getTileLabel(TileType tileType) {
    switch (tileType) {
      case TileType.grass:
        return 'G';
      case TileType.road:
        return 'R';
      case TileType.shop:
        return 'S';
      case TileType.gym:
        return 'G';
      case TileType.office:
        return 'O';
      case TileType.school:
        return 'Sc';
    }
  }
}
