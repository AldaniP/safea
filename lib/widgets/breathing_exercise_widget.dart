import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Fase pernapasan dalam satu siklus Box Breathing.
enum _BreathPhase {
  breatheIn, // Tarik Napas — 4 detik
  holdIn, // Tahan — 4 detik
  breatheOut, // Buang Napas — 4 detik
  holdOut, // Tahan — 4 detik
}

extension _BreathPhaseExt on _BreathPhase {
  /// Durasi setiap fase dalam detik.
  int get durationSeconds => 4;

  /// Label instruksi untuk UI.
  String get label {
    switch (this) {
      case _BreathPhase.breatheIn:
        return 'Tarik Napas...';
      case _BreathPhase.holdIn:
        return 'Tahan...';
      case _BreathPhase.breatheOut:
        return 'Buang Napas...';
      case _BreathPhase.holdOut:
        return 'Tahan...';
    }
  }

  /// Warna utama per fase.
  Color get color {
    switch (this) {
      case _BreathPhase.breatheIn:
        return AppColors.breatheInColor;
      case _BreathPhase.holdIn:
        return AppColors.holdColor;
      case _BreathPhase.breatheOut:
        return AppColors.breatheOutColor;
      case _BreathPhase.holdOut:
        return AppColors.holdAfterColor;
    }
  }

  /// Target skala lingkaran animasi (0.0 – 1.0).
  double get targetScale {
    switch (this) {
      case _BreathPhase.breatheIn:
        return 1.0;
      case _BreathPhase.holdIn:
        return 1.0;
      case _BreathPhase.breatheOut:
        return 0.5;
      case _BreathPhase.holdOut:
        return 0.5;
    }
  }

  /// Fase berikutnya.
  _BreathPhase get next {
    switch (this) {
      case _BreathPhase.breatheIn:
        return _BreathPhase.holdIn;
      case _BreathPhase.holdIn:
        return _BreathPhase.breatheOut;
      case _BreathPhase.breatheOut:
        return _BreathPhase.holdOut;
      case _BreathPhase.holdOut:
        return _BreathPhase.breatheIn;
    }
  }
}

/// Widget fullscreen animasi panduan pernapasan.
///
/// Menampilkan animasi lingkaran yang mengembang/mengecil
/// mengikuti ritme Box Breathing (4-4-4-4) selama 60 detik.
class BreathingExerciseWidget extends StatefulWidget {
  const BreathingExerciseWidget({super.key});

  /// Durasi total latihan dalam detik.
  static const int totalDuration = 64; // 4 siklus × 16 detik

  @override
  State<BreathingExerciseWidget> createState() =>
      _BreathingExerciseWidgetState();
}

