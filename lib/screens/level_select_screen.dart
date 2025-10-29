import 'package:flutter/material.dart';
import '../models/level.dart';
import '../services/database_service.dart';
import '../utils/level_data.dart';
import 'game_screen.dart';

enum GameMode {
  campaign,
  puzzleRush,
  dailyChallenge,
}

class LevelSelectScreen extends StatefulWidget {
  final GameMode mode;

  const LevelSelectScreen({Key? key, required this.mode}) : super(key: key);

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, PlayerProgress> _progressMap = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: LevelData.getTotalChapters(),
      vsync: this,
    );
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await DatabaseService.getAllProgress();
    setState(() {
      _progressMap = {for (var p in progress) p.levelId: p};
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3A),
        title: Text(_getModeTitle()),
        bottom: widget.mode == GameMode.campaign
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: const Color(0xFF00D4FF),
                tabs: List.generate(
                  LevelData.getTotalChapters(),
                  (index) => Tab(
                    child: Row(
                      children: [
                        Icon(_getChapterIcon(index + 1)),
                        const SizedBox(width: 8),
                        Text('Chapter ${index + 1}'),
                      ],
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: widget.mode == GameMode.campaign
          ? TabBarView(
              controller: _tabController,
              children: List.generate(
                LevelData.getTotalChapters(),
                (index) => _buildLevelGrid(index + 1),
              ),
            )
          : _buildLevelGrid(null),
    );
  }

  String _getModeTitle() {
    switch (widget.mode) {
      case GameMode.campaign:
        return 'Campaign';
      case GameMode.puzzleRush:
        return 'Puzzle Rush';
      case GameMode.dailyChallenge:
        return 'Daily Challenge';
    }
  }

  IconData _getChapterIcon(int chapter) {
    switch (chapter) {
      case 1:
        return Icons.looks_one;
      case 2:
        return Icons.looks_two;
      case 3:
        return Icons.looks_3;
      case 4:
        return Icons.looks_4;
      case 5:
        return Icons.looks_5;
      default:
        return Icons.circle;
    }
  }

  Widget _buildLevelGrid(int? chapter) {
    final levels = chapter != null
        ? LevelData.getLevelsByChapter(chapter)
        : LevelData.getAllLevels();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        final progress = _progressMap[level.id];
        final isLocked = _isLevelLocked(level, levels, index);

        return _buildLevelCard(level, progress, isLocked);
      },
    );
  }

  bool _isLevelLocked(Level level, List<Level> levels, int index) {
    if (index == 0) return false; // First level always unlocked

    // Check if previous level is completed
    if (index > 0) {
      final previousLevel = levels[index - 1];
      final previousProgress = _progressMap[previousLevel.id];
      return previousProgress == null || !previousProgress.completed;
    }

    return false;
  }

  Widget _buildLevelCard(Level level, PlayerProgress? progress, bool isLocked) {
    return GestureDetector(
      onTap: isLocked
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameScreen(level: level),
                ),
              ).then((_) => _loadProgress());
            },
      child: Opacity(
        opacity: isLocked ? 0.4 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F3A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getLevelBorderColor(progress),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLocked)
                const Icon(
                  Icons.lock,
                  color: Colors.white54,
                  size: 40,
                )
              else ...[
                Text(
                  '${level.levelNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (progress != null && progress.completed)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Icon(
                        index < progress.stars
                            ? Icons.star
                            : Icons.star_border,
                        color: const Color(0xFFFFBE0B),
                        size: 20,
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  level.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelBorderColor(PlayerProgress? progress) {
    if (progress == null) return Colors.transparent;

    if (progress.stars == 3) {
      return const Color(0xFFFFBE0B);
    } else if (progress.stars == 2) {
      return const Color(0xFF00D4FF);
    } else if (progress.stars == 1) {
      return const Color(0xFF666666);
    }

    return Colors.transparent;
  }
}
