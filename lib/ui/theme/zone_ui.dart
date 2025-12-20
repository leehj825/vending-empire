import 'package:flutter/material.dart';
import '../../simulation/models/zone.dart';

/// Extension on ZoneType for UI presentation (icons and colors)
extension ZoneTypeUI on ZoneType {
  /// Get icon for this zone type
  IconData get icon {
    switch (this) {
      case ZoneType.gym:
        return Icons.fitness_center;
      case ZoneType.office:
        return Icons.business;
      case ZoneType.school:
        return Icons.school;
      case ZoneType.subway:
        return Icons.train;
      case ZoneType.park:
        return Icons.park;
    }
  }

  /// Get color for this zone type
  Color get color {
    switch (this) {
      case ZoneType.gym:
        return Colors.orange;
      case ZoneType.office:
        return Colors.blue;
      case ZoneType.school:
        return Colors.purple;
      case ZoneType.subway:
        return Colors.grey;
      case ZoneType.park:
        return Colors.green;
    }
  }
}
