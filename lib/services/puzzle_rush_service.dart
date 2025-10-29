import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../models/level.dart';
import '../utils/level_data.dart';

class PuzzleRushSession {
  final List<Level> levels;
  int currentLevelIndex = 0;
  int totalScore = 0;
  final int totalTimeSeconds;
  int remainingTimeSeconds;
  Timer? timer;

  PuzzleRushSession({
    required this.levels,
    required this.totalTimeSeconds,
  }) : remainingTimeSeconds = totalTimeSeconds;

  bool get hasNextLevel => currentLevelIndex < levels.length;
  Level get currentLevel => levels[currentLevelIndex];
  bool get isTimeUp => remainingTimeSeconds <= 0;

  void startTimer(VoidCallback onTick) {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingTimeSeconds > 0) {
        remainingTimeSeconds--;
        onTick();
      } else {
        timer?.cancel();
      }
    });
  }

  void completeLevel(int stars, int rotations) {
    // Score calculation: stars * 100 + time bonus - rotation penalty
    final timeBonus = remainingTimeSeconds * 2;
    final rotationPenalty = rotations * 5;
    final levelScore = (stars * 100) + timeBonus - rotationPenalty;

    totalScore += max(0, levelScore);
    currentLevelIndex++;
  }

  void dispose() {
    timer?.cancel();
  }
}

class PuzzleRushService {
  static const int defaultTimeLimit = 300; // 5 minutes
  static const int levelsPerSession = 10;

  static List<Level> generateSession({int seed = 0}) {
    final random = Random(seed);
    final allLevels = LevelData.getAllLevels();

    // Select random levels with increasing difficulty
    final selectedLevels = <Level>[];

    // Easy levels (first 3)
    final easyLevels = allLevels
        .where((l) => l.difficulty == LevelDifficulty.easy)
        .toList();
    for (int i = 0; i < 3 && easyLevels.isNotEmpty; i++) {
      final index = random.nextInt(easyLevels.length);
      selectedLevels.add(easyLevels.removeAt(index));
    }

    // Medium levels (next 4)
    final mediumLevels = allLevels
        .where((l) => l.difficulty == LevelDifficulty.medium)
        .toList();
    for (int i = 0; i < 4 && mediumLevels.isNotEmpty; i++) {
      final index = random.nextInt(mediumLevels.length);
      selectedLevels.add(mediumLevels.removeAt(index));
    }

    // Hard levels (last 3)
    final hardLevels = allLevels
        .where((l) => l.difficulty == LevelDifficulty.hard)
        .toList();
    for (int i = 0; i < 3 && hardLevels.isNotEmpty; i++) {
      final index = random.nextInt(hardLevels.length);
      selectedLevels.add(hardLevels.removeAt(index));
    }

    return selectedLevels;
  }

  static PuzzleRushSession createSession({int? seed}) {
    final actualSeed = seed ?? DateTime.now().millisecondsSinceEpoch;
    final levels = generateSession(seed: actualSeed);

    return PuzzleRushSession(
      levels: levels,
      totalTimeSeconds: defaultTimeLimit,
    );
  }
}
