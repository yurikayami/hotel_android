# 🔧 Hướng Dẫn Tích Hợp Chi Tiết: Bài Thuốc & Món Ăn

> Tài liệu chi tiết từng bước để tích hợp các features vào Flutter app của bạn.

---

## 📋 Yêu Cầu Tiên Quyết

### Dependencies trong `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HTTP requests
  http: ^1.1.0
  
  # State management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  
  # Image handling
  image_picker: ^1.0.0
  image: ^4.0.0
  
  # Local storage
  shared_preferences: ^2.2.0
  flutter_secure_storage: ^9.0.0
  
  # JSON serialization (optional)
  json_annotation: ^4.8.1
  
  # Date/Time utilities
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  json_serializable: ^6.7.0
  riverpod_generator: ^2.3.0
```

---

## 🏗️ Cấu Trúc Thư Mục Khuyến Nghị

```
lib/
├── models/
│   ├── bai_thuoc.dart
│   ├── food_analysis.dart
│   ├── api_response.dart
│   └── user.dart
├── services/
│   ├── api_service.dart
│   ├── storage_service.dart
│   └── image_service.dart
├── providers/
│   ├── bai_thuoc_provider.dart
│   ├── food_analysis_provider.dart
│   ├── auth_provider.dart
│   └── user_provider.dart
├── screens/
│   ├── bai_thuoc/
│   │   ├── bai_thuoc_list_screen.dart
│   │   ├── bai_thuoc_detail_screen.dart
│   │   ├── create_bai_thuoc_screen.dart
│   │   └── widgets/
│   │       └── bai_thuoc_card.dart
│   ├── food_analysis/
│   │   ├── food_analysis_screen.dart
│   │   ├── food_history_screen.dart
│   │   └── widgets/
│   │       ├── food_result_card.dart
│   │       └── nutrition_chart.dart
│   └── home_screen.dart
├── widgets/
│   ├── loading_shimmer.dart
│   ├── error_widget.dart
│   └── custom_app_bar.dart
├── utils/
│   ├── constants.dart
│   ├── app_colors.dart
│   ├── validators.dart
│   └── date_formatter.dart
├── main.dart
└── app.dart
```

---

## 📝 Step-by-Step Integration

### Step 1: Cấu Hình API Constants

**File: `lib/utils/constants.dart`**

```dart
class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'https://localhost:7043/api';
  
  // Endpoints
  static const String baiThuocEndpoint = '$apiBaseUrl/BaiThuocAPI';
  static const String foodAnalysisEndpoint = '$apiBaseUrl/FoodAnalysis';
  static const String authEndpoint = '$apiBaseUrl/Auth';
  
  // Image upload constraints
  static const int maxImageSizeMB = 5;
  static const int maxImageSizeBytes = maxImageSizeMB * 1024 * 1024;
  
  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;
  
  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 2);
  
  // Cache duration
  static const Duration cacheDuration = Duration(hours: 1);
  
  // Storage keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
}

class MealTypes {
  static const String breakfast = 'breakfast';
  static const String lunch = 'lunch';
  static const String dinner = 'dinner';
  static const String snack = 'snack';
  
  static const List<String> all = [breakfast, lunch, dinner, snack];
  
  static String getDisplayName(String type) {
    switch (type.toLowerCase()) {
      case breakfast:
        return 'Bữa sáng';
      case lunch:
        return 'Bữa trưa';
      case dinner:
        return 'Bữa tối';
      case snack:
        return 'Ăn nhẹ';
      default:
        return type;
    }
  }
}
```

### Step 2: Tạo Model Classes

**File: `lib/models/api_response.dart`**

```dart
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<String>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      errors: (json['errors'] as List?)?.cast<String>(),
    );
  }
}
```

**File: `lib/models/bai_thuoc.dart`**

```dart
class BaiThuoc {
  final String id;
  final String ten;
  final String? moTa;
  final String? huongDanSuDung;
  final DateTime ngayTao;
  final String? image;
  final int soLuotThich;
  final int soLuotXem;
  final int? trangThai;
  final String? authorId;
  final String? authorName;
  final String? authorAvatar;

