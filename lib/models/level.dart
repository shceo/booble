import 'game_element.dart';

enum LevelDifficulty {
  tutorial,
  easy,
  medium,
  hard,
}

enum MechanicType {
  basic,
  splitter,
  portal,
  colorFilter,
  mixed,
}

class LevelConstraints {
  final int? maxRotations;
  final int? maxTime; // in seconds
  final bool hasFixedMirrors;
  final bool hasSlidingMirrors;

  LevelConstraints({
    this.maxRotations,
    this.maxTime,
    this.hasFixedMirrors = false,
    this.hasSlidingMirrors = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'maxRotations': maxRotations,
      'maxTime': maxTime,
      'hasFixedMirrors': hasFixedMirrors,
      'hasSlidingMirrors': hasSlidingMirrors,
    };
  }

  factory LevelConstraints.fromJson(Map<String, dynamic> json) {
    return LevelConstraints(
      maxRotations: json['maxRotations'] as int?,
      maxTime: json['maxTime'] as int?,
      hasFixedMirrors: json['hasFixedMirrors'] as bool? ?? false,
      hasSlidingMirrors: json['hasSlidingMirrors'] as bool? ?? false,
    );
  }
}

class StarRequirements {
  final int threeStarRotations;
  final int twoStarRotations;
  final int threeStarTime; // in seconds
  final int twoStarTime;

  StarRequirements({
    required this.threeStarRotations,
    required this.twoStarRotations,
    required this.threeStarTime,
    required this.twoStarTime,
  });

  int calculateStars(int rotations, int timeSeconds) {
    int stars = 1; // Base star for completion

    if (rotations <= threeStarRotations && timeSeconds <= threeStarTime) {
      return 3;
    } else if (rotations <= twoStarRotations && timeSeconds <= twoStarTime) {
      return 2;
    }

    return stars;
  }

  Map<String, dynamic> toJson() {
    return {
      'threeStarRotations': threeStarRotations,
      'twoStarRotations': twoStarRotations,
      'threeStarTime': threeStarTime,
      'twoStarTime': twoStarTime,
    };
  }

  factory StarRequirements.fromJson(Map<String, dynamic> json) {
    return StarRequirements(
      threeStarRotations: json['threeStarRotations'] as int,
      twoStarRotations: json['twoStarRotations'] as int,
      threeStarTime: json['threeStarTime'] as int,
      twoStarTime: json['twoStarTime'] as int,
    );
  }
}

class HiddenChallenge {
  final String id;
  final String description;
  final bool Function(dynamic context) checkCompletion;

  HiddenChallenge({
    required this.id,
    required this.description,
    required this.checkCompletion,
  });
}

class Level {
  final String id;
  final int levelNumber;
  final String name;
  final int gridWidth;
  final int gridHeight;
  final LevelDifficulty difficulty;
  final MechanicType mechanicType;
  final List<GameElement> elements;
  final LevelConstraints constraints;
  final StarRequirements starRequirements;
  final List<String> hiddenChallenges;
  final String? tutorialText;
  final int chapterNumber;

  Level({
    required this.id,
    required this.levelNumber,
    required this.name,
    required this.gridWidth,
    required this.gridHeight,
    required this.difficulty,
    required this.mechanicType,
    required this.elements,
    required this.constraints,
    required this.starRequirements,
    this.hiddenChallenges = const [],
    this.tutorialText,
    required this.chapterNumber,
  });

  List<LaserSource> get sources => elements.whereType<LaserSource>().toList();

  List<Target> get targets => elements.whereType<Target>().toList();

  List<Mirror> get mirrors => elements.whereType<Mirror>().toList();

  List<Splitter> get splitters => elements.whereType<Splitter>().toList();

  List<Portal> get portals => elements.whereType<Portal>().toList();

  List<ColorFilter> get colorFilters =>
      elements.whereType<ColorFilter>().toList();

  List<Obstacle> get obstacles => elements.whereType<Obstacle>().toList();

