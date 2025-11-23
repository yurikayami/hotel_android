# 📖 Flutter Food Analysis Documentation Index

> **Complete Documentation Suite** cho Flutter developers tích hợp Food Analysis API

---

## 📚 Documentation Files

### 🚀 Bắt Đầu Nhanh (15 phút)
- **[FLUTTER_QUICK_REFERENCE.md](./FLUTTER_QUICK_REFERENCE.md)**
  - ⚡ 5 phút setup
  - 📚 API reference (bảng)
  - 🎯 Common tasks
  - 🐛 Troubleshooting

👉 **Start here if you're in a hurry!**

---

### 📱 Chi Tiết Hướng Dẫn (1-2 giờ)
- **[FLUTTER_FOOD_ANALYSIS_GUIDE.md](./FLUTTER_FOOD_ANALYSIS_GUIDE.md)**

**Nội dung:**
1. 🎯 Tổng Quan (Mục đích, công nghệ, base URL)
2. 📚 Kiến Thức Nền Tảng
   - Quy trình phân tích ảnh (diagram)
   - Data models & DTOs
   - Health plan integration
3. 🔌 Endpoints & Hàm
   - `POST /analyze` - Phân tích ảnh
   - `GET /history/{userId}` - Lịch sử
   - `DELETE /history/{id}` - Xóa
4. 💻 Flutter Implementation
   - Project setup (pubspec.yaml)
   - Models & DTOs
   - API Service
   - State Management (Provider)
   - Complete UI Screens
5. ⚠️ Error Handling
6. 🎨 UI/UX Best Practices
7. 🧪 Testing & Debugging

👉 **Read this for comprehensive understanding!**

---

### 💻 Code Examples (Phục vụ Copy-Paste)
- **[FLUTTER_CODE_EXAMPLES.md](./FLUTTER_CODE_EXAMPLES.md)**

**Ví dụ:**
1. 🚀 Basic Usage - Setup App
2. 📱 Simple Widget - Đơn giản nhất
3. ⚙️ Advanced: Full Featured Screen
4. 🌐 Network Requests - HTTP calls
5. 🐛 Error Handling - Xử lý lỗi

👉 **Use this to copy working code!**

---

## 🗺️ Learning Path

### Cho New Developer (Chưa biết API là gì)
1. ✅ Đọc "Tổng Quan" trong FLUTTER_FOOD_ANALYSIS_GUIDE.md
2. ✅ Đọc "Kiến Thức Nền Tảng"
3. ✅ Xem Basic Usage example
4. ✅ Thử implement Simple Widget

**Time**: ~1 giờ

### Cho Intermediate Developer (Biết Flutter, chưa dùng API)
1. ✅ Skim qua FLUTTER_QUICK_REFERENCE.md
2. ✅ Đọc "Flutter Implementation" section
3. ✅ Copy Advanced example
4. ✅ Modify theo nhu cầu

**Time**: ~30 phút

### Cho Advanced Developer (Dùng nhiều API)
1. ✅ Xem Quick Reference (5 phút)
2. ✅ Copy code examples (5 phút)
3. ✅ Adapt cho project (10 phút)

**Time**: ~20 phút

---

## 🎯 By Use Case

### "Tôi muốn hiểu API là gì"
→ Read: FLUTTER_FOOD_ANALYSIS_GUIDE.md → Tổng Quan + Kiến Thức Nền Tảng

### "Tôi muốn implement ngay"
→ Read: FLUTTER_QUICK_REFERENCE.md (5 min setup)

### "Tôi muốn full featured app"
→ Read: FLUTTER_CODE_EXAMPLES.md → Advanced section

### "Tôi muốn debug issue"
→ Read: FLUTTER_FOOD_ANALYSIS_GUIDE.md → Error Handling

### "Tôi muốn best practices"
→ Read: FLUTTER_FOOD_ANALYSIS_GUIDE.md → UI/UX Best Practices

---

## 📋 API Endpoints Cheat Sheet

