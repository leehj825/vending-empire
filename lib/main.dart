import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ui/screens/menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Preload Fredoka font to ensure consistent rendering across platforms
  // This ensures the font is downloaded and cached before the app renders
  try {
    // Preload the font by creating a TextStyle - this triggers the download
    final textStyle = GoogleFonts.fredoka();
    // Access fontFamily to ensure it's loaded
    final fontFamily = textStyle.fontFamily;
    if (fontFamily != null) {
      debugPrint('Fredoka font loaded: $fontFamily');
    }
  } catch (e) {
    debugPrint('Font preload failed: $e');
    // Continue app startup even if font preload fails
  }
  
  // Initialize AdMob only on Android and iOS (not macOS, Windows, Linux, or Web)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('AdMob initialization failed: $e');
      // Continue app startup even if AdMob fails
    }
  }
  
  runApp(
    const ProviderScope(
      child: VendingMachineTycoonApp(),
    ),
  );
}

class VendingMachineTycoonApp extends StatelessWidget {
  const VendingMachineTycoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vending Machine Tycoon',
      theme: ThemeData(
        useMaterial3: true,
        // Define the default font family for the entire app
        // Using textTheme ensures consistent font rendering across all platforms
        textTheme: GoogleFonts.fredokaTextTheme(
          ThemeData.light().textTheme,
        ),
        // Explicitly set fontFamily to ensure consistency across platforms
        // This overrides platform-specific defaults (Roboto on Android, San Francisco on macOS)
        fontFamily: GoogleFonts.fredoka().fontFamily,
        // Apply font to all text styles to ensure consistency
        primaryTextTheme: GoogleFonts.fredokaTextTheme(
          ThemeData.light().primaryTextTheme,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
          surface: const Color(0xFFF5F5F5), // Light grey background instead of white
        ),
      ),
      home: const MenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
