# Fixed Sizes Review

This document lists all fixed-size configurations found in the codebase that should potentially be converted to relative sizes for better responsiveness.

## Config.dart - Fixed Sizes

### UI Constants (Should be relative)
1. **Fixed Font Sizes** (lines 23-27):
   - `fontSizeFixedLarge = 18.0`
   - `fontSizeFixedMedium = 16.0`
   - `fontSizeFixedNormal = 14.0`
   - `fontSizeFixedSmall = 12.0`
   - `fontSizeFixedTiny = 10.0`
   - **Note**: Comment says "for non-responsive elements" - verify if these are actually used

2. **Fixed Padding Values** (lines 34-36):
   - `paddingSmall = 8.0`
   - `paddingMedium = 16.0`
   - `paddingLarge = 24.0`
   - **Status**: Should be relative

3. **Fixed Border Radius** (lines 57-59):
   - `borderRadiusSmall = 8.0`
   - `borderRadiusMedium = 12.0`
   - `borderRadiusLarge = 16.0`
   - **Status**: Should be relative (factors exist but these fixed values also exist)

4. **Fixed Icon Sizes** (lines 62-65):
   - `iconSizeSmall = 16.0`
   - `iconSizeMedium = 24.0`
   - `iconSizeLarge = 32.0`
   - `iconSizeXLarge = 48.0`
   - **Status**: Should be relative

5. **Fixed Button Heights** (lines 68-69):
   - `buttonHeight = 48.0`
   - `buttonHeightSmall = 36.0`
   - **Status**: Should be relative

6. **Fixed Game Button Border Radius** (lines 74, 82):
   - `gameButtonBorderRadius = 8.0`
   - `smallGameButtonBorderRadius = 8.0`
   - **Status**: Should be relative

7. **Fixed Card Values** (lines 231-232):
   - `cardBorderWidth = 2.0`
   - `cardElevation = 4.0`
   - **Status**: Should be relative

8. **Fixed Map Padding** (lines 495-498):
   - `mapSidePadding = 100.0`
   - `mapTopPadding = 150.0`
   - `mapBottomPadding = 30.0`
   - `mapTargetBottomGap = 20.0`
   - **Status**: Should be relative

9. **Fixed Border Width** (line 344):
   - `machineInteriorDialogCashDisplayBorderWidth = 2.0`
   - **Status**: Should be relative

### Game Constants (May be intentional - game logic)
- `machineBasePrice = 400.0` - Game value, not UI
- `truckPrice = 500.0` - Game value, not UI
- `mapWidth = 1000.0` - Game world size, may be intentional
- `mapHeight = 1000.0` - Game world size, may be intentional
- `truckSpeed = 50.0` - Game physics, may be intentional
- `arrivalThreshold = 2.0` - Game physics, may be intentional
- `blinkSpeed = 2.0` - Animation speed, may be intentional

## Code Files - Fixed Sizes

### lib/ui/widgets/admob_banner.dart
- **Line 108-109**: `width: 20, height: 20` (loading spinner)
  - **Status**: Should be relative

### lib/ui/screens/main_screen.dart
- **Line 620**: `SizedBox(height: 16)` (spacing in save dialog)
  - **Status**: Should be relative

### lib/ui/widgets/game_button.dart
- **Line 62**: `width: 2` (border width)
  - **Status**: Should be relative
- **Line 77**: `SizedBox(width: 8)` (spacing between icon and text)
  - **Status**: Should be relative

### lib/game/city_map_game.dart
- **Line 134**: `const padding = 200.0` (camera clamp padding)
  - **Status**: Should be relative to map size

### lib/ui/screens/map_screen.dart
- **Line 75**: `EdgeInsets.all(16.0)` (padding)
  - **Status**: Should be relative
- **Line 89**: `SizedBox(height: 4)` (spacing)
  - **Status**: Should be relative

### lib/game/components/map_machine.dart
- **Line 193**: `fontSize: 16` (machine label text)
  - **Status**: Should be relative

### lib/ui/widgets/marketing_button.dart
- **Line 243**: `width: 3.0` (border width)
  - **Status**: Should be relative

### lib/ui/screens/warehouse_screen.dart
- **Line 161**: `Divider(height: 1)` (divider height)
  - **Status**: Should be relative

### lib/ui/screens/tile_city_screen.dart
- **Line 827**: `width: 1.5` (border width)
  - **Status**: Should be relative

## Summary

**Total Fixed Sizes Found**: ~30+ instances

**Categories**:
1. **UI Sizing** (should be relative): Font sizes, padding, spacing, border radius, icon sizes, button sizes
2. **Game Logic** (may be intentional): Prices, capacities, game world dimensions, physics constants
3. **Hardcoded in Code** (should be relative): SizedBox dimensions, EdgeInsets values, border widths

## Recommendations

1. Convert all UI-related fixed sizes in `config.dart` to relative factors
2. Replace hardcoded values in widget files with ScreenUtils calls
3. Keep game logic constants (prices, capacities) as fixed values
4. Consider making map dimensions relative or keep as game world constants

