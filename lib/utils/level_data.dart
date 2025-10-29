import '../models/game_element.dart';
import '../models/level.dart';

class LevelData {
  static List<Level> getAllLevels() {
    return [
      ..._getChapter1Levels(), // Basic mirrors (10 levels)
      ..._getChapter2Levels(), // Splitters (10 levels)
      ..._getChapter3Levels(), // Portals (10 levels)
      ..._getChapter4Levels(), // Color filters (10 levels)
      ..._getChapter5Levels(), // Mixed mechanics (10 levels)
    ];
  }

  // Chapter 1: Basic Mirrors
  static List<Level> _getChapter1Levels() {
    return [
      // Level 1: Tutorial - Simple reflection
      Level(
        id: 'ch1_lv1',
        levelNumber: 1,
        name: 'First Reflection',
        gridWidth: 5,
        gridHeight: 5,
        difficulty: LevelDifficulty.tutorial,
        mechanicType: MechanicType.basic,
        chapterNumber: 1,
        tutorialText: 'Tap a mirror to rotate it. Reflect the laser to the target!',
        constraints: LevelConstraints(maxRotations: 5, maxTime: 30),
        starRequirements: StarRequirements(
          threeStarRotations: 1,
          twoStarRotations: 2,
          threeStarTime: 10,
          twoStarTime: 20,
        ),
        elements: [
          LaserSource(position: Position(0, 2), direction: Direction.right),
          Mirror(position: Position(2, 2), direction: Direction.up),
          Target(position: Position(2, 0), id: 't1'),
        ],
      ),

      // Level 2: Two mirrors
      Level(
        id: 'ch1_lv2',
        levelNumber: 2,
        name: 'Double Bounce',
        gridWidth: 6,
        gridHeight: 6,
        difficulty: LevelDifficulty.easy,
        mechanicType: MechanicType.basic,
        chapterNumber: 1,
        constraints: LevelConstraints(maxRotations: 8, maxTime: 45),
        starRequirements: StarRequirements(
          threeStarRotations: 2,
          twoStarRotations: 4,
          threeStarTime: 15,
          twoStarTime: 30,
        ),
        elements: [
          LaserSource(position: Position(0, 3), direction: Direction.right),
          Mirror(position: Position(2, 3), direction: Direction.up),
          Mirror(position: Position(2, 1), direction: Direction.right),
          Target(position: Position(5, 1), id: 't1'),
        ],
      ),

      // Level 3: L-shape path
      Level(
        id: 'ch1_lv3',
        levelNumber: 3,
        name: 'The Corner',
        gridWidth: 6,
        gridHeight: 6,
        difficulty: LevelDifficulty.easy,
        mechanicType: MechanicType.basic,
        chapterNumber: 1,
        constraints: LevelConstraints(maxRotations: 10, maxTime: 50),
        starRequirements: StarRequirements(
          threeStarRotations: 2,
          twoStarRotations: 5,
          threeStarTime: 20,
          twoStarTime: 35,
        ),
        elements: [
          LaserSource(position: Position(0, 0), direction: Direction.down),
          Mirror(position: Position(0, 3), direction: Direction.up),
          Mirror(position: Position(3, 3), direction: Direction.up),
          Target(position: Position(3, 0), id: 't1'),
          Obstacle(position: Position(1, 1)),
          Obstacle(position: Position(2, 2)),
        ],
      ),

      // Level 4: Fixed mirror challenge
      Level(
        id: 'ch1_lv4',
        levelNumber: 4,
        name: 'Fixed Position',
        gridWidth: 7,
        gridHeight: 5,
        difficulty: LevelDifficulty.easy,
        mechanicType: MechanicType.basic,
        chapterNumber: 1,
        tutorialText: 'Gray mirrors cannot be rotated!',
        constraints: LevelConstraints(
          maxRotations: 6,
          maxTime: 40,
          hasFixedMirrors: true,
        ),
        starRequirements: StarRequirements(
          threeStarRotations: 2,
          twoStarRotations: 4,
          threeStarTime: 15,
          twoStarTime: 30,
        ),
        elements: [
          LaserSource(position: Position(0, 2), direction: Direction.right),
          Mirror(
            position: Position(2, 2),
            direction: Direction.up,
            isFixed: true,
          ),
          Mirror(position: Position(4, 2), direction: Direction.left),
          Mirror(position: Position(4, 0), direction: Direction.right),
          Target(position: Position(6, 0), id: 't1'),
        ],
      ),

      // Level 5: Zigzag
      Level(
        id: 'ch1_lv5',
        levelNumber: 5,
        name: 'Zigzag Path',
        gridWidth: 8,
        gridHeight: 5,
        difficulty: LevelDifficulty.medium,
        mechanicType: MechanicType.basic,
        chapterNumber: 1,
        constraints: LevelConstraints(maxRotations: 12, maxTime: 60),
        starRequirements: StarRequirements(
          threeStarRotations: 4,
          twoStarRotations: 7,
          threeStarTime: 25,
          twoStarTime: 45,
        ),
        elements: [
          LaserSource(position: Position(0, 2), direction: Direction.right),
          Mirror(position: Position(2, 2), direction: Direction.up),
          Mirror(position: Position(2, 0), direction: Direction.right),
          Mirror(position: Position(5, 0), direction: Direction.down),
          Mirror(position: Position(5, 4), direction: Direction.right),
          Target(position: Position(7, 4), id: 't1'),
          Obstacle(position: Position(3, 1)),
          Obstacle(position: Position(4, 3)),
        ],
      ),

      // Level 6: Two targets
      Level(
        id: 'ch1_lv6',
        levelNumber: 6,
        name: 'Double Target',
        gridWidth: 7,
        gridHeight: 7,
        difficulty: LevelDifficulty.medium,
        mechanicType: MechanicType.basic,
        chapterNumber: 1,
        constraints: LevelConstraints(maxRotations: 15, maxTime: 60),
        starRequirements: StarRequirements(
          threeStarRotations: 5,
          twoStarRotations: 9,
          threeStarTime: 30,
          twoStarTime: 50,
        ),
        elements: [
          LaserSource(position: Position(0, 3), direction: Direction.right),
          Mirror(position: Position(2, 3), direction: Direction.up),
          Mirror(position: Position(2, 1), direction: Direction.right),
          Mirror(position: Position(5, 1), direction: Direction.down),
          Target(position: Position(5, 3), id: 't1'),
          Target(position: Position(5, 6), id: 't2'),
        ],
      ),

      // Level 7: Maze
      Level(
        id: 'ch1_lv7',
        levelNumber: 7,
        name: 'The Maze',
        gridWidth: 8,
        gridHeight: 8,
        difficulty: LevelDifficulty.medium,
        mechanicType: MechanicType.basic,
        chapterNumber: 1,
        constraints: LevelConstraints(maxRotations: 18, maxTime: 70),
        starRequirements: StarRequirements(
          threeStarRotations: 6,
          twoStarRotations: 11,
          threeStarTime: 35,
          twoStarTime: 55,
        ),
        elements: [
          LaserSource(position: Position(0, 0), direction: Direction.right),
          Mirror(position: Position(2, 0), direction: Direction.down),
          Mirror(position: Position(2, 3), direction: Direction.right),
          Mirror(position: Position(5, 3), direction: Direction.down),
          Mirror(position: Position(5, 6), direction: Direction.right),
          Target(position: Position(7, 6), id: 't1'),
          Obstacle(position: Position(1, 1)),
          Obstacle(position: Position(3, 2)),
          Obstacle(position: Position(4, 4)),
          Obstacle(position: Position(6, 5)),
        ],
      ),

      // Level 8: Tight squeeze
      Level(
        id: 'ch1_lv8',
        levelNumber: 8,
        name: 'Tight Squeeze',
        gridWidth: 6,
        gridHeight: 6,
        difficulty: LevelDifficulty.hard,
        mechanicType: MechanicType.basic,
        chapterNumber: 1,
        constraints: LevelConstraints(maxRotations: 10, maxTime: 50),
        starRequirements: StarRequirements(
          threeStarRotations: 4,
          twoStarRotations: 7,
          threeStarTime: 25,
          twoStarTime: 40,
        ),
        elements: [
          LaserSource(position: Position(0, 0), direction: Direction.down),
          Mirror(position: Position(0, 2), direction: Direction.right),
          Mirror(position: Position(3, 2), direction: Direction.down),
          Mirror(position: Position(3, 5), direction: Direction.left),
          Target(position: Position(0, 5), id: 't1'),
          Obstacle(position: Position(1, 1)),
          Obstacle(position: Position(2, 3)),
          Obstacle(position: Position(4, 3)),
          Obstacle(position: Position(1, 4)),
        ],
      ),

      // Level 9: Multiple sources
      Level(
        id: 'ch1_lv9',
        levelNumber: 9,
        name: 'Two Lasers',
        gridWidth: 8,
        gridHeight: 6,
        difficulty: LevelDifficulty.hard,
        mechanicType: MechanicType.basic,
        chapterNumber: 1,
        constraints: LevelConstraints(maxRotations: 20, maxTime: 70),
        starRequirements: StarRequirements(
          threeStarRotations: 7,
          twoStarRotations: 12,
          threeStarTime: 35,
          twoStarTime: 55,
        ),
        elements: [
          LaserSource(position: Position(0, 1), direction: Direction.right),
          LaserSource(position: Position(0, 4), direction: Direction.right),
          Mirror(position: Position(3, 1), direction: Direction.down),
          Mirror(position: Position(3, 3), direction: Direction.up),
          Mirror(position: Position(3, 4), direction: Direction.down),
          Mirror(position: Position(6, 3), direction: Direction.up),
          Target(position: Position(3, 5), id: 't1'),
          Target(position: Position(6, 0), id: 't2'),
          Obstacle(position: Position(2, 2)),
          Obstacle(position: Position(5, 2)),
        ],
      ),

      // Level 10: Grand finale
      Level(
        id: 'ch1_lv10',
        levelNumber: 10,
        name: 'Mirror Master',
        gridWidth: 10,
        gridHeight: 8,
        difficulty: LevelDifficulty.hard,
        mechanicType: MechanicType.basic,
        chapterNumber: 1,
        constraints: LevelConstraints(maxRotations: 25, maxTime: 90),
        starRequirements: StarRequirements(
          threeStarRotations: 10,
          twoStarRotations: 17,
          threeStarTime: 50,
          twoStarTime: 75,
        ),
        elements: [
          LaserSource(position: Position(0, 4), direction: Direction.right),
          Mirror(position: Position(2, 4), direction: Direction.up),
          Mirror(position: Position(2, 2), direction: Direction.right),
          Mirror(position: Position(5, 2), direction: Direction.down),
          Mirror(position: Position(5, 5), direction: Direction.right),
          Mirror(position: Position(7, 5), direction: Direction.up),
          Mirror(position: Position(7, 1), direction: Direction.right),
          Target(position: Position(9, 1), id: 't1'),
          Target(position: Position(9, 7), id: 't2'),
          Obstacle(position: Position(3, 3)),
          Obstacle(position: Position(4, 6)),
          Obstacle(position: Position(6, 3)),
          Obstacle(position: Position(8, 4)),
        ],
      ),
    ];
  }

