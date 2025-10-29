import 'game_element.dart';

class LaserSegment {
  final Position start;
  final Position end;
  final Direction direction;
  final LaserColor color;

  LaserSegment({
    required this.start,
    required this.end,
    required this.direction,
    required this.color,
  });

  @override
  String toString() =>
      'LaserSegment(from: $start, to: $end, dir: $direction, color: $color)';
}

class LaserPath {
  final List<LaserSegment> segments;
  final LaserColor color;

  LaserPath({
    required this.segments,
    required this.color,
  });

  LaserPath copyWith({
    List<LaserSegment>? segments,
    LaserColor? color,
  }) {
    return LaserPath(
      segments: segments ?? this.segments,
      color: color ?? this.color,
    );
  }
}
