import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/profile_service.dart';

class Dass21Screen extends StatefulWidget {
  const Dass21Screen({super.key});

  @override
  State<Dass21Screen> createState() => _Dass21ScreenState();
}

class _Dass21ScreenState extends State<Dass21Screen> {
  String _step = 'intro'; // intro, assessment, result
  int _currentQuestionIdx = 0;
  final Map<int, int> _scores = {};

  final List<Map<String, dynamic>> _questions = [
    {'id': 1, 'type': 'S', 'text': 'Saya merasa sulit untuk menenangkan diri.'},
    {'id': 2, 'type': 'A', 'text': 'Saya menyadari mulut saya terasa kering.'},
    {
      'id': 3,
      'type': 'D',
      'text': 'Saya sama sekali tidak dapat merasakan perasaan positif.',
    },
    {
      'id': 4,
      'type': 'A',
      'text':
          'Saya mengalami kesulitan bernapas (seperti napas cepat atau tersengal-sengal) walaupun tidak melakukan aktivitas fisik.',
    },
    {
      'id': 5,
      'type': 'D',
      'text':
          'Saya merasa kesulitan untuk berinisiatif dalam melakukan sesuatu.',
    },
    {
      'id': 6,
      'type': 'S',
      'text': 'Saya cenderung bereaksi berlebihan terhadap suatu situasi.',
    },
    {
      'id': 7,
      'type': 'A',
      'text': 'Saya sering merasakan gemetar (misalnya, pada tangan).',
    },
    {
      'id': 8,
      'type': 'S',
      'text':
          'Saya merasa banyak menghabiskan energi karena merasa cemas/tegang.',
    },
    {
      'id': 9,
      'type': 'A',
      'text':
          'Saya khawatir akan situasi di mana saya bisa panik dan mempermalukan diri sendiri.',
    },
    {
      'id': 10,
      'type': 'D',
      'text': 'Saya merasa tidak ada hal yang dapat saya harapkan ke depannya.',
    },
    {'id': 11, 'type': 'S', 'text': 'Saya sering merasa gelisah.'},
    {
      'id': 12,
      'type': 'S',
      'text': 'Saya merasa sulit untuk relaks atau bersantai.',
    },
    {'id': 13, 'type': 'D', 'text': 'Saya merasa sedih dan tertekan.'},
    {
      'id': 14,
      'type': 'S',
      'text':
          'Saya tidak dapat toleran terhadap apa pun yang menghalangi saya untuk menyelesaikan tugas.',
    },
    {'id': 15, 'type': 'A', 'text': 'Saya sering merasa hampir panik.'},
    {
      'id': 16,
      'type': 'D',
      'text': 'Saya merasa tidak antusias dengan hal apa pun.',
    },
    {
      'id': 17,
      'type': 'D',
      'text': 'Saya merasa tidak berharga sebagai seorang manusia.',
    },
    {'id': 18, 'type': 'S', 'text': 'Saya merasa sangat mudah tersinggung.'},
    {
      'id': 19,
      'type': 'A',
      'text':
          'Saya menyadari gangguan detak jantung walaupun tidak sedang beraktivitas fisik (misalnya, detak jantung semakin cepat).',
    },
    {
      'id': 20,
      'type': 'A',
      'text': 'Saya merasa takut tanpa alasan yang jelas.',
    },
    {
      'id': 21,
      'type': 'D',
      'text': 'Saya merasa bahwa hidup itu tidak berarti.',
    },
  ];

  final List<Map<String, dynamic>> _answers = [
    {
      'value': 0,
      'label': '0 - Tidak Pernah',
      'desc': 'Tidak berlaku pada saya sama sekali',
    },
    {
      'value': 1,
      'label': '1 - Kadang-kadang',
      'desc': 'Berlaku pada saya sampai tingkat tertentu',
    },
    {'value': 2, 'label': '2 - Sering', 'desc': 'Sering berlaku pada saya'},
    {
      'value': 3,
      'label': '3 - Hampir Selalu',
      'desc': 'Sangat sering berlaku pada saya',
    },
  ];

