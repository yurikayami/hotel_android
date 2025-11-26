# 🚀 Flutter Food Analysis - Quick Reference

**Cách nhanh nhất để bắt đầu với Food Analysis API**

---

## ⚡ 5 Phút Setup

### 1. Add Dependencies
```yaml
dependencies:
  dio: ^5.3.0
  image_picker: ^1.0.4
  provider: ^6.0.0
  json_annotation: ^4.8.0
  intl: ^0.19.0

dev_dependencies:
  build_runner: ^2.4.0
  json_serializable: ^6.7.0
```

### 2. Create Models
```dart
@JsonSerializable()
class FoodAnalysisResponse {
  final int id;
  final String foodName;
  final double confidence;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final int suitable;
  final String advice;
  final String suggestions;
  
  // ... toJson(), fromJson() methods
}
```

### 3. Create Service
```dart
class FoodAnalysisService {
  final Dio dio = Dio();
  final String baseUrl = "https://localhost:7135/api/FoodAnalysis";

  Future<FoodAnalysisResponse> analyzeFood({
    required String userId,
    required XFile imageFile,
    String? mealType,
  }) async {
    FormData formData = FormData.fromMap({
      'UserId': userId,
      'Image': await MultipartFile.fromFile(imageFile.path),
      if (mealType != null) 'MealType': mealType,
    });

    Response response = await dio.post(
      '$baseUrl/analyze',
      data: formData,
    );

    return FoodAnalysisResponse.fromJson(response.data);
  }

  Future<List<FoodAnalysisResponse>> getHistory(String userId) async {
    Response response = await dio.get('$baseUrl/history/$userId');
    return (response.data as List)
        .map((e) => FoodAnalysisResponse.fromJson(e))
        .toList();
  }
}
```

### 4. Create Provider
```dart
class FoodAnalysisProvider extends ChangeNotifier {
  final FoodAnalysisService _service;
  
  bool isLoading = false;
  FoodAnalysisResponse? currentAnalysis;
  String? errorMessage;

  FoodAnalysisProvider(this._service);

  Future<void> analyzeFood({
    required String userId,
    required XFile imageFile,
    String? mealType,
  }) async {
    isLoading = true;
    notifyListeners();
    
    try {
      currentAnalysis = await _service.analyzeFood(
        userId: userId,
        imageFile: imageFile,
        mealType: mealType,
      );
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
```

### 5. Use in Widget
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FoodAnalysisProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final picker = ImagePicker();
                final image = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  provider.analyzeFood(
                    userId: 'user-id',
                    imageFile: image,
                  );
                }
              },
              child: const Text('Analyze'),
            ),
            if (provider.isLoading)
              const CircularProgressIndicator()
            else if (provider.currentAnalysis != null)
              Text(provider.currentAnalysis!.foodName),
          ],
        );
      },
    );
  }
}
```

---

## 📚 API Reference

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/analyze` | POST | Phân tích ảnh |
| `/history/{userId}` | GET | Lấy lịch sử |
| `/history/{id}` | DELETE | Xóa phân tích |

### POST /analyze
**Request:**
```json
{
  "userId": "user-id",
  "image": <binary>,
  "mealType": "lunch"
}
```

**Response:**
```json
{
  "id": 123,
  "foodName": "Phở Bò",
  "calories": 425.5,
  "protein": 28.3,
  "fat": 12.4,
  "carbs": 48.2,
  "confidence": 0.92,
  "suitable": 21,
  "advice": "✓ Bữa ăn này phù hợp...",
  "suggestions": "Có thể thêm rau xanh..."
}
```

### GET /history/{userId}
**Response:**
```json
[
  {
    "id": 123,
    "foodName": "Phở Bò",
    "calories": 425.5,
    "suitable": 21,
    "createdAt": "2025-01-16T10:30:00Z"
  },
  // ... more items
]
```

---

## 🎯 Common Tasks

### Show Loading
```dart
if (provider.isLoading) {
  Center(
    child: CircularProgressIndicator(),
  );
}
```

### Show Error
```dart
if (provider.errorMessage != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(provider.errorMessage!)),
  );
}
```