class _BreathingExerciseWidgetState extends State<BreathingExerciseWidget>
    with TickerProviderStateMixin {
  late AnimationController _circleController;
  late AnimationController _progressController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  _BreathPhase _currentPhase = _BreathPhase.breatheIn;
  int _remainingSeconds = BreathingExerciseWidget.totalDuration;
  int _phaseSecondsLeft = 4;
  bool _isActive = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();

    // Pengendali animasi lingkaran per-fase (4 detik)
    _circleController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _currentPhase.durationSeconds),
    );

    // Pengendali progress keseluruhan (64 detik)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: BreathingExerciseWidget.totalDuration),
    );

    _setupAnimations();
  }

  void _setupAnimations() {
    _scaleAnimation =
        Tween<double>(
          begin: _currentPhase == _BreathPhase.breatheIn ? 0.5 : 1.0,
          end: _currentPhase.targetScale,
        ).animate(
          CurvedAnimation(
            parent: _circleController,
            curve:
                _currentPhase == _BreathPhase.holdIn ||
                    _currentPhase == _BreathPhase.holdOut
                ? Curves.linear
                : Curves.easeInOutCubic,
          ),
        );

    _colorAnimation =
        ColorTween(
          begin: _getPreviousPhaseColor(),
          end: _currentPhase.color,
        ).animate(
          CurvedAnimation(parent: _circleController, curve: Curves.easeInOut),
        );
  }

  Color _getPreviousPhaseColor() {
    switch (_currentPhase) {
      case _BreathPhase.breatheIn:
        return AppColors.holdAfterColor;
      case _BreathPhase.holdIn:
        return AppColors.breatheInColor;
      case _BreathPhase.breatheOut:
        return AppColors.holdColor;
      case _BreathPhase.holdOut:
        return AppColors.breatheOutColor;
    }
  }

  void _startExercise() {
    setState(() {
      _isActive = true;
      _isCompleted = false;
      _remainingSeconds = BreathingExerciseWidget.totalDuration;
      _currentPhase = _BreathPhase.breatheIn;
      _phaseSecondsLeft = 4;
    });

    _setupAnimations();
    _progressController.forward(from: 0);
    _runPhase();
    _startCountdown();
  }

  void _runPhase() {
    if (!_isActive || _remainingSeconds <= 0) {
      _onComplete();
      return;
    }

    _circleController.duration = Duration(
      seconds: _currentPhase.durationSeconds,
    );
    _setupAnimations();
    _circleController.forward(from: 0).then((_) {
      if (!_isActive) return;
      setState(() {
        _currentPhase = _currentPhase.next;
        _phaseSecondsLeft = _currentPhase.durationSeconds;
      });
      _runPhase();
    });
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isActive || !mounted) return false;

      setState(() {
        _remainingSeconds--;
        _phaseSecondsLeft--;
        if (_phaseSecondsLeft < 0) {
          _phaseSecondsLeft = _currentPhase.durationSeconds - 1;
        }
      });

      if (_remainingSeconds <= 0) {
        _onComplete();
        return false;
      }
      return true;
    });
  }

  void _onComplete() {
    if (!mounted) return;
    _circleController.stop();
    _progressController.stop();
    setState(() {
      _isActive = false;
      _isCompleted = true;
    });
  }

  void _close() {
    _circleController.stop();
    _progressController.stop();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _circleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final circleMaxSize = min(size.width * 0.55, 260.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.darkBackgroundGradient
              : AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ─── Header ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Timer
                    if (_isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _formatTime(_remainingSeconds),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textDark,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 60),
                    // Close button
                    IconButton(
                      onPressed: _close,
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textDark,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Main Content ──────────────────────────
              Expanded(
                child: Center(
                  child: _isCompleted
                      ? _buildCompletedView(isDark)
                      : _isActive
                      ? _buildActiveView(circleMaxSize, isDark)
                      : _buildStartView(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Start View ──────────────────────────────────────────
  Widget _buildStartView(bool isDark) {
    return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.self_improvement_rounded,
              size: 80,
              color: AppColors.deepCalmBlue.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'Latihan Pernapasan',
              style: GoogleFonts.lora(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textLight : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Box Breathing — 4 siklus (≈1 menit)',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isDark
                    ? AppColors.textLight.withValues(alpha: 0.7)
                    : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Tarik napas 4 detik → Tahan 4 detik → '
                'Buang napas 4 detik → Tahan 4 detik',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textLight.withValues(alpha: 0.5)
                      : AppColors.textMuted.withValues(alpha: 0.8),
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 40),
            _buildGlassButton(
              onPressed: _startExercise,
              label: 'Mulai',
              icon: Icons.play_arrow_rounded,
              isDark: isDark,
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.05, end: 0, duration: 500.ms);
  }

  // ─── Active Breathing View ───────────────────────────────
  Widget _buildActiveView(double circleMaxSize, bool isDark) {
    return AnimatedBuilder(
      animation: Listenable.merge([_circleController, _progressController]),
      builder: (context, _) {
        final scale = _scaleAnimation.value;
        final color = _colorAnimation.value ?? AppColors.deepCalmBlue;
        final progress = _progressController.value;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Instruksi fase
            AnimatedSwitcher(
              duration: 400.ms,
              child: Text(
                _currentPhase.label,
                key: ValueKey(_currentPhase),
                style: GoogleFonts.lora(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Hitung mundur fase
            Text(
              '${_phaseSecondsLeft + 1}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textLight.withValues(alpha: 0.6)
                    : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 40),

            // ─── Animated Circle ─────────────────────
            SizedBox(
              width: circleMaxSize + 40,
              height: circleMaxSize + 40,
              child: CustomPaint(
                painter: _ProgressRingPainter(
                  progress: progress,
                  color: color.withValues(alpha: 0.3),
                  strokeWidth: 3,
                ),
                child: Center(
                  child: Container(
                    width: circleMaxSize * scale,
                    height: circleMaxSize * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          color.withValues(alpha: 0.6),
                          color.withValues(alpha: 0.15),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: circleMaxSize * scale * 0.5,
                        height: circleMaxSize * scale * 0.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Tombol berhenti
            TextButton.icon(
              onPressed: _close,
              icon: Icon(
                Icons.stop_rounded,
                color: isDark
                    ? AppColors.textLight.withValues(alpha: 0.5)
                    : AppColors.textMuted,
              ),
              label: Text(
                'Berhenti',
                style: GoogleFonts.poppins(
                  color: isDark
                      ? AppColors.textLight.withValues(alpha: 0.5)
                      : AppColors.textMuted,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── Completed View ──────────────────────────────────────
  Widget _buildCompletedView(bool isDark) {
    return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.calmGreen.withValues(alpha: 0.6),
                    AppColors.calmGreen.withValues(alpha: 0.15),
                  ],
                ),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sesi Selesai',
              style: GoogleFonts.lora(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textLight : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tubuhmu lebih tenang sekarang 🌿',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isDark
                    ? AppColors.textLight.withValues(alpha: 0.7)
                    : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 40),
            _buildGlassButton(
              onPressed: _startExercise,
              label: 'Ulangi',
              icon: Icons.refresh_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _close,
              child: Text(
                'Kembali',
                style: GoogleFonts.poppins(
                  color: isDark
                      ? AppColors.textLight.withValues(alpha: 0.6)
                      : AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 600.ms);
  }

  // ─── Glass Button Helper ─────────────────────────────────
  Widget _buildGlassButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.deepCalmBlue.withValues(alpha: 0.8),
                AppColors.deepCalmBlue.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepCalmBlue.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

/// Custom painter untuk menggambar ring progress di sekeliling lingkaran.
class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 3,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - strokeWidth;

    // Background ring
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
