import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/game_state.dart';

class PlayerProgress {
  final String levelId;
  final int stars;
  final int bestRotations;
  final int bestTime;
  final bool completed;
  final List<String> completedChallenges;
  final List<GameMove>? bestReplay;

  PlayerProgress({
    required this.levelId,
    required this.stars,
    required this.bestRotations,
    required this.bestTime,
    required this.completed,
    this.completedChallenges = const [],
    this.bestReplay,
  });

  Map<String, dynamic> toJson() {
    return {
      'levelId': levelId,
      'stars': stars,
      'bestRotations': bestRotations,
      'bestTime': bestTime,
      'completed': completed ? 1 : 0,
      'completedChallenges': jsonEncode(completedChallenges),
      'bestReplay': bestReplay != null
          ? jsonEncode(bestReplay!.map((m) => m.toJson()).toList())
          : null,
    };
  }

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    return PlayerProgress(
      levelId: json['levelId'] as String,
      stars: json['stars'] as int,
      bestRotations: json['bestRotations'] as int,
      bestTime: json['bestTime'] as int,
      completed: json['completed'] == 1,
      completedChallenges: json['completedChallenges'] != null
          ? List<String>.from(jsonDecode(json['completedChallenges'] as String))
          : [],
      bestReplay: json['bestReplay'] != null
          ? (jsonDecode(json['bestReplay'] as String) as List)
              .map((m) => GameMove.fromJson(m as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class PlayerInventory {
  int crystals;
  int trajectoryCharges;
  final Set<String> purchasedSkins;
  final Set<String> purchasedLevelPacks;

  PlayerInventory({
    this.crystals = 0,
    this.trajectoryCharges = 3,
    Set<String>? purchasedSkins,
    Set<String>? purchasedLevelPacks,
  })  : purchasedSkins = purchasedSkins ?? {},
        purchasedLevelPacks = purchasedLevelPacks ?? {};

  Map<String, dynamic> toJson() {
    return {
      'crystals': crystals,
      'trajectoryCharges': trajectoryCharges,
      'purchasedSkins': jsonEncode(purchasedSkins.toList()),
      'purchasedLevelPacks': jsonEncode(purchasedLevelPacks.toList()),
    };
  }

  factory PlayerInventory.fromJson(Map<String, dynamic> json) {
    return PlayerInventory(
      crystals: json['crystals'] as int? ?? 0,
      trajectoryCharges: json['trajectoryCharges'] as int? ?? 3,
      purchasedSkins: json['purchasedSkins'] != null
          ? Set<String>.from(jsonDecode(json['purchasedSkins'] as String))
          : {},
      purchasedLevelPacks: json['purchasedLevelPacks'] != null
          ? Set<String>.from(jsonDecode(json['purchasedLevelPacks'] as String))
          : {},
    );
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final bool unlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    this.unlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'unlocked': unlocked ? 1 : 0,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      unlocked: json['unlocked'] == 1,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }
}

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'laser_mirror.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE progress (
        levelId TEXT PRIMARY KEY,
        stars INTEGER NOT NULL,
        bestRotations INTEGER NOT NULL,
        bestTime INTEGER NOT NULL,
        completed INTEGER NOT NULL,
        completedChallenges TEXT,
        bestReplay TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE inventory (
        id INTEGER PRIMARY KEY,
        crystals INTEGER NOT NULL,
        trajectoryCharges INTEGER NOT NULL,
        purchasedSkins TEXT,
        purchasedLevelPacks TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE achievements (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        unlocked INTEGER NOT NULL,
        unlockedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_challenge (
        date TEXT PRIMARY KEY,
        levelData TEXT NOT NULL,
        completed INTEGER NOT NULL,
        bestScore INTEGER
      )
    ''');

    // Initialize default inventory
    await db.insert('inventory', {
      'id': 1,
      'crystals': 100,
      'trajectoryCharges': 3,
      'purchasedSkins': jsonEncode([]),
      'purchasedLevelPacks': jsonEncode([]),
    });

    // Initialize achievements
    final achievements = _getDefaultAchievements();
    for (final achievement in achievements) {
      await db.insert('achievements', achievement.toJson());
    }
  }

  static List<Achievement> _getDefaultAchievements() {
    return [
      Achievement(
        id: 'one_beam_two_goals',
        name: 'One Beam Two Goals',
        description: 'Activate two targets with a single laser beam',
      ),
      Achievement(
        id: 'speed_of_light',
        name: 'Speed of Light',
        description: 'Complete a level in under 10 seconds',
      ),
      Achievement(
        id: 'pure_optics',
        name: 'Pure Optics',
        description: 'Complete a level without unnecessary rotations',
      ),
      Achievement(
        id: 'perfectionist',
        name: 'Perfectionist',
        description: 'Get 3 stars on 10 levels',
      ),
      Achievement(
        id: 'master_puzzler',
        name: 'Master Puzzler',
        description: 'Complete all levels in a chapter',
      ),
    ];
  }

  // Progress methods
  static Future<void> saveProgress(PlayerProgress progress) async {
    final db = await database;
    await db.insert(
      'progress',
      progress.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<PlayerProgress?> getProgress(String levelId) async {
    final db = await database;
    final results = await db.query(
      'progress',
      where: 'levelId = ?',
      whereArgs: [levelId],
    );

    if (results.isEmpty) return null;
    return PlayerProgress.fromJson(results.first);
  }

  static Future<List<PlayerProgress>> getAllProgress() async {
    final db = await database;
    final results = await db.query('progress');
    return results.map((r) => PlayerProgress.fromJson(r)).toList();
  }

  static Future<int> getTotalStars() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(stars) as total FROM progress');
    return result.first['total'] as int? ?? 0;
  }

  // Inventory methods
  static Future<PlayerInventory> getInventory() async {
    final db = await database;
    final results = await db.query('inventory', where: 'id = ?', whereArgs: [1]);

    if (results.isEmpty) {
      return PlayerInventory();
    }
    return PlayerInventory.fromJson(results.first);
  }

  static Future<void> saveInventory(PlayerInventory inventory) async {
    final db = await database;
    await db.update(
      'inventory',
      inventory.toJson(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  static Future<void> addCrystals(int amount) async {
    final inventory = await getInventory();
    inventory.crystals += amount;
    await saveInventory(inventory);
  }

  static Future<bool> spendCrystals(int amount) async {
    final inventory = await getInventory();
    if (inventory.crystals >= amount) {
      inventory.crystals -= amount;
      await saveInventory(inventory);
      return true;
    }
    return false;
  }

  // Achievement methods
  static Future<List<Achievement>> getAchievements() async {
    final db = await database;
    final results = await db.query('achievements');
    return results.map((r) => Achievement.fromJson(r)).toList();
  }

  static Future<void> unlockAchievement(String achievementId) async {
    final db = await database;
    await db.update(
      'achievements',
      {
        'unlocked': 1,
        'unlockedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [achievementId],
    );

    // Award crystals for achievement
    await addCrystals(50);
  }

  static Future<bool> isAchievementUnlocked(String achievementId) async {
    final db = await database;
    final results = await db.query(
      'achievements',
      where: 'id = ? AND unlocked = 1',
      whereArgs: [achievementId],
    );
    return results.isNotEmpty;
  }

  // Daily challenge methods
  static Future<void> saveDailyChallenge({
    required String date,
    required String levelData,
    required bool completed,
    int? bestScore,
  }) async {
    final db = await database;
    await db.insert(
      'daily_challenge',
      {
        'date': date,
        'levelData': levelData,
        'completed': completed ? 1 : 0,
        'bestScore': bestScore,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, dynamic>?> getDailyChallenge(String date) async {
    final db = await database;
    final results = await db.query(
      'daily_challenge',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (results.isEmpty) return null;
    return results.first;
  }

  // Reset all game data
  static Future<void> resetAllData() async {
    final db = await database;

    // Clear all tables
    await db.delete('progress');
    await db.delete('achievements');
    await db.delete('daily_challenge');

    // Reset inventory to default
    await db.update(
      'inventory',
      {
        'crystals': 100,
        'trajectoryCharges': 3,
        'purchasedSkins': jsonEncode([]),
        'purchasedLevelPacks': jsonEncode([]),
      },
      where: 'id = ?',
      whereArgs: [1],
    );

    // Reinitialize achievements
    final achievements = _getDefaultAchievements();
    for (final achievement in achievements) {
      await db.insert('achievements', achievement.toJson());
    }
  }

  static Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
