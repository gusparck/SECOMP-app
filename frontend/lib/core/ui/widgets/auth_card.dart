import 'package:flutter/material.dart';

class AuthCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;

  const AuthCard({super.key, required this.child, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B), // Slate 800
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (subtitle != null) ...[
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B), // Slate 500
                ),
              ),
              const SizedBox(height: 32),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
