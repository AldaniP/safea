import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:async';
import '../../data/profile_service.dart';

class CalmScreen extends StatefulWidget {
  const CalmScreen({super.key});

  @override
  State<CalmScreen> createState() => _CalmScreenState();
}

class _CalmScreenState extends State<CalmScreen>
    with SingleTickerProviderStateMixin {
  String _mode = 'breathing'; // breathing, grounding
  String _phase = 'inhale'; // inhale, hold, exhale
  int _timeLeft = 4;
  Timer? _timer;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _startBreathing();
  }

  void _startBreathing() {
    _timer?.cancel();
    _animationController.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _mode != 'breathing') {
        timer.cancel();
        return;
      }
      setState(() {
        if (_timeLeft <= 1) {
          if (_phase == 'inhale') {
            _phase = 'hold';
            _timeLeft = 7;
            _animationController.stop();
          } else if (_phase == 'hold') {
            _phase = 'exhale';
            _timeLeft = 8;
            _animationController.duration = const Duration(seconds: 8);
            _animationController.reverse();
          } else {
            _phase = 'inhale';
            _timeLeft = 4;
            _animationController.duration = const Duration(seconds: 4);
            _animationController.forward();
          }
        } else {
          _timeLeft--;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _handleFinish() async {
    await ProfileService.addPoints(20);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Kerja bagus! Anda mendapatkan 20 poin karena telah menyempatkan waktu untuk relaksasi.',
          ),
        ),
      );
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildTabs(context),
              const SizedBox(height: 48),
              Expanded(
                child: Center(
                  child: _mode == 'breathing'
                      ? _buildBreathing()
                      : _buildGrounding(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Stabilisasi Darurat',
                  style: TextStyle(
                    color: Color(0xFF818CF8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tenang Dulu',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ambil waktu sejenak untuk menstabilkan diri. Kamu aman di sini.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => context.go('/safety'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.withValues(alpha: 0.1),
            foregroundColor: Colors.red[400],
            elevation: 0,
          ),
          icon: const Icon(LucideIcons.shieldAlert),
          label: const Text('Bantuan Darurat'),
        ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _mode = 'breathing';
                  _startBreathing();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _mode == 'breathing'
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                foregroundColor: _mode == 'breathing'
                    ? Theme.of(context).colorScheme.surface
                    : Colors.white70,
              ),
              child: const Text('Pernapasan 4-7-8'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _mode = 'grounding';
                  _timer?.cancel();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _mode == 'grounding'
                    ? const Color(0xFF6366F1)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                foregroundColor: _mode == 'grounding'
                    ? Colors.white
                    : Colors.white70,
              ),
              child: const Text('Grounding 5-4-3-2-1'),
            ),
          ],
        ),
        OutlinedButton.icon(
          onPressed: _handleFinish,
          icon: const Icon(LucideIcons.checkCircle2),
          label: const Text('Selesai Latihan'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            side: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreathing() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1 + (_scaleAnimation.value - 1) * 0.5,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.4),
                      ),
                    ),
                  );
                },
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.5),
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _phase == 'inhale'
                          ? 'Tarik'
                          : _phase == 'hold'
                          ? 'Tahan'
                          : 'Hembus',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '$_timeLeft',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Ikuti ritme lingkaran. Tarik napas melalui hidung selama 4 detik, tahan 7 detik, dan hembuskan perlahan melalui mulut selama 8 detik.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildGrounding() {
    final steps = [
      {
        'num': '5',
        'color': const Color(0xFF6366F1),
        'title': 'Benda yang bisa kamu lihat',
        'desc': 'Contoh: meja, dinding, layar ponsel, langit-langit, tanganmu.',
      },
      {
        'num': '4',
        'color': const Color(0xFF14B8A6),
        'title': 'Benda yang bisa kamu sentuh/rasakan',
        'desc': 'Contoh: tekstur pakaianmu, suhu udara, pijakan lantai.',
      },
      {
        'num': '3',
        'color': const Color(0xFFF59E0B),
        'title': 'Suara yang bisa kamu dengar',
        'desc': 'Contoh: detak jam, suara kendaraan, dengungan AC.',
      },
      {
        'num': '2',
        'color': const Color(0xFFF97316),
        'title': 'Aroma yang bisa kamu cium',
        'desc':
            'Contoh: udara sekitar, wangi sabun, atau bayangkan aroma kopi.',
      },
      {
        'num': '1',
        'color': const Color(0xFFF43F5E),
        'title': 'Hal baik tentang dirimu',
        'desc':
            'Pikirkan satu hal yang kamu syukuri atau apresiasi dari dirimu hari ini.',
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sebutkan dalam hati atau bersuara perlahan:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: steps.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final step = steps[index];
                  final color = step['color'] as Color;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.2),
                          child: Text(
                            step['num'] as String,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['title'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                step['desc'] as String,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
