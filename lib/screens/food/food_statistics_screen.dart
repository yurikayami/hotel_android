import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/food_analysis_provider.dart';
import '../../providers/auth_provider.dart';

/// Food Statistics Screen showing food analysis trends and insights
///
/// Features:
/// - Weekly trend bar chart with target line
/// - Daily average and highest calorie meal insights
/// - Meal distribution breakdown
class FoodStatisticsScreen extends StatefulWidget {
  const FoodStatisticsScreen({super.key});

  @override
  State<FoodStatisticsScreen> createState() => _FoodStatisticsScreenState();
}

class _FoodStatisticsScreenState extends State<FoodStatisticsScreen> {
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final authProvider = context.read<AuthProvider>();
    final foodProvider = context.read<FoodAnalysisProvider>();
    if (authProvider.user != null) {
      await foodProvider.fetchHistory(
        authProvider.user!.id.toString(),
      );
    }
  }

  /// Vietnamese day abbreviations: T2-CN (Mon-Sun)
  String _getDayLabel(DateTime date) {
    const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return days[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thống kê',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Consumer<FoodAnalysisProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.filteredHistory.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadHistory,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weekly trend chart
                _buildWeeklyChart(context, provider),
                const SizedBox(height: 24),

                // Insights grid
                _buildInsightsGrid(context, provider),
                const SizedBox(height: 24),

                // Meal distribution
                _buildMealDistribution(context, provider),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build weekly trend bar chart with target line
  Widget _buildWeeklyChart(
    BuildContext context,
    FoodAnalysisProvider provider,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final weeklyData = provider.getWeeklyCalories();
    final calorieTarget = provider.calorieTarget;

    // Convert to list for chart
    final chartData = weeklyData.entries
        .map((e) => (date: e.key, calories: e.value))
        .toList();

    // Find max value for scaling
    final maxCalories =
        (chartData.map((e) => e.calories).reduce((a, b) => a > b ? a : b) *
                1.2)
            .ceil()
            .toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xu hướng 7 ngày',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                // Bars
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    chartData.length,
                    (index) {
                      final data = chartData[index];
                      final barHeight = (data.calories / maxCalories) * 140;
                      final isOverTarget = data.calories > calorieTarget;
                      final dayLabel = _getDayLabel(data.date);

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Value label
                          if (barHeight > 0)
                            Text(
                              '${data.calories.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          const SizedBox(height: 4),
                          // Bar
                          Container(
                            width: 20,
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: isOverTarget
                                  ? Colors.orange.shade400
                                  : Colors.green.shade500,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Day label
                          Text(
                            dayLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // Target line
                if (calorieTarget > 0 && calorieTarget < maxCalories)
                  Positioned(
                    bottom: (calorieTarget / maxCalories) * 140 + 8, // 8 for spacing
                    left: 0,
                    right: 0,
                    child: CustomPaint(
                      painter: DashedLinePainter(
                        color: Colors.orange.shade600,
                        dashWidth: 4,
                        dashSpace: 4,
                      ),
                      size: const Size(double.infinity, 1),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Target line indicator
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Mục tiêu: ${calorieTarget.toStringAsFixed(0)} kcal',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green.shade500,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Trong mục tiêu',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.orange.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Vượt mục tiêu',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build insights grid (daily average and highest meal)
  Widget _buildInsightsGrid(
    BuildContext context,
    FoodAnalysisProvider provider,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final avgDaily = provider.getDailyAverage();
    final highestMeal = provider.getHighestCalorieMeal();

    return Row(
      children: [
        // Daily average card
        Expanded(
          child: Container(
            height: 110,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Trung bình/ngày',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${avgDaily.toStringAsFixed(0)} kcal',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Highest calorie meal card
        Expanded(
          child: Container(
            height: 110,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 20,
                      color: Colors.orange.shade400,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Nạp nhiều nhất',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  highestMeal?.foodName ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${highestMeal?.calories.toStringAsFixed(0) ?? '0'} kcal',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange.shade400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build meal distribution chart
  Widget _buildMealDistribution(
    BuildContext context,
    FoodAnalysisProvider provider,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final distribution = provider.getMealDistribution();

    // Filter out zero values
    final nonZeroDistribution =
        distribution.entries.where((e) => e.value > 0).toList();

    if (nonZeroDistribution.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate total
    final total =
        nonZeroDistribution.fold<double>(0, (sum, e) => sum + e.value);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân bổ Calo theo bữa ăn',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: Row(
              children: [
                // Donut chart
                Expanded(
                  flex: 1,
                  child: CustomPaint(
                    painter: DonutChartPainter(
                      data: nonZeroDistribution
                          .map((e) => (
                                color: _getMealColor(e.key),
                                percentage: e.value / total,
                              ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Legend
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: nonZeroDistribution.map((entry) {
                      final mealType = entry.key;
                      final calories = entry.value;
                      final percentage = (calories / total * 100);
                      final mealLabel =
                          _getMealTypeData(mealType)['label'] as String;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _getMealColor(mealType),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '$mealLabel\n${percentage.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get meal type display data
  Map<String, dynamic> _getMealTypeData(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return {'label': 'Sáng', 'icon': Icons.wb_sunny_outlined};
      case 'lunch':
        return {'label': 'Trưa', 'icon': Icons.light_mode_outlined};
      case 'dinner':
        return {'label': 'Tối', 'icon': Icons.dark_mode_outlined};
      case 'snack':
        return {'label': 'Phụ', 'icon': Icons.coffee_outlined};
      default:
        return {'label': mealType, 'icon': Icons.restaurant_outlined};
    }
  }

  /// Get color for meal type in chart
  Color _getMealColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange.shade400;
      case 'lunch':
        return Colors.green.shade500;
      case 'dinner':
        return Colors.blue.shade400;
      case 'snack':
        return Colors.pink.shade400;
      default:
        return Colors.grey.shade500;
    }
  }
}

/// Custom painter for donut chart
class DonutChartPainter extends CustomPainter {
  final List<({Color color, double percentage})> data;

  DonutChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    double startAngle = -3.14159 / 2;
    for (final segment in data) {
      final sweepAngle = segment.percentage * 2 * 3.14159;
      paint.color = segment.color;

      canvas.drawArc(
        Rect.fromCenter(
          center: center,
          width: radius * 2,
          height: radius * 2,
        ),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for dashed line
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  DashedLinePainter({
    required this.color,
    this.dashWidth = 4,
    this.dashSpace = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
