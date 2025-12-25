import 'package:flutter/material.dart';

/// Central configuration file for all constants used throughout the app
class AppConfig {
  AppConfig._(); // Private constructor to prevent instantiation

  // ============================================================================
  // FONT SIZES - Standardized font sizes for consistent UI
  // ============================================================================
  
  /// Font size factors for responsive sizing (relative to smaller screen dimension)
  static const double fontSizeFactorLarge = 0.045;      // Headers, titles
  static const double fontSizeFactorMedium = 0.035;    // Subheaders, important text
  static const double fontSizeFactorNormal = 0.032;    // Body text, labels
  static const double fontSizeFactorSmall = 0.025;     // Secondary text, captions
  static const double fontSizeFactorTiny = 0.02;       // Very small text
  
  /// Font size min/max multipliers (relative to smaller dimension)
  static const double fontSizeMinMultiplier = 0.025;
  static const double fontSizeMaxMultiplier = 0.065;
  
  /// Fixed font sizes for non-responsive elements
  static const double fontSizeFixedLarge = 18.0;
  static const double fontSizeFixedMedium = 16.0;
  static const double fontSizeFixedNormal = 14.0;
  static const double fontSizeFixedSmall = 12.0;
  static const double fontSizeFixedTiny = 10.0;
  
  // ============================================================================
  // UI CONSTANTS - Spacing, sizes, colors
  // ============================================================================
  
  /// Standard padding values
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  /// Spacing factors for SizedBox (relative to smaller screen dimension)
  static const double spacingFactorTiny = 0.001; // Very small spacing (1px on 1000px screen)
  static const double spacingFactorSmall = 0.002; // Small spacing (2px on 1000px screen)
  static const double spacingFactorMedium = 0.008; // Medium spacing (8px on 1000px screen)
  static const double spacingFactorLarge = 0.012; // Large spacing (12px on 1000px screen)
  static const double spacingFactorXLarge = 0.016; // Extra large spacing (16px on 1000px screen)
  
  /// Border radius values
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  
  /// Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;
  
  /// Button sizes
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  
  /// GameButton sizes (used in fleet manager and other screens)
  static const double gameButtonPaddingHorizontalFactor = 0.01; // Horizontal padding as factor of screen width
  static const double gameButtonPaddingVerticalFactor = 0.01; // Vertical padding as factor of smaller screen dimension
  static const double gameButtonBorderRadius = 8.0;
  static const double gameButtonIconSizeFactor = 0.05; // Icon size as factor of smaller screen dimension
  static const double gameButtonFontSizeFactor = 0.03; // Font size factor (responsive) - uses fontSizeFactorNormal by default
  
  /// SmallGameButton sizes (used in dialogs)
  static const double smallGameButtonPaddingHorizontalFactor = 0.01; // Horizontal padding as factor of screen width
  static const double smallGameButtonPaddingVerticalFactor = 0.01; // Vertical padding as factor of smaller screen dimension
  static const double smallGameButtonBorderRadius = 8.0;
  static const double smallGameButtonIconSizeFactor = 0.04; // Icon size as factor of smaller screen dimension
  static const double smallGameButtonFontSizeFactor = 0.025; // Font size factor (responsive) - uses fontSizeFactorSmall by default
  
  /// Truck selector card sizes (fleet manager screen)
  static const double truckCardWidthFactor = 0.15; // Card width as factor of screen width
  static const double truckCardHeightFactor = 0.16; // Card container height as factor of smaller screen dimension
  static const double truckCardPaddingFactor = 0.008; // Internal padding of truck card as factor of smaller screen dimension
  static const double truckCardBorderRadius = 2.0; // Border radius of truck card
  static const double truckCardMarginHorizontalFactor = 0.001; // Horizontal margin between cards as factor of screen width
  
  /// Truck icon sizes
  static const double truckIconContainerSizeFactor = 0.05; // Icon container size as factor of smaller screen dimension
  static const double truckIconSizeFactor = 0.05; // Icon size as factor of smaller screen dimension
  static const double truckIconContainerBorderRadius = 1.0; // Border radius of icon container
  
