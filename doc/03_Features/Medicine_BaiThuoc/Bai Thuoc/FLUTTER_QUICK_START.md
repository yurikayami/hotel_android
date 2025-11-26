# 🚀 Quick Start: Bài Thuốc & Món Ăn cho Flutter

> Hướng dẫn nhanh để bắt đầu tích hợp trong 15 phút.

---

## ⚡ 5 Bước Cơ Bản

### 1️⃣ Thêm Dependencies

```yaml
# pubspec.yaml
dependencies:
  http: ^1.1.0
  image_picker: ^1.0.0
  shared_preferences: ^2.2.0
```

### 2️⃣ Copy Các Model Files

Sao chép các file từ tài liệu chi tiết:
- `models/bai_thuoc.dart`
- `models/food_analysis.dart`
- `services/api_service.dart`

### 3️⃣ Tạo Simple Screens

**Danh sách Bài Thuốc:**

```dart
import 'package:flutter/material.dart';
import '../Bai thuoc - mon an/services/api_service.dart';

class BaiThuocScreen extends StatefulWidget {
  @override
  State<BaiThuocScreen> createState() => _BaiThuocScreenState();
}

class _BaiThuocScreenState extends State<BaiThuocScreen> {
  late ApiService apiService;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bài Thuốc')),
      body: FutureBuilder(
        future: apiService.getBaiThuocList(page: _page),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final baiThuocs = snapshot.data ?? [];

          return ListView.builder(
            itemCount: baiThuocs.length,
            itemBuilder: (context, index) {
              final item = baiThuocs[index];
              return ListTile(
                title: Text(item.ten),
                subtitle: Text(item.moTa ?? ''),
                leading: item.image != null
                    ? Image.network(item.image!, width: 50)
                    : Icon(Icons.article),
                onTap: () {
                  // Navigate to detail
                },
              );
            },
          );
        },
      ),
    );
  }
}
```

**Phân tích Món Ăn:**

```dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../Bai thuoc - mon an/services/api_service.dart';

class FoodAnalysisScreen extends StatefulWidget {
  @override
  State<FoodAnalysisScreen> createState() => _FoodAnalysisScreenState();
}

class _FoodAnalysisScreenState extends State<FoodAnalysisScreen> {
  late ApiService apiService;
  File? selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => selectedImage = File(image.path));
    }
  }

  Future<void> analyzeFood() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chọn ảnh trước')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await apiService.analyzeFoodImage(
        imageFile: selectedImage!,
        userId: 'user-123', // Replace with actual user ID
        mealType: 'lunch',
      );

      print('Food: ${result.foodName}');
      print('Calories: ${result.calories}');
      print('Protein: ${result.protein}g');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phân Tích Món Ăn')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (selectedImage != null)
              Image.file(selectedImage!, height: 250),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: pickImage,
              child: Text('Chọn Ảnh'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : analyzeFood,
              child: isLoading
                  ? CircularProgressIndicator()
                  : Text('Phân Tích'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4️⃣ Test API Connections

```dart
// Thử kết nối
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final apiService = ApiService();
  
  try {
    final baiThuocs = await apiService.getBaiThuocList();
    print('✅ Bài thuốc: ${baiThuocs.length} items');
  } catch (e) {
    print('❌ Lỗi: $e');
  }
}
```

### 5️⃣ Deploy

```bash
flutter build apk
flutter build ios
```

---

## 🔑 API Endpoints Reference

### Bài Thuốc

| Phương Thức | Endpoint | Mô Tả |
|---|---|---|
| GET | `/api/BaiThuocAPI` | Danh sách (page, pageSize) |
| GET | `/api/BaiThuocAPI/{id}` | Chi tiết |
| POST | `/api/BaiThuocAPI/create` | Tạo mới (cần auth) |

### Món Ăn

| Phương Thức | Endpoint | Mô Tả |
|---|---|---|
| POST | `/api/FoodAnalysis/analyze` | Phân tích ảnh |

---

## 💡 Tips & Tricks

### 1. Handle Bearer Token

```dart
class ApiService {
  String? token;

  void setToken(String newToken) {
    token = newToken;
  }

  Map<String, String> getHeaders() {
    final headers = {'Accept': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
```

### 2. Show Loading Dialog

```dart
void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang xử lý...'),
          ],
        ),
      ),
    ),
  );
}
```

### 3. Format Date

```dart
String formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
```

### 4. Validate Image File

```dart
bool isValidImage(File file) {
  final sizeInMB = file.lengthSync() / (1024 * 1024);
  return sizeInMB <= 5;
}
```

---

## 🐛 Troubleshooting

| Vấn Đề | Giải Pháp |
|---|---|
| SSL Certificate Error | Thêm `HttpClient().badCertificateCallback = (_, __, ___) => true;` (dev only) |
| Timeout | Tăng duration: `Duration(minutes: 2)` |
| Image không load | Kiểm tra URL, thêm `https://` |
| 401 Unauthorized | Kiểm tra token, refresh token |
| 404 Not Found | Kiểm tra ID, endpoint URL |

---

## 📱 Full Example App

```dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health App',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Health App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BaiThuocListScreen()),
                );
              },
              child: Text('Bài Thuốc'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FoodAnalysisSimpleScreen()),
                );
              },
              child: Text('Phân Tích Món Ăn'),
            ),
          ],
        ),
      ),
    );
  }
}

class BaiThuocListScreen extends StatefulWidget {
  @override
  State<BaiThuocListScreen> createState() => _BaiThuocListScreenState();
}

class _BaiThuocListScreenState extends State<BaiThuocListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bài Thuốc')),
      body: Center(
        child: Text('Danh sách Bài Thuốc'),
      ),
    );
  }
}

class FoodAnalysisSimpleScreen extends StatefulWidget {
  @override
  State<FoodAnalysisSimpleScreen> createState() =>
      _FoodAnalysisSimpleScreenState();
}

class _FoodAnalysisSimpleScreenState extends State<FoodAnalysisSimpleScreen> {
  File? selectedImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => selectedImage = File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phân Tích')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectedImage != null)
              Image.file(selectedImage!, height: 200),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: pickImage,
              child: Text('Chọn Ảnh'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 📚 Tài Liệu Liên Quan

- [Tài Liệu Chi Tiết](./FLUTTER_INTEGRATION_DETAILED.md)
- [API Reference](./API_QUICK_REFERENCE.md)
- [Complete Guide](./FLUTTER_BAI_THUOC_MON_AN_GUIDE.md)

---

**Version**: 1.0  
**Last Updated**: 16/01/2025