  // Chapter 2: Splitters
  static List<Level> _getChapter2Levels() {
    return [
      // Level 11: Tutorial - Simple split
      Level(
        id: 'ch2_lv1',
        levelNumber: 11,
        name: 'Split Introduction',
        gridWidth: 5,
        gridHeight: 5,
        difficulty: LevelDifficulty.tutorial,
        mechanicType: MechanicType.splitter,
        chapterNumber: 2,
        tutorialText: 'Splitters divide the laser beam into two perpendicular beams!',
        constraints: LevelConstraints(maxRotations: 3, maxTime: 30),
        starRequirements: StarRequirements(
          threeStarRotations: 1,
          twoStarRotations: 2,
          threeStarTime: 10,
          twoStarTime: 20,
        ),
        elements: [
          LaserSource(position: Position(0, 2), direction: Direction.right),
          Splitter(position: Position(2, 2), direction: Direction.up),
          Target(position: Position(2, 0), id: 't1'),
          Target(position: Position(2, 4), id: 't2'),
        ],
      ),

      // Level 12: Split and reflect
      Level(
        id: 'ch2_lv2',
        levelNumber: 12,
        name: 'Split & Reflect',
        gridWidth: 6,
        gridHeight: 6,
        difficulty: LevelDifficulty.easy,
        mechanicType: MechanicType.splitter,
        chapterNumber: 2,
        constraints: LevelConstraints(maxRotations: 8, maxTime: 45),
        starRequirements: StarRequirements(
          threeStarRotations: 3,
          twoStarRotations: 5,
          threeStarTime: 20,
          twoStarTime: 35,
        ),
        elements: [
          LaserSource(position: Position(0, 3), direction: Direction.right),
          Splitter(position: Position(2, 3), direction: Direction.up),
          Mirror(position: Position(2, 0), direction: Direction.right),
          Mirror(position: Position(2, 5), direction: Direction.right),
          Target(position: Position(5, 0), id: 't1'),
          Target(position: Position(5, 5), id: 't2'),
        ],
      ),

      // More levels with increasing complexity...
      // For brevity, I'll add a few more representative levels
      Level(
        id: 'ch2_lv3',
        levelNumber: 13,
        name: 'Triple Target',
        gridWidth: 7,
        gridHeight: 7,
        difficulty: LevelDifficulty.medium,
        mechanicType: MechanicType.splitter,
        chapterNumber: 2,
        hiddenChallenges: ['one_beam_two_goals'],
        constraints: LevelConstraints(maxRotations: 12, maxTime: 60),
        starRequirements: StarRequirements(
          threeStarRotations: 5,
          twoStarRotations: 8,
          threeStarTime: 30,
          twoStarTime: 50,
        ),
        elements: [
          LaserSource(position: Position(0, 3), direction: Direction.right),
          Splitter(position: Position(3, 3), direction: Direction.up),
          Mirror(position: Position(3, 1), direction: Direction.right),
          Target(position: Position(6, 1), id: 't1'),
          Target(position: Position(3, 6), id: 't2'),
          Target(position: Position(6, 3), id: 't3'),
        ],
      ),

      // Levels 14-20: More splitter challenges
      ...List.generate(7, (i) {
        final levelNum = 14 + i;
        return Level(
          id: 'ch2_lv${i + 4}',
          levelNumber: levelNum,
          name: 'Splitter Challenge ${i + 4}',
          gridWidth: 7 + (i ~/ 2),
          gridHeight: 7 + (i ~/ 2),
          difficulty: i < 3
              ? LevelDifficulty.easy
              : i < 5
                  ? LevelDifficulty.medium
                  : LevelDifficulty.hard,
          mechanicType: MechanicType.splitter,
          chapterNumber: 2,
          constraints: LevelConstraints(
            maxRotations: 15 + i * 2,
            maxTime: 60 + i * 5,
          ),
          starRequirements: StarRequirements(
            threeStarRotations: 5 + i,
            twoStarRotations: 9 + i * 2,
            threeStarTime: 30 + i * 3,
            twoStarTime: 50 + i * 5,
          ),
          elements: [
            LaserSource(position: Position(0, 3 + (i ~/ 2)), direction: Direction.right),
            Splitter(position: Position(3, 3), direction: Direction.up),
            Mirror(position: Position(2, 1), direction: Direction.right),
            Mirror(position: Position(4, 4), direction: Direction.up),
            Target(position: Position(6, 1), id: 't1'),
            Target(position: Position(3, 6), id: 't2'),
          ],
        );
      }),
    ];
  }

