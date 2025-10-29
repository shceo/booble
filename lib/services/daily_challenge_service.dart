import 'dart:math';
import '../models/level.dart';
import '../models/game_element.dart';
import 'database_service.dart';

class DailyChallengeService {
  static int _getDailySeed() {
    final now = DateTime.now();
    return now.year * 10000 + now.month * 100 + now.day;
  }

  static String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static Future<Level> getTodayChallenge() async {
    final dateString = _getTodayDateString();
    final existingChallenge =
        await DatabaseService.getDailyChallenge(dateString);

    if (existingChallenge != null) {
      // Return cached challenge
      return Level.fromJson(existingChallenge);
    }

    // Generate new challenge
    final level = _generateDailyLevel();

    // Save to database
    await DatabaseService.saveDailyChallenge(
      date: dateString,
      levelData: level.toJson().toString(),
      completed: false,
    );

    return level;
  }

  static Level _generateDailyLevel() {
    final seed = _getDailySeed();
    final random = Random(seed);

    // Generate a unique level for today
    final gridSize = 7 + random.nextInt(3); // 7-9
    final mechanicType = MechanicType.values[random.nextInt(MechanicType.values.length)];

    final elements = <GameElement>[];

    // Add laser source
    final sourceX = 0;
    final sourceY = gridSize ~/ 2;
    elements.add(LaserSource(
      position: Position(sourceX, sourceY),
      direction: Direction.right,
      color: LaserColor.values[random.nextInt(LaserColor.values.length)],
    ));

    // Add targets (2-3)
    final targetCount = 2 + random.nextInt(2);
    for (int i = 0; i < targetCount; i++) {
      elements.add(Target(
        position: Position(
          gridSize - 1 - random.nextInt(2),
          random.nextInt(gridSize),
        ),
        id: 't${i + 1}',
      ));
    }

    // Add mirrors (4-8)
    final mirrorCount = 4 + random.nextInt(5);
    for (int i = 0; i < mirrorCount; i++) {
      final x = 1 + random.nextInt(gridSize - 2);
      final y = random.nextInt(gridSize);

      // Check if position is free
      if (!elements.any((e) => e.position == Position(x, y))) {
        elements.add(Mirror(
          position: Position(x, y),
          direction: Direction.values[random.nextInt(Direction.values.length)],
          isFixed: random.nextDouble() < 0.3, // 30% chance to be fixed
        ));
      }
    }

    // Add mechanic-specific elements
    switch (mechanicType) {
      case MechanicType.splitter:
        for (int i = 0; i < 1 + random.nextInt(2); i++) {
          final x = 2 + random.nextInt(gridSize - 4);
          final y = random.nextInt(gridSize);

          if (!elements.any((e) => e.position == Position(x, y))) {
            elements.add(Splitter(
              position: Position(x, y),
              direction: Direction.values[random.nextInt(2) * 2],
            ));
          }
        }
        break;

      case MechanicType.portal:
        final portalX1 = 1 + random.nextInt(gridSize ~/ 2);
        final portalY1 = random.nextInt(gridSize);
        final portalX2 = gridSize ~/ 2 + random.nextInt(gridSize ~/ 2);
        final portalY2 = random.nextInt(gridSize);

        if (!elements.any((e) =>
            e.position == Position(portalX1, portalY1) ||
            e.position == Position(portalX2, portalY2))) {
          elements.add(Portal(
            position: Position(portalX1, portalY1),
            pairId: 'p1',
          ));
          elements.add(Portal(
            position: Position(portalX2, portalY2),
            pairId: 'p1',
          ));
        }
        break;

      case MechanicType.colorFilter:
        for (int i = 0; i < 1 + random.nextInt(2); i++) {
          final x = 2 + random.nextInt(gridSize - 4);
          final y = random.nextInt(gridSize);

          if (!elements.any((e) => e.position == Position(x, y))) {
            elements.add(ColorFilter(
              position: Position(x, y),
              direction: Direction.values[random.nextInt(Direction.values.length)],
              allowedColor: LaserColor.values[random.nextInt(LaserColor.values.length)],
            ));
          }
        }
        break;

      default:
        break;
    }

    // Add obstacles (2-5)
    final obstacleCount = 2 + random.nextInt(4);
    for (int i = 0; i < obstacleCount; i++) {
      final x = 1 + random.nextInt(gridSize - 2);
      final y = random.nextInt(gridSize);

      if (!elements.any((e) => e.position == Position(x, y))) {
        elements.add(Obstacle(position: Position(x, y)));
      }
    }

    return Level(
      id: 'daily_${_getTodayDateString()}',
      levelNumber: 9999,
      name: 'Daily Challenge',
      gridWidth: gridSize,
      gridHeight: gridSize,
      difficulty: LevelDifficulty.hard,
      mechanicType: mechanicType,
      chapterNumber: 0,
      elements: elements,
      constraints: LevelConstraints(
        maxRotations: 20 + random.nextInt(10),
        maxTime: 120,
      ),
      starRequirements: StarRequirements(
        threeStarRotations: 8 + random.nextInt(5),
        twoStarRotations: 15 + random.nextInt(5),
        threeStarTime: 60,
        twoStarTime: 90,
      ),
    );
  }

  static Future<void> completeChallenge({
    required int stars,
    required int score,
  }) async {
    final dateString = _getTodayDateString();

    await DatabaseService.saveDailyChallenge(
      date: dateString,
      levelData: '',
      completed: true,
      bestScore: score,
    );

    // Award bonus crystals
    await DatabaseService.addCrystals(stars * 20);
  }

  static Future<bool> isTodayChallengeCompleted() async {
    final dateString = _getTodayDateString();
    final challenge = await DatabaseService.getDailyChallenge(dateString);

    return challenge != null && challenge['completed'] == 1;
  }
}
