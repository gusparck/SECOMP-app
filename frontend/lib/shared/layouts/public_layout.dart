import 'package:flutter/material.dart';
import '../../core/ui/backgrounds/gradient_background.dart';

class PublicLayout extends StatelessWidget {
  final Widget child;

  const PublicLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(padding: const EdgeInsets.all(24), child: child),
        ),
      ),
    );
  }
}