  /// Truck name and status sizes
  static const double truckNameFontSizeFactor = 0.02; // Truck name font size factor (uses fontSizeFactorSmall by default)
  static const double truckStatusFontSizeFactor = 0.02; // Status badge font size factor (uses fontSizeFactorSmall by default)
  static const double truckStatusPaddingHorizontalFactor = 0.002; // Status badge horizontal padding as factor of screen width
  static const double truckStatusPaddingVerticalFactor = 0.001; // Status badge vertical padding as factor of smaller screen dimension
  static const double truckStatusBorderRadius = 1.0; // Status badge border radius
  
  /// Bottom navigation bar sizes
  static const double bottomNavBarHeightFactor = 0.20; // Height as factor of smaller screen dimension
  
  /// Tab button sizes (HQ, City, Fleet, Market buttons)
  static const double tabButtonHeightFactor = 0.20; // Height as factor of smaller screen dimension
  static const double tabButtonHeightMinFactor = 0.20; // Minimum height as factor of smaller screen dimension
  static const double tabButtonHeightMaxFactor = 0.20; // Maximum height as factor of smaller screen dimension
  
  /// Tab button icon size (for fallback icons)
  static const double tabButtonIconSizeFactor = 0.20; // Icon size as factor of smaller screen dimension
  static const double tabButtonIconSizeMinFactor = 0.20; // Minimum icon size factor
  static const double tabButtonIconSizeMaxFactor = 0.20; // Maximum icon size factor
  
  /// Save/Exit button sizes
  static const double saveExitButtonHeightFactor = 0.10; // Height as factor of smaller screen dimension
  static const double saveExitButtonHeightMaxFactor = 0.10; // Maximum height as factor of smaller screen dimension
  static const double saveExitButtonWidthFactor = 0.10; // Width as factor of screen width
  static const double saveExitButtonWidthMinFactor = 0.10; // Minimum width as factor of screen width
  static const double saveExitButtonWidthMaxFactor = 0.10; // Maximum width as factor of screen width
  
  /// Top status bar boxes (cash, reputation, time)
  static const double statusCardWidthFactor = 0.75; // Width as factor of smaller dimension (0.25 * 3.0)
  static const double statusCardWidthMinFactor = 0.25; // Minimum width as factor of smaller dimension
  static const double statusCardWidthMaxFactor = 0.33; // Maximum width as factor of smaller dimension
  static const double statusCardHeightRatio = 1.0; // Height ratio relative to card width
  
  /// Status card icon settings
  static const double statusCardIconSizeFactor = 0.2; // Icon size factor relative to card width
  static const double statusCardIconSizeMinFactor = 0.2; // Minimum icon size as factor of smaller dimension
  static const double statusCardIconSizeMaxFactor = 0.2; // Maximum icon size as factor of smaller dimension
  static const double statusCardIconTopPositionFactor = 2.0; // Icon top position factor (1.0 = uses padding, adjust to change icon vertical position)
  
  /// Status card text settings
  static const double statusCardTextSizeFactor = 0.04; // Text font size factor (relative to smaller screen dimension)
  static const double statusCardTextBottomPositionFactor = 2.0; // Text bottom position factor (1.0 = uses padding, adjust to change text vertical position)
  
  /// Status card padding and spacing
  static const double statusCardPaddingFactor = 0.01; // Internal padding factor relative to card width
  static const double statusCardPaddingMinFactor = 0.01; // Minimum padding as factor of smaller dimension
  static const double statusCardPaddingMaxFactor = 0.01; // Maximum padding as factor of smaller dimension
  static const double statusBarContainerPaddingFactor = 0.001; // Container padding around status bar
  
  /// Card dimensions
  static const double cardBorderWidth = 2.0;
  static const double cardElevation = 4.0;
  
  /// Animation durations
  static const Duration animationDurationFast = Duration(milliseconds: 100);
  static const Duration animationDurationMedium = Duration(milliseconds: 200);
  static const Duration animationDurationSlow = Duration(milliseconds: 300);
  
