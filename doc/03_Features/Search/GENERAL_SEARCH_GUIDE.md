# Hướng Dẫn Sử Dụng Chức Năng Tìm Kiếm Tổng Quát

## 📋 Tổng Quan

Chức năng tìm kiếm tổng quát cho phép người dùng tìm kiếm trên 4 loại dữ liệu:
- **👤 Người dùng** (Users)
- **📝 Bài viết** (Posts)
- **💊 Bài thuốc** (Medicines)
- **🍜 Món ăn** (Dishes)

## 🎯 Cấu Trúc File

```
lib/
├── providers/
│   └── search_provider.dart          # State management cho search
├── screens/
│   ├── search/
│   │   └── general_search_screen.dart  # Màn hình chính
│   └── posts/
│       └── post_feed_screen.dart       # Updated: kết nối nút search
```

## 🚀 Cách Sử Dụng

### 1. **Setup Provider** (trong main.dart)

```dart
import 'package:provider/provider.dart';
import 'providers/search_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // ... Providers khác
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
```

### 2. **Gọi màn hình từ nút Search** (Đã được cấu hình)

```dart
// Trong post_feed_screen.dart - chỉ cần nhấp nút search_rounded
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const GeneralSearchScreen(),
  ),
);
```

### 3. **API Integration**

Tự động gọi API từ `SearchProvider`:

```dart
// API endpoint (được config sẵn)
GET https://192.168.1.3:7135/api/search?q={query}&type={type}&page=1&limit=20
GET https://192.168.1.3:7135/api/search/suggestions?q={query}&type={type}&limit=10
```

## 🎨 UI Components

### Màn hình chính bao gồm:

1. **Search Bar** - Nhập từ khóa
   - Back button
   - Search icon
   - Clear button (khi có text)

2. **Tab Bar** - 5 tabs:
   - Tất cả (all)
   - Người dùng (users)
   - Bài viết (posts)
   - Bài thuốc (medicines)
   - Món ăn (dishes)

3. **Tab Content**:
   - **Tất cả**: Hiển thị 3 kết quả từ mỗi loại
   - **Người dùng**: List view với follow button
   - **Bài viết**: List view với engagement info
   - **Bài thuốc**: List view với thumbnail & price
   - **Món ăn**: Grid view 3 columns

### Card Components:

#### User Card
```
[Avatar] [Tên] [Username]
              [Follow button]
```

#### Post Card
```
[Avatar] [Tên] [@Username] [Thời gian]
[Nội dung bài viết...]
[Số bình luận] [Số lượt thích]
```

#### Medicine Card
```
[Ảnh] [Tên bài thuốc]
      [Mô tả]
      [Lượt xem]
```

#### Dish Card (List)
```
[Ảnh] [Tên món ăn]
      [Giá]
      [Loại] [Số người]
```

#### Dish Card (Grid)
```
[Ảnh]
[Tên]
[Giá]
```

## ⚙️ Cấu Hình & Tuỳ Chỉnh

### 1. Thay đổi Base URL

File: `lib/providers/search_provider.dart`

```dart
const String BASE_URL = 'https://192.168.1.3:7135/api';

// Cập nhật URL này thành API server thực tế
final Uri uri = Uri.parse('$BASE_URL/search?q=$query&type=$_selectedType&page=1&limit=20');
```

### 2. Thay đổi Debounce Time

File: `lib/screens/search/general_search_screen.dart`

```dart
void _onSearchChanged(String query) {
  _debounceTimer?.cancel();
  // Thay đổi 500ms thành giá trị khác nếu cần
  _debounceTimer = Timer(const Duration(milliseconds: 500), () {
    _performSearch(query);
  });
}
```

### 3. Thay đổi số kết quả mỗi tab

File: `lib/screens/search/general_search_screen.dart`

```dart
// Trong _buildAllResultsTab(), thay đổi .take(3) thành .take(5) để hiện 5 kết quả
_buildUsersList(provider.results.users.take(3).toList()), // .take(3)
```

### 4. Thay đổi số columns trong grid dishes

File: `lib/screens/search/general_search_screen.dart`

```dart
// Trong _buildDishesTab()
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,  // Thay đổi thành 2 hoặc 4 tuỳ ý
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
  ),
  // ...
)
```

## 🔌 API Responses Expected

### Search Success Response

