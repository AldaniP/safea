import 'package:flutter/material.dart';

class AnalysisSummaryScreen extends StatelessWidget {
  final Map<String, int> scores;
  final String aiSummary;

  const AnalysisSummaryScreen({
    super.key,
    required this.scores,
    required this.aiSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ringkasan Analisis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kondisi Emosionalmu',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildScoreCard('Depresi', scores['D'] ?? 0, Colors.blue),
            _buildScoreCard('Kecemasan', scores['A'] ?? 0, Colors.orange),
            _buildScoreCard('Stres', scores['S'] ?? 0, Colors.red),
            const SizedBox(height: 30),
            const Text(
              'Wawasan AI',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              aiSummary,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Navigate to Roadmap...
              },
              child: const Center(child: Text('Lihat Roadmap')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String label, int score, Color color) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(label),
        trailing: Text(
          score.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
