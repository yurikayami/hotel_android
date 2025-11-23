# 🍽️ Food Analysis Feature - Implementation Guide

## Tổng Quan

Tính năng **Phân Tích Món Ăn** đã được tích hợp thành công vào ứng dụng Hotel Android. Feature này cho phép người dùng:

- ✅ Chụp ảnh hoặc chọn ảnh món ăn từ thư viện
- ✅ Phân tích món ăn bằng AI để nhận thông tin dinh dưỡng
- ✅ Xem lời khuyên dựa trên phác đồ sức khỏe cá nhân
- ✅ Lưu và xem lại lịch sử phân tích
- ✅ Xóa các bản ghi phân tích không cần thiết

---

## 📁 Cấu Trúc Files

### 1. Services
**File**: `lib/services/food_analysis_service.dart`
- API service để giao tiếp với backend
- Các phương thức:
  - `analyzeFood()`: Upload và phân tích ảnh món ăn
  - `getHistory()`: Lấy lịch sử phân tích
  - `deleteAnalysis()`: Xóa bản ghi phân tích

### 2. Providers
**File**: `lib/providers/food_analysis_provider.dart`
- State management cho food analysis
- Quản lý:
  - Loading state
  - Error messages
  - Current analysis result
  - Analysis history

### 3. Models
**File**: `lib/models/prediction_history.dart`
- Data models:
  - `PredictionHistory`: Kết quả phân tích
  - `PredictionDetail`: Chi tiết từng thành phần

### 4. Screens
**File**: `lib/screens/food/food_analysis_screen.dart`
- UI cho tính năng phân tích món ăn
- 2 tabs:
  - **Phân Tích**: Chụp/chọn ảnh và xem kết quả
  - **Lịch Sử**: Xem các phân tích trước đó

---

## 🚀 Cách Sử Dụng

### 1. Truy Cập Tính Năng

Từ màn hình cá nhân (Profile), nhấn vào nút **"Phân Tích Món Ăn 🍽️"** (màu xanh lá).

### 2. Phân Tích Món Ăn

1. Chọn loại bữa ăn (Sáng, Trưa, Tối, Phụ)
2. Chọn một trong hai tùy chọn:
   - **Chụp Ảnh**: Mở camera để chụp
   - **Chọn Từ Thư Viện**: Chọn ảnh có sẵn
3. Đợi 5-15 giây để AI phân tích
4. Xem kết quả:
   - Tên món ăn
   - Độ tin cậy (%)
   - Thông tin dinh dưỡng (Calories, Protein, Chất béo, Carbs)
   - Lời khuyên dựa trên phác đồ
   - Chi tiết các thành phần (nếu có)

### 3. Xem Lịch Sử

1. Chuyển sang tab **"Lịch Sử"**
2. Xem danh sách các phân tích trước đó
3. Nhấn vào một item để xem chi tiết
4. Kéo xuống để refresh

### 4. Xóa Bản Ghi

- Nhấn vào icon thùng rác ở mỗi item trong lịch sử
- Xác nhận để xóa

---

## 🔧 Cấu Hình Backend

### API Endpoint
Đảm bảo backend đang chạy tại địa chỉ được cấu hình trong `lib/services/api_config.dart`:

```dart
static const String baseUrl = 'https://192.168.1.3:7135/api';
static const String foodAnalysis = '/FoodAnalysis';
```

### Các Endpoint Được Sử Dụng

1. **POST** `/api/FoodAnalysis/analyze`
   - Upload ảnh và nhận kết quả phân tích
   - Request: `multipart/form-data`
     - `userId`: String
     - `image`: File
     - `mealType`: String (optional)

2. **GET** `/api/FoodAnalysis/history/{userId}`
   - Lấy lịch sử phân tích của user
   - Query params: `page`, `pageSize`

3. **DELETE** `/api/FoodAnalysis/history/{id}`
   - Xóa một bản ghi phân tích

---

## 📦 Dependencies

Các package đã được thêm vào `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.9.0              # HTTP client cho multipart upload
  image_picker: ^1.0.4     # Chọn ảnh từ camera/gallery
  provider: ^6.1.1         # State management
  intl: ^0.20.2            # Date formatting
  
dev_dependencies:
  build_runner: ^2.4.7     # Code generation
  json_serializable: ^6.7.1 # JSON serialization
```

---

## 🎨 UI Features

### Design Highlights

1. **Modern Material Design 3**
   - Gradient buttons
   - Elevated cards
   - Smooth animations

2. **Responsive Layout**
   - Adapt to different screen sizes
   - Pull-to-refresh
   - Error handling with user-friendly messages

3. **Visual Feedback**
   - Loading indicators
   - Confidence badges với màu sắc
   - Nutrition info với icons

4. **Meal Type Selector**
   - Choice chips với icons
   - Visual selection state

---

## 🧪 Testing

### Manual Testing Checklist

- [ ] Chụp ảnh từ camera
- [ ] Chọn ảnh từ gallery
- [ ] Kiểm tra loading state
- [ ] Kiểm tra hiển thị kết quả
- [ ] Kiểm tra lịch sử
- [ ] Kiểm tra xóa bản ghi
- [ ] Kiểm tra error handling (no internet, timeout, etc.)
- [ ] Kiểm tra pull-to-refresh

