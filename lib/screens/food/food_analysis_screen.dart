import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../providers/food_analysis_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/prediction_history.dart';
import '../../services/api_config.dart';
import '../../utils/image_url_helper.dart';

/// Food Analysis Screen for analyzing food images and viewing history
class FoodAnalysisScreen extends StatefulWidget {
  const FoodAnalysisScreen({super.key});

  @override
  State<FoodAnalysisScreen> createState() => _FoodAnalysisScreenState();
}

class _FoodAnalysisScreenState extends State<FoodAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  String _selectedMealType = 'lunch';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load history when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<FoodAnalysisProvider>().fetchHistory(
          authProvider.user!.id,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: const Text(
              'Phân Tích Món Ăn',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            elevation: 0,
            pinned: true,
            floating: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showDebugInfo(context),
                tooltip: 'Thông tin debug',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              tabs: const [
                Tab(icon: Icon(Icons.camera_alt), text: 'Phân Tích'),
                Tab(icon: Icon(Icons.history), text: 'Lịch Sử'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [_buildAnalysisTab(), _buildHistoryTab()],
        ),
      ),
    );
  }

  /// Show debug info dialog
  void _showDebugInfo(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông Tin Debug'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Backend URL:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${ApiConfig.baseUrl}${ApiConfig.foodAnalysis}'),
              const SizedBox(height: 12),
              Text('User ID:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(authProvider.user?.id ?? 'Not logged in'),
              const SizedBox(height: 12),
              Text('Timeout:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${ApiConfig.connectionTimeout.inSeconds}s'),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Kiểm tra:\n'
                '• Backend đang chạy?\n'
                '• IP address đúng?\n'
                '• SSL certificate OK?\n'
                '• Firewall cho phép?',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  /// Tab for analyzing new images
  Widget _buildAnalysisTab() {
    final colorScheme = Theme.of(context).colorScheme;
    final authProvider = context.read<AuthProvider>();

    return Consumer<FoodAnalysisProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Meal type selector
              _buildMealTypeSelector(colorScheme),
              const SizedBox(height: 24),

              // Camera/Gallery buttons
              _buildImageSourceButtons(colorScheme, authProvider),
              const SizedBox(height: 32),

              // Loading indicator
              if (provider.isLoading) ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Đang phân tích món ăn...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'AI đang xử lý ảnh của bạn\nVui lòng đợi 5-15 giây',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Error message
              if (provider.errorMessage != null) ...[
                _buildErrorCard(provider.errorMessage!, colorScheme),
                const SizedBox(height: 24),
              ],

              // Analysis result
              if (provider.currentAnalysis != null) ...[
                _buildAnalysisResult(provider.currentAnalysis!, colorScheme),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Meal type selector - Material 3 style
  Widget _buildMealTypeSelector(ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;
    final mealTypes = [
      {
        'value': 'breakfast',
        'label': 'Sáng',
        'icon': Icons.wb_sunny,
        'time': '6-9 AM',
      },
      {
        'value': 'lunch',
        'label': 'Trưa',
        'icon': Icons.light_mode,
        'time': '11-1 PM',
      },
      {
        'value': 'dinner',
        'label': 'Tối',
        'icon': Icons.dark_mode,
        'time': '6-8 PM',
      },
      {
        'value': 'snack',
        'label': 'Phụ',
        'icon': Icons.restaurant,
        'time': 'Bất kỳ',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn bữa ăn',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // Horizontal scrollable list with meal details
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: mealTypes.length,
            itemBuilder: (context, index) {
              final meal = mealTypes[index];
              final isSelected = _selectedMealType == meal['value'];
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 8,
                  right: index == mealTypes.length - 1 ? 0 : 0,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMealType = meal['value'] as String;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 95,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outline.withValues(alpha: 0.2),
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              meal['icon'] as IconData,
                              size: 26,
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              meal['label'] as String,
                              style: textTheme.labelMedium?.copyWith(
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              meal['time'] as String,
                              style: textTheme.labelSmall?.copyWith(
                                color: isSelected
                                    ? colorScheme.onPrimary.withValues(alpha: 0.7)
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Image selection section - Material 3 style
  Widget _buildImageSourceButtons(
    ColorScheme colorScheme,
    AuthProvider authProvider,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section title
        Text(
          'Tải lên ảnh',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Card container for both buttons - Material 3 style
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Camera button
                _buildImageSelectionButton(
                  colorScheme,
                  authProvider,
                  icon: Icons.camera_alt_rounded,
                  label: 'Chụp ảnh mới',
                  description: 'Dùng camera thiết bị của bạn',
                  source: ImageSource.camera,
                  isPrimary: true,
                ),
                const SizedBox(height: 10),

                // Divider
                Divider(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  height: 1,
                ),
                const SizedBox(height: 10),

                // Gallery button
                _buildImageSelectionButton(
                  colorScheme,
                  authProvider,
                  icon: Icons.photo_library_rounded,
                  label: 'Chọn từ thư viện',
                  description: 'Chọn ảnh đã có trên thiết bị',
                  source: ImageSource.gallery,
                  isPrimary: false,
                ),
              ],
            ),
          ),
        ),

        // Tips section - Material 3 style with proper card
        const SizedBox(height: 16),
        Card(
          color: colorScheme.primaryContainer.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mẹo chụp ảnh tốt',
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Chụp từ trên xuống\n'
                        '• Ánh sáng tự nhiên\n'
                        '• Toàn bộ món ăn trong khung',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Image selection button - Material 3 style
  Widget _buildImageSelectionButton(
    ColorScheme colorScheme,
    AuthProvider authProvider, {
    required IconData icon,
    required String label,
    required String description,
    required ImageSource source,
    required bool isPrimary,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _pickImage(source, authProvider),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              // Icon container - Material 3 style
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isPrimary
                      ? colorScheme.primary.withValues(alpha: 0.9)
                      : colorScheme.primary.withValues(alpha: 0.12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isPrimary
                      ? colorScheme.onPrimary
                      : colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source, AuthProvider authProvider) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && authProvider.user != null) {
        if (mounted) {
          context.read<FoodAnalysisProvider>().analyzeFood(
            userId: authProvider.user!.id,
            imageFile: image,
            mealType: _selectedMealType,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Error card - Material 3 style
  Widget _buildErrorCard(String message, ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: colorScheme.errorContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: colorScheme.error,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Có lỗi xảy ra',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.error,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.error),
                  onPressed: () {
                    context.read<FoodAnalysisProvider>().clearError();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.error.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Analysis result card
  Widget _buildAnalysisResult(
    PredictionHistory analysis,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with overlay badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  ImageUrlHelper.formatImageUrl(analysis.imagePath),
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 280,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
              // Confidence badge
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(analysis.confidence),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _getConfidenceColor(
                          analysis.confidence,
                        ).withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${analysis.confidence.toStringAsFixed(2)}% chắc chắn',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Food name and basic info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  analysis.foodName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        analysis.mealType?.toUpperCase() ?? 'THỰC ĐƠN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(analysis.createdAt),
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Main nutrition stats - horizontal scrollable
                Text(
                  'Thông tin dinh dưỡng',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildNutritionCard(
                        'Calories',
                        analysis.calories.toStringAsFixed(0),
                        'kcal',
                        Icons.local_fire_department,
                        Colors.orange,
                        colorScheme,
                      ),
                      const SizedBox(width: 12),
                      _buildNutritionCard(
                        'Protein',
                        analysis.protein.toStringAsFixed(1),
                        'g',
                        Icons.egg,
                        Colors.red,
                        colorScheme,
                      ),
                      const SizedBox(width: 12),
                      _buildNutritionCard(
                        'Carbs',
                        analysis.carbs.toStringAsFixed(1),
                        'g',
                        Icons.grain,
                        Colors.amber,
                        colorScheme,
                      ),
                      const SizedBox(width: 12),
                      _buildNutritionCard(
                        'Fat',
                        analysis.fat.toStringAsFixed(1),
                        'g',
                        Icons.opacity,
                        Colors.blue,
                        colorScheme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Advice section
                if (analysis.advice != null && analysis.advice!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      border: Border.all(
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gợi ý',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                analysis.advice!,
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.8,
                                  ),
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Details button
                if (analysis.details != null &&
                    analysis.details!.isNotEmpty) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _showDetailsDialog(analysis),
                      icon: const Icon(Icons.restaurant_menu),
                      label: const Text('Xem chi tiết thành phần'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Nutrition card widget
  Widget _buildNutritionCard(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Nutrition grid
  /// Show details dialog
  void _showDetailsDialog(PredictionHistory analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi Tiết Thành Phần'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: (analysis.details ?? []).map((detail) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: Text(
                      '${detail.confidence.toStringAsFixed(2)}%',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  title: Text(
                    detail.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${detail.weight.toStringAsFixed(0)}g • ${detail.calories.toStringAsFixed(0)} kcal',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('P: ${detail.protein.toStringAsFixed(1)}g'),
                      Text('F: ${detail.fat.toStringAsFixed(1)}g'),
                      Text('C: ${detail.carbs.toStringAsFixed(1)}g'),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  /// History tab
  Widget _buildHistoryTab() {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<FoodAnalysisProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.history.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có lịch sử phân tích',
                  style: TextStyle(
                    fontSize: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hãy chụp ảnh món ăn để bắt đầu!',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final authProvider = context.read<AuthProvider>();
            if (authProvider.user != null) {
              await provider.fetchHistory(authProvider.user!.id);
            }
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter section with Material 3 Design
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time filter section
                      Text(
                        'Thời gian',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildMaterial3FilterChip(
                            'Tất cả',
                            provider.selectedTimeFilter == 'all',
                            colorScheme,
                            onTap: () => provider.setTimeFilter('all'),
                          ),
                          _buildMaterial3FilterChip(
                            'Hôm nay',
                            provider.selectedTimeFilter == 'today',
                            colorScheme,
                            onTap: () => provider.setTimeFilter('today'),
                          ),
                          _buildMaterial3FilterChip(
                            'Tuần',
                            provider.selectedTimeFilter == 'week',
                            colorScheme,
                            onTap: () => provider.setTimeFilter('week'),
                          ),
                          _buildMaterial3FilterChip(
                            'Tháng',
                            provider.selectedTimeFilter == 'month',
                            colorScheme,
                            onTap: () => provider.setTimeFilter('month'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Meal type filter section
                      Text(
                        'Loại bữa ăn',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildMaterial3FilterChip(
                            'Tất cả',
                            provider.selectedMealFilter == 'all',
                            colorScheme,
                            onTap: () => provider.setMealFilter('all'),
                          ),
                          _buildMaterial3FilterChip(
                            'Sáng',
                            provider.selectedMealFilter == 'breakfast',
                            colorScheme,
                            onTap: () => provider.setMealFilter('breakfast'),
                          ),
                          _buildMaterial3FilterChip(
                            'Trưa',
                            provider.selectedMealFilter == 'lunch',
                            colorScheme,
                            onTap: () => provider.setMealFilter('lunch'),
                          ),
                          _buildMaterial3FilterChip(
                            'Tối',
                            provider.selectedMealFilter == 'dinner',
                            colorScheme,
                            onTap: () => provider.setMealFilter('dinner'),
                          ),
                          _buildMaterial3FilterChip(
                            'Phụ',
                            provider.selectedMealFilter == 'snack',
                            colorScheme,
                            onTap: () => provider.setMealFilter('snack'),
                          ),
                        ],
                      ),

                      // Results counter
                      const SizedBox(height: 12),
                      Text(
                        'Tìm thấy ${provider.filteredHistory.length} kết quả',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                // History list
                if (provider.filteredHistory.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Không có kết quả phù hợp',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.filteredHistory.length,
                    itemBuilder: (context, index) {
                      final item = provider.filteredHistory[index];
                      return _buildHistoryItem(item, colorScheme, provider);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build a filter chip widget
  /// Build a Material 3 filter chip widget
  Widget _buildMaterial3FilterChip(
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
      selectedColor: colorScheme.primary.withValues(alpha: 0.9),
      side: BorderSide(
        color: isSelected
            ? colorScheme.primary
            : colorScheme.outline.withValues(alpha: 0.3),
        width: 1,
      ),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  /// History item card
  Widget _buildHistoryItem(
    PredictionHistory item,
    ColorScheme colorScheme,
    FoodAnalysisProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Show detail modal bottom sheet
          _showFoodDetailModal(context, item, Theme.of(context).colorScheme);
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and basic info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image thumbnail
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Image.network(
                    ImageUrlHelper.formatImageUrl(item.imagePath),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_not_supported,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.foodName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
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
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Chip(
                              label: Text(
                                '${item.confidence.toStringAsFixed(2)}%',
                                style: const TextStyle(fontSize: 11),
                              ),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: () => _confirmDelete(item, provider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Show food detail modal bottom sheet
  void _showFoodDetailModal(
    BuildContext context,
    PredictionHistory item,
    ColorScheme colorScheme,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
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
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  ImageUrlHelper.formatImageUrl(item.imagePath),
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      width: double.infinity,
                      color: colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          size: 48,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Food name
              Text(
                item.foodName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Confidence
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: _getConfidenceColor(item.confidence),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Độ chính xác: ${item.confidence.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Macros grid
              Text(
                'Thông tin dinh dưỡng',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  _buildMacroCard(
                    'Calories',
                    item.calories.toStringAsFixed(0),
                    'kcal',
                    Icons.local_fire_department,
                    Colors.orange,
                    colorScheme,
                  ),
                  _buildMacroCard(
                    'Protein',
                    item.protein.toStringAsFixed(1),
                    'g',
                    Icons.restaurant,
                    Colors.red,
                    colorScheme,
                  ),
                  _buildMacroCard(
                    'Chất béo',
                    item.fat.toStringAsFixed(1),
                    'g',
                    Icons.opacity,
                    Colors.blue,
                    colorScheme,
                  ),
                  _buildMacroCard(
                    'Carbs',
                    item.carbs.toStringAsFixed(1),
                    'g',
                    Icons.grain,
                    Colors.amber,
                    colorScheme,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Advice section
              if (item.advice != null && item.advice!.isNotEmpty) ...[
                Text(
                  'Lời khuyên',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    item.advice!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Creation date
              Text(
                'Ngày phân tích: ${DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Build macro card for the modal
  Widget _buildMacroCard(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 10,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Confirm delete dialog
  void _confirmDelete(PredictionHistory item, FoodAnalysisProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${item.foodName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                await provider.deleteAnalysis(item.id);
                navigator.pop();
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Đã xóa')),
                  );
                }
              } catch (e) {
                navigator.pop();
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Lỗi xóa: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  /// Get confidence color
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 90) return Colors.green;
    if (confidence >= 70) return Colors.lightGreen;
    if (confidence >= 50) return Colors.orange;
    return Colors.red;
  }
}

