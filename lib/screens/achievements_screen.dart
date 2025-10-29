import 'package:flutter/material.dart';
import '../services/database_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Achievement> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final achievements = await DatabaseService.getAchievements();
    setState(() {
      _achievements = achievements;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount =
        _achievements.where((a) => a.unlocked).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Text('Achievements'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildProgressHeader(unlockedCount, _achievements.length),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _achievements.length,
                    itemBuilder: (context, index) {
                      return _buildAchievementCard(_achievements[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProgressHeader(int unlocked, int total) {
    final percentage = (unlocked / total * 100).toInt();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00FF88).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$unlocked / $total',
                style: const TextStyle(
                  color: Color(0xFF00FF88),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: unlocked / total,
              backgroundColor: const Color(0xFF2A2F4A),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF00FF88),
              ),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$percentage% Complete',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achievement.unlocked
              ? const Color(0xFFFFBE0B).withOpacity(0.5)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: achievement.unlocked
                  ? const Color(0xFFFFBE0B).withOpacity(0.2)
                  : const Color(0xFF2A2F4A),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.unlocked ? Icons.emoji_events : Icons.lock,
              color: achievement.unlocked
                  ? const Color(0xFFFFBE0B)
                  : Colors.white30,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: TextStyle(
                    color:
                        achievement.unlocked ? Colors.white : Colors.white54,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color:
                        achievement.unlocked ? Colors.white70 : Colors.white38,
                    fontSize: 14,
                  ),
                ),
                if (achievement.unlocked && achievement.unlockedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF00FF88),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                          style: const TextStyle(
                            color: Color(0xFF00FF88),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (achievement.unlocked)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00D4FF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.diamond,
                    color: Color(0xFF00D4FF),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '+50',
                    style: TextStyle(
                      color: Color(0xFF00D4FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
