import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/analysis_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final List<Map<String, dynamic>> _fallbackData = [
    {'name': 'Senin', 'stress': 65.0, 'anxiety': 40.0, 'mood': 75.0},
    {'name': 'Selasa', 'stress': 70.0, 'anxiety': 45.0, 'mood': 65.0},
    {'name': 'Rabu', 'stress': 85.0, 'anxiety': 60.0, 'mood': 50.0},
    {'name': 'Kamis', 'stress': 55.0, 'anxiety': 30.0, 'mood': 80.0},
    {'name': 'Jumat', 'stress': 45.0, 'anxiety': 20.0, 'mood': 90.0},
    {'name': 'Sabtu', 'stress': 30.0, 'anxiety': 15.0, 'mood': 95.0},
    {'name': 'Minggu', 'stress': 25.0, 'anxiety': 10.0, 'mood': 90.0},
  ];

  List<Map<String, dynamic>> _getChartData(BuildContext context) {
    final history = context.watch<AnalysisService>().getAnalysisHistory();
    if (history.isNotEmpty) {
      final plottedData = history.map((record) {
        double stress = 50.0;
        double anxiety = 50.0;

        final conditions =
            record['analysisResult']['detectedConditions'] as List;
        for (var cond in conditions) {
          final name = (cond['name'] as String).toLowerCase();
          final confidence = (cond['confidence'] as num).toDouble();
          if (name.contains('stres') || name.contains('burnout')) {
            stress = confidence;
          }
          if (name.contains('cemas') || name.contains('anxi')) {
            anxiety = confidence;
          }
        }

        final mood = (100.0 - (stress + anxiety) / 2).clamp(10.0, 100.0);
        final date = DateTime.parse(record['date'] as String);

        return {
          'name': '${date.day}/${date.month}',
          'stress': stress,
          'anxiety': anxiety,
          'mood': mood,
        };
      }).toList();

      return plottedData.length > 7
          ? plottedData.sublist(plottedData.length - 7)
          : plottedData;
    } else {
      return []; // Return empty data to show dynamic state properly as per prompt "replace hardcoded values with data". But if fallback is needed, we can use _fallbackData. Let's use empty or fallback. Actually the prompt says "Replace hardcoded values with data from the analysis... Ensure all features work as intended". Let's use empty to truly reflect dynamic data, or fallback if empty.
    }
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _getChartData(context);
    // If no real data, we can fallback or show empty. Let's use _fallbackData for now if empty to avoid breaking layout, but prompt says "replace hardcoded values". So let's show an empty message if no data.

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            if (chartData.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('Belum ada data analisis. Lakukan asesmen untuk melihat progress.'),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return Row(
                      children: [
                        Expanded(child: _buildLineChart(context, chartData)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildBarChart(context, chartData)),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildLineChart(context, chartData),
                      const SizedBox(height: 24),
                      _buildBarChart(context, chartData),
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
        Text(
          'Progress & Analisis',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pantau perkembangan kesehatan mentalmu dari waktu ke waktu secara komprehensif.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildLineChart(BuildContext context, List<Map<String, dynamic>> chartData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tren Stress & Kecemasan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Semakin rendah semakin baik',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Theme.of(context).dividerColor,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < 0 ||
                              value.toInt() >= chartData.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              chartData[value.toInt()]['name'],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (chartData.length - 1).toDouble() < 0 ? 0 : (chartData.length - 1).toDouble(),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(e.key.toDouble(), e.value['stress']),
                          )
                          .toList(),
                      isCurved: true,
                      color: const Color(0xFFF43F5E), // rose-500
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: chartData
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(e.key.toDouble(), e.value['anxiety']),
                          )
                          .toList(),
                      isCurved: true,
                      color: const Color(0xFFFBBF24), // amber-400
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(const Color(0xFFF43F5E), 'Stres'),
                const SizedBox(width: 16),
                _buildLegendItem(const Color(0xFFFBBF24), 'Kecemasan'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, List<Map<String, dynamic>> chartData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Indeks Mood Pilihan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Semakin tinggi semakin baik',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Theme.of(context).dividerColor,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < 0 ||
                              value.toInt() >= chartData.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              chartData[value.toInt()]['name'],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  maxY: 100,
                  barGroups: chartData.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value['mood'],
                          color: const Color(0xFF2DD4BF), // teal-400
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(const Color(0xFF2DD4BF), 'Mood Harian'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
