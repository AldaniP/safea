import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BusinessScreen extends StatelessWidget {
  const BusinessScreen({super.key});

  final List<Map<String, dynamic>> _corporateData = const [
    {'month': 'Jan', 'wl_balance': 65.0, 'burnout_risk': 40.0},
    {'month': 'Feb', 'wl_balance': 70.0, 'burnout_risk': 35.0},
    {'month': 'Mar', 'wl_balance': 60.0, 'burnout_risk': 50.0},
    {'month': 'Apr', 'wl_balance': 75.0, 'burnout_risk': 30.0},
    {'month': 'Mei', 'wl_balance': 80.0, 'burnout_risk': 25.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildSummaryCards(context),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 1000) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildChart(context)),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildRecommendations(context)),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildChart(context),
                    const SizedBox(height: 24),
                    _buildRecommendations(context),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final content = [
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
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: const Text(
                    'ENTERPRISE VIEW',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Dashboard SDM & Kesejahteraan Tim',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Laporan analitik agregat terenkripsi (tanpa mengekspos data individu).',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          if (!isWide) const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Unduh Laporan PDF'),
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
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        final width = isWide
            ? (constraints.maxWidth - 3 * 24) / 4
            : double.infinity;

        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            _buildMetricCard(
              context,
              width,
              'TOTAL KARYAWAN AKTIF',
              '1,250',
              LucideIcons.users,
              '+12% Partisipasi',
              LucideIcons.arrowUpRight,
              const Color(0xFF2DD4BF),
            ),
            _buildMetricCard(
              context,
              width,
              'CFI (CORPORATE FATIGUE INDEX)',
              'Normal',
              LucideIcons.activity,
              'Menurun 5 Poin',
              LucideIcons.arrowDownRight,
              const Color(0xFF2DD4BF),
              iconColor: const Color(0xFF14B8A6),
            ),
            _buildMetricCard(
              context,
              width,
              'WORK-LIFE BALANCE SCORE',
              '80/100',
              null,
              'Kondisi Sangat Baik',
              LucideIcons.arrowUpRight,
              const Color(0xFF2DD4BF),
            ),
            _buildMetricCard(
              context,
              width,
              'DIVISI RISIKO BURNOUT TERTINGGI',
              'Tim Engineering',
              LucideIcons.briefcase,
              'Perlu intervensi & penyesuaian workload',
              null,
              Colors.grey,
              valueColor: Colors.white,
              iconColor: const Color(0xFFF87171),
              borderColor: const Color(0xFFEF4444).withValues(alpha: 0.5),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    double width,
    String title,
    String value,
    IconData? valueIcon,
    String subValue,
    IconData? subIcon,
    Color subColor, {
    Color valueColor = Colors.white,
    Color? iconColor,
    Color? borderColor,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: borderColor ?? Theme.of(context).dividerColor,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: borderColor != null
                      ? const Color(0xFFF87171)
                      : Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (valueIcon != null && borderColor != null) ...[
                    Icon(valueIcon, color: iconColor, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: iconColor != null && borderColor == null
                          ? iconColor
                          : valueColor,
                    ),
                  ),
                  if (valueIcon != null && borderColor == null) ...[
                    const SizedBox(width: 8),
                    Icon(valueIcon, color: Colors.grey, size: 20),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (subIcon != null) ...[
                    Icon(subIcon, color: subColor, size: 16),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      subValue,
                      style: TextStyle(
                        color: subColor,
                        fontSize: 12,
                        fontWeight: subIcon != null
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tren Kesejahteraan vs Risiko Burnout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Agregat data anonim dari check-in AI seluruh tim',
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
                              value.toInt() >= _corporateData.length)
                            return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _corporateData[value.toInt()]['month'],
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
                  maxX: (_corporateData.length - 1).toDouble(),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _corporateData
                          .asMap()
                          .entries
                          .map(
                            (e) =>
                                FlSpot(e.key.toDouble(), e.value['wl_balance']),
                          )
                          .toList(),
                      isCurved: true,
                      color: const Color(0xFF2DD4BF), // teal-400
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF2DD4BF).withValues(alpha: 0.2),
                      ),
                    ),
                    LineChartBarData(
                      spots: _corporateData
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              e.value['burnout_risk'],
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: const Color(0xFFF43F5E), // rose-500
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFFF43F5E).withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(const Color(0xFF2DD4BF), 'Work-Life Balance'),
                const SizedBox(width: 16),
                _buildLegendItem(const Color(0xFFF43F5E), 'Risiko Burnout'),
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

  Widget _buildRecommendations(BuildContext context) {
    return Card(
      color: const Color(0xFF4F46E5), // indigo-600
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rekomendasi Skalabel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Action Plan Berdasarkan AI',
              style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 12),
            ), // indigo-200
            const SizedBox(height: 24),
            _buildRecItem(
              context,
              LucideIcons.activity,
              'Workshop Manajemen Waktu',
              '30% tim melaporkan stres dari tumpukan tugas.',
              'Buat Campaign Intervensi',
            ),
            const SizedBox(height: 16),
            _buildRecItem(
              context,
              LucideIcons.users,
              'Group Counseling',
              'Tim Engineering membutuhkan pendampingan segera.',
              'Hubungi Provider',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecItem(
    BuildContext context,
    IconData icon,
    String title,
    String desc,
    String btnLabel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4338CA).withValues(alpha: 0.5), // indigo-700/50
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6366F1)), // indigo-500
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(color: Color(0xFFE0E7FF), fontSize: 12),
          ), // indigo-100
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4F46E5), // indigo-600
              minimumSize: const Size(double.infinity, 36),
            ),
            child: Text(btnLabel),
          ),
        ],
      ),
    );
  }
}
