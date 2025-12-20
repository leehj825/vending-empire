import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';
import '../../game/city_map_game.dart';

/// Screen that displays the city map using Flame game engine
class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AppBar removed - managed by MainScreen
    return GameWidget<CityMapGame>.controlled(
      gameFactory: () => CityMapGame(ref),
    );
  }
}

