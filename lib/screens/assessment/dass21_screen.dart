import 'package:flutter/material.dart';
import '../../services/dass21_scorer.dart';

class Dass21Screen extends StatefulWidget {
  const Dass21Screen({super.key});

  @override
  State<Dass21Screen> createState() => _Dass21ScreenState();
}

class _Dass21ScreenState extends State<Dass21Screen> {
  final Map<int, int> _responses = {};

  // DASS-21 Questions (Simplified for demo)
  final List<String> _questions = [
    'Saya merasa sulit untuk menenangkan diri',
    'Saya menyadari mulut saya terasa kering',
    'Saya sama sekali tidak dapat merasakan perasaan positif',
    'Saya mengalami kesulitan bernapas (misalnya, napas cepat tersengal-sengal)',
    'Saya merasa sulit untuk berinisiatif melakukan sesuatu',
    'Saya cenderung bereaksi berlebihan terhadap suatu situasi',
    'Saya pernah mengalami gemetar (misalnya, pada tangan)',
    'Saya merasa telah menghabiskan banyak energi gugup',
    'Saya khawatir akan situasi yang membuat saya panik dan mempermalukan diri sendiri',
    'Saya merasa tidak ada hal yang bisa saya harapkan',
    'Saya mendapati diri saya mudah gelisah',
    'Saya merasa sulit untuk bersantai',
    'Saya merasa sedih dan tertekan',
    'Saya tidak toleran terhadap apa pun yang menghalangi saya untuk melanjutkan apa yang sedang saya lakukan',
    'Saya merasa hampir panik',
    'Saya tidak mampu menjadi antusias akan apa pun',
    'Saya merasa tidak berharga sebagai seorang manusia',
    'Saya merasa bahwa saya mudah tersinggung',
    'Saya menyadari detak jantung saya meski tidak melakukan aktivitas fisik',
    'Saya merasa takut tanpa alasan yang jelas',
    'Saya merasa bahwa hidup ini tidak bermakna',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asesmen DASS-21')),
      body: ListView.builder(
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ${_questions[index]}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(4, (score) {
                      return Column(
                        children: [
                          Radio<int>(
                            value: score,
                            groupValue: _responses[index + 1],
                            onChanged: (val) {
                              setState(() {
                                _responses[index + 1] = val!;
                              });
                            },
                          ),
                          Text(score.toString()),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _responses.length == 21
            ? () {
                // Calculate scores and navigate
                final d = Dass21Scorer.calculateSubscaleScore(
                  _responses,
                  Dass21Scorer.depressionItems,
                );
                final a = Dass21Scorer.calculateSubscaleScore(
                  _responses,
                  Dass21Scorer.anxietyItems,
                );
                final s = Dass21Scorer.calculateSubscaleScore(
                  _responses,
                  Dass21Scorer.stressItems,
                );

                debugPrint('Scores: D:$d, A:$a, S:$s');
                // Navigate to Audio Recording...
              }
            : null,
        label: const Text('Selanjutnya: Rekam Audio'),
        icon: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
