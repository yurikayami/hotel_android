# Food Analysis Screen - Redesigned Structure

## Tổng quan

Màn hình phân tích món ăn đã được **chia thành 3 màn hình riêng biệt** để cải thiện trải nghiệm người dùng và dễ bảo trì hơn.

## Cấu trúc mới

### 1. **FoodCameraScreen** (`food_camera_screen.dart`)
Màn hình chính với giao diện camera AI để chụp hoặc chọn ảnh.

**Tính năng:**
- 🎯 **Scanner Frame Animation**: Khung quét với hiệu ứng scanning line
- 🍽️ **Meal Type Selector**: Chọn loại bữa ăn (Sáng/Trưa/Tối/Phụ)
- 📷 **Action Buttons**:
  - Nút Thư viện: Chọn ảnh từ gallery
  - Nút Chụp (giữa): Chụp ảnh mới
  - Nút Lịch sử: Xem lịch sử phân tích
- 🎨 **Material 3 Design**: Bottom sheet với handle bar, gradient effects

**UI Elements:**
```
├── Top Bar
│   ├── Back Button
│   ├── "AI Camera" Badge
│   └── Settings Button
├── Scanner Frame (Center)
│   ├── Corner Borders (animated)
│   ├── Scanning Line (moving gradient)
│   └── Hint Chip
└── Bottom Controls Panel
    ├── Handle Bar
    ├── Meal Type Selector (horizontal scroll)
    └── Action Buttons Row
```

### 2. **FoodResultScreen** (`food_result_screen.dart`)
Màn hình hiển thị kết quả phân tích với thông tin dinh dưỡng đầy đủ.

**Tính năng:**
- 🖼️ **Hero Image**: Ảnh món ăn với gradient overlay
- 📊 **Nutrition Grid**: Hiển thị Calories, Protein, Carbs
- 💡 **AI Insights Card**: Đánh giá và gợi ý từ AI
- ℹ️ **Detail Modal**: Xem chi tiết đầy đủ thông tin dinh dưỡng
- 🔄 **Share & More Options**: Chia sẻ và tùy chọn khác

**UI Elements:**
```
├── Sliver App Bar (collapsible)
│   ├── Hero Image (40% screen height)
│   ├── Back, Share, More buttons
│   └── Gradient Overlay
└── Content Sheet
    ├── Header
    │   ├── Meal Type Badge
    │   ├── Date/Time
    │   ├── Food Name (large)
    │   └── Confidence Indicator
    ├── Nutrition Grid (3 cards)
    ├── AI Insights Card
    └── View Details Button
```

### 3. **FoodHistoryScreen** (`food_history_screen.dart`)
Màn hình lịch sử với filter và danh sách các phân tích trước đây.

**Tính năng:**
- 🔍 **Smart Filters**: 
  - Thời gian: Tất cả/Hôm nay/Tuần này/Tháng này
  - Loại bữa: Tất cả/Sáng/Trưa/Tối/Phụ
- 📋 **History Cards**: Hiển thị thumbnail, tên món, calories, ngày giờ
- 🗑️ **Delete Function**: Xóa bản ghi với confirmation dialog
- 🔄 **Pull to Refresh**: Làm mới danh sách
- ➡️ **Navigate to Details**: Tap vào card để xem chi tiết

**UI Elements:**
```
├── Sliver App Bar
│   ├── Title: "Lịch sử ăn uống"
│   └── Calendar Button
├── Filters Section
│   ├── Time Filters (chips)
│   └── Meal Type Filters (chips)
└── History List
    └── History Cards
        ├── Food Thumbnail (Hero)
        ├── Food Info
        │   ├── Name
        │   ├── Meal Badge + Date
        │   └── Calories
        └── Delete Button
```

## Navigation Flow

```
HomeScreen
    │
    ├─> FoodAnalysisScreen (redirect)
    │       │
    │       └─> FoodCameraScreen
    │               │
    │               ├─> [Chụp/Chọn ảnh] ─> FoodResultScreen
    │               │                           │
    │               │                           └─> [Back/Share/Delete]
    │               │
    │               └─> FoodHistoryScreen
    │                       │
    │                       ├─> [Tap card] ─> FoodResultScreen
    │                       └─> [Delete] ─> Confirmation Dialog
```

