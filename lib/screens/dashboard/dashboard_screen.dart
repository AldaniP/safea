import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../services/point_notifier.dart';
import '../../services/roadmap_service.dart';
import '../../models/roadmap_model.dart';
import '../../widgets/reward_animation.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dasbor Anda')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPointsHeader(context),
            const SizedBox(height: 24),
            const Text(
              'Tren Emosi Mingguan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 250, child: _buildTrendGraph()),
            const SizedBox(height: 32),
            const Text(
              'Roadmap Anda',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRoadmapSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsHeader(BuildContext context) {
    return Consumer<PointNotifier>(
      builder: (context, pointNotifier, child) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Poin',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Text(
                      '${pointNotifier.totalPoints}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Level ${pointNotifier.level}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrendGraph() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
                if (value >= 0 && value < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(days[value.toInt()]),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 80),
              FlSpot(1, 75),
              FlSpot(2, 60),
              FlSpot(3, 50),
              FlSpot(4, 55),
              FlSpot(5, 40),
              FlSpot(6, 30), // Stress decreasing
            ],
            isCurved: true,
            color: Colors.blue,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapSection(BuildContext context) {
    return ValueListenableBuilder<Roadmap?>(
      valueListenable: RoadmapService.instance.currentRoadmap,
      builder: (context, roadmap, child) {
        if (roadmap == null) {
          return const Center(
            child: Text(
              'Selesaikan asesmen untuk mendapatkan roadmap khusus Anda.',
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: roadmap.activities.length,
          itemBuilder: (context, index) {
            final activity = roadmap.activities[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  activity.isCompleted
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: activity.isCompleted ? Colors.green : Colors.grey,
                ),
                title: Text(
                  activity.title,
                  style: TextStyle(
                    decoration: activity.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                trailing: Text(
                  '+${activity.pointValue} pts',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: activity.isCompleted
                    ? null
                    : () async {
                        await RoadmapService.instance.completeActivity(
                          activity.id,
                          Provider.of<PointNotifier>(context, listen: false),
                        );
                        if (context.mounted) {
                          RewardAnimation.showReward(
                            context,
                            activity.pointValue,
                          );
                        }
                      },
              ),
            );
          },
        );
      },
    );
  }
}
