# 📝 Flutter Food Analysis - Code Examples

## Ví Dụ Hoàn Chỉnh - Complete Implementation

---

## 1. Basic Usage - Cách Sử Dụng Cơ Bản

### Bước 1: Setup Main App

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'services/food_analysis_service.dart';
import 'providers/food_analysis_provider.dart';
import 'screens/food_analysis_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Analysis Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: MultiProvider(
        providers: [
          // Provide FoodAnalysisService
          Provider<FoodAnalysisService>(
            create: (_) => FoodAnalysisService(
              dio: Dio()
                ..options.connectTimeout = const Duration(seconds: 30)
                ..options.receiveTimeout = const Duration(seconds: 30),
            ),
          ),
          // Provide FoodAnalysisProvider
          ChangeNotifierProxyProvider<FoodAnalysisService,
              FoodAnalysisProvider>(
            create: (context) =>
                FoodAnalysisProvider(context.read<FoodAnalysisService>()),
            update: (context, service, previous) =>
                previous ?? FoodAnalysisProvider(service),
          ),
        ],
        child: const FoodAnalysisScreen(
          userId: '728b7060-5a5c-4e25-a034-24cfde225029',
        ),
      ),
    );
  }
}
```

---

## 2. Simple Widget - Widget Đơn Giản

```dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'providers/food_analysis_provider.dart';

class SimpleFoodAnalysisWidget extends StatelessWidget {
  final String userId;

  const SimpleFoodAnalysisWidget({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.read<FoodAnalysisProvider>();

    return Column(
      children: [
        // Upload button
        ElevatedButton.icon(
          icon: const Icon(Icons.camera_alt),
          label: const Text('Analyze Food'),
          onPressed: () async {
            final picker = ImagePicker();
            final image = await picker.pickImage(
              source: ImageSource.camera,
            );

            if (image != null) {
              provider.analyzeFood(
                userId: userId,
                imageFile: image,
                mealType: 'lunch',
              );
            }
          },
        ),

        // Result display
        Consumer<FoodAnalysisProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage != null) {
              return Text('Error: ${provider.errorMessage}');
            }

            if (provider.currentAnalysis != null) {
              final analysis = provider.currentAnalysis!;
              return Column(
                children: [
                  Text(
                    analysis.foodName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('${analysis.caloriesFormatted} kcal'),
                  Text('${analysis.suitable}% suitable'),
                ],
              );
            }

            return const Text('No analysis yet');
          },
        ),
      ],
    );
  }
}
```

---

## 3. Advanced: Full Featured Screen

```dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/food_analysis_provider.dart';
import 'models/food_analysis_models.dart';

class AdvancedFoodAnalysisScreen extends StatefulWidget {
  final String userId;

  const AdvancedFoodAnalysisScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<AdvancedFoodAnalysisScreen> createState() =>
      _AdvancedFoodAnalysisScreenState();
}

