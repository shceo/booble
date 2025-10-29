import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/daily_challenge_service.dart';
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
      body: Container(
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
            ],
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
          // Settings icon
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF666666),
              borderRadius: BorderRadius.circular(12),
            ),
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
          const SizedBox(width: 16),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
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
    return SizedBox(
      width: 280,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF00FF88),
                size: 64,
              ),
              const SizedBox(height: 16),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