  /// Snackbar durations
  static const Duration snackbarDurationShort = Duration(seconds: 2);
  static const Duration snackbarDurationLong = Duration(seconds: 3);
  
  // ============================================================================
  // GAME CONSTANTS - Prices, capacities, limits
  // ============================================================================
  
  /// Machine purchase prices
  static const double machineBasePrice = 400.0;
  
  /// Truck prices
  static const double truckPrice = 500.0;
  
  /// Warehouse capacity
  static const int warehouseMaxCapacity = 1000;
  
  /// Machine capacity
  static const double machineMaxCapacity = 50.0;
  static const int machineMaxItemsPerProduct = 20;
  
  /// Machine purchase limits per type
  static const int machineLimitPerType = 2;
  
  /// Fuel cost per unit distance
  static const double fuelCostPerUnit = 0.50;
  
  /// Route efficiency thresholds
  static const double routeEfficiencyGreat = 50.0;
  static const double routeEfficiencyGood = 100.0;
  static const double routeEfficiencyFair = 200.0;
  
  // ============================================================================
  // SIMULATION CONSTANTS
  // ============================================================================
  
  /// Time constants
  static const int hoursPerDay = 24;
  static const int ticksPerHour = 10;
  static const int ticksPerDay = hoursPerDay * ticksPerHour; // 240
  
  /// Gas/fuel constants
  static const double gasPrice = 0.05; // Cost per unit distance
  
  /// Reputation constants
  static const int emptyMachinePenaltyHours = 4;
  static const int reputationPenaltyPerEmptyHour = 5;
  
  /// Item disposal
  static const double disposalCostPerExpiredItem = 0.50;
  
  /// Pathfinding constants
  static const double roadSnapThreshold = 0.1;
  static const double pathfindingHeuristicWeight = 1.0;
  static const double wrongWayPenalty = 10.0;
  
  /// Movement speed
  static const double movementSpeed = 0.1;
  
  // ============================================================================
  // CITY MAP CONSTANTS
  // ============================================================================
  
  /// Grid size
  static const int cityGridSize = 10;
  
  /// Tile spacing factors
  static const double tileSpacingFactor = 0.80;
  static const double horizontalSpacingFactor = 0.70;
  
  /// Building scales
  static const double buildingScale = 0.81;
  static const double schoolScale = 0.77; // School tile scale (same as other small buildings)
  static const double gasStationScale = 0.72;
  static const double parkScale = 0.72;
  static const double houseScale = 0.72;
  static const double warehouseScale = 0.72;
  
  /// Building block sizes
  static const int minBlockSize = 2;
  static const int maxBlockSize = 3;
  
  /// Map padding
  static const double mapSidePadding = 100.0;
  static const double mapTopPadding = 150.0;
  static const double mapBottomPadding = 30.0;
  static const double mapTargetBottomGap = 20.0;
  
  /// Initial zoom
  static const double initialMapZoom = 1.5;
  
  // ============================================================================
  // UI COLORS
  // ============================================================================
  
  /// Primary game colors
  static const Color gameGreen = Color(0xFF4CAF50);
  static const Color surfaceColor = Color(0xFFF5F5F5);
  static const Color grassGreen = Color(0xFF388E3C);
  
  /// Status colors
  static const Color statusGood = Colors.green;
  static const Color statusWarning = Colors.orange;
  static const Color statusDanger = Colors.red;
  
  // ============================================================================
  // DEBOUNCE & TIMING
  // ============================================================================
  
  /// Debounce durations
  static const Duration debounceTap = Duration(milliseconds: 300);
  static const Duration debounceDelay = Duration(milliseconds: 150);
  
  // ============================================================================
  // SAVE/LOAD
  // ============================================================================
  
  static const String saveKey = 'vending_empire_save';
  
  // ============================================================================
  // FLAME GAME CONSTANTS
  // ============================================================================
  
  static const double mapWidth = 1000.0;
  static const double mapHeight = 1000.0;
  
  static const double worldScale = 100.0;
  static const double truckSpeed = 50.0; // Pixels per second
  static const double arrivalThreshold = 2.0;
  static const double blinkSpeed = 2.0; // Blinks per second
}

