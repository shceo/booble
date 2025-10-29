import '../models/game_state.dart';
import '../models/level.dart';
import 'database_service.dart';

class AchievementService {
  static Future<void> checkAchievements({
    required GameState gameState,
    required Level level,
  }) async {
    // Check "Speed of Light" - Complete level in under 10 seconds
    if (gameState.elapsedSeconds < 10 && gameState.isCompleted) {
      await _unlockAchievement('speed_of_light');
    }

    // Check "Pure Optics" - Complete without unnecessary rotations
    if (gameState.rotationCount <= level.starRequirements.threeStarRotations &&
        gameState.isCompleted) {
      await _unlockAchievement('pure_optics');
    }

    // Check "One Beam Two Goals" - Activate two targets with single beam
    // This would need to be checked in the laser physics
    // For now, we'll check if level has hidden challenge
    if (level.hiddenChallenges.contains('one_beam_two_goals') &&
        gameState.isCompleted) {
      await _unlockAchievement('one_beam_two_goals');
    }

    // Check "Perfectionist" - Get 3 stars on 10 levels
    if (gameState.stars == 3) {
      final allProgress = await DatabaseService.getAllProgress();
      final threeStarCount =
          allProgress.where((p) => p.stars == 3).length;

      if (threeStarCount >= 10) {
        await _unlockAchievement('perfectionist');
      }
    }

    // Check "Master Puzzler" - Complete all levels in a chapter
    if (gameState.isCompleted) {
      final chapterLevels =
          await _getChapterProgress(level.chapterNumber);

      if (chapterLevels.every((p) => p.completed)) {
        await _unlockAchievement('master_puzzler');
      }
    }
  }

  static Future<void> _unlockAchievement(String achievementId) async {
    final isUnlocked =
        await DatabaseService.isAchievementUnlocked(achievementId);

    if (!isUnlocked) {
      await DatabaseService.unlockAchievement(achievementId);
    }
  }

  static Future<List<PlayerProgress>> _getChapterProgress(
      int chapter) async {
    final allProgress = await DatabaseService.getAllProgress();

    // Get level IDs for this chapter
    final chapterLevelIds = <String>[];
    for (int i = 1; i <= 10; i++) {
      chapterLevelIds.add('ch${chapter}_lv$i');
    }

    return allProgress
        .where((p) => chapterLevelIds.contains(p.levelId))
        .toList();
  }

  static Future<bool> checkOneLaserTwoTargets({
    required List<dynamic> laserPaths,
    required List<dynamic> activatedTargets,
  }) async {
    // Check if a single laser beam path activated multiple targets
    if (laserPaths.length == 1 && activatedTargets.length >= 2) {
      await _unlockAchievement('one_beam_two_goals');
      return true;
    }
    return false;
  }
}
