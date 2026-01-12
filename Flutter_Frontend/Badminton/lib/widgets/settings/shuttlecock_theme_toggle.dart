import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A custom animated theme toggle widget with two characters hitting a shuttlecock
/// The shuttlecock moves from one character to the other when tapped
class ShuttlecockThemeToggle extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggle;

  const ShuttlecockThemeToggle({
    super.key,
    required this.isDarkMode,
    required this.onToggle,
  });

  @override
  State<ShuttlecockThemeToggle> createState() => _ShuttlecockThemeToggleState();
}

class _ShuttlecockThemeToggleState extends State<ShuttlecockThemeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shuttlecockPosition;
  late Animation<double> _shuttlecockRotation;
  late Animation<double> _leftPlayerAnimation;
  late Animation<double> _rightPlayerAnimation;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Shuttlecock moves from left (0.0) to right (1.0)
    _shuttlecockPosition = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    // Shuttlecock rotates as it moves
    _shuttlecockRotation = Tween<double>(
      begin: 0.0,
      end: math.pi * 2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Left player animation (hits when going right)
    _leftPlayerAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 80,
      ),
    ]).animate(_controller);

    // Right player animation (hits when going left)
    _rightPlayerAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 80,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isAnimating = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_isAnimating) return;

    setState(() => _isAnimating = true);

    if (widget.isDarkMode) {
      // Going from dark to light (left to right)
      _controller.forward(from: 0.0).then((_) => widget.onToggle());
    } else {
      // Going from light to dark (right to left)
      _controller.reverse(from: 1.0).then((_) => widget.onToggle());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1a1a1a) : const Color(0xFFf5f5f5);
    final textColor = isDark ? const Color(0xFFe8e8e8) : const Color(0xFF1a1a1a);

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Theme labels
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ThemeLabel(
                    icon: Icons.dark_mode_outlined,
                    label: 'Dark',
                    isActive: widget.isDarkMode,
                    textColor: textColor,
                  ),
                  _ThemeLabel(
                    icon: Icons.light_mode_outlined,
                    label: 'Light',
                    isActive: !widget.isDarkMode,
                    textColor: textColor,
                  ),
                ],
              ),
            ),

            // Ground line
            Positioned(
              bottom: 60,
              left: 40,
              right: 40,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),

            // Animated shuttlecock
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Positioned(
                  bottom: 70 + (math.sin(_shuttlecockPosition.value * math.pi) * 40),
                  left: 40 + (_shuttlecockPosition.value * (MediaQuery.of(context).size.width - 120)),
                  child: Transform.rotate(
                    angle: _shuttlecockRotation.value,
                    child: _Shuttlecock(color: textColor),
                  ),
                );
              },
            ),

            // Left character (Dark mode)
            Positioned(
              bottom: 62,
              left: 30,
              child: AnimatedBuilder(
                animation: _leftPlayerAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -_leftPlayerAnimation.value * 10),
                    child: _Character(
                      isActive: widget.isDarkMode,
                      color: textColor,
                      facingRight: true,
                    ),
                  );
                },
              ),
            ),

            // Right character (Light mode)
            Positioned(
              bottom: 62,
              right: 30,
              child: AnimatedBuilder(
                animation: _rightPlayerAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -_rightPlayerAnimation.value * 10),
                    child: _Character(
                      isActive: !widget.isDarkMode,
                      color: textColor,
                      facingRight: false,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color textColor;

  const _ThemeLabel({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF4a9eff) : textColor.withOpacity(0.3),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF4a9eff) : textColor.withOpacity(0.3),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _Shuttlecock extends StatelessWidget {
  final Color color;

  const _Shuttlecock({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 24),
      painter: _ShuttlecockPainter(color: color),
    );
  }
}

class _ShuttlecockPainter extends CustomPainter {
  final Color color;

  _ShuttlecockPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Cork (rounded top part)
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.25),
      size.width * 0.4,
      paint,
    );

    // Feathers (cone shape)
    final path = Path()
      ..moveTo(size.width / 2, size.height * 0.25)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    canvas.drawPath(path, paint);

    // Feather lines
    for (int i = 1; i < 4; i++) {
      final x = (size.width / 4) * i;
      canvas.drawLine(
        Offset(x, size.height * 0.4),
        Offset(x, size.height * 0.9),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Character extends StatelessWidget {
  final bool isActive;
  final Color color;
  final bool facingRight;

  const _Character({
    required this.isActive,
    required this.color,
    required this.facingRight,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: facingRight ? 1 : -1,
      child: CustomPaint(
        size: const Size(40, 60),
        painter: _CharacterPainter(
          color: isActive ? const Color(0xFF4a9eff) : color.withOpacity(0.4),
        ),
      ),
    );
  }
}

class _CharacterPainter extends CustomPainter {
  final Color color;

  _CharacterPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    // Head
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.2),
      size.width * 0.25,
      paint,
    );

    // Body
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;

    // Torso
    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.35),
      Offset(size.width / 2, size.height * 0.65),
      paint,
    );

    // Arms (one raised holding racket)
    // Raised arm
    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.4),
      Offset(size.width * 0.7, size.height * 0.25),
      paint,
    );

    // Racket (simple oval)
    final racketPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.8, size.height * 0.2),
        width: 12,
        height: 16,
      ),
      racketPaint,
    );

    // Other arm
    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.45),
      Offset(size.width * 0.3, size.height * 0.55),
      paint,
    );

    // Legs
    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.65),
      Offset(size.width * 0.4, size.height * 0.9),
      paint,
    );

    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.65),
      Offset(size.width * 0.6, size.height * 0.9),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