  GameElement? getElementAt(Position position) {
    return elements.firstWhere(
      (element) => element.position == position,
      orElse: () => Obstacle(position: position),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'levelNumber': levelNumber,
      'name': name,
      'gridWidth': gridWidth,
      'gridHeight': gridHeight,
      'difficulty': difficulty.index,
      'mechanicType': mechanicType.index,
      'constraints': constraints.toJson(),
      'starRequirements': starRequirements.toJson(),
      'hiddenChallenges': hiddenChallenges,
      'tutorialText': tutorialText,
      'chapterNumber': chapterNumber,
      'elements': elements.map((e) => _elementToJson(e)).toList(),
    };
  }

  Map<String, dynamic> _elementToJson(GameElement element) {
    final baseJson = {
      'type': element.type.index,
      'x': element.position.x,
      'y': element.position.y,
      'isFixed': element.isFixed,
    };

    if (element is Mirror) {
      baseJson['direction'] = element.direction.index;
      baseJson['isSliding'] = element.isSliding;
    } else if (element is LaserSource) {
      baseJson['direction'] = element.direction.index;
      baseJson['color'] = element.color.index;
    } else if (element is Target) {
      baseJson['id'] = element.id;
      if (element.requiredColor != null) {
        baseJson['requiredColor'] = element.requiredColor!.index;
      }
    } else if (element is Splitter) {
      baseJson['direction'] = element.direction.index;
    } else if (element is Portal) {
      baseJson['pairId'] = element.pairId;
    } else if (element is ColorFilter) {
      baseJson['direction'] = element.direction.index;
      baseJson['allowedColor'] = element.allowedColor.index;
    }

    return baseJson;
  }

  factory Level.fromJson(Map<String, dynamic> json) {
    final elements = (json['elements'] as List)
        .map((e) => _elementFromJson(e as Map<String, dynamic>))
        .toList();

    return Level(
      id: json['id'] as String,
      levelNumber: json['levelNumber'] as int,
      name: json['name'] as String,
      gridWidth: json['gridWidth'] as int,
      gridHeight: json['gridHeight'] as int,
      difficulty: LevelDifficulty.values[json['difficulty'] as int],
      mechanicType: MechanicType.values[json['mechanicType'] as int],
      elements: elements,
      constraints: LevelConstraints.fromJson(
          json['constraints'] as Map<String, dynamic>),
      starRequirements: StarRequirements.fromJson(
          json['starRequirements'] as Map<String, dynamic>),
      hiddenChallenges: (json['hiddenChallenges'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tutorialText: json['tutorialText'] as String?,
      chapterNumber: json['chapterNumber'] as int,
    );
  }

  static GameElement _elementFromJson(Map<String, dynamic> json) {
    final type = ElementType.values[json['type'] as int];
    final position = Position(json['x'] as int, json['y'] as int);
    final isFixed = json['isFixed'] as bool? ?? false;

    switch (type) {
      case ElementType.mirror:
        return Mirror(
          position: position,
          direction: Direction.values[json['direction'] as int],
          isSliding: json['isSliding'] as bool? ?? false,
          isFixed: isFixed,
        );
      case ElementType.source:
        return LaserSource(
          position: position,
          direction: Direction.values[json['direction'] as int],
          color: LaserColor.values[json['color'] as int? ?? 0],
        );
      case ElementType.target:
        return Target(
          position: position,
          id: json['id'] as String,
          requiredColor: json['requiredColor'] != null
              ? LaserColor.values[json['requiredColor'] as int]
              : null,
        );
      case ElementType.splitter:
        return Splitter(
          position: position,
          direction: Direction.values[json['direction'] as int],
          isFixed: isFixed,
        );
      case ElementType.portal:
        return Portal(
          position: position,
          pairId: json['pairId'] as String,
        );
      case ElementType.colorFilter:
        return ColorFilter(
          position: position,
          direction: Direction.values[json['direction'] as int],
          allowedColor: LaserColor.values[json['allowedColor'] as int],
          isFixed: isFixed,
        );
      case ElementType.obstacle:
        return Obstacle(position: position);
    }
  }
}