```json
{
  "success": true,
  "message": "Tìm kiếm thành công",
  "data": {
    "users": [
      {
        "id": "1",
        "userName": "user1",
        "displayName": "Nguyễn Văn A",
        "email": "user1@example.com",
        "avatarUrl": "https://example.com/avatar.jpg"
      }
    ],
    "posts": [
      {
        "id": "1",
        "noiDung": "Bài viết...",
        "authorId": "1",
        "authorName": "Nguyễn Văn A",
        "authorAvatar": "https://example.com/avatar.jpg",
        "ngayDang": "2025-11-21T10:30:00Z",
        "luotThich": 10,
        "soBinhLuan": 5
      }
    ],
    "medicines": [
      {
        "id": "1",
        "ten": "Thuốc cảm",
        "moTa": "Mô tả...",
        "image": "/uploads/medicine.jpg",
        "soLuotXem": 100
      }
    ],
    "dishes": [
      {
        "id": "1",
        "ten": "Cơm gà",
        "gia": 50000,
        "image": "/uploads/dish.jpg",
        "loai": "Cơm",
        "soNguoi": 1
      }
    ]
  }
}
```

### Error Response

```json
{
  "success": false,
  "message": "Lỗi server",
  "code": "SEARCH_ERROR"
}
```

## 🔄 User Flow

```
1. Người dùng mở màn hình "Dành cho bạn"
    ↓
2. Nhấp nút search (🔍 icon)
    ↓
3. Mở GeneralSearchScreen
    ↓
4. Người dùng nhập từ khóa (với debounce 500ms)
    ↓
5. API gọi /api/search?q={query}
    ↓
6. Kết quả hiển thị trong tabs
    ↓
7. Người dùng nhấp vào item bất kỳ
    ↓
8. Navigate đến detail screen tương ứng
    └─ User → UserProfileScreen(userId)
    └─ Post → PostDetailScreen(post)
    └─ Medicine → BaiThuocDetailScreen(medicineId)
    └─ Dish → MonAnDetailScreen(monAn)
```

## 🧪 Testing

### Test Case 1: Search Tất Cả
```
Input: "cơm"
Expected: Hiển thị users, posts, medicines, dishes chứa "cơm"
```

### Test Case 2: Switch Tab
```
Input: "cơm", nhấp tab "Món ăn"
Expected: Chỉ hiển thị dishes
```

### Test Case 3: Clear Search
```
Input: Nhấp nút X
Expected: Search bar clear, kết quả reset
```

### Test Case 4: Go Back
```
Input: Nhấp back button
Expected: Quay lại màn hình trước
```

### Test Case 5: Navigate to Detail
```
Input: Nhấp vào một user/post/medicine/dish
Expected: Mở detail screen tương ứng
```

## 🐛 Troubleshooting

### Issue: "GeneralSearchScreen not found"
**Giải pháp**: Kiểm tra import trong `post_feed_screen.dart`:
```dart
import '../search/general_search_screen.dart';
```

### Issue: API timeout
**Giải pháp**: Kiểm tra:
1. URL base: `https://192.168.1.3:7135`
2. Kết nối mạng
3. Backend đang chạy

### Issue: Không hiển thị kết quả
**Giải pháp**:
1. Kiểm tra API trả về format đúng
2. Kiểm tra models (User, Post, etc.) có `fromJson()` không
3. Check `searchProvider.errorMessage`

### Issue: Image không load
**Giải pháp**:
1. Kiểm tra `ImageUrlHelper.getFullImageUrl()`
2. Kiểm tra URL image có hợp lệ không
3. Fallback icon sẽ hiển thị nếu error

## 📚 Thêm Tính Năng

### Thêm "Tìm Kiếm Gần Đây"
```dart
// Lưu search history
SharedPreferences prefs = await SharedPreferences.getInstance();
List<String> history = prefs.getStringList('search_history') ?? [];
history.insert(0, query);
await prefs.setStringList('search_history', history.take(10).toList());

// Hiển thị trong state "No Search"
```

### Thêm "Trending Searches"
```dart
// Gọi API /api/search/trending
// Hiển thị dưới search bar
```

### Thêm Filters
```dart
// Filter theo date, price, category, etc.
// Sử dụng QueryBuilder
```

### Thêm Advanced Search
```dart
// Search với regex, fuzzy matching
// Lọc theo multiple criteria
```

## 📖 Referência

- **API Documentation**: `doc/API_BACKEND_DOCUMENTATION.md`
- **Models**: `lib/models/`
- **Providers**: `lib/providers/`
- **Screens**: `lib/screens/`

---

**Last Updated**: November 21, 2025  
**Version**: 1.0
