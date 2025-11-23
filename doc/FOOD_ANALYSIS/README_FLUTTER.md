# 📱 Flutter Food Analysis API Documentation

**Complete guide for Flutter developers to integrate Food Analysis API**

---

## 📖 Documentation Suite

This documentation package contains everything you need to implement Food Analysis feature in your Flutter app.

### Quick Links
- 🚀 **[Quick Reference](./FLUTTER_QUICK_REFERENCE.md)** - 5-15 min read
- 📚 **[Complete Guide](./FLUTTER_FOOD_ANALYSIS_GUIDE.md)** - 1-2 hour read
- 💻 **[Code Examples](./FLUTTER_CODE_EXAMPLES.md)** - Copy-paste ready
- 📋 **[Documentation Index](./FLUTTER_DOCUMENTATION_INDEX.md)** - Navigation

---

## 🎯 What You'll Learn

✅ How Food Analysis API works  
✅ How to setup your Flutter project  
✅ How to integrate with your app  
✅ How to handle images and uploads  
✅ How to display results beautifully  
✅ How to manage state with Provider  
✅ How to handle errors gracefully  
✅ Complete working examples  

---

## ⚡ 5-Minute Getting Started

### 1. Add Dependencies
```bash
flutter pub add dio image_picker provider json_annotation
flutter pub add --dev build_runner json_serializable
```

### 2. Generate Models
```bash
flutter pub run build_runner build
```

### 3. Create API Service
```dart
class FoodAnalysisService {
  final Dio dio = Dio();
  
  Future<FoodAnalysisResponse> analyzeFood({
    required String userId,
    required XFile imageFile,
  }) async {
    FormData formData = FormData.fromMap({
      'UserId': userId,
      'Image': await MultipartFile.fromFile(imageFile.path),
    });
    
    Response response = await dio.post(
      'https://localhost:7135/api/FoodAnalysis/analyze',
      data: formData,
    );
    
    return FoodAnalysisResponse.fromJson(response.data);
  }
}
```

### 4. Use in Widget
```dart
ElevatedButton(
  onPressed: () async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final result = await service.analyzeFood(
        userId: 'user-id',
        imageFile: image,
      );
      // Display result
    }
  },
  child: Text('Analyze Food'),
)
```

---

## 📊 API Overview

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/analyze` | POST | Upload & analyze food image |
| `/history/{userId}` | GET | Get analysis history |
| `/history/{id}` | DELETE | Delete analysis record |

---

## 🎨 Feature Highlights

### Image Analysis
- 📸 Capture or pick from gallery
- 🤖 AI-powered food recognition
- 📊 Detailed nutrition breakdown
- ⏱️ 5-15 second processing time

### Health Integration
- 💪 Compare with user's health plan
- 📈 Calculate suitability score (0-100%)
- 💡 Get personalized advice
- 📝 Track nutrition history

### Beautiful UI
- 📱 Modern Material Design
- 🎨 Color-coded nutrition info
- 📊 Progress indicators
- 🌐 Responsive layouts

---

## 📚 Learning Paths

### Path 1: I'm New to APIs (2 hours)
1. Read: Tổng Quan section
2. Read: Kiến Thức Nền Tảng section
3. Read: Flutter Implementation section
4. Review: Code Examples
5. Practice: Build a simple screen

### Path 2: I Know APIs (30 minutes)
1. Skim: Quick Reference
2. Review: Code Examples
3. Copy: Advanced example
4. Adapt: To your project

### Path 3: Just Get It Done (15 minutes)
1. Read: 5-Minute Setup above
2. Copy: Simple Widget example
3. Run: Test it out

---

## 🛠️ Technology Stack

- **HTTP Client**: Dio
- **State Management**: Provider
- **Image Picker**: image_picker
- **JSON Serialization**: json_serializable
- **Utilities**: intl (date formatting)

---

## 📝 Example Project Structure

```
lib/
├── main.dart
├── models/
│   └── food_analysis_models.dart
├── services/
│   └── food_analysis_service.dart
├── providers/
│   └── food_analysis_provider.dart
├── screens/
│   ├── food_analysis_screen.dart
│   └── history_screen.dart
└── widgets/
    ├── nutrition_card.dart
    └── history_item.dart
```

---

## 🚀 Features Checklist

- [x] Image upload (camera & gallery)
- [x] Food recognition
- [x] Nutrition calculation
- [x] Health plan comparison
- [x] Suitability scoring
- [x] AI advice generation
- [x] History management
- [x] Error handling
- [x] Loading states
- [x] Beautiful UI

---

## ⚠️ Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Image too large | Compress before upload |
| Timeout | Increase Dio timeout to 60s |
| Models not generated | Run `flutter pub run build_runner build` |
| 400 Bad Request | Verify userId format & image |
| Connection refused | Check server is running |

---

## 📞 Support

- 📖 Full Documentation: See doc files in this folder
- 💬 Questions: Check FAQ section in Quick Reference
- 🐛 Bugs: Report with code example
- 💡 Suggestions: Create an issue

---

## 📊 Response Example

```json
{
  "id": 123,
  "userId": "728b7060-5a5c-4e25-a034-24cfde225029",
  "imagePath": "https://localhost:7135/uploads/abc123.jpg",
  "foodName": "Phở Bò",
  "confidence": 0.92,
  "calories": 425.5,
  "protein": 28.3,
  "fat": 12.4,
  "carbs": 48.2,
  "mealType": "lunch",
  "createdAt": "2025-01-16T10:30:00Z",
  "advice": "✓ Bữa ăn này phù hợp với phác đồ của bạn. Calories: 425.5/2000. Còn lại: 1574.5 kcal.",
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

---

## 🎓 Key Concepts

### Confidence Score
- Range: 0 to 1 (0% to 100%)
- Higher = more accurate
- Display as percentage: `(confidence * 100).toStringAsFixed(1)`

### Suitability Score
- Range: 0 to 100%
- Compare with user's health plan
- Color code: Green (>90%), Yellow (>70%), Orange (>50%), Red (<50%)

### Meal Types
- breakfast
- lunch
- dinner
- snack

### Nutrition Units
- Calories: kcal
- Protein: grams
- Fat: grams
- Carbs: grams

---

## 📈 Performance Tips

1. **Compress Images**: Before upload, reduce size to ~500KB
2. **Cache Results**: Store locally using SharedPreferences
3. **Pagination**: Use page/pageSize for history
4. **Debounce**: Prevent multiple rapid requests
5. **Error Recovery**: Implement automatic retry

---

## 🔐 Security Notes

- Always verify userId before sending
- Validate image file type on client side
- Use HTTPS in production
- Don't hardcode API URLs (use config)
- Handle sensitive data carefully

---

## 📱 Tested On

- Flutter 3.3+
- Dart 3.0+
- Android 7+
- iOS 11+

---

## 📄 License

This documentation is provided as-is for internal use.

---

## ✅ Next Steps

1. **Choose your learning path** (see above)
2. **Start with Quick Reference** if in hurry
3. **Read Complete Guide** for deep understanding
4. **Copy Code Examples** for your project
5. **Test with your API** - replace with your server URL
6. **Deploy** - switch to production URL

---

## 🎉 You're Ready!

Everything you need is in this documentation package. 

**Start with**: [FLUTTER_QUICK_REFERENCE.md](./FLUTTER_QUICK_REFERENCE.md)

---

**Version**: 1.0  
**Last Updated**: January 16, 2025  
**Status**: ✅ Complete & Ready to Use
