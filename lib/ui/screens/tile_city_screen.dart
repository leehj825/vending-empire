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
  northSouth,
  eastWest,
  intersection,
}

class TileCityScreen extends StatefulWidget {
  const TileCityScreen({super.key});

  @override
  State<TileCityScreen> createState() => _TileCityScreenState();
}

class _TileCityScreenState extends State<TileCityScreen> {
  static const int gridSize = 20;
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
    if ((hasNorth && hasSouth) || (hasEast && hasWest)) {
      return hasNorth && hasSouth
          ? RoadDirection.northSouth
          : RoadDirection.eastWest;
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

  String _getTileAssetPath(int x, int y) {
    final tileType = _grid[y][x];
    final roadDir = _roadDirections[y][x];

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

  double _getRoadRotation(int x, int y) {
    final roadDir = _roadDirections[y][x];
    if (roadDir == RoadDirection.northSouth) {
      return math.pi / 2; // 90 degrees for North-South
    }
    return 0.0; // East-West (default)
  }

  @override
  Widget build(BuildContext context) {
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
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
          childAspectRatio: 1.0,
        ),
        itemCount: gridSize * gridSize,
        itemBuilder: (context, index) {
          final x = index % gridSize;
          final y = index ~/ gridSize;
          final tileType = _grid[y][x];
          final isRoad = tileType == TileType.road;
          final rotation = isRoad ? _getRoadRotation(x, y) : 0.0;

          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 0.5),
            ),
            child: Transform.rotate(
              angle: rotation,
              child: Image.asset(
                _getTileAssetPath(x, y),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image fails to load
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
            ),
          );
        },
      ),
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
