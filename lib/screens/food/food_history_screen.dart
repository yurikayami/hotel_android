import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/prediction_history.dart';
import '../../utils/image_url_helper.dart';
import '../../providers/food_analysis_provider.dart';
import '../../providers/auth_provider.dart';
import 'food_result_screen.dart';
import 'food_statistics_screen.dart';
import '../profile/edit_profile_screen.dart';

/// Food History Screen displaying user's food intake history
class FoodHistoryScreen extends StatefulWidget {
  const FoodHistoryScreen({super.key});

  @override
  State<FoodHistoryScreen> createState() => _FoodHistoryScreenState();
}

class _FoodHistoryScreenState extends State<FoodHistoryScreen> {
  String _selectedMealType = 'all'; // all, breakfast, lunch, dinner, snack

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final authProvider = context.read<AuthProvider>();
    final foodProvider = context.read<FoodAnalysisProvider>();
    if (authProvider.user != null) {
      await foodProvider.fetchHistory(authProvider.user!.id.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lịch sử ăn uống',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, size: 24),
            tooltip: 'Xem thống kê',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FoodStatisticsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<FoodAnalysisProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.filteredHistory.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          return CustomScrollView(
            slivers: [
              // Summary card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildSummaryCard(context, provider),
                ),
              ),

              // Meal type filters
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildMealTypeFilters(colorScheme),
                ),
              ),

