import 'dart:ui';

import 'package:flutter/material.dart';

@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  final double sm;
  final double md;
  final double lg;

  const AppSpacing({required this.sm, required this.md, required this.lg});

  @override
  AppSpacing copyWith({double? sm, double? md, double? lg}) {
    return AppSpacing(sm: sm ?? this.sm, md: md ?? this.md, lg: lg ?? this.lg);
  }

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) return this;

    return AppSpacing(
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
    );
  }
}
