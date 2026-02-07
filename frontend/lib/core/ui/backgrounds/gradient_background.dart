import 'package:flutter/material.dart';
import 'wave_clipper.dart';

class GradientBackground extends StatefulWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
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
      builder: (_, __) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(
                      const Color(0xFF1E3C72),
                      const Color(0xFF2A5298),
                      _controller.value,
                    )!,
                    Color.lerp(
                      const Color(0xFF2A5298),
                      const Color(0xFF1E3C72),
                      _controller.value,
                    )!,
                  ],
                ),
              ),
            ),
            ClipPath(
              clipper: BottomWaveClipper(),
              child: Container(color: Colors.black.withOpacity(0.06)),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}
