import '../models/game_element.dart';
import '../models/laser_beam.dart';

class LaserPhysics {
  static const int maxBounces = 100; // Prevent infinite loops

  static List<LaserPath> traceLasers(List<GameElement> elements) {
    final sources = elements.whereType<LaserSource>().toList();
    final List<LaserPath> allPaths = [];

    for (final source in sources) {
      final paths = _traceFromSource(source, elements);
      allPaths.addAll(paths);
    }

    return allPaths;
  }

  static List<LaserPath> _traceFromSource(
    LaserSource source,
    List<GameElement> elements,
  ) {
    final List<LaserPath> paths = [];
    final initialBeam = _BeamState(
      position: source.position,
      direction: source.direction,
      color: source.color,
    );

    _traceBeam(initialBeam, elements, paths, Set<String>());
    return paths;
  }

  static void _traceBeam(
    _BeamState beam,
    List<GameElement> elements,
    List<LaserPath> paths,
    Set<String> visited,
  ) {
    final List<LaserSegment> currentSegments = [];
    var currentPos = beam.position;
    var currentDir = beam.direction;
    var currentColor = beam.color;
    int bounces = 0;

    // Create visited key to prevent infinite loops
    String visitKey(Position pos, Direction dir) => '${pos.x},${pos.y},$dir';

    while (bounces < maxBounces) {
      final key = visitKey(currentPos, currentDir);
      if (visited.contains(key)) {
        break; // Infinite loop detected
      }
      visited.add(key);

      // Calculate next position
      final nextPos = _getNextPosition(currentPos, currentDir);

      // Check if out of bounds (will be checked by caller)
      final startSegment = currentPos;
      final element = _getElementAt(nextPos, elements);

      if (element == null) {
        // Continue in same direction
        currentSegments.add(LaserSegment(
          start: currentPos,
          end: nextPos,
          direction: currentDir,
          color: currentColor,
        ));
        currentPos = nextPos;
        bounces++;
        continue;
      }

      // Hit an element
      if (element is Obstacle) {
        // Beam stops
        currentSegments.add(LaserSegment(
          start: currentPos,
          end: element.position,
          direction: currentDir,
          color: currentColor,
        ));
        break;
      } else if (element is Target) {
        // Reached target
        currentSegments.add(LaserSegment(
          start: currentPos,
          end: element.position,
          direction: currentDir,
          color: currentColor,
        ));
        break;
      } else if (element is Mirror) {
        // Reflect
        final newDir = element.reflect(currentDir);
        if (newDir != null) {
          currentSegments.add(LaserSegment(
            start: currentPos,
            end: element.position,
            direction: currentDir,
            color: currentColor,
          ));
          currentPos = element.position;
          currentDir = newDir;
          bounces++;
        } else {
          // Invalid reflection, stop
          break;
        }
      } else if (element is Splitter) {
        // Split beam
        final newDirs = element.split(currentDir);
        currentSegments.add(LaserSegment(
          start: currentPos,
          end: element.position,
          direction: currentDir,
          color: currentColor,
        ));

        if (newDirs.length > 1) {
          // Create new path for current segments
          if (currentSegments.isNotEmpty) {
            paths.add(LaserPath(
              segments: List.from(currentSegments),
              color: currentColor,
            ));
            currentSegments.clear();
          }

          // Trace each split beam
          for (final dir in newDirs) {
            final newBeam = _BeamState(
              position: element.position,
              direction: dir,
              color: currentColor,
            );
            _traceBeam(newBeam, elements, paths, Set.from(visited));
          }
          return; // Don't continue this beam
        } else {
          // Pass through
          currentDir = newDirs.first;
          currentPos = element.position;
          bounces++;
        }
      } else if (element is Portal) {
        // Teleport
        final linked = _findLinkedPortal(element, elements);
        if (linked != null) {
          currentSegments.add(LaserSegment(
            start: currentPos,
            end: element.position,
            direction: currentDir,
            color: currentColor,
          ));
          currentPos = linked.position;
          // Direction stays the same after portal
          bounces++;
        } else {
          // No linked portal, stop
          break;
        }
      } else if (element is ColorFilter) {
        // Check color compatibility
        if (element.canPass(currentColor)) {
          currentSegments.add(LaserSegment(
            start: currentPos,
            end: element.position,
            direction: currentDir,
            color: currentColor,
          ));
          // If white beam, change to filter color
          if (currentColor == LaserColor.white) {
            currentColor = element.allowedColor;
          }
          currentPos = element.position;
          bounces++;
        } else {
          // Beam blocked
          currentSegments.add(LaserSegment(
            start: currentPos,
            end: element.position,
            direction: currentDir,
            color: currentColor,
          ));
          break;
        }
      } else if (element is LaserSource) {
        // Hit another source, stop
        break;
      }
    }

    if (currentSegments.isNotEmpty) {
      paths.add(LaserPath(
        segments: currentSegments,
        color: currentColor,
      ));
    }
  }

  static Position _getNextPosition(Position current, Direction direction) {
    switch (direction) {
      case Direction.up:
        return Position(current.x, current.y - 1);
      case Direction.right:
        return Position(current.x + 1, current.y);
      case Direction.down:
        return Position(current.x, current.y + 1);
      case Direction.left:
        return Position(current.x - 1, current.y);
    }
  }

  static GameElement? _getElementAt(
    Position position,
    List<GameElement> elements,
  ) {
    try {
      return elements.firstWhere((e) => e.position == position);
    } catch (e) {
      return null;
    }
  }

  static Portal? _findLinkedPortal(Portal portal, List<GameElement> elements) {
    final portals = elements.whereType<Portal>().toList();
    try {
      return portals.firstWhere(
        (p) => p.pairId == portal.pairId && p.position != portal.position,
      );
    } catch (e) {
      return null;
    }
  }

  static Set<String> findActivatedTargets(
    List<LaserPath> paths,
    List<GameElement> elements,
  ) {
    final Set<String> activated = {};
    final targets = elements.whereType<Target>().toList();

    for (final path in paths) {
      for (final segment in path.segments) {
        for (final target in targets) {
          if (segment.end == target.position) {
            // Check color requirement
            if (target.requiredColor == null ||
                target.requiredColor == path.color) {
              activated.add(target.id);
            }
          }
        }
      }
    }

    return activated;
  }
}

class _BeamState {
  final Position position;
  final Direction direction;
  final LaserColor color;

  _BeamState({
    required this.position,
    required this.direction,
    required this.color,
  });
}