  // Chapter 3: Portals
  static List<Level> _getChapter3Levels() {
    return [
      // Level 21: Portal tutorial
      Level(
        id: 'ch3_lv1',
        levelNumber: 21,
        name: 'Portal Basics',
        gridWidth: 6,
        gridHeight: 5,
        difficulty: LevelDifficulty.tutorial,
        mechanicType: MechanicType.portal,
        chapterNumber: 3,
        tutorialText: 'Portals teleport the laser beam to the linked portal!',
        constraints: LevelConstraints(maxRotations: 4, maxTime: 30),
        starRequirements: StarRequirements(
          threeStarRotations: 1,
          twoStarRotations: 2,
          threeStarTime: 10,
          twoStarTime: 20,
        ),
        elements: [
          LaserSource(position: Position(0, 2), direction: Direction.right),
          Portal(position: Position(2, 2), pairId: 'p1'),
          Portal(position: Position(4, 2), pairId: 'p1'),
          Target(position: Position(5, 2), id: 't1'),
        ],
      ),

      // Levels 22-30: Portal challenges
      ...List.generate(9, (i) {
        final levelNum = 22 + i;
        return Level(
          id: 'ch3_lv${i + 2}',
          levelNumber: levelNum,
          name: 'Portal Challenge ${i + 2}',
          gridWidth: 6 + (i ~/ 2),
          gridHeight: 6 + (i ~/ 2),
          difficulty: i < 3
              ? LevelDifficulty.easy
              : i < 6
                  ? LevelDifficulty.medium
                  : LevelDifficulty.hard,
          mechanicType: MechanicType.portal,
          chapterNumber: 3,
          constraints: LevelConstraints(
            maxRotations: 10 + i * 2,
            maxTime: 50 + i * 5,
          ),
          starRequirements: StarRequirements(
            threeStarRotations: 4 + i,
            twoStarRotations: 7 + i * 2,
            threeStarTime: 25 + i * 3,
            twoStarTime: 40 + i * 5,
          ),
          elements: [
            LaserSource(position: Position(0, 3), direction: Direction.right),
            Portal(position: Position(2, 3), pairId: 'p1'),
            Portal(position: Position(4, 1), pairId: 'p1'),
            Mirror(position: Position(3, 3), direction: Direction.up),
            Target(position: Position(5, 1), id: 't1'),
          ],
        );
      }),
    ];
  }

