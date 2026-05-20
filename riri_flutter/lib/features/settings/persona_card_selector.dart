import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/notifications/personas.dart';
import '../../core/notifications/personality_copy.dart';
import '../../theme/riri_theme.dart';

String getStickerForPersona(PersonalityMode mode) {
  switch (mode) {
    case PersonalityMode.bestie:
      return 'assets/stickers/Barkada Mode.webp';
    case PersonalityMode.malupit:
      return 'assets/stickers/Angry.webp';
    case PersonalityMode.chill:
      return 'assets/stickers/Sunglasses.webp';
    case PersonalityMode.tita:
      return 'assets/stickers/Whispering Nudge.webp';
  }
}

class RotatingGradientBorder extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final double borderWidth;
  final BorderRadius borderRadius;
  final bool isRotating;

  const RotatingGradientBorder({
    super.key,
    required this.child,
    required this.colors,
    this.borderWidth = 2.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    required this.isRotating,
  });

  @override
  State<RotatingGradientBorder> createState() => _RotatingGradientBorderState();
}

class _RotatingGradientBorderState extends State<RotatingGradientBorder> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.isRotating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant RotatingGradientBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRotating && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isRotating && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRotating) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          border: Border.all(color: const Color(0xFF2F2F4A), width: 1.5),
        ),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GradientBorderPainter(
            colors: widget.colors,
            angle: _controller.value * 2 * pi,
            borderWidth: widget.borderWidth,
            borderRadius: widget.borderRadius,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final List<Color> colors;
  final double angle;
  final double borderWidth;
  final BorderRadius borderRadius;

  _GradientBorderPainter({
    required this.colors,
    required this.angle,
    required this.borderWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    paint.shader = SweepGradient(
      colors: colors,
      transform: GradientRotation(angle),
    ).createShader(rect);

    final rrect = borderRadius.toRRect(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.colors != colors;
  }
}

class PersonaCardSelector extends ConsumerWidget {
  final PersonalityMode? selectedMode;
  final ValueChanged<PersonalityMode> onPersonaSelected;

  const PersonaCardSelector({
    super.key,
    required this.selectedMode,
    required this.onPersonaSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: PersonalityMode.values.map((mode) {
        final config = PersonaConfig.registry[mode]!;
        final isActive = selectedMode == mode;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onPersonaSelected(mode);
            },
            child: RotatingGradientBorder(
              isRotating: isActive,
              colors: config.confettiColors,
              borderRadius: BorderRadius.circular(24),
              borderWidth: 3.0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: RiriTheme.cardBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: config.accentColor.withValues(alpha: 0.1),
                        border: Border.all(
                          color: config.accentColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          getStickerForPersona(mode),
                          fit: BoxFit.contain,
                          errorBuilder: (context, _, _) => Icon(
                            Icons.face,
                            size: 32,
                            color: config.accentColor,
                          ),
                        ),
                      ),
                    ).animate(target: isActive ? 1.0 : 0.0).scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.1, 1.1),
                          duration: 200.ms,
                          curve: Curves.easeOutBack,
                        ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                config.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: RiriTheme.offWhite,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (isActive) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: config.accentColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: config.accentColor.withValues(alpha: 0.4), width: 1.0),
                                  ),
                                  child: Text(
                                    'ACTIVE 💅',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: config.accentColor,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            config.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: RiriTheme.textSecondary,
                                  height: 1.3,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
