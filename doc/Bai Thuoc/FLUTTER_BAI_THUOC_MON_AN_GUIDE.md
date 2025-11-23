# 📱 Hướng Dẫn Tích Hợp Bài Thuốc & Món Ăn cho Flutter App

> Tài liệu chi tiết dành cho Flutter developers để tích hợp các tính năng liên quan đến **Bài Thuốc** (Medical Articles) và **Phân Tích Thành Phần Dinh Dưỡng Món Ăn** (Food Analysis).

---

## 📑 Mục Lục

1. [Tổng Quan](#tổng-quan)
2. [Hướng Dẫn Cơ Bản](#hướng-dẫn-cơ-bản)
3. [API Bài Thuốc](#api-bài-thuốc)
4. [API Phân Tích Món Ăn](#api-phân-tích-món-ăn)
5. [Mô Hình Dữ Liệu](#mô-hình-dữ-liệu)
6. [Ví Dụ Code Flutter](#ví-dụ-code-flutter)
7. [Xử Lý Lỗi](#xử-lý-lỗi)
8. [Best Practices](#best-practices)

---

## 🎯 Tổng Quan

### Chức Năng Bài Thuốc
- 📚 Xem danh sách bài thuốc với phân trang
- 📄 Xem chi tiết từng bài thuốc
- ❤️ Theo dõi lượt thích và lượt xem
- 👤 Xem thông tin tác giả của bài viết
- ➕ Tạo bài thuốc mới (cần đăng nhập)

### Chức Năng Phân Tích Món Ăn
- 📸 Chụp ảnh hoặc chọn ảnh từ thư viện
- 🤖 Sử dụng AI để phân tích thành phần dinh dưỡng
- 📊 Xem chi tiết dinh dưỡng (calo, protein, chất béo, carbs)
- ✅ Đánh giá tính phù hợp với phác đồ sức khỏe của người dùng
- 💾 Lưu lịch sử phân tích

---

## 🚀 Hướng Dẫn Cơ Bản

### API Base URL
```dart
const String BASE_URL = 'https://localhost:7043/api';
```

### Headers Cơ Bản
```dart
Map<String, String> headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
};

// Khi cần xác thực (nếu endpoint yêu cầu)
Map<String, String> headersWithAuth = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer $token',
};
```

---

## 📚 API Bài Thuốc

### Base Path: `/api/BaiThuocAPI`

#### 1️⃣ Lấy Danh Sách Bài Thuốc

**Endpoint**: `GET /api/BaiThuocAPI`

**Tham Số Query**:
| Tham Số | Kiểu | Mặc Định | Mô Tả |
|---------|------|---------|-------|
| `page` | integer | 1 | Số trang (bắt đầu từ 1) |
| `pageSize` | integer | 10 | Số bài mỗi trang (max 50) |

**Response (200 OK)**:
```json
{
  "success": true,
  "message": "Lấy danh sách bài thuốc thành công",
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "ten": "10 Cách Giảm Cân Hiệu Quả",
      "moTa": "Bài viết giới thiệu các phương pháp giảm cân an toàn...",
      "huongDanSuDung": "Đọc và thực hiện theo hướng dẫn...",
      "ngayTao": "2025-01-15T10:30:00Z",
      "image": "https://localhost:7043/uploads/baithuoc/image1.jpg",
      "soLuotThich": 125,
      "soLuotXem": 2500,
      "authorId": "user-123",
      "authorName": "Dr. Nguyen A",
      "authorAvatar": "https://localhost:7043/uploads/avatars/dr-nguyen.jpg"
    }
    // ... more items
  ]
}
```

**Mã Lỗi**:
- `400 Bad Request`: Tham số không hợp lệ
- `500 Internal Server Error`: Lỗi server

---

#### 2️⃣ Lấy Chi Tiết Bài Thuốc

**Endpoint**: `GET /api/BaiThuocAPI/{id}`

**Tham Số Path**:
| Tham Số | Kiểu | Mô Tả |
|---------|------|-------|
| `id` | GUID | ID của bài thuốc |

**Response (200 OK)**:
```json
{
  "success": true,
  "message": "Lấy chi tiết bài thuốc thành công",
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "ten": "10 Cách Giảm Cân Hiệu Quả",
    "moTa": "Bài viết giới thiệu các phương pháp giảm cân an toàn và khoa học...",
    "huongDanSuDung": "1. Ăn uống cân bằng\n2. Tập thể dục đều đặn\n3. Ngủ đủ giấc",
    "ngayTao": "2025-01-15T10:30:00Z",
    "image": "https://localhost:7043/uploads/baithuoc/image1.jpg",
    "soLuotThich": 125,
    "soLuotXem": 2501,
    "authorId": "user-123",
    "authorName": "Dr. Nguyen A",
    "authorAvatar": "https://localhost:7043/uploads/avatars/dr-nguyen.jpg"
  }
}
```

**Lưu ý**: Mỗi lần gọi API này, `soLuotXem` sẽ tăng lên 1.

**Mã Lỗi**:
- `404 Not Found`: Bài thuốc không tồn tại

---

#### 3️⃣ Tạo Bài Thuốc Mới

**Endpoint**: `POST /api/BaiThuocAPI/create`

**Yêu Cầu**: ✅ Cần đăng nhập (Requires Authentication)

**Content-Type**: `multipart/form-data`

**Tham Số Form**:
| Tham Số | Kiểu | Bắt Buộc | Mô Tả |
|---------|------|---------|-------|
| `ten` | string | ✅ Có | Tiêu đề bài thuốc (max 500 ký tự) |
| `moTa` | string | ❌ Không | Mô tả chi tiết (max 5000 ký tự) |
| `huongDanSuDung` | string | ❌ Không | Hướng dẫn sử dụng (max 5000 ký tự) |
| `image` | file | ❌ Không | Ảnh đại diện (max 5MB) |

**Request Example (cURL)**:
```bash
curl -X POST "https://localhost:7043/api/BaiThuocAPI/create" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "ten=10 Cách Giảm Cân Hiệu Quả" \
  -F "moTa=Bài viết giới thiệu..." \
  -F "huongDanSuDung=1. Ăn uống cân bằng..." \
  -F "image=@/path/to/image.jpg"
```

**Response (200 OK)**:
```json
{
  "success": true,
  "message": "Tạo bài thuốc thành công",
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "ten": "10 Cách Giảm Cân Hiệu Quả",
    "moTa": "Bài viết giới thiệu...",
    "huongDanSuDung": "1. Ăn uống cân bằng...",
    "ngayTao": "2025-01-16T15:45:00Z",
    "image": "https://localhost:7043/uploads/baithuoc/abc123def456.jpg",
    "soLuotThich": 0,
    "soLuotXem": 0
  }
}
```

**Mã Lỗi**:
- `400 Bad Request`: Thiếu thông tin bắt buộc hoặc file quá lớn
- `401 Unauthorized`: Chưa đăng nhập

---

## 🍲 API Phân Tích Món Ăn

### Base Path: `/api/FoodAnalysis`

#### 1️⃣ Phân Tích Ảnh Món Ăn (AI)

**Endpoint**: `POST /api/FoodAnalysis/analyze`

**Content-Type**: `multipart/form-data`

**Tham Số Form**:
| Tham Số | Kiểu | Bắt Buộc | Mô Tả |
|---------|------|---------|-------|
| `image` | file | ✅ Có | Ảnh món ăn (JPG, PNG) |
| `userId` | string | ✅ Có | ID của người dùng |
| `mealType` | string | ❌ Không | Loại bữa ăn: "breakfast", "lunch", "dinner", "snack" |

**Request Example (cURL)**:
```bash
curl -X POST "https://localhost:7043/api/FoodAnalysis/analyze" \
  -F "image=@/path/to/food.jpg" \
  -F "userId=user-123" \
  -F "mealType=lunch"
```

**Response (200 OK)**:
```json
{
  "id": "prediction-123",
  "userId": "user-123",
  "imagePath": "https://localhost:7043/uploads/food_analysis_2025.jpg",
  "foodName": "Cơm chiên tôm",
  "confidence": 0.92,
  "calories": 450.5,
  "protein": 18.3,
  "fat": 15.2,
  "carbs": 52.1,
  "mealType": "lunch",
  "suitable": 85,
  "suggestions": "Món ăn này phù hợp với phác đồ của bạn. Hãy cân bằng với rau xanh.",
  "advice": "Bạn nên ăn kèm với salad rau xanh để cân bằng chất xơ.",
  "details": [
    {
      "label": "Tôm",
      "weight": 150,
      "confidence": 0.95,
      "calories": 180,
      "protein": 22,
      "fat": 2,
      "carbs": 0
    },
    {
      "label": "Cơm",
      "weight": 200,
      "confidence": 0.98,
      "calories": 260,
      "protein": 4,
      "fat": 1,
      "carbs": 52
    }
  ],
  "createdAt": "2025-01-16T14:30:00Z"
}
```

**Giải Thích Trường**:
- `confidence`: Độ tin cậy của mô hình AI (0-1)
- `suitable`: Điểm phù hợp với phác đồ sức khỏe (0-100)
- `suggestions`: Gợi ý ăn uống
- `details`: Chi tiết từng thành phần trong món ăn

**Mã Lỗi**:
- `400 Bad Request`: Thiếu tham số hoặc file không phải ảnh
- `500 Internal Server Error`: Lỗi khi gọi AI model

---

## 📦 Mô Hình Dữ Liệu

### 1. BaiThuoc Model (Bài Thuốc)

```typescript
interface BaiThuoc {
  id: string;                    // GUID
  ten: string;                   // Tiêu đề (max 500 ký tự)
  moTa?: string;                 // Mô tả (max 5000 ký tự)
  huongDanSuDung?: string;       // Hướng dẫn (max 5000 ký tự)
  ngayTao: Date;                 // Ngày tạo
  image?: string;                // URL ảnh đại diện
  soLuotThich: number;           // Số lượt thích
  soLuotXem: number;             // Số lượt xem
  trangThai: number;             // 1: Active, 0: Inactive
  authorId: string;              // ID tác giả
  authorName: string;            // Tên tác giả
  authorAvatar?: string;         // Avatar tác giả
}
```

### 2. FoodAnalysisResult Model (Kết Quả Phân Tích)

```typescript
interface FoodAnalysisResult {
  id: string;                    // Prediction ID
  userId: string;                // ID người dùng
  imagePath: string;             // URL ảnh đã lưu
  foodName: string;              // Tên món ăn được nhận diện
  confidence: number;            // Độ tin cậy (0-1)
  calories: number;              // Năng lượng (kcal)
  protein: number;               // Protein (grams)
  fat: number;                   // Chất béo (grams)
  carbs: number;                 // Carbohydrates (grams)
  mealType: string;              // Loại bữa ăn
  suitable: number;              // Điểm phù hợp (0-100)
  suggestions: string;           // Gợi ý ăn uống
  advice: string;                // Lời khuyên
  createdAt: Date;               // Thời gian phân tích
  details: FoodDetail[];         // Chi tiết từng thành phần
}

interface FoodDetail {
  label: string;                 // Tên thành phần
  weight: number;                // Khối lượng (grams)
  confidence: number;            // Độ tin cậy
  calories: number;              // Calo
  protein: number;               // Protein
  fat: number;                   // Chất béo
  carbs: number;                 // Carbohydrates
}
```

### 3. API Response Wrapper

```typescript
interface ApiResponse<T> {
  success: boolean;              // Trạng thái thành công
  message: string;               // Thông báo
  data?: T;                      // Dữ liệu (nếu có)
  errors?: string[];             // Danh sách lỗi (nếu có)
}
```

---

## 💻 Ví Dụ Code Flutter

### 1. Model Classes

```dart
// lib/models/bai_thuoc.dart
class BaiThuoc {
  final String id;
  final String ten;
  final String? moTa;
  final String? huongDanSuDung;
  final DateTime ngayTao;
  final String? image;
  final int soLuotThich;
  final int soLuotXem;
  final String authorId;
  final String authorName;
  final String? authorAvatar;

  BaiThuoc({
    required this.id,
    required this.ten,
    this.moTa,
    this.huongDanSuDung,
    required this.ngayTao,
    this.image,
    required this.soLuotThich,
    required this.soLuotXem,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
  });

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
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
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
    'authorId': authorId,
    'authorName': authorName,
    'authorAvatar': authorAvatar,
  };
}
```

```dart
// lib/models/food_analysis.dart
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

  FoodAnalysisResult({
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

  FoodDetail({
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
}
```

### 2. API Service

```dart
// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../models/bai_thuoc.dart';
import '../models/food_analysis.dart';

class ApiService {
  static const String baseUrl = 'https://localhost:7043/api';
  static const String baiThuocEndpoint = '$baseUrl/BaiThuocAPI';
  static const String foodAnalysisEndpoint = '$baseUrl/FoodAnalysis';

  String? _token;

  // Constructor
  ApiService({String? token}) {
    _token = token;
  }

  // Set token (sau khi login)
  void setToken(String token) {
    _token = token;
  }

  // ============ BAITH THUỐC APIs ============

  /// Lấy danh sách bài thuốc có phân trang
  Future<List<BaiThuoc>> getBaiThuocList({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final Uri uri = Uri.parse(baiThuocEndpoint).replace(
        queryParameters: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: _getHeaders(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> dataList = jsonData['data'] as List<dynamic>;
          return dataList
              .map((item) => BaiThuoc.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(jsonData['message'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Failed to load bai thuoc (${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy chi tiết bài thuốc
  Future<BaiThuoc> getBaiThuocDetail(String id) async {
    try {
      final Uri uri = Uri.parse('$baiThuocEndpoint/$id');

      final response = await http.get(
        uri,
        headers: _getHeaders(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return BaiThuoc.fromJson(jsonData['data'] as Map<String, dynamic>);
        } else {
          throw Exception(jsonData['message'] ?? 'Unknown error');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Bài thuốc không tồn tại');
      } else {
        throw Exception('Failed to load bai thuoc detail (${response.statusCode})');
      }
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
        throw Exception('Bạn cần đăng nhập để tạo bài thuốc');
      }

      final Uri uri = Uri.parse('$baiThuocEndpoint/create');
      final request = http.MultipartRequest('POST', uri);

      // Set headers
      request.headers.addAll(_getHeaders());

      // Add form fields
      request.fields['ten'] = ten;
      if (moTa != null) request.fields['moTa'] = moTa;
      if (huongDanSuDung != null) {
        request.fields['huongDanSuDung'] = huongDanSuDung;
      }

      // Add image file
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      final streamedResponse = await request.send()
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw Exception('Request timeout'),
          );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return BaiThuoc.fromJson(jsonData['data'] as Map<String, dynamic>);
        } else {
          throw Exception(jsonData['message'] ?? 'Unknown error');
        }
      } else if (response.statusCode == 400) {
        final jsonData = json.decode(response.body);
        throw Exception(jsonData['message'] ?? 'Bad request');
      } else if (response.statusCode == 401) {
        throw Exception('Bạn cần đăng nhập');
      } else {
        throw Exception('Failed to create bai thuoc (${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ============ FOOD ANALYSIS APIs ============

  /// Phân tích ảnh món ăn
  Future<FoodAnalysisResult> analyzeFoodImage({
    required File imageFile,
    required String userId,
    String? mealType,
  }) async {
    try {
      final Uri uri = Uri.parse('$foodAnalysisEndpoint/analyze');
      final request = http.MultipartRequest('POST', uri);

      // Set headers
      request.headers.addAll(_getHeaders());

      // Add form fields
      request.fields['userId'] = userId;
      if (mealType != null) {
        request.fields['mealType'] = mealType;
      }

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse = await request.send()
          .timeout(
            const Duration(minutes: 2),
            onTimeout: () => throw Exception('Request timeout'),
          );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return FoodAnalysisResult.fromJson(jsonData as Map<String, dynamic>);
      } else if (response.statusCode == 400) {
        final jsonData = json.decode(response.body);
        throw Exception(jsonData['message'] ?? 'Bad request');
      } else {
        throw Exception('Failed to analyze food (${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ============ HELPER METHODS ============

  /// Xây dựng headers cho request
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
}
```

### 3. Provider / State Management (với Riverpod hoặc GetX)

**Ví dụ với Riverpod:**

```dart
// lib/providers/bai_thuoc_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/bai_thuoc.dart';

// API Service Provider
final apiServiceProvider = Provider((ref) {
  return ApiService();
});

// Bài Thuốc List Provider (với pagination)
final baiThuocListProvider = FutureProvider.autoDispose.family(
  (ref, int page) async {
    final apiService = ref.watch(apiServiceProvider);
    return apiService.getBaiThuocList(page: page, pageSize: 10);
  },
);

// Bài Thuốc Detail Provider
final baiThuocDetailProvider = FutureProvider.autoDispose.family(
  (ref, String id) async {
    final apiService = ref.watch(apiServiceProvider);
    return apiService.getBaiThuocDetail(id);
  },
);

// Create Bài Thuốc Provider
final createBaiThuocProvider = FutureProvider.autoDispose.family(
  (ref, Map<String, dynamic> params) async {
    final apiService = ref.watch(apiServiceProvider);
    return apiService.createBaiThuoc(
      ten: params['ten'] as String,
      moTa: params['moTa'] as String?,
      huongDanSuDung: params['huongDanSuDung'] as String?,
      imageFile: params['imageFile'] as File?,
    );
  },
);
```

```dart
// lib/providers/food_analysis_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/food_analysis.dart';

// Analyze Food Provider
final analyzeFoodProvider = FutureProvider.autoDispose.family(
  (ref, Map<String, dynamic> params) async {
    final apiService = ref.watch(apiServiceProvider);
    return apiService.analyzeFoodImage(
      imageFile: params['imageFile'] as File,
      userId: params['userId'] as String,
      mealType: params['mealType'] as String?,
    );
  },
);
```

### 4. UI Screens

**Danh sách Bài Thuốc:**

```dart
// lib/screens/bai_thuoc_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bai_thuoc_provider.dart';

class BaiThuocListScreen extends ConsumerStatefulWidget {
  const BaiThuocListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BaiThuocListScreen> createState() => _BaiThuocListScreenState();
}

class _BaiThuocListScreenState extends ConsumerState<BaiThuocListScreen> {
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    final baiThuocListAsync = ref.watch(baiThuocListProvider(_page));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài Thuốc'),
      ),
      body: baiThuocListAsync.when(
        data: (baiThuocList) {
          return ListView.builder(
            itemCount: baiThuocList.length,
            itemBuilder: (context, index) {
              final item = baiThuocList[index];
              return BaiThuocCard(
                baiThuoc: item,
                onTap: () {
                  // Navigate to detail screen
                  Navigator.pushNamed(
                    context,
                    '/bai-thuoc-detail',
                    arguments: item.id,
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Lỗi: ${error.toString()}'),
        ),
      ),
    );
  }
}

// Widget hiển thị từng bài thuốc
class BaiThuocCard extends StatelessWidget {
  final BaiThuoc baiThuoc;
  final VoidCallback onTap;

  const BaiThuocCard({
    Key? key,
    required this.baiThuoc,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh
            if (baiThuoc.image != null)
              Image.network(
                baiThuoc.image!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            // Nội dung
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  Text(
                    baiThuoc.ten,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Mô tả
                  if (baiThuoc.moTa != null)
                    Text(
                      baiThuoc.moTa!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 12),
                  // Thống kê
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '❤️ ${baiThuoc.soLuotThich}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        '👁️ ${baiThuoc.soLuotXem}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Tác giả
                  Row(
                    children: [
                      if (baiThuoc.authorAvatar != null)
                        CircleAvatar(
                          radius: 16,
                          backgroundImage:
                              NetworkImage(baiThuoc.authorAvatar!),
                        ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            baiThuoc.authorName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Ngày: ${baiThuoc.ngayTao.day}/${baiThuoc.ngayTao.month}/${baiThuoc.ngayTao.year}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Chi tiết Bài Thuốc:**

```dart
// lib/screens/bai_thuoc_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bai_thuoc_provider.dart';

class BaiThuocDetailScreen extends ConsumerWidget {
  final String id;

  const BaiThuocDetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baiThuocAsync = ref.watch(baiThuocDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Bài Thuốc'),
      ),
      body: baiThuocAsync.when(
        data: (baiThuoc) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh bài viết
                if (baiThuoc.image != null)
                  Image.network(
                    baiThuoc.image!,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tiêu đề
                      Text(
                        baiThuoc.ten,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      // Thông tin tác giả
                      Row(
                        children: [
                          if (baiThuoc.authorAvatar != null)
                            CircleAvatar(
                              radius: 24,
                              backgroundImage:
                                  NetworkImage(baiThuoc.authorAvatar!),
                            ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                baiThuoc.authorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Ngày: ${baiThuoc.ngayTao.day}/${baiThuoc.ngayTao.month}/${baiThuoc.ngayTao.year}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Thống kê
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('❤️ Thích'),
                              Text(
                                '${baiThuoc.soLuotThich}',
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('👁️ Xem'),
                              Text(
                                '${baiThuoc.soLuotXem}',
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      // Mô tả
                      if (baiThuoc.moTa != null) ...[
                        Text(
                          'Mô Tả',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(baiThuoc.moTa!),
                        const SizedBox(height: 16),
                      ],
                      // Hướng dẫn sử dụng
                      if (baiThuoc.huongDanSuDung != null) ...[
                        Text(
                          'Hướng Dẫn Sử Dụng',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(baiThuoc.huongDanSuDung!),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Lỗi: ${error.toString()}'),
        ),
      ),
    );
  }
}
```

**Phân tích Món Ăn:**

```dart
// lib/screens/food_analysis_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/food_analysis_provider.dart';
import '../models/food_analysis.dart';

class FoodAnalysisScreen extends ConsumerStatefulWidget {
  const FoodAnalysisScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FoodAnalysisScreen> createState() => _FoodAnalysisScreenState();
}

class _FoodAnalysisScreenState extends ConsumerState<FoodAnalysisScreen> {
  File? _selectedImage;
  String _selectedMealType = 'lunch';
  FoodAnalysisResult? _analysisResult;
  bool _isAnalyzing = false;

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  Future<void> _analyzeFood() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh')),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      // Get user ID from auth provider or local storage
      const userId = 'user-123'; // Replace with actual user ID

      final result = await ref.read(
        analyzeFoodProvider({
          'imageFile': _selectedImage!,
          'userId': userId,
          'mealType': _selectedMealType,
        }).future,
      );

      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() => _isAnalyzing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân Tích Món Ăn'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hình ảnh được chọn
              Container(
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : const Center(
                        child: Text('Chưa chọn ảnh'),
                      ),
              ),
              const SizedBox(height: 16),
              // Nút chọn ảnh
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Chọn Ảnh'),
              ),
              const SizedBox(height: 16),
              // Loại bữa ăn
              Text(
                'Loại bữa ăn',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _selectedMealType,
                isExpanded: true,
                onChanged: (value) {
                  setState(() => _selectedMealType = value ?? 'lunch');
                },
                items: const [
                  DropdownMenuItem(value: 'breakfast', child: Text('Bữa sáng')),
                  DropdownMenuItem(value: 'lunch', child: Text('Bữa trưa')),
                  DropdownMenuItem(value: 'dinner', child: Text('Bữa tối')),
                  DropdownMenuItem(value: 'snack', child: Text('Ăn nhẹ')),
                ],
              ),
              const SizedBox(height: 24),
              // Nút phân tích
              ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzeFood,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isAnalyzing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Phân Tích'),
              ),
              const SizedBox(height: 24),
              // Kết quả phân tích
              if (_analysisResult != null) ...[
                _buildAnalysisResult(_analysisResult!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisResult(FoodAnalysisResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Text(
          'Kết Quả Phân Tích',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        // Tên món ăn
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Món ăn được nhận diện'),
                const SizedBox(height: 8),
                Text(
                  result.foodName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Độ tin cậy: ${(result.confidence * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Dinh dưỡng
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông Tin Dinh Dưỡng',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildNutritionRow('Năng lượng', '${result.calories.toStringAsFixed(1)} kcal'),
                _buildNutritionRow('Protein', '${result.protein.toStringAsFixed(1)}g'),
                _buildNutritionRow('Chất béo', '${result.fat.toStringAsFixed(1)}g'),
                _buildNutritionRow('Carbs', '${result.carbs.toStringAsFixed(1)}g'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Đánh giá phù hợp
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Phù Hợp Với Phác Đồ'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: result.suitable / 100,
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${result.suitable}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Gợi ý
        if (result.suggestions.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gợi Ý',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(result.suggestions),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        // Lời khuyên
        if (result.advice.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lời Khuyên',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(result.advice),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        // Chi tiết từng thành phần
        if (result.details.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chi Tiết Từng Thành Phần',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...result.details.map((detail) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.label,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Khối lượng: ${detail.weight}g'),
                          Text('Calo: ${detail.calories.toStringAsFixed(1)} kcal'),
                          Text('Protein: ${detail.protein.toStringAsFixed(1)}g'),
                          Text('Chất béo: ${detail.fat.toStringAsFixed(1)}g'),
                          Text('Carbs: ${detail.carbs.toStringAsFixed(1)}g'),
                          Text('Độ tin cậy: ${(detail.confidence * 100).toStringAsFixed(1)}%'),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
```

---

## 🚨 Xử Lý Lỗi

### Các Mã Lỗi Phổ Biến

| Mã | Ý Nghĩa | Cách Xử Lý |
|-----|---------|-----------|
| 400 | Bad Request | Kiểm tra tham số, định dạng file |
| 401 | Unauthorized | Yêu cầu người dùng đăng nhập |
| 404 | Not Found | Dữ liệu không tồn tại |
| 500 | Internal Server Error | Lỗi server, thử lại sau |

### Ví Dụ Error Handling

```dart
try {
  final result = await apiService.analyzeFoodImage(
    imageFile: imageFile,
    userId: userId,
    mealType: 'lunch',
  );
} on SocketException {
  print('Không có kết nối internet');
} on TimeoutException {
  print('Yêu cầu hết thời gian');
} catch (e) {
  print('Lỗi: ${e.toString()}');
}
```

---

## 💡 Best Practices

### 1. **Caching**
```dart
// Lưu danh sách bài thuốc vào local storage để giảm request
final List<BaiThuoc> cachedBaiThuocs = [];
```

### 2. **Image Optimization**
```dart
// Nén ảnh trước khi gửi lên server
import 'package:image/image.dart' as img;

Future<File> compressImage(File imageFile) async {
  final image = img.decodeImage(imageFile.readAsBytesSync());
  final compressedImage = img.encodeJpg(image!, quality: 85);
  final compressedFile = File(imageFile.path)
    ..writeAsBytesSync(compressedImage);
  return compressedFile;
}
```

### 3. **User Experience**
- Hiển thị loading indicator khi đang tải dữ liệu
- Cung cấp thông báo lỗi rõ ràng bằng tiếng Việt
- Hỗ trợ offline mode nếu có dữ liệu cache

### 4. **Security**
- Lưu token an toàn bằng `flutter_secure_storage`
- Không hardcode token hoặc URL
- Sử dụng HTTPS cho tất cả request

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

// Lưu token
await storage.write(key: 'auth_token', value: token);

// Lấy token
final token = await storage.read(key: 'auth_token');
```

---

## 📞 Support & Contact

Nếu có câu hỏi hoặc gặp vấn đề, vui lòng liên hệ đội phát triển backend.

---

**Version**: 1.0  
**Last Updated**: 16/01/2025  
**Created By**: Development Team