  // Chapter 4: Color Filters
  static List<Level> _getChapter4Levels() {
    return [
      // Level 31: Color filter tutorial
      Level(
        id: 'ch4_lv1',
        levelNumber: 31,
        name: 'Color Basics',
        gridWidth: 6,
        gridHeight: 5,
        difficulty: LevelDifficulty.tutorial,
        mechanicType: MechanicType.colorFilter,
        chapterNumber: 4,
        tutorialText: 'Color filters only allow specific laser colors to pass through!',
        constraints: LevelConstraints(maxRotations: 4, maxTime: 30),
        starRequirements: StarRequirements(
          threeStarRotations: 1,
          twoStarRotations: 2,
          threeStarTime: 10,
          twoStarTime: 20,
        ),
        elements: [
          LaserSource(
            position: Position(0, 2),
            direction: Direction.right,
            color: LaserColor.red,
          ),
          ColorFilter(
            position: Position(2, 2),
            direction: Direction.right,
            allowedColor: LaserColor.red,
          ),
          Target(
            position: Position(5, 2),
            id: 't1',
            requiredColor: LaserColor.red,
          ),
        ],
      ),

      // Levels 32-40: Color filter challenges
      ...List.generate(9, (i) {
        final levelNum = 32 + i;
        final colors = [LaserColor.red, LaserColor.green, LaserColor.blue];
        return Level(
          id: 'ch4_lv${i + 2}',
          levelNumber: levelNum,
          name: 'Spectrum ${i + 2}',
          gridWidth: 6 + (i ~/ 2),
          gridHeight: 6 + (i ~/ 2),
          difficulty: i < 3
              ? LevelDifficulty.easy
              : i < 6
                  ? LevelDifficulty.medium
                  : LevelDifficulty.hard,
          mechanicType: MechanicType.colorFilter,
          chapterNumber: 4,
          constraints: LevelConstraints(
            maxRotations: 10 + i * 2,
            maxTime: 50 + i * 5,
          ),
          starRequirements: StarRequirements(
            threeStarRotations: 4 + i,
            twoStarRotations: 7 + i * 2,
            threeStarTime: 25 + i * 3,
            twoStarTime: 40 + i * 5,
          ),
          elements: [
            LaserSource(
              position: Position(0, 3),
              direction: Direction.right,
              color: colors[i % 3],
            ),
            ColorFilter(
              position: Position(2, 3),
              direction: Direction.right,
              allowedColor: colors[i % 3],
            ),
            Mirror(position: Position(3, 3), direction: Direction.up),
            Target(
              position: Position(5, 1),
              id: 't1',
              requiredColor: colors[i % 3],
            ),
          ],
        );
      }),
    ];
  }

