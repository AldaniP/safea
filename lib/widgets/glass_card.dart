import 'dart:ui';

import 'package:flutter/material.dart';

/// Widget kontainer Glassmorphism yang dapat digunakan ulang.
///
/// Menerapkan efek blur latar belakang (frosted glass) dengan
/// border semi-transparan dan shadow halus untuk kedalaman visual.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.blurSigma = 15,
    this.opacity,
    this.borderOpacity,
  });

  /// Konten di dalam glass card.
  final Widget child;

  /// Padding internal card.
  final EdgeInsetsGeometry padding;

  /// Radius sudut card.
  final double borderRadius;

  /// Intensitas blur latar belakang.
  final double blurSigma;

  /// Opasitas latar belakang. Jika null, akan menyesuaikan
  /// dengan brightness tema (0.18 untuk light, 0.10 untuk dark).
  final double? opacity;

  /// Opasitas border. Jika null, default 0.25.
  final double? borderOpacity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgOpacity = opacity ?? (isDark ? 0.10 : 0.18);
    final brdOpacity = borderOpacity ?? (isDark ? 0.15 : 0.25);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.white).withValues(
              alpha: bgOpacity,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: brdOpacity),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
