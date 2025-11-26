# 📱 Flutter Food Analysis API Guide

> **Hướng dẫn toàn diện** cho các developer Flutter tích hợp API Phân Tích Ảnh Món Ăn bằng AI

---

## 📋 Mục Lục

1. [Tổng Quan](#tổng-quan)
2. [Kiến Thức Nền Tảng](#kiến-thức-nền-tảng)
3. [Endpoints & Các Hàm](#endpoints--các-hàm)
4. [Flutter Implementation](#flutter-implementation)
5. [Error Handling](#error-handling)
6. [UI/UX Best Practices](#uiux-best-practices)
7. [Testing & Debugging](#testing--debugging)
8. [Code Examples](#code-examples)

---

## 🎯 Tổng Quan

### Mục Đích
Hệ thống Food Analysis cho phép người dùng:
- **Chụp ảnh** một món ăn
- **Phân tích** bằng AI để lấy thông tin dinh dưỡng
- **So sánh** với phác đồ sức khỏe cá nhân
- **Lưu lịch sử** phân tích để theo dõi

### Công Nghệ
- **Backend**: ASP.NET Core 9.0
- **Database**: SQL Server
- **AI Model**: Python-based food recognition
- **Image Storage**: Local wwwroot + URL serving

### Base URL
```
https://localhost:7135/api/FoodAnalysis
```

---

## 📚 Kiến Thức Nền Tảng

### 1. Quy Trình Phân Tích Ảnh

```
┌─────────────┐
│ User chụp ảnh
└──────┬──────┘
       │
       ▼
┌─────────────────────────┐
│ Upload lên server       │
│ - Validate file         │
│ - Lưu vào wwwroot       │
└──────┬──────────────────┘
       │
       ▼
┌─────────────────────────┐
│ Call Python API         │
│ - Image recognition     │
│ - Nutrition extraction  │
└──────┬──────────────────┘
       │
       ▼
┌─────────────────────────┐
│ So sánh với Health Plan │
│ - Tính calories         │
│ - Đánh giá suitability  │
└──────┬──────────────────┘
       │
       ▼
┌─────────────────────────┐
│ Lưu vào Database        │
│ - PredictionHistory     │
│ - PredictionDetail      │
└──────┬──────────────────┘
       │
       ▼
┌─────────────────────────┐
│ Return response         │
│ - Food info             │
│ - Advice & Suggestions  │
└─────────────────────────┘
```

### 2. Data Models

#### **FoodAnalysisFormDto** (Request)
```dart
class FoodAnalysisRequest {
  String userId;              // ID của user
  File image;                 // Ảnh chụp (File object)
  String? mealType;           // Optional: "breakfast", "lunch", "dinner", "snack"
}
```

#### **PredictionResponse** (Response Success)
```dart
class FoodAnalysisResponse {
  int id;                     // ID của dự đoán (lưu trong DB)
  String userId;
  String imagePath;           // URL ảnh trên server
  String foodName;            // Tên món ăn được dự đoán
  double confidence;          // Độ tin cậy (0-1, ví dụ: 0.95)
  
  // Thông tin dinh dưỡng
  double calories;            // Calo tổng cộng (kcal)
  double protein;             // Protein (grams)
  double fat;                 // Chất béo (grams)
  double carbs;               // Carbohydrate (grams)
  
  // Thông tin bữa ăn
  String mealType;            // Loại bữa ăn
  DateTime createdAt;         // Thời gian tạo
  
  // Lời khuyên từ AI
  String advice;              // Lời khuyên
  int suitable;               // Mức phù hợp (0-100%)
  String suggestions;         // Gợi ý cải thiện
  
  // Chi tiết từng thành phần
  List<PredictionDetail>? details;
}

class PredictionDetail {
  int id;
  int predictionHistoryId;
  String label;               // Ví dụ: "cơm", "thịt gà"
  double weight;              // Khối lượng (grams)
  double calories;            // Calo (kcal)
  double protein;             // Protein (grams)
  double fat;                 // Chất béo (grams)
  double carbs;               // Carbohydrate (grams)
  double confidence;          // Độ tin cậy (0-1)
}
```

### 3. Health Plan Integration

Khi phân tích ảnh, hệ thống sẽ:
1. Lấy **Health Plan** của user (phác đồ sức khỏe)
2. So sánh calories của mon ăn với mục tiêu hằng ngày
3. Tính toán **suitability score** (0-100%)
4. Tạo **lời khuyên** được cá nhân hóa

**Ví dụ:**
- Health Plan: 2000 kcal/ngày
- Phở Bò: 400 kcal
- Suitability: 20% (400/2000 = 0.2)
- Advice: "✓ Bữa ăn này phù hợp với phác đồ. Còn lại: 1600 kcal"

---

## 🔌 Endpoints & Các Hàm

### 1. POST /api/FoodAnalysis/analyze
**Phân tích ảnh món ăn**

**Mục đích**: Tải lên ảnh, phân tích bằng AI, lưu kết quả

**Request Headers**:
```
Content-Type: multipart/form-data
Authorization: Bearer <access_token>  // Nếu cần auth
```

**Request Body (Form Data)**:
```
userId: "728b7060-5a5c-4e25-a034-24cfde225029"
image: <file>  // Binary file
mealType: "lunch"  // Optional
```

**Request Validation**:
- ✅ userId: Không được null/empty
- ✅ image: Phải là file hợp lệ (JPG, PNG, GIF, WebP)
- ✅ image: Size < 5MB
- ✅ mealType: Optional, default = "lunch"

**Response Success (200)**:
```json
{
  "id": 123,
  "userId": "728b7060-5a5c-4e25-a034-24cfde225029",
  "imagePath": "https://localhost:7135/uploads/abc123def.jpg",
  "foodName": "Phở Bò",
  "confidence": 0.92,
  "calories": 425.5,
  "protein": 28.3,
  "fat": 12.4,
  "carbs": 48.2,
  "mealType": "lunch",
  "createdAt": "2025-01-16T10:30:00Z",
  "advice": "✓ Bữa ăn này phù hợp với phác đồ của bạn...",
  "suitable": 21,
  "suggestions": "Có thể thêm rau xanh để cân bằng hơn",
  "details": [
    {
      "id": 1,
      "predictionHistoryId": 123,
      "label": "Cơm",
      "weight": 150.0,
      "calories": 195.0,
      "protein": 3.5,
      "fat": 0.5,
      "carbs": 44.2,
      "confidence": 0.95
    },
    {
      "id": 2,
      "predictionHistoryId": 123,
      "label": "Thịt bò",
      "weight": 80.0,
      "calories": 180.0,
      "protein": 24.8,
      "fat": 8.4,
      "carbs": 0.0,
      "confidence": 0.89
    }
  ]
}
```

**Response Error (400)**:
```json
{
  "error": "Invalid request",
  "message": "User ID is required"
}
```

**Response Error (500)**:
```json
{
  "error": "Processing error",
  "message": "Unable to analyze food. Please try again later."
}
```

**Performance**:
- ⏱️ Thời gian xử lý: 5-15 giây
- 📊 Phụ thuộc vào: Chất lượng ảnh, kích thước ảnh, độ phức tạp

---

### 2. GET /api/FoodAnalysis/history/{userId}
**Lấy lịch sử phân tích**

**Mục đích**: Hiển thị danh sách các mon ăn đã phân tích

**Path Parameters**:
```
userId: "728b7060-5a5c-4e25-a034-24cfde225029"
```

**Query Parameters** (Optional):
```
page: 1          // Trang (default: 1)
pageSize: 20     // Số items/trang (default: 20)
startDate: "2025-01-01"  // Lọc từ ngày
endDate: "2025-01-31"    // Lọc đến ngày
```

**Response Success (200)**:
```json
[
  {
    "id": 123,
    "imagePath": "https://localhost:7135/uploads/abc123.jpg",
    "foodName": "Phở Bò",
    "confidence": 0.92,
    "calories": 425.5,
    "protein": 28.3,
    "fat": 12.4,
    "carbs": 48.2,
    "mealType": "lunch",
    "createdAt": "2025-01-16T10:30:00Z",
    "advice": "✓ Bữa ăn này phù hợp..."
  },
  {
    "id": 122,
    "imagePath": "https://localhost:7135/uploads/xyz789.jpg",
    "foodName": "Cơm Tấm",
    "confidence": 0.88,
    "calories": 380.0,
    "protein": 15.2,
    "fat": 18.5,
    "carbs": 42.3,
    "mealType": "dinner",
    "createdAt": "2025-01-15T18:45:00Z",
    "advice": "⚠ Bữa ăn này vượt quá..."
  }
]
```

**Response Error (404)**:
```json
{
  "error": "Not found",
  "message": "User not found or has no analysis history"
}
```

---

### 3. DELETE /api/FoodAnalysis/history/{id}
**Xóa một bản ghi phân tích**

**Mục đích**: Xóa một phân tích khỏi lịch sử

**Path Parameters**:
```
id: 123  // ID của phân tích
```

**Response Success (204)**:
```
No content returned
```

**Response Error (404)**:
```json
{
  "error": "Not found",
  "message": "Analysis record not found"
}
```

---

## 💻 Flutter Implementation

### 1. Thiết Lập Project

#### pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HTTP & Networking
  dio: ^5.3.0              # HTTP client
  http: ^1.1.0             # Alternative HTTP
  
  # Image Handling
  image_picker: ^1.0.4     # Pick từ gallery/camera
  image: ^4.1.0            # Image processing
  
  # State Management
  provider: ^6.0.0         # Simple state management
  
  # JSON Serialization
  json_serializable: ^6.7.0
  json_annotation: ^4.8.0
  
  # Utilities
  intl: ^0.19.0            # Date formatting
  logger: ^2.0.0           # Logging
  
dev_dependencies:
  build_runner: ^2.4.0
  json_serializable: ^6.7.0
```

### 2. Models & DTOs

#### lib/models/food_analysis_models.dart
```dart
import 'package:json_annotation/json_annotation.dart';

part 'food_analysis_models.g.dart';

@JsonSerializable()
class FoodAnalysisResponse {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'userId')
  final String userId;

  @JsonKey(name: 'imagePath')
  final String imagePath;

  @JsonKey(name: 'foodName')
  final String foodName;

  @JsonKey(name: 'confidence')
  final double confidence;

  @JsonKey(name: 'calories')
  final double calories;

  @JsonKey(name: 'protein')
  final double protein;

  @JsonKey(name: 'fat')
  final double fat;

  @JsonKey(name: 'carbs')
  final double carbs;

  @JsonKey(name: 'mealType')
  final String mealType;

  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  @JsonKey(name: 'advice')
  final String advice;

  @JsonKey(name: 'suitable')
  final int suitable;

  @JsonKey(name: 'suggestions')
  final String suggestions;

  @JsonKey(name: 'details')
  final List<PredictionDetail>? details;

  FoodAnalysisResponse({
    required this.id,
    required this.userId,
    required this.imagePath,
    required this.foodName,
    required this.confidence,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.mealType,
    required this.createdAt,
    required this.advice,
    required this.suitable,
    required this.suggestions,
    this.details,
  });

  factory FoodAnalysisResponse.fromJson(Map<String, dynamic> json) =>
      _$FoodAnalysisResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FoodAnalysisResponseToJson(this);

  /// Utility: Format calories with comma separator
  String get caloriesFormatted => calories.toStringAsFixed(1);

  /// Utility: Get suitability status
  String get suitabilityStatus {
    if (suitable > 90) return "Rất phù hợp ✓";
    if (suitable > 70) return "Tương đối phù hợp";
    if (suitable > 50) return "Cần chú ý";
    return "Không phù hợp ⚠";
  }

  /// Utility: Get suitability color
  Color get suitabilityColor {
    if (suitable > 90) return Colors.green;
    if (suitable > 70) return Colors.lightGreen;
    if (suitable > 50) return Colors.orange;
    return Colors.red;
  }
}

@JsonSerializable()
class PredictionDetail {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'predictionHistoryId')
  final int predictionHistoryId;

  @JsonKey(name: 'label')
  final String label;

  @JsonKey(name: 'weight')
  final double weight;

  @JsonKey(name: 'calories')
  final double calories;

  @JsonKey(name: 'protein')
  final double protein;

  @JsonKey(name: 'fat')
  final double fat;

  @JsonKey(name: 'carbs')
  final double carbs;

  @JsonKey(name: 'confidence')
  final double confidence;

  PredictionDetail({
    required this.id,
    required this.predictionHistoryId,
    required this.label,
    required this.weight,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.confidence,
  });

  factory PredictionDetail.fromJson(Map<String, dynamic> json) =>
      _$PredictionDetailFromJson(json);

  Map<String, dynamic> toJson() => _$PredictionDetailToJson(this);

  /// Utility: Format confidence as percentage
  String get confidencePercent => "${(confidence * 100).toStringAsFixed(1)}%";
}
```

### 3. API Service

#### lib/services/food_analysis_service.dart
```dart
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../models/food_analysis_models.dart';
import 'package:logger/logger.dart';

class FoodAnalysisService {
  final Dio dio;
  final String baseUrl = "https://localhost:7135/api/FoodAnalysis";
  final Logger logger = Logger();

  FoodAnalysisService({Dio? dio}) : dio = dio ?? Dio();

  /// Phân tích ảnh món ăn
  Future<FoodAnalysisResponse> analyzeFood({
    required String userId,
    required XFile imageFile,
    String? mealType,
  }) async {
    try {
      logger.i("Starting food analysis for user: $userId");

      // Tạo FormData
      FormData formData = FormData.fromMap({
        'UserId': userId,
        'Image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.name,
        ),
        if (mealType != null) 'MealType': mealType,
      });

      // POST request
      Response response = await dio.post(
        '$baseUrl/analyze',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          validateStatus: (status) => status! < 500,
        ),
      );

      logger.i("Response status: ${response.statusCode}");
      logger.d("Response data: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;
        return FoodAnalysisResponse.fromJson(data);
      } else {
        throw Exception(
          response.data?['message'] ?? 'Failed to analyze food',
        );
      }
    } catch (e) {
      logger.e("Error analyzing food: $e");
      rethrow;
    }
  }

  /// Lấy lịch sử phân tích
  Future<List<FoodAnalysisResponse>> getHistory(
    String userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      logger.i("Fetching history for user: $userId");

      Response response = await dio.get(
        '$baseUrl/history/$userId',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      logger.i("Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((item) => FoodAnalysisResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          response.data?['message'] ?? 'Failed to fetch history',
        );
      }
    } catch (e) {
      logger.e("Error fetching history: $e");
      rethrow;
    }
  }

  /// Xóa một bản ghi phân tích
  Future<void> deleteAnalysis(int id) async {
    try {
      logger.i("Deleting analysis: $id");

      Response response = await dio.delete(
        '$baseUrl/history/$id',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      logger.i("Response status: ${response.statusCode}");

      if (response.statusCode != 204) {
        throw Exception(
          response.data?['message'] ?? 'Failed to delete analysis',
        );
      }
    } catch (e) {
      logger.e("Error deleting analysis: $e");
      rethrow;
    }
  }
}
```

### 4. State Management (Provider)

#### lib/providers/food_analysis_provider.dart
```dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/food_analysis_models.dart';
import '../services/food_analysis_service.dart';

class FoodAnalysisProvider extends ChangeNotifier {
  final FoodAnalysisService _service;

  FoodAnalysisProvider(this._service);

  // State
  bool isLoading = false;
  bool isLoadingHistory = false;
  FoodAnalysisResponse? currentAnalysis;
  List<FoodAnalysisResponse> history = [];
  String? errorMessage;

  // Methods

  /// Phân tích ảnh
  Future<void> analyzeFood({
    required String userId,
    required XFile imageFile,
    String? mealType,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentAnalysis = await _service.analyzeFood(
        userId: userId,
        imageFile: imageFile,
        mealType: mealType,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Lấy lịch sử
  Future<void> fetchHistory(String userId) async {
    isLoadingHistory = true;
    errorMessage = null;
    notifyListeners();

    try {
      history = await _service.getHistory(userId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// Xóa phân tích
  Future<void> deleteAnalysis(int id) async {
    try {
      await _service.deleteAnalysis(id);
      history.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Reset state
  void reset() {
    currentAnalysis = null;
    history = [];
    errorMessage = null;
    notifyListeners();
  }
}
```

### 5. UI Screens

#### lib/screens/food_analysis_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/food_analysis_provider.dart';
import '../models/food_analysis_models.dart';

class FoodAnalysisScreen extends StatefulWidget {
  final String userId;

  const FoodAnalysisScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  State<FoodAnalysisScreen> createState() => _FoodAnalysisScreenState();
}

class _FoodAnalysisScreenState extends State<FoodAnalysisScreen> {
  final ImagePicker _picker = ImagePicker();
  String? selectedMealType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân Tích Ảnh Món Ăn'),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Consumer<FoodAnalysisProvider>(
        builder: (context, provider, _) {
          if (provider.currentAnalysis != null) {
            return _buildAnalysisResult(provider.currentAnalysis!);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildUploadSection(provider),
                const SizedBox(height: 24),
                _buildHistorySection(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build upload section
  Widget _buildUploadSection(FoodAnalysisProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Meal type selector
          const Text(
            'Loại bữa ăn:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            isExpanded: true,
            value: selectedMealType,
            hint: const Text('Chọn loại bữa ăn'),
            items: ['breakfast', 'lunch', 'dinner', 'snack']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) => setState(() => selectedMealType = value),
          ),
          const SizedBox(height: 16),

          // Upload buttons
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Chụp Ảnh'),
            onPressed: () => _pickImage(provider, ImageSource.camera),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text('Chọn từ Thư Viện'),
            onPressed: () => _pickImage(provider, ImageSource.gallery),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
            ),
          ),

          // Loading indicator
          if (provider.isLoading) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 8),
            const Text('Đang phân tích... (5-15 giây)'),
          ],

          // Error message
          if (provider.errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                provider.errorMessage!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Pick image and analyze
  Future<void> _pickImage(
    FoodAnalysisProvider provider,
    ImageSource source,
  ) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      provider.analyzeFood(
        userId: widget.userId,
        imageFile: image,
        mealType: selectedMealType,
      );
    }
  }

  /// Build analysis result
  Widget _buildAnalysisResult(FoodAnalysisResponse analysis) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Image
          Image.network(
            analysis.imagePath,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          // Food name and confidence
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
                    const Text('Độ tin cậy: '),
                    Text(
                      analysis.confidencePercent,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: analysis.confidence > 0.8
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Nutrition info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _buildNutritionCard('Calo', analysis.caloriesFormatted, 'kcal'),
                _buildNutritionCard(
                  'Protein',
                  analysis.protein.toStringAsFixed(1),
                  'g',
                ),
                _buildNutritionCard(
                  'Chất Béo',
                  analysis.fat.toStringAsFixed(1),
                  'g',
                ),
                _buildNutritionCard(
                  'Carbs',
                  analysis.carbs.toStringAsFixed(1),
                  'g',
                ),
              ],
            ),
          ),

          // Suitability score
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: analysis.suitabilityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: analysis.suitabilityColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Phù hợp với phác đồ:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${analysis.suitable}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: analysis.suitabilityColor,
                          fontSize: 18,
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
                  'Lời khuyên:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
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
                    'Gợi ý:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
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

          // Details
          if (analysis.details != null && analysis.details!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chi tiết thành phần:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Calo: ${detail.calories.toStringAsFixed(1)} | '
                            'Protein: ${detail.protein.toStringAsFixed(1)}g | '
                            'Carbs: ${detail.carbs.toStringAsFixed(1)}g',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<FoodAnalysisProvider>().reset();
                    },
                    child: const Text('Phân Tích Khác'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Save to favorite or meal plan
                    },
                    child: const Text('Lưu'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build nutrition card
  Widget _buildNutritionCard(String label, String value, String unit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build history section
  Widget _buildHistorySection(FoodAnalysisProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lịch Sử Phân Tích',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (provider.isLoadingHistory)
            const Center(child: CircularProgressIndicator())
          else if (provider.history.isEmpty)
            const Center(
              child: Text('Chưa có phân tích nào'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.history.length,
              itemBuilder: (context, index) {
                final item = provider.history[index];
                return HistoryItem(
                  analysis: item,
                  onDelete: () => provider.deleteAnalysis(item.id),
                );
              },
            ),
        ],
      ),
    );
  }
}

// History item widget
class HistoryItem extends StatelessWidget {
  final FoodAnalysisResponse analysis;
  final VoidCallback onDelete;

  const HistoryItem({
    Key? key,
    required this.analysis,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Image.network(
          analysis.imagePath,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
        title: Text(analysis.foodName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${analysis.caloriesFormatted} kcal'),
            Text(
              '${analysis.suitable}% phù hợp',
              style: TextStyle(
                color: analysis.suitabilityColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          color: Colors.red,
          onPressed: onDelete,
        ),
        onTap: () {
          // TODO: Show detail
        },
      ),
    );
  }
}
```

---

## ⚠️ Error Handling

### Common Errors

| Error | Nguyên Nhân | Cách Khắc Phục |
|-------|-----------|-----------------|
| 400 Bad Request | Invalid userId hoặc image | Kiểm tra userId format và file image |
| 500 Internal Server Error | Server error hoặc AI model fail | Retry sau 5-10 giây |
| Network timeout | Connection chậm | Tăng timeout, kiểm tra internet |
| Invalid image | File không phải ảnh | Chọn ảnh JPG/PNG hợp lệ |

### Error Handling Pattern

```dart
try {
  final result = await provider.analyzeFood(
    userId: userId,
    imageFile: imageFile,
  );
  // Handle success
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    showError("Kết nối timeout, vui lòng thử lại");
  } else if (e.response?.statusCode == 400) {
    showError("Dữ liệu không hợp lệ");
  } else {
    showError("Lỗi: ${e.message}");
  }
} catch (e) {
  showError("Lỗi không xác định: $e");
}
```

---

## 🎨 UI/UX Best Practices

### 1. Loading States
- ✅ Hiện loading indicator trong 5-15 giây
- ✅ Disable upload buttons khi đang processing
- ✅ Show progress message

### 2. Image Preview
- ✅ Hiện ảnh đã chọn trước khi upload
- ✅ Cho phép re-select ảnh
- ✅ Compress ảnh nếu file lớn

### 3. Result Display
- ✅ Hiện dữ liệu dinh dưỡng rõ ràng
- ✅ Color-code suitability score
- ✅ Show individual components

### 4. History Management
- ✅ Paginate nếu có nhiều items
- ✅ Sorting options (newest/oldest)
- ✅ Delete with confirmation

---

## 🧪 Testing & Debugging

### Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('FoodAnalysisService', () {
    late FoodAnalysisService service;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      service = FoodAnalysisService(dio: mockDio);
    });

    test('analyzeFood returns FoodAnalysisResponse', () async {
      // Mock response
      when(mockDio.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => Response(
            data: {
              'id': 1,
              'foodName': 'Phở Bò',
              'calories': 425.5,
              // ... other fields
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Test
      final result = await service.analyzeFood(
        userId: 'test-user',
        imageFile: XFile('test.jpg'),
      );

      expect(result.foodName, 'Phở Bò');
      expect(result.calories, 425.5);
    });
  });
}
```

### Debugging Tips

1. **Enable Logging**:
```dart
final dio = Dio();
dio.interceptors.add(LoggingInterceptor());
```

2. **Check Network**:
```bash
flutter run -d chrome  // Debug on web with DevTools
```

3. **Verbose Logs**:
```dart
logger.level = Level.verbose;
```

---

## 📱 Code Examples

Xem file tại: `/Doc/FLUTTER_CODE_EXAMPLES/`

### Complete Example App Structure

```
lib/
├── main.dart                          # App entry
├── models/
│   └── food_analysis_models.dart     # Data models
├── services/
│   ├── food_analysis_service.dart    # API calls
│   └── storage_service.dart          # Local storage
├── providers/
│   └── food_analysis_provider.dart   # State management
├── screens/
│   ├── food_analysis_screen.dart     # Main screen
│   ├── history_screen.dart           # History screen
│   └── detail_screen.dart            # Detail screen
├── widgets/
│   ├── nutrition_card.dart           # Nutrition display
│   └── history_item.dart             # History list item
└── utils/
    ├── constants.dart                # Constants
    └── helpers.dart                  # Helper functions
```

---

## 📞 Support

- 📧 Email: api-support@example.com
- 📖 Docs: https://api.example.com/docs
- 🐛 Issues: https://github.com/issues

---

**Version**: 1.0  
**Last Updated**: January 16, 2025  
**Maintained by**: API Team
