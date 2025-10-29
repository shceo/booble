import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/level.dart';
import '../services/game_controller.dart';
import '../services/database_service.dart';
import '../services/achievement_service.dart';
import '../services/daily_challenge_service.dart';
import '../widgets/game_board.dart';

class GameScreen extends StatefulWidget {
  final Level level;

  const GameScreen({Key? key, required this.level}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GameController(level: widget.level);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.startLevel();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E27),
        body: SafeArea(
          child: Consumer<GameController>(
            builder: (context, controller, child) {
              if (controller.state.status == GameStatus.won) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showWinDialog(context, controller.state);
                });
              }

              return Column(
                children: [
                  _buildHeader(controller.state),
                  Expanded(
                    child: GameBoard(
                      gridWidth: widget.level.gridWidth,
                      gridHeight: widget.level.gridHeight,
                      elements: controller.state.currentElements,
                      laserPaths: controller.laserPaths,
                      onElementTap: (position) {
                        controller.rotateElement(position);
                      },
                      showTrajectory: controller.state.isPowerUpActive,
                    ),
                  ),
                  _buildFooter(controller),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(GameState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.level.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Level ${widget.level.levelNumber}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildStatsPanel(state),
        ],
      ),
    );
  }

  Widget _buildStatsPanel(GameState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildStatItem(
            Icons.access_time,
            _formatTime(state.elapsedSeconds),
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            Icons.sync,
            '${state.rotationCount}',
          ),
          const SizedBox(width: 16),
          _buildProgressIndicator(state),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00D4FF), size: 20),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(GameState state) {
    final totalTargets = state.level.targets.length;
    final activatedCount = state.activatedTargets.length;

    return Row(
      children: [
        Icon(
          activatedCount == totalTargets
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
          color: activatedCount == totalTargets
              ? const Color(0xFF00FF88)
              : Colors.white54,
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          '$activatedCount/$totalTargets',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(GameController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.refresh,
            label: 'Reset',
            onPressed: () {
              controller.resetLevel();
              controller.startLevel();
            },
            color: const Color(0xFFFF6B6B),
          ),
          _buildActionButton(
            icon: Icons.lightbulb_outline,
            label: 'Hint',
            onPressed: controller.state.canUsePowerUp
                ? () => controller.usePowerUp()
                : null,
            color: const Color(0xFFFFBE0B),
            cooldown: controller.state.powerUpCooldown,
          ),
          _buildActionButton(
            icon: Icons.pause,
            label: 'Pause',
            onPressed: () => controller.pauseGame(),
            color: const Color(0xFF00D4FF),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
    int? cooldown,
  }) {
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1.0,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 4),
            Text(
              cooldown != null && cooldown > 0 ? '$cooldown s' : label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showWinDialog(BuildContext context, GameState state) {
    final stars = state.stars;
    final isDailyChallenge = widget.level.id.startsWith('daily_');

    // Check achievements
    AchievementService.checkAchievements(
      gameState: state,
      level: widget.level,
    );

    if (isDailyChallenge) {
      // Save daily challenge completion
      DailyChallengeService.completeChallenge(
        stars: stars,
        score: stars * 1000 - state.rotationCount * 10 - state.elapsedSeconds,
      );
    } else {
      // Save normal progress
      DatabaseService.saveProgress(PlayerProgress(
        levelId: widget.level.id,
        stars: stars,
        bestRotations: state.rotationCount,
        bestTime: state.elapsedSeconds,
        completed: true,
        bestReplay: state.moveHistory,
      ));

      // Award crystals based on stars
      DatabaseService.addCrystals(stars * 10);
    }

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
              const Text(
                'Level Complete!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Icon(
                    index < stars ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFBE0B),
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildStatRow('Time', _formatTime(state.elapsedSeconds)),
              const SizedBox(height: 8),
              _buildStatRow('Rotations', '${state.rotationCount}'),
              const SizedBox(height: 8),
              _buildStatRow('Crystals', '+${stars * 10}'),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF666666),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Menu'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _controller.resetLevel();
                        _controller.startLevel();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D4FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Retry'),
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

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