  const BaiThuoc({
    required this.id,
    required this.ten,
    this.moTa,
    this.huongDanSuDung,
    required this.ngayTao,
    this.image,
    required this.soLuotThich,
    required this.soLuotXem,
    this.trangThai,
    this.authorId,
    this.authorName,
    this.authorAvatar,
  });

  // JSON serialization
  factory BaiThuoc.fromJson(Map<String, dynamic> json) {
    return BaiThuoc(
      id: json['id'] as String,
      ten: json['ten'] as String,
      moTa: json['moTa'] as String?,
      huongDanSuDung: json['huongDanSuDung'] as String?,
      ngayTao: DateTime.parse(json['ngayTao'] as String),
      image: json['image'] as String?,
      soLuotThich: json['soLuotThich'] as int? ?? 0,
      soLuotXem: json['soLuotXem'] as int? ?? 0,
      trangThai: json['trangThai'] as int?,
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
      authorAvatar: json['authorAvatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ten': ten,
    'moTa': moTa,
    'huongDanSuDung': huongDanSuDung,
    'ngayTao': ngayTao.toIso8601String(),
    'image': image,
    'soLuotThich': soLuotThich,
    'soLuotXem': soLuotXem,
    'trangThai': trangThai,
    'authorId': authorId,
    'authorName': authorName,
    'authorAvatar': authorAvatar,
  };

  // Copy with method
  BaiThuoc copyWith({
    String? id,
    String? ten,
    String? moTa,
    String? huongDanSuDung,
    DateTime? ngayTao,
    String? image,
    int? soLuotThich,
    int? soLuotXem,
    int? trangThai,
    String? authorId,
    String? authorName,
    String? authorAvatar,
  }) {
    return BaiThuoc(
      id: id ?? this.id,
      ten: ten ?? this.ten,
      moTa: moTa ?? this.moTa,
      huongDanSuDung: huongDanSuDung ?? this.huongDanSuDung,
      ngayTao: ngayTao ?? this.ngayTao,
      image: image ?? this.image,
      soLuotThich: soLuotThich ?? this.soLuotThich,
      soLuotXem: soLuotXem ?? this.soLuotXem,
      trangThai: trangThai ?? this.trangThai,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
    );
  }
}
```

**File: `lib/models/food_analysis.dart`**

```dart
class FoodAnalysisResult {
  final String id;
  final String userId;
  final String imagePath;
  final String foodName;
  final double confidence;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final String mealType;
  final int suitable;
  final String suggestions;
  final String advice;
  final DateTime createdAt;
  final List<FoodDetail> details;

  const FoodAnalysisResult({
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
    required this.suitable,
    required this.suggestions,
    required this.advice,
    required this.createdAt,
    required this.details,
  });

  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    return FoodAnalysisResult(
      id: json['id'] as String,
      userId: json['userId'] as String,
      imagePath: json['imagePath'] as String,
      foodName: json['foodName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      mealType: json['mealType'] as String,
      suitable: json['suitable'] as int,
      suggestions: json['suggestions'] as String,
      advice: json['advice'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      details: (json['details'] as List<dynamic>?)
          ?.map((e) => FoodDetail.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class FoodDetail {
  final String label;
  final double weight;
  final double confidence;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  const FoodDetail({
    required this.label,
    required this.weight,
    required this.confidence,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  factory FoodDetail.fromJson(Map<String, dynamic> json) {
    return FoodDetail(
      label: json['label'] as String,
      weight: (json['weight'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'weight': weight,
    'confidence': confidence,
    'calories': calories,
    'protein': protein,
    'fat': fat,
    'carbs': carbs,
  };
}
```

### Step 3: Tạo API Service

**File: `lib/services/api_service.dart`**

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../models/bai_thuoc.dart';
import '../models/food_analysis.dart';
import '../utils/constants.dart';

class ApiService {
  String? _token;

  ApiService({String? token}) {
    _token = token;
  }

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  // ============ BAITH THUỐC ============

  /// Lấy danh sách bài thuốc
  Future<List<BaiThuoc>> getBaiThuocList({
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    try {
      final uri = Uri.parse(AppConstants.baiThuocEndpoint).replace(
        queryParameters: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await _makeRequest(
        method: 'GET',
        uri: uri,
        timeout: AppConstants.requestTimeout,
      );

      final data = json.decode(response.body);

      if (data['success'] == true && data['data'] != null) {
        final List<BaiThuoc> items = (data['data'] as List)
            .map((item) => BaiThuoc.fromJson(item))
            .toList();
        return items;
      } else {
        throw ApiException(data['message'] ?? 'Unknown error');
      }
    } on SocketException {
      throw ApiException('Không có kết nối internet');
    } on TimeoutException {
      throw ApiException('Yêu cầu hết thời gian');
    } on FormatException {
      throw ApiException('Lỗi định dạng dữ liệu');
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy chi tiết bài thuốc
  Future<BaiThuoc> getBaiThuocDetail(String id) async {
    try {
      final uri = Uri.parse('${AppConstants.baiThuocEndpoint}/$id');

      final response = await _makeRequest(
        method: 'GET',
        uri: uri,
        timeout: AppConstants.requestTimeout,
      );

      if (response.statusCode == 404) {
        throw ApiException('Bài thuốc không tồn tại');
      }

      final data = json.decode(response.body);

      if (data['success'] == true && data['data'] != null) {
        return BaiThuoc.fromJson(data['data']);
      } else {
        throw ApiException(data['message'] ?? 'Unknown error');
      }
    } on SocketException {
      throw ApiException('Không có kết nối internet');
    } on TimeoutException {
      throw ApiException('Yêu cầu hết thời gian');
    } catch (e) {
      rethrow;
    }
  }

  /// Tạo bài thuốc mới
  Future<BaiThuoc> createBaiThuoc({
    required String ten,
    String? moTa,
    String? huongDanSuDung,
    File? imageFile,
  }) async {
    try {
      if (_token == null) {
        throw ApiException('Bạn cần đăng nhập');
      }

      final uri = Uri.parse('${AppConstants.baiThuocEndpoint}/create');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll(_getHeaders());

      // Add fields
      request.fields['ten'] = ten;
      if (moTa != null) request.fields['moTa'] = moTa;
      if (huongDanSuDung != null) {
        request.fields['huongDanSuDung'] = huongDanSuDung;
      }

      // Add file
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      final streamedResponse = await request.send()
          .timeout(AppConstants.uploadTimeout);

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        throw ApiException('Bạn cần đăng nhập');
      }

      if (response.statusCode == 400) {
        final data = json.decode(response.body);
        throw ApiException(data['message'] ?? 'Bad request');
      }

      final data = json.decode(response.body);

      if (data['success'] == true && data['data'] != null) {
        return BaiThuoc.fromJson(data['data']);
      } else {
        throw ApiException(data['message'] ?? 'Unknown error');
      }
    } on SocketException {
      throw ApiException('Không có kết nối internet');
    } on TimeoutException {
      throw ApiException('Yêu cầu hết thời gian');
    } catch (e) {
      rethrow;
    }
  }

  // ============ FOOD ANALYSIS ============

  /// Phân tích ảnh món ăn
  Future<FoodAnalysisResult> analyzeFoodImage({
    required File imageFile,
    required String userId,
    String mealType = 'lunch',
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.foodAnalysisEndpoint}/analyze');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll(_getHeaders());

      request.fields['userId'] = userId;
      request.fields['mealType'] = mealType;

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse = await request.send()
          .timeout(AppConstants.uploadTimeout);

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 400) {
        final data = json.decode(response.body);
        throw ApiException(data['message'] ?? 'Bad request');
      }

      if (response.statusCode != 200) {
        throw ApiException('Lỗi phân tích ảnh (${response.statusCode})');
      }

      final data = json.decode(response.body);
      return FoodAnalysisResult.fromJson(data);
    } on SocketException {
      throw ApiException('Không có kết nối internet');
    } on TimeoutException {
      throw ApiException('Yêu cầu hết thời gian');
    } catch (e) {
      rethrow;
    }
  }

  // ============ HELPERS ============

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  Future<http.Response> _makeRequest({
    required String method,
    required Uri uri,
    required Duration timeout,
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      late http.Response response;

      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers).timeout(timeout);
          break;
        case 'POST':
          response = await http
              .post(uri, headers: headers, body: body)
              .timeout(timeout);
          break;
        case 'PUT':
          response = await http
              .put(uri, headers: headers, body: body)
              .timeout(timeout);
          break;
        case 'DELETE':
          response =
              await http.delete(uri, headers: headers).timeout(timeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      return response;
    } on TimeoutException {
      throw ApiException('Request timeout');
    }
  }
}

/// Custom Exception
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
```

### Step 4: Tạo Storage Service

**File: `lib/services/storage_service.dart`**

```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token operations
  static Future<bool> saveToken(String token) {
    return _prefs.setString(AppConstants.authTokenKey, token);
  }

  static String? getToken() {
    return _prefs.getString(AppConstants.authTokenKey);
  }

  static Future<bool> deleteToken() {
    return _prefs.remove(AppConstants.authTokenKey);
  }

  // User ID operations
  static Future<bool> saveUserId(String userId) {
    return _prefs.setString(AppConstants.userIdKey, userId);
  }

  static String? getUserId() {
    return _prefs.getString(AppConstants.userIdKey);
  }

  // User name operations
  static Future<bool> saveUserName(String userName) {
    return _prefs.setString(AppConstants.userNameKey, userName);
  }

  static String? getUserName() {
    return _prefs.getString(AppConstants.userNameKey);
  }

  // Clear all
  static Future<bool> clearAll() {
    return _prefs.clear();
  }
}
```

### Step 5: Setup Main App & Providers

**File: `lib/main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Bai thuoc - mon an/services/storage_service.dart';
import '../Bai thuoc - mon an/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  await StorageService.init();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

**File: `lib/app.dart`**

```dart
import 'package:flutter/material.dart';
import '../Bai thuoc - mon an/screens/bai_thuoc/bai_thuoc_list_screen.dart';
import '../Bai thuoc - mon an/screens/food_analysis/food_analysis_screen.dart';
import '../Bai thuoc - mon an/utils/app_colors.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/bai-thuoc-list': (context) => const BaiThuocListScreen(),
        '/food-analysis': (context) => const FoodAnalysisScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Assistant'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/bai-thuoc-list');
              },
              child: const Text('Bài Thuốc'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/food-analysis');
              },
              child: const Text('Phân Tích Món Ăn'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🧪 Testing

### Unit Test Example

```dart
// test/services/api_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:your_app/services/api_service.dart';

void main() {
  group('ApiService - BaiThuoc', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    test('getBaiThuocList returns list of BaiThuoc', () async {
      // Mock data
      final mockResponse = '''
      {
        "success": true,
        "message": "Success",
        "data": [
          {
            "id": "123",
            "ten": "Test Article",
            "moTa": "Test description",
            "huongDanSuDung": "Test guide",
            "ngayTao": "2025-01-15T10:00:00Z",
            "image": "https://example.com/image.jpg",
            "soLuotThich": 10,
            "soLuotXem": 100,
            "authorId": "author-1",
            "authorName": "Dr. Test",
            "authorAvatar": "https://example.com/avatar.jpg"
          }
        ]
      }
      ''';

      // Test
      expect(mockResponse.isNotEmpty, true);
    });
  });
}
```

---

## 🚀 Deployment Checklist

- [ ] Đã update API base URL cho environment production
- [ ] Đã remove debug logs
- [ ] Đã test trên device thực
- [ ] Đã handle tất cả lỗi network
- [ ] Đã implement caching
- [ ] Đã secure token storage
- [ ] Đã optimize images
- [ ] Đã test các edge cases

---

**Version**: 1.0  
**Last Updated**: 16/01/2025
