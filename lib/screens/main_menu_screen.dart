import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/daily_challenge_service.dart';
import '../widgets/liquid_glass_widgets.dart';
import 'level_select_screen.dart';
import 'shop_screen.dart';
import 'achievements_screen.dart';
import 'settings_screen.dart';
import 'game_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _totalStars = 0;
  int _crystals = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stars = await DatabaseService.getTotalStars();
    final inventory = await DatabaseService.getInventory();
    setState(() {
      _totalStars = stars;
      _crystals = inventory.crystals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedNeonBeamsBackground(
        beamCount: 8,
        beamColor: const Color(0xFFFF3366),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A0E27),
                Color(0xFF1A1F3A),
                Color(0xFF0F1428),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTitle(),
                          const SizedBox(height: 60),
                          _buildMenuButton(
                            icon: Icons.play_arrow,
                            label: 'Campaign',
                            color: const Color(0xFF00D4FF),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const LevelSelectScreen(mode: GameMode.campaign),
                                ),
                              ).then((_) => _loadStats());
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildMenuButton(
                            icon: Icons.flash_on,
                            label: 'Puzzle Rush',
                            color: const Color(0xFFFF9900),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const LevelSelectScreen(mode: GameMode.puzzleRush),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildMenuButton(
                            icon: Icons.calendar_today,
                            label: 'Daily Challenge',
                            color: const Color(0xFFAA00FF),
                            onPressed: () => _handleDailyChallengePressed(),
                          ),
                          const SizedBox(height: 16),
                          _buildMenuButton(
                            icon: Icons.shopping_bag,
                            label: 'Shop',
                            color: const Color(0xFFFFBE0B),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ShopScreen(),
                                ),
                              ).then((_) => _loadStats());
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildMenuButton(
                            icon: Icons.emoji_events,
                            label: 'Achievements',
                            color: const Color(0xFF00FF88),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AchievementsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Settings icon with liquid glass
          LiquidGlassContainer(
            width: 48,
            height: 48,
            borderRadius: 12,
            padding: const EdgeInsets.all(0),
            opacity: 0.2,
            gradientColors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.1),
            ],
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                ).then((_) => _loadStats());
              },
            ),
          ),
          const Spacer(),
          _buildStatBadge(
            icon: Icons.star,
            value: '$_totalStars',
            color: const Color(0xFFFFBE0B),
          ),
          const SizedBox(width: 12),
          _buildStatBadge(
            icon: Icons.diamond,
            value: '$_crystals',
            color: const Color(0xFF00D4FF),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return LiquidGlassContainer(
      height: 40,
      width: 90,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: 20,
      opacity: 0.15,
      gradientColors: [
        color.withOpacity(0.2),
        color.withOpacity(0.1),
      ],
      border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00D4FF), Color(0xFFAA00FF)],
          ).createShader(bounds),
          child: const Text(
            'LASER MIRROR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'MINI',
          style: TextStyle(
            color: Color(0xFF00FF88),
            fontSize: 32,
            fontWeight: FontWeight.w300,
            letterSpacing: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return LiquidGlassButton(
      width: 280,
      height: 60,
      borderRadius: 18,
      primaryColor: color,
      useNeonEffect: true,
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDailyChallengePressed() async {
    // Check if today's challenge is already completed
    final isCompleted = await DailyChallengeService.isTodayChallengeCompleted();

    if (!mounted) return;

    if (isCompleted) {
      // Show modal that today's challenge is already completed
      _showChallengeCompletedModal();
    } else {
      // Get today's challenge and navigate to game
      final level = await DailyChallengeService.getTodayChallenge();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(level: level),
        ),
      ).then((_) => _loadStats());
    }
  }

  void _showChallengeCompletedModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: LiquidGlassContainer(
          width: 320,
          height: 340,
          padding: const EdgeInsets.all(32),
          borderRadius: 24,
          opacity: 0.2,
          gradientColors: [
            const Color(0xFF00FF88).withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
          border: Border.all(
            color: const Color(0xFF00FF88).withOpacity(0.4),
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
                      color: const Color(0xFF00FF88).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF00FF88),
                  size: 64,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Challenge Complete!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Today\'s challenge has been completed. Come back tomorrow for a new challenge!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              LiquidGlassButton(
                width: double.infinity,
                height: 50,
                primaryColor: const Color(0xFF00D4FF),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