```
POST   /api/FoodAnalysis/analyze
       ↳ Upload ảnh, phân tích
       ↳ Return: FoodAnalysisResponse

GET    /api/FoodAnalysis/history/{userId}
       ↳ Lấy lịch sử phân tích
       ↳ Return: List<FoodAnalysisResponse>

DELETE /api/FoodAnalysis/history/{id}
       ↳ Xóa một phân tích
       ↳ Return: 204 No Content
```

---

## 🏗️ Architecture Overview

```
Flutter App
    ↓
┌─────────────────────┐
│ UI Screens          │
│ (food_analysis...)  │
└──────────┬──────────┘
           ↓
┌─────────────────────┐
│ Provider (State)    │
│ Manage loading,     │
│ current, history    │
└──────────┬──────────┘
           ↓
┌─────────────────────┐
│ Service             │
│ HTTP calls          │
│ (analyzeFood...)    │
└──────────┬──────────┘
           ↓
┌─────────────────────┐
│ Dio Client          │
│ HTTP client         │
└──────────┬──────────┘
           ↓
┌─────────────────────┐
│ Backend API         │
│ https://localhost:  │
│ 7135/api/Food...    │
└─────────────────────┘
```

---

## 📊 Model Reference

### FoodAnalysisResponse (Main Result)
```dart
{
  id: int,
  foodName: string,
  confidence: double (0-1),
  calories: double,
  protein: double,
  fat: double,
  carbs: double,
  suitable: int (0-100),
  advice: string,
  suggestions: string,
  details: List<PredictionDetail>?
}
```

### PredictionDetail (Component Breakdown)
```dart
{
  id: int,
  label: string (ví dụ: "cơm"),
  weight: double (grams),
  calories: double,
  protein: double,
  fat: double,
  carbs: double,
  confidence: double (0-1)
}
```

---

## ⚙️ Setup Checklist

- [ ] Add dependencies (dio, image_picker, provider, json_annotation)
- [ ] Generate models: `flutter pub run build_runner build`
- [ ] Create FoodAnalysisService
- [ ] Create FoodAnalysisProvider
- [ ] Setup Provider in main.dart
- [ ] Create UI screen
- [ ] Test with camera/gallery
- [ ] Handle loading states
- [ ] Handle error states
- [ ] Show results

---

## 🚀 Quick Start Command

```bash
# 1. Add dependencies
flutter pub add dio image_picker provider json_annotation

# 2. Add dev dependencies
flutter pub add --dev build_runner json_serializable

# 3. Generate code
flutter pub run build_runner build

# 4. Run app
flutter run
```

---

## 📞 FAQ

### Q: Bao lâu để phân tích xong?
**A**: 5-15 giây. Phụ thuộc vào chất lượng ảnh.

### Q: Ảnh yêu cầu format gì?
**A**: JPG, PNG, GIF, WebP. Max 5MB (được auto compress).

### Q: Làm sao để sử dụng offline?
**A**: Không thể. Cần kết nối internet vì AI model trên server.

### Q: Tôi có thể cache kết quả không?
**A**: Có. Sử dụng SharedPreferences hoặc local database.

### Q: Làm sao handle network timeout?
**A**: Tăng Dio timeout trong BaseOptions hoặc implement retry logic.

### Q: Có test API sẵn không?
**A**: Có. Xem API_TESTING_GUIDE.md hoặc dùng REST client.

---

## 🔗 Related Documentation

- [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) - Backend API docs
- [API_TESTING_GUIDE.md](./API_TESTING_GUIDE.md) - How to test API
- [FOODANALYSIS_FIX_SUMMARY.md](./FOODANALYSIS_FIX_SUMMARY.md) - Bug fixes
- [MODELS_REFERENCE.md](./MODELS_REFERENCE.md) - Database models

---

## 📈 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Jan 16, 2025 | Initial release |

---

## ✍️ Contributing

Found a bug or want to improve docs?
- Report: Create an issue
- Suggest: Comment in the relevant doc file
- Fix: Submit a PR

---

## 📝 Notes

- All code examples use **Dio** for HTTP client
- All examples use **Provider** for state management
- All examples use **json_serializable** for JSON parsing
- All timestamps are in **UTC**
- All monetary values are in **VND** (Vietnamese Dong)

---

**Last Updated**: January 16, 2025  
**Status**: ✅ Complete  
**Maintained by**: API Team