### Test với các trường hợp

1. **Ảnh chất lượng tốt** → Confidence cao
2. **Ảnh mờ/tối** → Confidence thấp
3. **Ảnh không phải món ăn** → Backend trả về lỗi
4. **Không có kết nối mạng** → Hiển thị error message
5. **Lịch sử rỗng** → Hiển thị empty state

---

## 🐛 Troubleshooting

### 1. Lỗi "Target of URI doesn't exist: 'package:dio/dio.dart'"

**Giải pháp**:
```bash
flutter clean
flutter pub get
# Hoặc
dart pub cache repair
flutter pub get
```

Lỗi này chỉ là warning của VS Code analyzer, code vẫn compile và chạy bình thường.

### 2. Timeout khi phân tích

- Tăng timeout trong `FoodAnalysisService`:
```dart
..options.connectTimeout = const Duration(seconds: 60)
..options.receiveTimeout = const Duration(seconds: 60)
```

### 3. Ảnh quá lớn

- Giảm chất lượng ảnh trong `ImagePicker`:
```dart
final image = await picker.pickImage(
  source: source,
  maxWidth: 1920,
  maxHeight: 1080,
  imageQuality: 85, // Giảm xuống 70-80
);
```

### 4. Backend không phản hồi

Kiểm tra:
- Backend đang chạy
- IP address đúng trong `api_config.dart`
- SSL certificate (đã có `MyHttpOverrides` để bypass trong dev)
- Firewall/network settings

---

## 📱 Screenshots Flow

```
Profile Screen
    ↓
[Phân Tích Món Ăn] Button
    ↓
Food Analysis Screen
    ├─ Tab 1: Phân Tích
    │   ├─ Chọn loại bữa ăn
    │   ├─ [Chụp Ảnh] hoặc [Chọn Từ Thư Viện]
    │   ├─ Loading... (5-15s)
    │   └─ Hiển thị kết quả:
    │       ├─ Ảnh món ăn
    │       ├─ Tên + confidence
    │       ├─ Nutrition grid
    │       ├─ Advice box
    │       └─ [Xem Chi Tiết] button
    │
    └─ Tab 2: Lịch Sử
        └─ Danh sách các phân tích
            ├─ Thumbnail + info
            ├─ Tap để xem chi tiết
            └─ Swipe/tap delete icon để xóa
```

---

## 🔐 Security Notes

1. **SSL Bypass**: Hiện tại đang bypass SSL cho development
   ```dart
   HttpOverrides.global = MyHttpOverrides();
   ```
   ⚠️ **Cần remove trong production**

2. **User Authentication**: Feature yêu cầu user phải đăng nhập để lấy `userId`

3. **Image Storage**: Ảnh được lưu trên server, đảm bảo có proper cleanup policy

---

## 🚀 Future Enhancements

### Có thể thêm:
- [ ] Lọc lịch sử theo ngày/bữa ăn
- [ ] Export lịch sử ra PDF/CSV
- [ ] Thống kê dinh dưỡng theo tuần/tháng
- [ ] Đề xuất món ăn dựa trên mục tiêu
- [ ] Chia sẻ kết quả lên social feed
- [ ] Offline mode với local database
- [ ] Multiple image analysis (phân tích nhiều ảnh cùng lúc)
- [ ] Voice input cho meal notes
- [ ] Camera overlay với AR guides

---

## 📚 Related Documentation

- **API Documentation**: `doc/FOOD_ANALYSIS/API_DOCUMENTATION.md`
- **Flutter Guide**: `doc/FOOD_ANALYSIS/FLUTTER_FOOD_ANALYSIS_GUIDE.md`
- **Code Examples**: `doc/FOOD_ANALYSIS/FLUTTER_CODE_EXAMPLES.md`
- **Quick Reference**: `doc/FOOD_ANALYSIS/FLUTTER_QUICK_REFERENCE.md`

---

## ✅ Implementation Status

- ✅ Service layer implementation
- ✅ Provider/state management
- ✅ UI screens (Analysis + History tabs)
- ✅ Image picker integration
- ✅ Error handling
- ✅ Loading states
- ✅ JSON serialization
- ✅ Navigation integration
- ✅ Profile screen button

---

## 👨‍💻 Development Notes

### Code Quality
- Follows Flutter best practices
- Uses SOLID principles
- Proper separation of concerns (Service → Provider → UI)
- Comprehensive error handling
- User-friendly error messages in Vietnamese

### Performance
- Lazy loading for history list
- Image caching with `cached_network_image`
- Efficient state updates with `ChangeNotifier`
- Optimized image picker settings

### Accessibility
- Proper semantic labels
- Clear visual feedback
- Error states with actionable messages
- Loading indicators

---

**Status**: ✅ **HOÀN THÀNH - READY FOR TESTING**

**Created**: 2025-11-16  
**Last Updated**: 2025-11-16  
**Version**: 1.0.0
