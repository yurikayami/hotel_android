import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/food_analysis_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/prediction_history.dart';
import '../../utils/image_url_helper.dart';
import 'food_result_screen.dart';

/// Food History Screen showing all past food analyses
class FoodHistoryScreen extends StatefulWidget {
  const FoodHistoryScreen({super.key});

  @override
  State<FoodHistoryScreen> createState() => _FoodHistoryScreenState();
}

class _FoodHistoryScreenState extends State<FoodHistoryScreen> {
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            pinned: true,
            backgroundColor: colorScheme.surface,
            title: Text(
              'Lịch sử ăn uống',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () {
                  // TODO: Show date picker
                },
              ),
            ],
          ),

          // Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildFilters(colorScheme),
            ),
          ),

          // History list
          Consumer<FoodAnalysisProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (provider.errorMessage != null) {
                return SliverFillRemaining(
                  child: Center(
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
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.tonal(
                          onPressed: _loadHistory,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final items = provider.filteredHistory;

              if (items.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có lịch sử',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hãy bắt đầu phân tích món ăn của bạn',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildHistoryCard(item, colorScheme, provider),
                    );
                  }, childCount: items.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build filters section
  Widget _buildFilters(ColorScheme colorScheme) {
    return Consumer<FoodAnalysisProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time filter
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Thời gian',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    'Tất cả',
                    provider.selectedTimeFilter == 'all',
                    colorScheme,
                    onTap: () => provider.setTimeFilter('all'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Hôm nay',
                    provider.selectedTimeFilter == 'today',
                    colorScheme,
                    onTap: () => provider.setTimeFilter('today'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Tuần này',
                    provider.selectedTimeFilter == 'week',
                    colorScheme,
                    onTap: () => provider.setTimeFilter('week'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Tháng này',
                    provider.selectedTimeFilter == 'month',
                    colorScheme,
                    onTap: () => provider.setTimeFilter('month'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Meal type filter
            Row(
              children: [
                Icon(
                  Icons.restaurant,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Loại bữa ăn',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    'Tất cả',
                    provider.selectedMealFilter == 'all',
                    colorScheme,
                    onTap: () => provider.setMealFilter('all'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Sáng',
                    provider.selectedMealFilter == 'breakfast',
                    colorScheme,
                    onTap: () => provider.setMealFilter('breakfast'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Trưa',
                    provider.selectedMealFilter == 'lunch',
                    colorScheme,
                    onTap: () => provider.setMealFilter('lunch'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Tối',
                    provider.selectedMealFilter == 'dinner',
                    colorScheme,
                    onTap: () => provider.setMealFilter('dinner'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Phụ',
                    provider.selectedMealFilter == 'snack',
                    colorScheme,
                    onTap: () => provider.setMealFilter('snack'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build filter chip
  Widget _buildFilterChip(
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

  /// Build history card
  Widget _buildHistoryCard(
    PredictionHistory item,
    ColorScheme colorScheme,
    FoodAnalysisProvider provider,
  ) {
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
                    color: colorScheme.surfaceContainer,
                    child: item.imagePath.isNotEmpty
                        ? Image.network(
                            ImageUrlHelper.formatImageUrl(item.imagePath),
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
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
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Calories
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.calories.toStringAsFixed(0)} kcal',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
                onPressed: () => _confirmDelete(item, provider),
              ),
            ],
          ),
        ),
      ),
    );
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

  /// Get meal type data
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

  /// Confirm delete dialog
  void _confirmDelete(PredictionHistory item, FoodAnalysisProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Xóa bản ghi?'),
          content: Text('Bạn có chắc chắn muốn xóa "${item.foodName}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);

                final authProvider = context.read<AuthProvider>();
                if (authProvider.user != null) {
                  try {
                    await provider.deleteAnalysis(item.id);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã xóa thành công')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
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
        );
      },
    );
  }
}
