import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/roadmap_service.dart';

class RelaxationScreen extends StatefulWidget {
  const RelaxationScreen({super.key});

  @override
  State<RelaxationScreen> createState() => _RelaxationScreenState();
}

class _RelaxationScreenState extends State<RelaxationScreen> {
  final List<Map<String, dynamic>> _affirmations = [
    {
      'text': 'Perasaan saya valid, dan saya berhak untuk merasa tenang.',
      'icon': LucideIcons.sun,
    },
    {
      'text': 'Saya melepaskan apa yang tidak bisa saya kendalikan.',
      'icon': LucideIcons.moon,
    },
    {
      'text': 'Langkah kecil adalah kemajuan. Saya bangga dengan diri saya.',
      'icon': LucideIcons.coffee,
    },
  ];

  List<Map<String, dynamic>> _roadmapSteps = [];

  @override
  void initState() {
    super.initState();
    _loadRoadmap();
  }

  void _loadRoadmap() {
    setState(() {
      _roadmapSteps = RoadmapService.getRoadmap();
    });
  }

  void _toggleStep(int id) async {
    final updated = await RoadmapService.toggleRoadmapStep(id);
    setState(() {
      _roadmapSteps = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 4, child: _buildLeftColumn(context)),
                      const SizedBox(width: 32),
                      Expanded(flex: 8, child: _buildRightColumn(context)),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildLeftColumn(context),
                    const SizedBox(height: 32),
                    _buildRightColumn(context),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.sparkles, color: Colors.amber, size: 32),
            const SizedBox(width: 12),
            Text(
              'Relaksasi & Afirmasi',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Temukan kedamaian batin melalui roadmap relaksasi harian dan kata-kata positif.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildLeftColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Afirmasi Hari Ini',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ..._affirmations.map(
          (aff) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(aff['icon'] as IconData, color: Colors.amber),
                    const SizedBox(height: 16),
                    Text(
                      '"${aff['text']}"',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: const Color(0xFF4F46E5), // indigo-600
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  'Gabung Komunitas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bagikan pencapaian relaksasi secara anonim tanpa menyebut detail trauma.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 14),
                ), // indigo-200
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/community'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4F46E5),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Lihat Cerita Anonim'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn(BuildContext context) {
    final completedCount = _roadmapSteps
        .where((s) => s['completed'] as bool)
        .length;
    final progressPercent = _roadmapSteps.isEmpty
        ? 0
        : ((completedCount / _roadmapSteps.length) * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Roadmap Pemulihan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Selesaikan tantangan harian untuk meningkatkan resilience Anda.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'PROGRES MINGGU INI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      '$progressPercent%',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 48),
            Stack(
              children: [
                Positioned(
                  left: 23,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                Column(
                  children: _roadmapSteps.map((step) {
                    final isCompleted = step['completed'] as bool;
                    return InkWell(
                      onTap: () => _toggleStep(step['id'] as int),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              child: Icon(
                                isCompleted
                                    ? LucideIcons.checkCircle2
                                    : LucideIcons.circle,
                                color: isCompleted
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? Theme.of(context).colorScheme.primary
                                            .withValues(alpha: 0.1)
                                      : Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest
                                            .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isCompleted
                                        ? Theme.of(context).colorScheme.primary
                                              .withValues(alpha: 0.3)
                                        : Theme.of(context).dividerColor,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      step['title'] as String,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isCompleted
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      step['desc'] as String,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