## Thiết kế theo Material 3

Tất cả 3 màn hình tuân theo nguyên tắc Material 3:

### Color Scheme
- **Primary**: Deep Green `#2E7D32` (health & food theme)
- **Secondary**: Vibrant Orange `#FF6F00` (accent)
- **Surface**: Dynamic based on theme mode
- **Nutrition Colors**:
  - Calories: Orange
  - Protein: Red
  - Carbs: Amber
  - Fat: Blue

### Typography
- **Headlines**: Bold, prominent for food names
- **Body**: Readable, với proper line height
- **Labels**: Small, uppercase cho badges

### Components
- ✅ FilledButton, FilledButton.tonal
- ✅ Card với elevation 2, radius 16
- ✅ FilterChip với selection state
- ✅ Hero transitions
- ✅ SliverAppBar với collapse
- ✅ Modal Bottom Sheets
- ✅ InkWell ripple effects

## State Management

Sử dụng **Provider Pattern** với `FoodAnalysisProvider`:

```dart
FoodAnalysisProvider
├── isLoading: bool
├── errorMessage: String?
├── currentAnalysis: PredictionHistory?
├── filteredHistory: List<PredictionHistory>
├── Methods:
│   ├── analyzeFood()
│   ├── fetchHistory()
│   ├── deleteAnalysis()
│   ├── setTimeFilter()
│   └── setMealFilter()
```

## Improvements from Old Design

### Trước (1 màn hình với TabBar):
❌ Quá nhiều chức năng trong 1 màn
❌ Tab bar chiếm không gian
❌ Khó navigate
❌ Thiếu visual hierarchy

### Sau (3 màn hình riêng):
✅ Mỗi màn hình có mục đích rõ ràng
✅ Tận dụng toàn bộ màn hình
✅ Flow tự nhiên hơn
✅ Dễ maintain và extend
✅ Better animations & transitions
✅ Theo chuẩn Material 3

## Testing Checklist

- [ ] Camera screen hiển thị đúng scanner animation
- [ ] Meal selector hoạt động mượt mà
- [ ] Chụp ảnh và chọn ảnh từ gallery
- [ ] Hiển thị loading overlay khi phân tích
- [ ] Result screen hiển thị đầy đủ thông tin
- [ ] Nutrition cards có màu và icon đúng
- [ ] AI insights card hiển thị đúng
- [ ] Navigate từ history sang result
- [ ] Filters hoạt động (time & meal type)
- [ ] Delete với confirmation dialog
- [ ] Hero transitions mượt mà

## Future Enhancements

### Camera Screen:
- [ ] Flash toggle
- [ ] Camera flip (front/back)
- [ ] Real-time camera preview
- [ ] Zoom controls

### Result Screen:
- [ ] Share functionality (social media)
- [ ] Edit meal info
- [ ] Add notes
- [ ] Compare with daily goals

### History Screen:
- [ ] Date range picker
- [ ] Search by food name
- [ ] Sort options
- [ ] Export to CSV/PDF
- [ ] Statistics & charts

## Files Changed

| File | Status | Description |
|------|--------|-------------|
| `food_analysis_screen.dart` | ♻️ Refactored | Now just redirects to Camera Screen |
| `food_camera_screen.dart` | ✨ New | Main camera interface |
| `food_result_screen.dart` | ✨ New | Analysis result display |
| `food_history_screen.dart` | ✨ New | History with filters |

## Dependencies

Không cần thêm dependencies mới. Sử dụng các package có sẵn:
- `provider` - State management
- `image_picker` - Camera & gallery
- `intl` - Date formatting

---

**Note**: Thiết kế UI theo theme của app (Material 3) thay vì dark mode theme trong file doc gốc, để đảm bảo tính nhất quán với phần còn lại của ứng dụng.