  Map<String, dynamic> _getSeverity(int score, String type) {
    if (type == 'D') {
      if (score <= 9)
        return {
          'label': 'Normal',
          'color': Colors.teal,
          'bg': Colors.teal.withValues(alpha: 0.1),
        };
      if (score <= 13)
        return {
          'label': 'Ringan',
          'color': Colors.blue,
          'bg': Colors.blue.withValues(alpha: 0.1),
        };
      if (score <= 20)
        return {
          'label': 'Sedang',
          'color': Colors.amber,
          'bg': Colors.amber.withValues(alpha: 0.1),
        };
      if (score <= 27)
        return {
          'label': 'Parah',
          'color': Colors.orange,
          'bg': Colors.orange.withValues(alpha: 0.1),
        };
      return {
        'label': 'Sangat Parah',
        'color': Colors.red,
        'bg': Colors.red.withValues(alpha: 0.1),
      };
    }
    if (type == 'A') {
      if (score <= 7)
        return {
          'label': 'Normal',
          'color': Colors.teal,
          'bg': Colors.teal.withValues(alpha: 0.1),
        };
      if (score <= 9)
        return {
          'label': 'Ringan',
          'color': Colors.blue,
          'bg': Colors.blue.withValues(alpha: 0.1),
        };
      if (score <= 14)
        return {
          'label': 'Sedang',
          'color': Colors.amber,
          'bg': Colors.amber.withValues(alpha: 0.1),
        };
      if (score <= 19)
        return {
          'label': 'Parah',
          'color': Colors.orange,
          'bg': Colors.orange.withValues(alpha: 0.1),
        };
      return {
        'label': 'Sangat Parah',
        'color': Colors.red,
        'bg': Colors.red.withValues(alpha: 0.1),
      };
    }
    // Stress
    if (score <= 14)
      return {
        'label': 'Normal',
        'color': Colors.teal,
        'bg': Colors.teal.withValues(alpha: 0.1),
      };
    if (score <= 18)
      return {
        'label': 'Ringan',
        'color': Colors.blue,
        'bg': Colors.blue.withValues(alpha: 0.1),
      };
    if (score <= 25)
      return {
        'label': 'Sedang',
        'color': Colors.amber,
        'bg': Colors.amber.withValues(alpha: 0.1),
      };
    if (score <= 33)
      return {
        'label': 'Parah',
        'color': Colors.orange,
        'bg': Colors.orange.withValues(alpha: 0.1),
      };
    return {
      'label': 'Sangat Parah',
      'color': Colors.red,
      'bg': Colors.red.withValues(alpha: 0.1),
    };
  }

  void _handleStart() {
    setState(() {
      _scores.clear();
      _currentQuestionIdx = 0;
      _step = 'assessment';
    });
  }

  Map<String, dynamic> _calculateResults() {
    int d = 0, a = 0, s = 0;
    _scores.forEach((idx, val) {
      final q = _questions[idx];
      if (q['type'] == 'D') d += val;
      if (q['type'] == 'A') a += val;
      if (q['type'] == 'S') s += val;
    });
    final finalDepression = d * 2;
    final finalAnxiety = a * 2;
    final finalStress = s * 2;

    final totalScore = finalDepression + finalAnxiety + finalStress;
    final maxScore = 126;
    final wellbeing = (((maxScore - totalScore) / maxScore) * 100).round();

    return {
      'depression': finalDepression,
      'anxiety': finalAnxiety,
      'stress': finalStress,
      'wellbeing': wellbeing,
    };
  }

  void _handleFinish() async {
    final res = _calculateResults();
    await ProfileService.addPoints(100);
    await ProfileService.updateProfile({'lastScore': res['wellbeing']});
    setState(() {
      _step = 'result';
    });
  }