  // Chapter 5: Mixed mechanics
  static List<Level> _getChapter5Levels() {
    return List.generate(10, (i) {
      final levelNum = 41 + i;
      return Level(
        id: 'ch5_lv${i + 1}',
        levelNumber: levelNum,
        name: 'Master Challenge ${i + 1}',
        gridWidth: 8 + (i ~/ 3),
        gridHeight: 8 + (i ~/ 3),
        difficulty: i < 3
            ? LevelDifficulty.medium
            : i < 7
                ? LevelDifficulty.hard
                : LevelDifficulty.hard,
        mechanicType: MechanicType.mixed,
        chapterNumber: 5,
        constraints: LevelConstraints(
          maxRotations: 20 + i * 3,
          maxTime: 80 + i * 10,
        ),
        starRequirements: StarRequirements(
          threeStarRotations: 8 + i * 2,
          twoStarRotations: 14 + i * 3,
          threeStarTime: 40 + i * 5,
          twoStarTime: 65 + i * 8,
        ),
        elements: [
          LaserSource(position: Position(0, 4), direction: Direction.right),
          Mirror(position: Position(2, 4), direction: Direction.up),
          Splitter(position: Position(4, 2), direction: Direction.up),
          Portal(position: Position(3, 3), pairId: 'p1'),
          Portal(position: Position(6, 1), pairId: 'p1'),
          ColorFilter(
            position: Position(5, 5),
            direction: Direction.right,
            allowedColor: LaserColor.red,
          ),
          Target(position: Position(7, 1), id: 't1'),
          Target(position: Position(4, 7), id: 't2'),
          Obstacle(position: Position(3, 5)),
        ],
      );
    });
  }

  static Level? getLevelById(String id) {
    try {
      return getAllLevels().firstWhere((level) => level.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Level> getLevelsByChapter(int chapter) {
    return getAllLevels().where((l) => l.chapterNumber == chapter).toList();
  }

  static int getTotalLevels() => getAllLevels().length;

  static int getTotalChapters() => 5;
}