class _AdvancedFoodAnalysisScreenState
    extends State<AdvancedFoodAnalysisScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late TabController _tabController;
  String? selectedMealType;
  XFile? selectedImage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load history on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodAnalysisProvider>().fetchHistory(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍽️ Food Analysis'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.camera_alt), text: 'Analyze'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnalyzeTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  /// Analyze tab
  Widget _buildAnalyzeTab() {
    return Consumer<FoodAnalysisProvider>(
      builder: (context, provider, _) {
        // Show result if available
        if (provider.currentAnalysis != null) {
          return _buildResultView(provider.currentAnalysis!);
        }

        // Show form
        return SingleChildScrollView(
          child: Column(
            children: [
              // Image preview
              if (selectedImage != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(File(selectedImage!.path)),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.all(16),
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: Colors.grey,
                    ),
                  ),
                ),

              // Upload buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Meal type selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Meal Type:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedMealType,
                      hint: const Text('Select meal type'),
                      items: ['breakfast', 'lunch', 'dinner', 'snack']
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e.toUpperCase(),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => selectedMealType = value);
                      },
                      selectedItemBuilder: (BuildContext context) {
                        return ['breakfast', 'lunch', 'dinner', 'snack']
                            .map<Widget>((String item) {
                          return Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              item.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Analyze button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: selectedImage == null || provider.isLoading
                        ? null
                        : () => _analyzeFood(provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'ANALYZE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Loading message
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Analyzing food...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This may take 5-15 seconds',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

              // Error message
              if (provider.errorMessage != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '❌ Error',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// History tab
  Widget _buildHistoryTab() {
    return Consumer<FoodAnalysisProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingHistory) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.history.isEmpty) {
          return const Center(
            child: Text('No analysis history yet'),
          );
        }

        return ListView.builder(
          itemCount: provider.history.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final item = provider.history[index];
            return _buildHistoryCard(item, provider);
          },
        );
      },
    );
  }

  /// History card
  Widget _buildHistoryCard(
    FoodAnalysisResponse analysis,
    FoodAnalysisProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Show detail
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => DraggableScrollableSheet(
              expand: false,
              builder: (_, controller) => _buildDetailView(analysis),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  analysis.imagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysis.foodName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${analysis.caloriesFormatted} kcal',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, HH:mm').format(analysis.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Suitability indicator
              Column(
                children: [
                  Text(
                    '${analysis.suitable}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: analysis.suitabilityColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Suitable',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              // Delete button
              PopupMenuButton(
                itemBuilder: (_) => [
                  PopupMenuItem(
                    child: const Text('Delete'),
                    onTap: () => _showDeleteDialog(analysis, provider),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Detail view
  Widget _buildDetailView(FoodAnalysisResponse analysis) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Image.network(
            analysis.imagePath,
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  analysis.foodName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Confidence: ${analysis.confidencePercent}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        analysis.mealType.toUpperCase(),
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Nutrition grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _buildStatCard(
                  'Calo',
                  analysis.caloriesFormatted,
                  'kcal',
                  Colors.red,
                ),
                _buildStatCard(
                  'Protein',
                  analysis.protein.toStringAsFixed(1),
                  'g',
                  Colors.blue,
                ),
                _buildStatCard(
                  'Fat',
                  analysis.fat.toStringAsFixed(1),
                  'g',
                  Colors.yellow,
                ),
                _buildStatCard(
                  'Carbs',
                  analysis.carbs.toStringAsFixed(1),
                  'g',
                  Colors.green,
                ),
              ],
            ),
          ),

          // Suitability
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: analysis.suitabilityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: analysis.suitabilityColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Health Plan Compatibility',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        analysis.suitabilityStatus,
                        style: TextStyle(
                          color: analysis.suitabilityColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${analysis.suitable}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: analysis.suitabilityColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: analysis.suitable / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor:
                          AlwaysStoppedAnimation(analysis.suitabilityColor),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Advice
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Advice',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(analysis.advice),
                ),
              ],
            ),
          ),

          // Suggestions
          if (analysis.suggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Suggestions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(analysis.suggestions),
                  ),
                ],
              ),
            ),

          // Details if available
          if (analysis.details != null && analysis.details!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Food Components',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...analysis.details!.map((detail) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                detail.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${detail.weight.toStringAsFixed(0)}g',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${detail.calories.toStringAsFixed(1)} kcal | '
                            'P: ${detail.protein.toStringAsFixed(1)}g | '
                            'F: ${detail.fat.toStringAsFixed(1)}g | '
                            'C: ${detail.carbs.toStringAsFixed(1)}g',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Result view
  Widget _buildResultView(FoodAnalysisResponse analysis) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDetailView(analysis),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<FoodAnalysisProvider>().reset();
                      setState(() => selectedImage = null);
                    },
                    child: const Text('Analyze Another'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Save to meal plan
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved to meal plan')),
                      );
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build stat card
  Widget _buildStatCard(
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Pick image
  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() => selectedImage = image);
    }
  }

  /// Analyze food
  void _analyzeFood(FoodAnalysisProvider provider) {
    if (selectedImage == null) return;

    provider.analyzeFood(
      userId: widget.userId,
      imageFile: selectedImage!,
      mealType: selectedMealType ?? 'lunch',
    );
  }

  /// Show delete dialog
  void _showDeleteDialog(
    FoodAnalysisResponse analysis,
    FoodAnalysisProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Analysis?'),
        content: Text(
          'Are you sure you want to delete "${analysis.foodName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteAnalysis(analysis.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
```

---

## 4. Network Request Examples

### Using Dio with Logging

```dart
import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    print('→ REQUEST: ${options.method} ${options.path}');
    print('  Headers: ${options.headers}');
    print('  Body: ${options.data}');
    return handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    print('← RESPONSE: ${response.statusCode}');
    print('  Data: ${response.data}');
    return handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    print('❌ ERROR: ${err.message}');
    print('  Type: ${err.type}');
    return handler.next(err);
  }
}

// Usage
final dio = Dio();
dio.interceptors.add(LoggingInterceptor());
```

---

## 5. Error Handling Examples

```dart
Future<void> handleAnalysis() async {
  try {
    final result = await service.analyzeFood(
      userId: userId,
      imageFile: image,
    );
    print('Success: ${result.foodName}');
  } on DioException catch (e) {
    if (e.response?.statusCode == 400) {
      showError('Invalid request');
    } else if (e.response?.statusCode == 500) {
      showError('Server error, please try again later');
    } else if (e.type == DioExceptionType.connectionTimeout) {
      showError('Connection timeout');
    } else if (e.type == DioExceptionType.unknown) {
      showError('Network error: ${e.error}');
    } else {
      showError('Error: ${e.message}');
    }
  } catch (e) {
    showError('Unexpected error: $e');
  }
}

void showError(String message) {
  print('ERROR: $message');
  // Show snackbar, dialog, etc.
}
```

---

**Last Updated**: January 16, 2025
