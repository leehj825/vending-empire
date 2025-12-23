import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main_screen.dart';
import '../../state/save_load_service.dart';
import '../../state/providers.dart';

/// Main menu screen shown at app startup
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  Future<void> _loadGame(BuildContext context, WidgetRef ref) async {
    final savedState = await SaveLoadService.loadGame();
    
    if (savedState == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No saved game found'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Load the game state into the controller
    ref.read(gameControllerProvider.notifier).loadGameState(savedState);

    // Navigate to main game screen
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Game loaded successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Game Title Image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Image.asset(
                  'assets/images/title.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
              
              const Spacer(flex: 3),
              
              // Start Game Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to main game screen
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/start_button.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 80,
                        color: Colors.red,
                        child: const Center(
                          child: Text(
                            'START GAME',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const Spacer(flex: 4),
              
              // Bottom Buttons Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Load Game Button
                    Expanded(
                      child: FutureBuilder<bool>(
                        future: SaveLoadService.hasSavedGame(),
                        builder: (context, snapshot) {
                          final hasSave = snapshot.data ?? false;
                          return GestureDetector(
                            onTap: hasSave ? () => _loadGame(context, ref) : null,
                            child: Opacity(
                              opacity: hasSave ? 1.0 : 0.5,
                              child: Image.asset(
                                'assets/images/load_game_button.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 60,
                                    color: Colors.yellow,
                                    child: const Center(
                                      child: Text(
                                        'LOAD GAME',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Options Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Implement options screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Options feature coming soon!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/images/options_button.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 60,
                              color: Colors.yellow,
                              child: const Center(
                                child: Text(
                                  'OPTIONS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Credits Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Implement credits screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Credits feature coming soon!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/images/credits_button.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 60,
                              color: Colors.yellow,
                              child: const Center(
                                child: Text(
                                  'CREDITS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