  void _handleAnswer(int value) {
    setState(() {
      _scores[_currentQuestionIdx] = value;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentQuestionIdx < _questions.length - 1) {
        setState(() {
          _currentQuestionIdx++;
        });
      } else {
        _handleFinish();
      }
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
            if (_step == 'intro') _buildIntro(context),
            if (_step == 'assessment') _buildAssessment(context),
            if (_step == 'result') _buildResult(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(
              0xFF4F46E5,
            ).withValues(alpha: 0.1), // indigo-500/10
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF6366F1).withValues(alpha: 0.2),
            ), // indigo-400/20
          ),
          child: const Text(
            'Clinical Tool',
            style: TextStyle(
              color: Color(0xFF818CF8),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ), // indigo-400
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Asesmen DASS-21',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Alat skrining mandiri untuk mengukur tingkat Depresi, Kecemasan, dan Stres.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildIntro(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  LucideIcons.clipboardList,
                  color: Color(0xFF818CF8),
                ), // indigo-400
                SizedBox(width: 8),
                Text(
                  'Panduan Pengisian',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Kuesioner ini terdiri dari 21 pernyataan. Harap baca setiap pernyataan dan pilih jawaban yang paling sesuai dengan apa yang Anda alami selama SATU MINGGU terakhir. Tidak ada jawaban benar atau salah, jawablah sejujur mungkin.',
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilihan Jawaban:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._answers.map((a) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 150,
                            child: Text(
                              a['label'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '- ${a['desc']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _handleStart,
                icon: const Icon(LucideIcons.arrowRight),
                label: const Text(
                  'Mulai Asesmen',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5), // indigo-600
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessment(BuildContext context) {
    final progress = (_currentQuestionIdx + 1) / _questions.length;
    final question = _questions[_currentQuestionIdx];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PERTANYAAN ${_currentQuestionIdx + 1} DARI ${_questions.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF818CF8),
                  ),
                ), // indigo-400
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              color: const Color(0xFF6366F1), // indigo-500
              borderRadius: BorderRadius.circular(8),
              minHeight: 8,
            ),
            const SizedBox(height: 48),
            Text(
              '"${question['text']}"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _answers.map((ans) {
                    final isSelected =
                        _scores[_currentQuestionIdx] == ans['value'];
                    return SizedBox(
                      width: isWide
                          ? (constraints.maxWidth - 16) / 2
                          : double.infinity,
                      child: InkWell(
                        onTap: () => _handleAnswer(ans['value'] as int),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF4F46E5).withValues(alpha: 0.2)
                                : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF6366F1)
                                  : Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ans['label'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ans['desc'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white70
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 48),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _currentQuestionIdx > 0
                      ? () {
                          setState(() {
                            _currentQuestionIdx--;
                          });
                        }
                      : null,
                  icon: const Icon(LucideIcons.arrowLeft),
                  label: const Text('Sebelumnya'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final result = _calculateResults();
    final data = [
      {
        'title': 'Depresi',
        'score': result['depression'],
        'type': 'D',
        'icon': LucideIcons.alertTriangle,
        'desc': 'Kehilangan minat, rasa sedih, pesimisme',
      },
      {
        'title': 'Kecemasan',
        'score': result['anxiety'],
        'type': 'A',
        'icon': LucideIcons.activity,
        'desc': 'Sistem saraf aktif, panik, efek fisik',
      },
      {
        'title': 'Stres',
        'score': result['stress'],
        'type': 'S',
        'icon': LucideIcons.wind,
        'desc': 'Tegang, sulit relaks, mudah marah',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hasil Asesmen Anda',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            return Wrap(
              spacing: 24,
              runSpacing: 24,
              children: data.map((item) {
                final severity = _getSeverity(
                  item['score'] as int,
                  item['type'] as String,
                );
                return SizedBox(
                  width: isWide
                      ? (constraints.maxWidth - 48) / 3
                      : double.infinity,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: severity['bg'] as Color,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: severity['color'] as Color,
                                ),
                              ),
                              Text(
                                '${item['score']}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: severity['color'] as Color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item['title'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['desc'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: severity['bg'] as Color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Status: ${severity['label']}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: severity['color'] as Color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 32),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final content = [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Interpretasi Hasil',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Asesmen DASS-21 bukanlah alat diagnostik klinis tunggal. Jika Anda mencetak skor Sedang, Parah, atau Sangat Parah pada salah satu skala, disarankan untuk menjadwalkan konsultasi dengan ahli.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (!isWide) const SizedBox(height: 16),
                  if (isWide) const SizedBox(width: 24),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _handleStart,
                        icon: const Icon(LucideIcons.refreshCw, size: 16),
                        label: const Text('Ulangi'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => context.go('/consultation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                        ), // indigo-600
                        child: const Text('Cari Bantuan Ahli'),
                      ),
                    ],
                  ),
                ];
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: content,
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: content,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
