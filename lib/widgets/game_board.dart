import 'package:flutter/material.dart';
import '../models/game_element.dart';
import '../models/laser_beam.dart';
import 'dart:math' as math;

class GameBoard extends StatelessWidget {
  final int gridWidth;
  final int gridHeight;
  final List<GameElement> elements;
  final List<LaserPath> laserPaths;
  final Function(Position) onElementTap;
  final bool showTrajectory;

  const GameBoard({
    Key? key,
    required this.gridWidth,
    required this.gridHeight,
    required this.elements,
    required this.laserPaths,
    required this.onElementTap,
    this.showTrajectory = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = math.min(
          constraints.maxWidth / gridWidth,
          constraints.maxHeight / gridHeight,
        );

        return Center(
          child: Container(
            width: cellSize * gridWidth,
            height: cellSize * gridHeight,
            color: const Color(0xFF0A0E27),
            child: Stack(
              children: [
                // Grid lines
                CustomPaint(
                  size: Size(
                    cellSize * gridWidth,
                    cellSize * gridHeight,
                  ),
                  painter: GridPainter(
                    gridWidth: gridWidth,
                    gridHeight: gridHeight,
                    cellSize: cellSize,
                  ),
                ),
                // Laser beams
                if (showTrajectory)
                  CustomPaint(
                    size: Size(
                      cellSize * gridWidth,
                      cellSize * gridHeight,
                    ),
                    painter: LaserPainter(
                      laserPaths: laserPaths,
                      cellSize: cellSize,
                    ),
                  ),
                // Elements
                ...elements.map((element) {
                  return Positioned(
                    left: element.position.x * cellSize,
                    top: element.position.y * cellSize,
                    child: GestureDetector(
                      onTap: () => onElementTap(element.position),
                      child: SizedBox(
                        width: cellSize,
                        height: cellSize,
                        child: _buildElement(element, cellSize),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildElement(GameElement element, double cellSize) {
    if (element is Mirror) {
      return MirrorWidget(
        mirror: element,
        size: cellSize,
      );
    } else if (element is LaserSource) {
      return LaserSourceWidget(
        source: element,
        size: cellSize,
      );
    } else if (element is Target) {
      return TargetWidget(
        target: element,
        size: cellSize,
      );
    } else if (element is Splitter) {
      return SplitterWidget(
        splitter: element,
        size: cellSize,
      );
    } else if (element is Portal) {
      return PortalWidget(
        portal: element,
        size: cellSize,
      );
    } else if (element is ColorFilter) {
      return ColorFilterWidget(
        filter: element,
        size: cellSize,
      );
    } else if (element is Obstacle) {
      return ObstacleWidget(size: cellSize);
    }
    return const SizedBox.shrink();
  }
}

class GridPainter extends CustomPainter {
  final int gridWidth;
  final int gridHeight;
  final double cellSize;

  GridPainter({
    required this.gridWidth,
    required this.gridHeight,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1F3A).withOpacity(0.3)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (int i = 0; i <= gridWidth; i++) {
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, gridHeight * cellSize),
        paint,
      );
    }

    // Draw horizontal lines
    for (int i = 0; i <= gridHeight; i++) {
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(gridWidth * cellSize, i * cellSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LaserPainter extends CustomPainter {
  final List<LaserPath> laserPaths;
  final double cellSize;

  LaserPainter({
    required this.laserPaths,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in laserPaths) {
      final paint = Paint()
        ..color = _getLaserColor(path.color)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      for (final segment in path.segments) {
        final start = Offset(
          segment.start.x * cellSize + cellSize / 2,
          segment.start.y * cellSize + cellSize / 2,
        );
        final end = Offset(
          segment.end.x * cellSize + cellSize / 2,
          segment.end.y * cellSize + cellSize / 2,
        );

        canvas.drawLine(start, end, paint);
      }
    }
  }

  Color _getLaserColor(LaserColor color) {
    switch (color) {
      case LaserColor.red:
        return const Color(0xFFFF3366);
      case LaserColor.green:
        return const Color(0xFF00FF88);
      case LaserColor.blue:
        return const Color(0xFF3366FF);
      case LaserColor.white:
        return const Color(0xFFFFFFFF);
    }
  }

  @override
  bool shouldRepaint(covariant LaserPainter oldDelegate) {
    return laserPaths != oldDelegate.laserPaths;
  }
}

class MirrorWidget extends StatelessWidget {
  final Mirror mirror;
  final double size;

  const MirrorWidget({
    Key? key,
    required this.mirror,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size * 0.15),
      child: Transform.rotate(
        angle: _getRotationAngle(),
        child: CustomPaint(
          size: Size(size, size),
          painter: MirrorPainter(
            isFixed: mirror.isFixed,
            isSliding: mirror.isSliding,
          ),
        ),
      ),
    );
  }

  double _getRotationAngle() {
    switch (mirror.direction) {
      case Direction.up:
        return math.pi / 4; // 45 degrees
      case Direction.right:
        return -math.pi / 4; // -45 degrees
      case Direction.down:
        return math.pi / 4;
      case Direction.left:
        return -math.pi / 4;
    }
  }
}

class MirrorPainter extends CustomPainter {
  final bool isFixed;
  final bool isSliding;

  MirrorPainter({
    required this.isFixed,
    required this.isSliding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isFixed
          ? const Color(0xFF666666)
          : const Color(0xFF00D4FF)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw diagonal line
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.8),
      paint,
    );

    // Add sliding indicator
    if (isSliding) {
      final dotPaint = Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width * 0.08,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LaserSourceWidget extends StatelessWidget {
  final LaserSource source;
  final double size;

  const LaserSourceWidget({
    Key? key,
    required this.source,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size * 0.2),
      child: Transform.rotate(
        angle: _getRotationAngle(),
        child: CustomPaint(
          size: Size(size, size),
          painter: LaserSourcePainter(color: source.color),
        ),
      ),
    );
  }

  double _getRotationAngle() {
    switch (source.direction) {
      case Direction.up:
        return -math.pi / 2;
      case Direction.right:
        return 0;
      case Direction.down:
        return math.pi / 2;
      case Direction.left:
        return math.pi;
    }
  }
}

class LaserSourcePainter extends CustomPainter {
  final LaserColor color;

  LaserSourcePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _getColor()
      ..style = PaintingStyle.fill;

    // Draw triangle pointing right
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.3)
      ..lineTo(size.width * 0.8, size.height * 0.5)
      ..lineTo(size.width * 0.2, size.height * 0.7)
      ..close();

    canvas.drawPath(path, paint);

    // Draw glow
    final glowPaint = Paint()
      ..color = _getColor().withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.5),
      size.width * 0.15,
      glowPaint,
    );
  }

  Color _getColor() {
    switch (color) {
      case LaserColor.red:
        return const Color(0xFFFF3366);
      case LaserColor.green:
        return const Color(0xFF00FF88);
      case LaserColor.blue:
        return const Color(0xFF3366FF);
      case LaserColor.white:
        return const Color(0xFFFFFFFF);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TargetWidget extends StatelessWidget {
  final Target target;
  final double size;

  const TargetWidget({
    Key? key,
    required this.target,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size * 0.2),
      child: CustomPaint(
        size: Size(size, size),
        painter: TargetPainter(
          isActivated: target.isActivated,
          requiredColor: target.requiredColor,
        ),
      ),
    );
  }
}

class TargetPainter extends CustomPainter {
  final bool isActivated;
  final LaserColor? requiredColor;

  TargetPainter({
    required this.isActivated,
    this.requiredColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isActivated
          ? const Color(0xFF00FF88)
          : const Color(0xFF444466)
      ..style = PaintingStyle.fill;

    // Draw circles
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.4,
      paint,
    );

    final innerPaint = Paint()
      ..color = isActivated
          ? const Color(0xFF00DD66)
          : const Color(0xFF333344)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.25,
      innerPaint,
    );

    final centerPaint = Paint()
      ..color = isActivated
          ? const Color(0xFF00FF88)
          : const Color(0xFF222233)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.1,
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant TargetPainter oldDelegate) {
    return isActivated != oldDelegate.isActivated;
  }
}

class SplitterWidget extends StatelessWidget {
  final Splitter splitter;
  final double size;

  const SplitterWidget({
    Key? key,
    required this.splitter,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size * 0.15),
      child: Transform.rotate(
        angle: _getRotationAngle(),
        child: CustomPaint(
          size: Size(size, size),
          painter: SplitterPainter(isFixed: splitter.isFixed),
        ),
      ),
    );
  }

  double _getRotationAngle() {
    switch (splitter.direction) {
      case Direction.up:
      case Direction.down:
        return 0;
      case Direction.left:
      case Direction.right:
        return math.pi / 2;
    }
  }
}

class SplitterPainter extends CustomPainter {
  final bool isFixed;

  SplitterPainter({required this.isFixed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isFixed
          ? const Color(0xFF666666)
          : const Color(0xFFFF9900)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw vertical line
    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.2),
      Offset(size.width / 2, size.height * 0.8),
      paint,
    );

    // Draw horizontal arrows
    final arrowPaint = Paint()
      ..color = isFixed
          ? const Color(0xFF666666)
          : const Color(0xFFFF9900)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Left arrow
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.2, size.height * 0.5),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.3, size.height * 0.4),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.3, size.height * 0.6),
      arrowPaint,
    );

    // Right arrow
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.5),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.8, size.height * 0.5),
      Offset(size.width * 0.7, size.height * 0.4),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.8, size.height * 0.5),
      Offset(size.width * 0.7, size.height * 0.6),
      arrowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PortalWidget extends StatelessWidget {
  final Portal portal;
  final double size;

  const PortalWidget({
    Key? key,
    required this.portal,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size * 0.2),
      child: CustomPaint(
        size: Size(size, size),
        painter: PortalPainter(pairId: portal.pairId),
      ),
    );
  }
}

class PortalPainter extends CustomPainter {
  final String pairId;

  PortalPainter({required this.pairId});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFAA00FF)
      ..style = PaintingStyle.fill;

    // Draw outer ring
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.4,
      paint,
    );

