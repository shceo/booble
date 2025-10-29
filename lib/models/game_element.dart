import 'dart:math';

enum ElementType {
  mirror,
  source,
  target,
  splitter,
  portal,
  colorFilter,
  obstacle,
}

enum LaserColor {
  red,
  green,
  blue,
  white,
}

enum Direction {
  up,
  right,
  down,
  left,
}

class Position {
  final int x;
  final int y;

  const Position(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => 'Position($x, $y)';

  Position copyWith({int? x, int? y}) {
    return Position(x ?? this.x, y ?? this.y);
  }
}

abstract class GameElement {
  final Position position;
  final ElementType type;
  bool isFixed;

  GameElement({
    required this.position,
    required this.type,
    this.isFixed = false,
  });

  GameElement copyWith();
}

class Mirror extends GameElement {
  Direction direction;
  final bool isSliding;

  Mirror({
    required Position position,
    required this.direction,
    this.isSliding = false,
    bool isFixed = false,
  }) : super(position: position, type: ElementType.mirror, isFixed: isFixed);

  // Reflects laser beam based on mirror direction
  Direction? reflect(Direction incoming) {
    switch (direction) {
      case Direction.up: // Mirror oriented NE-SW (/)
        switch (incoming) {
          case Direction.right:
            return Direction.up;
          case Direction.down:
            return Direction.left;
          case Direction.left:
            return Direction.down;
          case Direction.up:
            return Direction.right;
        }
      case Direction.right: // Mirror oriented NW-SE (\)
        switch (incoming) {
          case Direction.right:
            return Direction.down;
          case Direction.down:
            return Direction.right;
          case Direction.left:
            return Direction.up;
          case Direction.up:
            return Direction.left;
        }
      case Direction.down: // Same as up
        switch (incoming) {
          case Direction.right:
            return Direction.up;
          case Direction.down:
            return Direction.left;
          case Direction.left:
            return Direction.down;
          case Direction.up:
            return Direction.right;
        }
      case Direction.left: // Same as right
        switch (incoming) {
          case Direction.right:
            return Direction.down;
          case Direction.down:
            return Direction.right;
          case Direction.left:
            return Direction.up;
          case Direction.up:
            return Direction.left;
        }
    }
  }

  void rotate() {
    if (!isFixed) {
      final values = Direction.values;
      direction = values[(direction.index + 1) % values.length];
    }
  }

  @override
  Mirror copyWith({
    Position? position,
    Direction? direction,
    bool? isSliding,
    bool? isFixed,
  }) {
    return Mirror(
      position: position ?? this.position,
      direction: direction ?? this.direction,
      isSliding: isSliding ?? this.isSliding,
      isFixed: isFixed ?? this.isFixed,
    );
  }
}

class LaserSource extends GameElement {
  final Direction direction;
  final LaserColor color;

  LaserSource({
    required Position position,
    required this.direction,
    this.color = LaserColor.white,
  }) : super(position: position, type: ElementType.source, isFixed: true);

  @override
  LaserSource copyWith({
    Position? position,
    Direction? direction,
    LaserColor? color,
  }) {
    return LaserSource(
      position: position ?? this.position,
      direction: direction ?? this.direction,
      color: color ?? this.color,
    );
  }
}

class Target extends GameElement {
  bool isActivated;
  final LaserColor? requiredColor;
  final String id;

  Target({
    required Position position,
    required this.id,
    this.isActivated = false,
    this.requiredColor,
  }) : super(position: position, type: ElementType.target, isFixed: true);

  void activate() {
    isActivated = true;
  }

  void deactivate() {
    isActivated = false;
  }

  @override
  Target copyWith({
    Position? position,
    bool? isActivated,
    LaserColor? requiredColor,
    String? id,
  }) {
    return Target(
      position: position ?? this.position,
      id: id ?? this.id,
      isActivated: isActivated ?? this.isActivated,
      requiredColor: requiredColor ?? this.requiredColor,
    );
  }
}

class Splitter extends GameElement {
  Direction direction;

  Splitter({
    required Position position,
    required this.direction,
    bool isFixed = false,
  }) : super(position: position, type: ElementType.splitter, isFixed: isFixed);

  // Splits beam into two perpendicular beams
  List<Direction> split(Direction incoming) {
    if (direction == Direction.up || direction == Direction.down) {
      // Vertical splitter
      if (incoming == Direction.left || incoming == Direction.right) {
        return [Direction.up, Direction.down];
      }
    } else {
      // Horizontal splitter
      if (incoming == Direction.up || incoming == Direction.down) {
        return [Direction.left, Direction.right];
      }
    }
    // If beam comes from aligned direction, it passes through
    return [incoming];
  }

  void rotate() {
    if (!isFixed) {
      final values = Direction.values;
      direction = values[(direction.index + 1) % values.length];
    }
  }

  @override
  Splitter copyWith({
    Position? position,
    Direction? direction,
    bool? isFixed,
  }) {
    return Splitter(
      position: position ?? this.position,
      direction: direction ?? this.direction,
      isFixed: isFixed ?? this.isFixed,
    );
  }
}

class Portal extends GameElement {
  final String pairId;
  final Portal? linkedPortal;

  Portal({
    required Position position,
    required this.pairId,
    this.linkedPortal,
  }) : super(position: position, type: ElementType.portal, isFixed: true);

  @override
  Portal copyWith({
    Position? position,
    String? pairId,
    Portal? linkedPortal,
  }) {
    return Portal(
      position: position ?? this.position,
      pairId: pairId ?? this.pairId,
      linkedPortal: linkedPortal ?? this.linkedPortal,
    );
  }
}

class ColorFilter extends GameElement {
  Direction direction;
  final LaserColor allowedColor;

  ColorFilter({
    required Position position,
    required this.direction,
    required this.allowedColor,
    bool isFixed = false,
  }) : super(
            position: position, type: ElementType.colorFilter, isFixed: isFixed);

  bool canPass(LaserColor beamColor) {
    return beamColor == allowedColor || beamColor == LaserColor.white;
  }

  void rotate() {
    if (!isFixed) {
      final values = Direction.values;
      direction = values[(direction.index + 1) % values.length];
    }
  }

  @override
  ColorFilter copyWith({
    Position? position,
    Direction? direction,
    LaserColor? allowedColor,
    bool? isFixed,
  }) {
    return ColorFilter(
      position: position ?? this.position,
      direction: direction ?? this.direction,
      allowedColor: allowedColor ?? this.allowedColor,
      isFixed: isFixed ?? this.isFixed,
    );
  }
}

class Obstacle extends GameElement {
  Obstacle({
    required Position position,
  }) : super(position: position, type: ElementType.obstacle, isFixed: true);

  @override
  Obstacle copyWith({Position? position}) {
    return Obstacle(position: position ?? this.position);
  }
}
