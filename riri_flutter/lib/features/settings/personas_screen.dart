import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/notifications/personas.dart';
import '../../core/notifications/personality_copy.dart';
import '../../core/persistence/riri_providers.dart';
import '../../theme/riri_theme.dart';

class PersonaSelectorScreen extends ConsumerStatefulWidget {
  const PersonaSelectorScreen({super.key});

  @override
  ConsumerState<PersonaSelectorScreen> createState() => _PersonaSelectorScreenState();
}

class _PersonaSelectorScreenState extends ConsumerState<PersonaSelectorScreen> {
  // Store the active preview tab per persona to allow independent toggling
  final Map<PersonalityMode, String> _previewTabs = {
    PersonalityMode.bestie: 'standard',
    PersonalityMode.malupit: 'standard',
    PersonalityMode.chill: 'standard',
    PersonalityMode.tita: 'standard',
  };

  String _getStickerForPersona(PersonalityMode mode) {
    switch (mode) {
      case PersonalityMode.bestie:
        return 'assets/stickers/Barkada Mode.png';
      case PersonalityMode.malupit:
        return 'assets/stickers/Angry.png';
      case PersonalityMode.chill:
        return 'assets/stickers/Sunglasses.png';
      case PersonalityMode.tita:
        return 'assets/stickers/Whispering Nudge.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeMode = ref.watch(personalityModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riri Personas'),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Gorgeous Header Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: RiriTheme.brandGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: RiriTheme.primaryPurple.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology, size: 28, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Piliin ang Iyong Riri',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customize the personality and Nagging level of your Taglish assistant. Bawat galaw mo, may reaksyon si Riri.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ).animate().fade(duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOutQuad),
            const SizedBox(height: 24),

            // Section Subtitle
            Text(
              'AVAILABLE PERSONALITIES',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: RiriTheme.textSecondary,
                  ),
            ).animate().fade(delay: 200.ms),
            const SizedBox(height: 12),

            // Persona Cards
            ...PersonalityMode.values.map((mode) {
              final config = PersonaConfig.registry[mode]!;
              final isActive = activeMode == mode;
              final currentTab = _previewTabs[mode] ?? 'standard';

              return Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: GestureDetector(
                  onTap: () async {
                    if (!isActive) {
                      HapticFeedback.mediumImpact();
                      await ref.read(personalityModeProvider.notifier).setPersonalityMode(mode);
                    }
                  },
                  child: _RotatingGradientBorder(
                    isRotating: isActive,
                    colors: config.confettiColors,
                    borderRadius: BorderRadius.circular(24),
                    borderWidth: 3.0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: RiriTheme.cardBg,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Sticker, Name, Badges
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sticker Hero Image
                              Container(
                                width: 72,
                                height: 72,
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
                                    _getStickerForPersona(mode),
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, _, __) => Icon(
                                      Icons.face,
                                      size: 40,
                                      color: config.accentColor,
                                    ),
                                  ),
                                ),
                              ).animate(target: isActive ? 1.0 : 0.0).scale(
                                    begin: const Offset(1.0, 1.0),
                                    end: const Offset(1.15, 1.15),
                                    duration: 300.ms,
                                    curve: Curves.elasticOut,
                                  ),
                              const SizedBox(width: 16),
                              // Title & Description
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          config.name,
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                color: RiriTheme.offWhite,
                                                fontWeight: FontWeight.w900,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (isActive)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(colors: config.confettiColors),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'ACTIVE',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      config.description,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: RiriTheme.textSecondary,
                                            height: 1.3,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Live Notification Preview Card
                          _buildLiveNotificationPreview(context, mode, config, currentTab),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveNotificationPreview(
    BuildContext context,
    PersonalityMode mode,
    PersonaConfig config,
    String currentTab,
  ) {
    // Dynamic copy based on current tab selection
    String titleText = '';
    String bodyText = '';
    const taskName = 'Mag-aral ng Flutter 🚀';

    if (currentTab == 'standard') {
      titleText = config.standard.renderTitle({'task': taskName});
      bodyText = config.standard.renderBody({'task': taskName});
    } else if (currentTab == 'snooze') {
      titleText = config.snooze.renderTitle({'task': taskName});
      bodyText = config.snooze.renderBody({'task': taskName});
    } else {
      titleText = config.overdue.renderTitle({'task': taskName, 'days': '3'});
      bodyText = config.overdue.renderBody({'task': taskName, 'days': '3'});
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab Selector Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LIVE NOTIFICATION PREVIEW',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: RiriTheme.textMuted,
                  ),
            ),
            // Minimalist Tab Selector
            Row(
              children: ['standard', 'snooze', 'overdue'].map((tab) {
                final isSelected = currentTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _previewTabs[mode] = tab;
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? config.accentColor.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? config.accentColor.withValues(alpha: 0.3) : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        tab.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? config.accentColor : RiriTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Android Styled Preview Notification Chip
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RiriTheme.darkBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2F2F4A), width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: config.accentColor.withValues(alpha: 0.2),
                        ),
                        child: Icon(
                          Icons.notifications_active,
                          size: 14,
                          color: config.accentColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'RIRI APP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: RiriTheme.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'now',
                    style: TextStyle(
                      fontSize: 10,
                      color: RiriTheme.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Notification Title
              Text(
                titleText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: RiriTheme.offWhite,
                ),
              ),
              const SizedBox(height: 4),
              // Notification Body
              Text(
                bodyText,
                style: const TextStyle(
                  fontSize: 12,
                  color: RiriTheme.textSecondary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              // Mock Notification Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _mockActionButton('DONE ✅', config.accentColor),
                  const SizedBox(width: 8),
                  _mockActionButton('SNOOZE ☕', RiriTheme.textMuted),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mockActionButton(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

// Custom painter rotating border widget
class _RotatingGradientBorder extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final double borderWidth;
  final BorderRadius borderRadius;
  final bool isRotating;

  const _RotatingGradientBorder({
    required this.child,
    required this.colors,
    this.borderWidth = 2.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    required this.isRotating,
  });

  @override
  State<_RotatingGradientBorder> createState() => _RotatingGradientBorderState();
}

class _RotatingGradientBorderState extends State<_RotatingGradientBorder> with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(covariant _RotatingGradientBorder oldWidget) {
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

    // Create a rotating gradient
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