### Display Result
```dart
if (provider.currentAnalysis != null) {
  final a = provider.currentAnalysis!;
  Text('${a.foodName} - ${a.calories} kcal');
}
```

### Pick Image
```dart
final picker = ImagePicker();
final image = await picker.pickImage(source: ImageSource.camera);
```

### Format Numbers
```dart
final calories = 425.5;
calories.toStringAsFixed(1);  // "425.5"
(confidence * 100).toStringAsFixed(1);  // "92.0"
```

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Image too large | Compress before upload |
| Timeout | Increase dio timeout to 60s |
| CORS error | Check server CORS settings |
| Model not generated | Run `flutter pub run build_runner build` |
| 400 Bad Request | Check userId format, image validity |
| 500 Server Error | Retry after 10 seconds |

---

## 📱 Screen Layout

```
┌─────────────────────────┐
│ [Camera] [Gallery]      │  <- Image picker buttons
├─────────────────────────┤
│ [Image Preview]         │
├─────────────────────────┤
│ Meal Type: [Lunch ▼]    │  <- Dropdown
├─────────────────────────┤
│     [ANALYZE FOOD]      │  <- Main button
├─────────────────────────┤
│ ⏳ Analyzing...         │
│    5-15 seconds         │
└─────────────────────────┘

RESULT SCREEN:
┌─────────────────────────┐
│ [Image]                 │
├─────────────────────────┤
│ Phở Bò (92% confident)  │
├─────────────────────────┤
│ 425 kcal | 28g P | 12g F│
├─────────────────────────┤
│ ✓ 21% Suitable          │
│ ▓▓░░░░░░░░ (Progress)   │
├─────────────────────────┤
│ Advice: ...             │
│ Suggestions: ...        │
├─────────────────────────┤
│ [ANALYZE ANOTHER][SAVE] │
└─────────────────────────┘
```

---

## 🔧 Configuration

### Dio Setup
```dart
final dio = Dio(
  BaseOptions(
    baseUrl: 'https://localhost:7135',
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    contentType: 'application/json',
  ),
);
```

### Provider Setup
```dart
MultiProvider(
  providers: [
    Provider<FoodAnalysisService>(
      create: (_) => FoodAnalysisService(),
    ),
    ChangeNotifierProxyProvider<FoodAnalysisService, FoodAnalysisProvider>(
      create: (_) => FoodAnalysisProvider(_),
      update: (_, service, __) => FoodAnalysisProvider(service),
    ),
  ],
  child: MyApp(),
);
```

---

## 📊 State Flow

```
START
  ↓
[User selects image]
  ↓
[isLoading = true]
  ↓
[POST /analyze]
  ↓
  ├─ SUCCESS
  │   ↓
  │  [currentAnalysis = result]
  │   ↓
  │  [Show result UI]
  │
  └─ ERROR
      ↓
     [errorMessage = error]
      ↓
     [Show error snackbar]
```

---

## 🎨 Color Scheme

```dart
// Suitability Colors
> 90%  → Green      (Colors.green)
> 70%  → Light Green (Colors.lightGreen)
> 50%  → Orange     (Colors.orange)
< 50%  → Red        (Colors.red)

// Nutrition Colors
Calories → Red
Protein  → Blue
Fat      → Yellow
Carbs    → Green
```

---

## 💡 Tips & Tricks

1. **Cache Images**: Use `cached_network_image` package
2. **Compress Upload**: Reduce image size before upload
3. **Show Progress**: Add LinearProgressIndicator during analysis
4. **Format Display**: Use `intl` package for dates
5. **Error Recovery**: Implement retry logic with exponential backoff
6. **Logging**: Use `logger` package for debugging
7. **Testing**: Mock Dio with `mockito` package

---

## 📞 Resources

- 📖 Full Guide: See `FLUTTER_FOOD_ANALYSIS_GUIDE.md`
- 💻 Code Examples: See `FLUTTER_CODE_EXAMPLES.md`
- 📚 API Docs: See `API_DOCUMENTATION.md`

---

**Version**: 1.0  
**Last Updated**: January 16, 2025
