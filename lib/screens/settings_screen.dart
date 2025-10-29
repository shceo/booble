import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../widgets/liquid_glass_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // About the game section
              LiquidGlassCard(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                accentColor: const Color(0xFF00D4FF),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'About Laser Mirror Mini',
                      style: TextStyle(
                        color: Color(0xFF00D4FF),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'A challenging puzzle game where you manipulate mirrors and lasers to activate all targets. Master the art of reflection, solve complex puzzles, and compete in daily challenges!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Reset data section
              LiquidGlassCard(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                accentColor: const Color(0xFFFF6B6B),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text(
                      'Reset Game Data',
                      style: TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This will erase all your progress, achievements, and inventory',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Drop data button
              LiquidGlassButton(
                width: double.infinity,
                height: 56,
                borderRadius: 16,
                primaryColor: const Color(0xFFFF6B6B),
                useNeonEffect: true,
                onPressed: () => _showResetConfirmation(context),
                child: const Text(
                  'DROP DATA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: LiquidGlassContainer(
          width: 320,
          height: 340,
          padding: const EdgeInsets.all(24),
          borderRadius: 24,
          opacity: 0.2,
          gradientColors: [
            const Color(0xFFFF6B6B).withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
          border: Border.all(
            color: const Color(0xFFFF6B6B).withOpacity(0.4),
            width: 2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Color(0xFFFF6B6B),
                  size: 64,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Reset All Data?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This action cannot be undone. All your progress, achievements, and inventory will be permanently deleted.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: LiquidGlassButton(
                      height: 50,
                      primaryColor: const Color(0xFF666666),
                      useNeonEffect: false,
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LiquidGlassButton(
                      height: 50,
                      primaryColor: const Color(0xFFFF6B6B),
                      onPressed: () async {
                        await DatabaseService.resetAllData();
                        if (context.mounted) {
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Close settings
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All game data has been reset'),
                              backgroundColor: Color(0xFFFF6B6B),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