              // History list
              _buildHistoryList(context, provider),
            ],
          );
        },
      ),
    );
  }

  /// Build meal type filter chips
  Widget _buildMealTypeFilters(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loại bữa ăn',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildMealFilterChip(
                'Tất cả',
                _selectedMealType == 'all',
                colorScheme,
                onTap: () => setState(() => _selectedMealType = 'all'),
              ),
              const SizedBox(width: 8),
              _buildMealFilterChip(
                'Bữa sáng',
                _selectedMealType == 'breakfast',
                colorScheme,
                onTap: () => setState(() => _selectedMealType = 'breakfast'),
              ),
              const SizedBox(width: 8),
              _buildMealFilterChip(
                'Bữa trưa',
                _selectedMealType == 'lunch',
                colorScheme,
                onTap: () => setState(() => _selectedMealType = 'lunch'),
              ),
              const SizedBox(width: 8),
              _buildMealFilterChip(
                'Bữa tối',
                _selectedMealType == 'dinner',
                colorScheme,
                onTap: () => setState(() => _selectedMealType = 'dinner'),
              ),
              const SizedBox(width: 8),
              _buildMealFilterChip(
                'Bữa ăn nhẹ',
                _selectedMealType == 'snack',
                colorScheme,
                onTap: () => setState(() => _selectedMealType = 'snack'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Build meal filter chip
  Widget _buildMealFilterChip(
    String label,
    bool isSelected,
    ColorScheme colorScheme, {
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.primary,
      side: BorderSide(
        color: isSelected
            ? colorScheme.primary
            : colorScheme.outline.withValues(alpha: 0.3),
        width: 1.5,
      ),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  /// Build history list sliver
  Widget _buildHistoryList(
    BuildContext context,
    FoodAnalysisProvider provider,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final allHistory = provider.filteredHistory;

    // Filter by meal type
    final history = _selectedMealType == 'all'
        ? allHistory
        : allHistory
            .where((item) =>
                item.mealType?.toLowerCase() == _selectedMealType)
            .toList();

    if (history.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 48,
                  color: colorScheme.outlineVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có dữ liệu',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Group by date
    final grouped = _groupByDate(history);
    final dateKeys = grouped.keys.toList();

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final dateKey = dateKeys[index];
          final items = grouped[dateKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  dateKey,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),

              // Items for this date
              ...items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildHistoryCard(context, item),
                );
              }),

              const SizedBox(height: 8),
            ],
          );
        }, childCount: dateKeys.length),
      ),
    );
  }

  /// Group history items by date
  Map<String, List<PredictionHistory>> _groupByDate(
    List<PredictionHistory> items,
  ) {
    final grouped = <String, List<PredictionHistory>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final item in items) {
      final itemDate = DateTime(
        item.createdAt.year,
        item.createdAt.month,
        item.createdAt.day,
      );

      String dateKey;
      if (itemDate == today) {
        dateKey = 'Hôm nay';
      } else if (itemDate == yesterday) {
        dateKey = 'Hôm qua';
      } else {
        dateKey = DateFormat('dd/MM/yyyy').format(item.createdAt);
      }

      grouped.putIfAbsent(dateKey, () => []).add(item);
    }

    // Sort groups with today first
    final sorted = <String, List<PredictionHistory>>{};
    if (grouped.containsKey('Hôm nay')) {
      sorted['Hôm nay'] = grouped['Hôm nay']!;
    }
    if (grouped.containsKey('Hôm qua')) {
      sorted['Hôm qua'] = grouped['Hôm qua']!;
    }

    final otherKeys = grouped.keys
        .where((k) => k != 'Hôm nay' && k != 'Hôm qua')
        .toList();
    otherKeys.sort((a, b) {
      final dateA = DateFormat('dd/MM/yyyy').parse(a);
      final dateB = DateFormat('dd/MM/yyyy').parse(b);
      return dateB.compareTo(dateA); // Most recent first
    });

    for (final key in otherKeys) {
      sorted[key] = grouped[key]!;
    }

    return sorted;
  }

  /// Build today's summary card with progress bar
  Widget _buildSummaryCard(
    BuildContext context,
    FoodAnalysisProvider provider,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final todayCalories = provider.getTodayCalories();
    final calorieTarget = provider.calorieTarget;
    final isOverTarget = todayCalories > calorieTarget;
    final percentage = (todayCalories / calorieTarget).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOverTarget
              ? [Colors.orange.shade400, Colors.orange.shade600]
              : [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isOverTarget ? Colors.orange : Colors.green)
                .withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mục tiêu hôm nay',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                iconSize: 20,
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Calorie display
          Text(
            '${todayCalories.toStringAsFixed(0)} / ${calorieTarget.toStringAsFixed(0)} kcal',
            style: textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Percentage and remaining text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(percentage * 100).toStringAsFixed(0)}% của mục tiêu',
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Text(
                isOverTarget
                    ? '+${(todayCalories - calorieTarget).toStringAsFixed(0)} kcal'
                    : 'Còn ${(calorieTarget - todayCalories).toStringAsFixed(0)} kcal',
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build history card - redesigned UI
  Widget _buildHistoryCard(
    BuildContext context,
    PredictionHistory item,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  FoodResultScreen(analysis: item, imagePath: item.imagePath),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Food image
              Hero(
                tag: 'food_${item.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: colorScheme.surfaceContainerHighest,
                    child: item.imagePath.isNotEmpty
                        ? Image.network(
                            ImageUrlHelper.formatImageUrl(item.imagePath),
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.restaurant,
                                size: 40,
                                color: colorScheme.onSurfaceVariant,
                              );
                            },
                          )
                        : Icon(
                            Icons.restaurant,
                            size: 40,
                            color: colorScheme.onSurfaceVariant,
                          ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Food info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food name
                    Text(
                      item.foodName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Meal type and date
                    Row(
                      children: [
                        _buildMealTypeBadge(item.mealType, colorScheme),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            DateFormat(
                              'dd/MM/yy • HH:mm',
                            ).format(item.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Calories with dynamic color
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: _getCalorieColor(item.calories),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.calories.toStringAsFixed(0)} kcal',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _getCalorieColor(item.calories),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete button
              IconButton(
                icon: Icon(Icons.delete_outline, color: colorScheme.error),
                onPressed: () => _confirmDelete(context, item),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get dynamic color for calories
  Color _getCalorieColor(double calories) {
    if (calories < 400) return Colors.green;
    if (calories < 700) return Colors.orange;
    return Colors.red;
  }

  /// Build meal type badge
  Widget _buildMealTypeBadge(String? mealType, ColorScheme colorScheme) {
    final meal = _getMealTypeData(mealType ?? 'lunch');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            meal['icon'] as IconData,
            size: 12,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            meal['label'] as String,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  /// Confirm delete dialog
  void _confirmDelete(BuildContext context, PredictionHistory item) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa bản ghi?'),
        content: Text('Bạn có chắc chắn muốn xóa "${item.foodName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              final authProvider = context.read<AuthProvider>();
              final foodProvider = context.read<FoodAnalysisProvider>();

              if (authProvider.user != null) {
                try {
                  await foodProvider.deleteAnalysis(item.id);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã xóa thành công')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: $e'),
                        backgroundColor: colorScheme.error,
                      ),
                    );
                  }
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  /// Get meal type display data
  Map<String, dynamic> _getMealTypeData(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return {'label': 'Sáng', 'icon': Icons.wb_sunny};
      case 'lunch':
        return {'label': 'Trưa', 'icon': Icons.light_mode};
      case 'dinner':
        return {'label': 'Tối', 'icon': Icons.dark_mode};
      case 'snack':
        return {'label': 'Phụ', 'icon': Icons.coffee};
      default:
        return {'label': mealType, 'icon': Icons.restaurant};
    }
  }
}
