import 'game_element.dart';
import 'level.dart';

enum GameStatus {
  playing,
  won,
  paused,
  ready,
}

class GameState {
  final Level level;
  final List<GameElement> currentElements;
  final GameStatus status;
  final int rotationCount;
  final int elapsedSeconds;
  final Set<String> activatedTargets;
  final bool isPowerUpActive;
  final int powerUpCooldown;
  final List<GameMove> moveHistory;

  GameState({
    required this.level,
    required this.currentElements,
    this.status = GameStatus.ready,
    this.rotationCount = 0,
    this.elapsedSeconds = 0,
    this.activatedTargets = const {},
    this.isPowerUpActive = false,
    this.powerUpCooldown = 0,
    this.moveHistory = const [],
  });

  bool get isCompleted {
    final targetIds = level.targets.map((t) => t.id).toSet();
    return targetIds.isNotEmpty && activatedTargets.containsAll(targetIds);
  }

  int get stars {
    if (!isCompleted) return 0;
    return level.starRequirements.calculateStars(rotationCount, elapsedSeconds);
  }

  bool get canUsePowerUp => !isPowerUpActive && powerUpCooldown == 0;

  GameState copyWith({
    Level? level,
    List<GameElement>? currentElements,
    GameStatus? status,
    int? rotationCount,
    int? elapsedSeconds,
    Set<String>? activatedTargets,
    bool? isPowerUpActive,
    int? powerUpCooldown,
    List<GameMove>? moveHistory,
  }) {
    return GameState(
      level: level ?? this.level,
      currentElements: currentElements ?? this.currentElements,
      status: status ?? this.status,
      rotationCount: rotationCount ?? this.rotationCount,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      activatedTargets: activatedTargets ?? this.activatedTargets,
      isPowerUpActive: isPowerUpActive ?? this.isPowerUpActive,
      powerUpCooldown: powerUpCooldown ?? this.powerUpCooldown,
      moveHistory: moveHistory ?? this.moveHistory,
    );
  }
}

class GameMove {
  final Position position;
  final int timestamp;
  final String action; // 'rotate', 'powerup'

  GameMove({
    required this.position,
    required this.timestamp,
    required this.action,
  });

  Map<String, dynamic> toJson() {
    return {
      'x': position.x,
      'y': position.y,
      'timestamp': timestamp,
      'action': action,
    };
  }

  factory GameMove.fromJson(Map<String, dynamic> json) {
    return GameMove(
      position: Position(json['x'] as int, json['y'] as int),
      timestamp: json['timestamp'] as int,
      action: json['action'] as String,
    );
  }
}