    // Draw inner circle
    final innerPaint = Paint()
      ..color = const Color(0xFF0A0E27)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.25,
      innerPaint,
    );

    // Draw glow
    final glowPaint = Paint()
      ..color = const Color(0xFFAA00FF).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.4,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ColorFilterWidget extends StatelessWidget {
  final ColorFilter filter;
  final double size;

  const ColorFilterWidget({
    Key? key,
    required this.filter,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size * 0.2),
      child: CustomPaint(
        size: Size(size, size),
        painter: ColorFilterPainter(
          color: filter.allowedColor,
          isFixed: filter.isFixed,
        ),
      ),
    );
  }
}

class ColorFilterPainter extends CustomPainter {
  final LaserColor color;
  final bool isFixed;

  ColorFilterPainter({
    required this.color,
    required this.isFixed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _getColor()
      ..style = PaintingStyle.fill;

    // Draw diamond shape
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.1)
      ..lineTo(size.width * 0.9, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.9)
      ..lineTo(size.width * 0.1, size.height * 0.5)
      ..close();

    canvas.drawPath(path, paint);

    // Draw border
    final borderPaint = Paint()
      ..color = isFixed
          ? const Color(0xFF666666)
          : Colors.white.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, borderPaint);
  }

  Color _getColor() {
    switch (color) {
      case LaserColor.red:
        return const Color(0xFFFF3366).withOpacity(0.6);
      case LaserColor.green:
        return const Color(0xFF00FF88).withOpacity(0.6);
      case LaserColor.blue:
        return const Color(0xFF3366FF).withOpacity(0.6);
      case LaserColor.white:
        return const Color(0xFFFFFFFF).withOpacity(0.6);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ObstacleWidget extends StatelessWidget {
  final double size;

  const ObstacleWidget({
    Key? key,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(size * 0.15),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2F4A),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF3A3F5A),
          width: 2,
        ),
      ),
    );
  }
}
