import 'package:provider/provider.dart';
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

  void _toggleStep(int id) async {
    await context.read<RoadmapService>().toggleRoadmapStep(id);
  }

  @override
  Widget build(BuildContext context) {
    final roadmapSteps = context.watch<RoadmapService>().getRoadmap();

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
                      Expanded(flex: 8, child: _buildRightColumn(context, roadmapSteps)),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildLeftColumn(context),
                    const SizedBox(height: 32),
                    _buildRightColumn(context, roadmapSteps),
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
          'Ruang tenangmu untuk menemukan kembali fokus dan kedamaian.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildLeftColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActionCard(
          context,
          title: 'Latihan Pernapasan 4-7-8',
          desc: 'Turunkan detak jantung dan kurangi kecemasan instan.',
          icon: LucideIcons.wind,
          color: const Color(0xFF818CF8),
          onTap: () => context.go('/calm'),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          context,
          title: 'Grounding 5-4-3-2-1',
          desc: 'Tarik kembali fokusmu ke masa kini saat merasa panik.',
          icon: LucideIcons.anchor,
          color: const Color(0xFF34D399),
          onTap: () {},
        ),
        const SizedBox(height: 32),
        const Text(
          'Afirmasi Harian',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ..._affirmations.map((a) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(a['icon'] as IconData, color: Colors.amber),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        a['text'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRightColumn(BuildContext context, List<Map<String, dynamic>> roadmapSteps) {
    final completedCount = roadmapSteps.where((s) => s['completed'] as bool).length;
    final totalSteps = roadmapSteps.length;
    final progress = totalSteps > 0 ? completedCount / totalSteps : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Roadmap Pemulihan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$completedCount / $totalSteps Selesai',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 24),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: roadmapSteps.length,
                  separatorBuilder: (context, index) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final step = roadmapSteps[index];
                    final isCompleted = step['completed'] as bool;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => _toggleStep(step['id'] as int),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isCompleted
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                                width: 2,
                              ),
                              color: isCompleted
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                            ),
                            child: isCompleted
                                ? const Icon(
                                    Icons.check,
                                    size: 20,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['title'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted ? Colors.grey : Colors.white,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                step['desc'] as String,
                                style: TextStyle(
                                  color: isCompleted ? Colors.grey : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      desc,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
