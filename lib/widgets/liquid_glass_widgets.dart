import 'dart:ui';
import 'package:flutter/material.dart';

/// Liquid Glass Container - основной контейнер с эффектом жидкого стекла
class LiquidGlassContainer extends StatelessWidget {
  final Widget? child;
  final double width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurAmount;
  final double opacity;
  final List<Color>? gradientColors;
  final Border? border;
  final BoxShadow? customShadow;

  const LiquidGlassContainer({
    Key? key,
    this.child,
    this.width = double.infinity,
    this.height = double.infinity,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blurAmount = 10,
    this.opacity = 0.15,
    this.gradientColors,
    this.border,
    this.customShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          customShadow ??
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
          BoxShadow(
            color: (gradientColors?.first ?? const Color(0xFF00D4FF))
                .withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors ??
                    [
                      Colors.white.withOpacity(opacity),
                      Colors.white.withOpacity(opacity * 0.5),
                    ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ??
                  Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Liquid Glass Button - кнопка с эффектом жидкого стекла
class LiquidGlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final double borderRadius;
  final Color? primaryColor;
  final bool useNeonEffect;

  const LiquidGlassButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.width = 200,
    this.height = 56,
    this.borderRadius = 16,
    this.primaryColor,
    this.useNeonEffect = true,
  }) : super(key: key);

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.primaryColor ?? Theme.of(context).primaryColor;

    return GestureDetector(
      onTapDown: widget.onPressed != null
          ? (_) {
              setState(() => _isPressed = true);
              _controller.forward();
            }
          : null,
      onTapUp: widget.onPressed != null
          ? (_) {
              setState(() => _isPressed = false);
              _controller.reverse();
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: widget.onPressed != null
          ? () {
              setState(() => _isPressed = false);
              _controller.reverse();
            }
          : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.useNeonEffect
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: _isPressed ? 10 : 20,
                      spreadRadius: _isPressed ? 0 : 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: widget.useNeonEffect
                        ? color.withOpacity(0.5)
                        : Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Center(child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Liquid Glass Card - карточка с эффектом жидкого стекла
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? accentColor;

  const LiquidGlassCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 16,
    this.onTap,
    this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Neon Light Beam - неоновый лучик для анимации
class NeonLightBeam extends StatefulWidget {
  final Color color;
  final double width;
  final double height;
  final Duration duration;
  final Offset startPosition;
  final Offset endPosition;

  const NeonLightBeam({
    Key? key,
    this.color = const Color(0xFFFF3366),
    this.width = 3,
    this.height = 100,
    this.duration = const Duration(seconds: 3),
    required this.startPosition,
    required this.endPosition,
  }) : super(key: key);

  @override
  State<NeonLightBeam> createState() => _NeonLightBeamState();
}

class _NeonLightBeamState extends State<NeonLightBeam>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    widget.color.withOpacity(0),
                    widget.color,
                    widget.color.withOpacity(0),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.8),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Animated Neon Beams Background - фон с анимированными неоновыми лучиками
class AnimatedNeonBeamsBackground extends StatefulWidget {
  final Widget child;
  final int beamCount;
  final Color beamColor;

  const AnimatedNeonBeamsBackground({
    Key? key,
    required this.child,
    this.beamCount = 5,
    this.beamColor = const Color(0xFFFF3366),
  }) : super(key: key);

  @override
  State<AnimatedNeonBeamsBackground> createState() =>
      _AnimatedNeonBeamsBackgroundState();
}

class _AnimatedNeonBeamsBackgroundState
    extends State<AnimatedNeonBeamsBackground> {
  final List<_BeamData> _beams = [];

  @override
  void initState() {
    super.initState();
    _generateBeams();
  }

  void _generateBeams() {
    _beams.clear();
    for (int i = 0; i < widget.beamCount; i++) {
      _beams.add(_BeamData.random());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ...List.generate(
          widget.beamCount,
          (index) {
            final beam = _beams[index];
            return NeonLightBeam(
              key: ValueKey('beam_$index'),
              color: widget.beamColor,
              width: beam.width,
              height: beam.height,
              duration: beam.duration,
              startPosition: beam.startPosition,
              endPosition: beam.endPosition,
            );
          },
        ),
      ],
    );
  }
}

/// Вспомогательный класс для данных луча
class _BeamData {
  final double width;
  final double height;
  final Duration duration;
  final Offset startPosition;
  final Offset endPosition;

  _BeamData({
    required this.width,
    required this.height,
    required this.duration,
    required this.startPosition,
    required this.endPosition,
  });

  factory _BeamData.random() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final angle = (random % 360) * 3.14159 / 180;
    final startX = (random % 1000).toDouble();
    final startY = (random % 1500).toDouble();
    final distance = 300 + (random % 500).toDouble();

    return _BeamData(
      width: 2 + (random % 4).toDouble(),
      height: 80 + (random % 120).toDouble(),
      duration: Duration(milliseconds: 2000 + (random % 3000)),
      startPosition: Offset(startX, startY),
      endPosition: Offset(
        startX + distance * (random % 2 == 0 ? 1 : -1),
        startY + distance * (random % 2 == 0 ? 1 : -1),
      ),
    );
  }
}
