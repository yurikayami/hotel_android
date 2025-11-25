import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/prediction_history.dart';
import '../../utils/image_url_helper.dart';

/// Food Result Screen showing analysis results with nutrition info
class FoodResultScreen extends StatelessWidget {
  final PredictionHistory analysis;
  final String imagePath;

  const FoodResultScreen({
    required this.analysis,
    required this.imagePath,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image header
          SliverAppBar(
            expandedHeight: size.height * 0.24,
            pinned: true,
            backgroundColor: colorScheme.surface,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                color: colorScheme.surface.withValues(alpha: 0.95),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  customBorder: const CircleBorder(),
                  child: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  color: colorScheme.surface.withValues(alpha: 0.95),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () {
                      // TODO: Share functionality
                    },
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(
                        Icons.share,
                        color: colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  color: colorScheme.surface.withValues(alpha: 0.95),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () {
                      _showMoreOptions(context);
                    },
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(
                        Icons.more_horiz,
                        color: colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'food_${analysis.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image - support both local file and network URL
                    _buildImage(imagePath),

                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header info
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Meal type badge and date
                        Row(
                          children: [
                            _buildMealTypeBadge(analysis.mealType, colorScheme),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat(
                                'dd/MM/yyyy • HH:mm',
                              ).format(analysis.createdAt),
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Food name
                        Text(
                          analysis.foodName,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Confidence indicator
                        _buildConfidenceIndicator(
                          analysis.confidence,
                          colorScheme,
                        ),
                      ],
                    ),
                  ),

                  // Nutrition grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _buildNutritionGrid(colorScheme),
                  ),

                  const SizedBox(height: 24),

                  // AI Insights
                  if (analysis.advice != null && analysis.advice!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: _buildAiInsights(
                        analysis.advice!,
                        colorScheme,
                        textTheme,
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Detailed nutritional info button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: FilledButton.tonal(
                      onPressed: () {
                        _showDetailedNutrition(context);
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Xem chi tiết thành phần'),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build image widget - support both local and network
  Widget _buildImage(String path) {
    // Check if it's a network URL
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        ImageUrlHelper.formatImageUrl(path),
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.restaurant, size: 64));
        },
      );
    } else {
      // Local file
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.restaurant, size: 64));
        },
      );
    }
  }

  /// Build meal type badge
  Widget _buildMealTypeBadge(String? mealType, ColorScheme colorScheme) {
    final mealData = _getMealTypeData(mealType ?? 'lunch');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            mealData['icon'] as IconData,
            size: 14,
            color: colorScheme.onPrimary,
          ),
          const SizedBox(width: 6),
          Text(
            mealData['label'] as String,
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build confidence indicator
  Widget _buildConfidenceIndicator(double confidence, ColorScheme colorScheme) {
    final color = _getConfidenceColor(confidence);

    return Row(
      children: [
        Icon(Icons.verified, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          'Độ chính xác: ${confidence.toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Build nutrition grid
  Widget _buildNutritionGrid(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _buildNutritionCard(
            label: 'Calories',
            value: analysis.calories.toStringAsFixed(0),
            unit: 'kcal',
            icon: Icons.local_fire_department,
            color: Colors.orange,
            colorScheme: colorScheme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNutritionCard(
            label: 'Protein',
            value: analysis.protein.toStringAsFixed(1),
            unit: 'g',
            icon: Icons.fitness_center,
            color: Colors.red,
            colorScheme: colorScheme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNutritionCard(
            label: 'Carbs',
            value: analysis.carbs.toStringAsFixed(1),
            unit: 'g',
            icon: Icons.grain,
            color: Colors.amber,
            colorScheme: colorScheme,
          ),
        ),
      ],
    );
  }

  /// Build nutrition card
  Widget _buildNutritionCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build AI insights card
  Widget _buildAiInsights(
    String recommendation,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.lightbulb,
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Đánh giá bữa ăn',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            recommendation,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Show more options bottom sheet
  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Icon(Icons.edit, color: colorScheme.primary),
                title: const Text('Chỉnh sửa'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Edit functionality
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: colorScheme.error),
                title: const Text('Xóa'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Delete functionality
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// Show detailed nutrition bottom sheet
  void _showDetailedNutrition(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  'Thành phần dinh dưỡng',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                // Nutrition details
                _buildNutritionRow(
                  'Calories',
                  '${analysis.calories.toStringAsFixed(0)} kcal',
                ),
                _buildNutritionRow(
                  'Protein',
                  '${analysis.protein.toStringAsFixed(1)} g',
                ),
                _buildNutritionRow(
                  'Carbs',
                  '${analysis.carbs.toStringAsFixed(1)} g',
                ),
                _buildNutritionRow(
                  'Fat',
                  '${analysis.fat.toStringAsFixed(1)} g',
                ),

                const SizedBox(height: 24),

                // Close button
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Đóng'),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build nutrition row
  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  /// Get confidence color
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 90) return Colors.green;
    if (confidence >= 70) return Colors.lightGreen;
    if (confidence >= 50) return Colors.orange;
    return Colors.red;
  }
}
