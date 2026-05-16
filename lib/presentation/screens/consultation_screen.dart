import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/profile_service.dart';
import '../../data/reminders_service.dart';

class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({super.key});

  final List<Map<String, dynamic>> _professionals = const [
    {
      "name": "Dr. Sarah Mahfudz, M.Psi",
      "specialty": "Kecemasan & Burnout",
      "rating": 4.9,
      "experience": "10 Tahun",
      "availability": "Tersedia hari ini",
    },
    {
      "name": "Budi Santoso, M.Psi, Psikolog",
      "specialty": "Manajemen Stres & PTSD",
      "rating": 4.8,
      "experience": "8 Tahun",
      "availability": "Besok, 10:00",
    },
    {
      "name": "Rina Wijaya, S.Psi, M.Sc",
      "specialty": "Depresi & Krisis Karir",
      "rating": 5.0,
      "experience": "12 Tahun",
      "availability": "Hari ini, 15:00",
    },
  ];

  void _handleSchedule(BuildContext context, Map<String, dynamic> prof) async {
    await RemindersService.addReminder({
      'title': 'Konsultasi dengan ${prof['name']}',
      'time': prof['availability'],
      'type': 'assessment',
      'actionLabel': 'Mulai Telekonsultasi',
      'actionLink': '/consultation',
    });

    await ProfileService.updateProfile({
      'lastSession': {
        'date': DateTime.now().toIso8601String(),
        'doctor': prof['name'],
      },
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Konsultasi dengan ${prof['name']} berhasil dijadwalkan untuk ${prof['availability']}. Silakan cek Pengingat Cerdas di Dashboard.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildCategories(context),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: _professionals.map((prof) {
                    return SizedBox(
                      width: isWide
                          ? (constraints.maxWidth - 48) / 3
                          : double.infinity,
                      child: _buildProfessionalCard(context, prof),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 48),
            _buildEmergencyCard(context),
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
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Professional Care',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Temukan bantuan mendalam dari psikolog klinis yang terverifikasi dan aman (End-to-End Encryption).',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildCategories(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('Semua Spesialisasi'),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('Burnout Kerja'),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('Keluarga & Relasi'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCard(
    BuildContext context,
    Map<String, dynamic> prof,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  child: const Icon(
                    LucideIcons.user,
                    color: Colors.grey,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prof['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prof['specialty'],
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.star,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${prof['rating']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            LucideIcons.users,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            prof['experience'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.clock, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      prof['availability'],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _handleSchedule(context, prof),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Jadwalkan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final content = [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Butuh Bantuan Segera?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Sesi krisis tersedia 24/7. Seluruh komunikasi Anda dijamin dengan standar kerahasiaan Enterprise (Privacy by Design).',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          if (!isWide) const SizedBox(height: 24),
          if (isWide) const SizedBox(width: 24),
          ElevatedButton(
            onPressed: () => context.go('/safety'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            ),
            child: const Text(
              'Sesi Darurat',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ];

        return Card(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: content,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: content,
                  ),
          ),
        );
      },
    );
  }
}
