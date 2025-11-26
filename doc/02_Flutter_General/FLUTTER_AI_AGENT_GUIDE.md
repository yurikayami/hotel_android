# 🤖 FLUTTER AI AGENT - PROJECT BUILD GUIDE

## 📖 GIỚI THIỆU

Đây là tài liệu hướng dẫn chi tiết cho Flutter AI Agent để xây dựng ứng dụng Flutter tích hợp với **Hotel Web API** - một nền tảng về sức khỏe và dinh dưỡng.

---

## 🎯 MỤC TIÊU DỰ ÁN

Xây dựng ứng dụng Flutter Mobile với các tính năng:

1. **Authentication** - Đăng ký, Đăng nhập (Email + Google OAuth)
2. **Social Network** - Đăng bài, Like, Comment
3. **Food Analysis** - Phân tích món ăn từ ảnh bằng AI
4. **Content Management** - Xem món ăn, bài thuốc, nước uống
5. **Health Tracking** - Theo dõi dinh dưỡng hàng ngày

---

## 📚 TÀI LIỆU THAM KHẢO

### 1. API Integration Guide
**File:** `FLUTTER_INTEGRATION_GUIDE.md`

**Nội dung:**
- Tổng quan về API
- Chi tiết tất cả endpoints
- Request/Response formats
- Authentication với JWT
- Error handling
- Media files handling

**Sử dụng cho:**
- Hiểu cấu trúc API
- Biết cách gọi từng endpoint
- Xử lý authentication
- Handle errors

### 2. Database Schema
**File:** `DATABASE_SCHEMA.md`

**Nội dung:**
- Cấu trúc database SQL Server
- Chi tiết từng table
- Relationships giữa các tables
- SQL queries mẫu

**Sử dụng cho:**
- Hiểu data models
- Design Flutter models tương ứng
- Biết relationships giữa các entities

### 3. Flutter Code Examples
**File:** `FLUTTER_CODE_EXAMPLES.md`

**Nội dung:**
- Setup project Flutter
- Models với JSON serialization
- API Service implementation
- UI Screen examples
- Complete working code

**Sử dụng cho:**
- Copy/paste code templates
- Implement services
- Build UI screens
- Testing

---

## 🚀 BƯỚC THỰC HIỆN

### PHASE 1: PROJECT SETUP

#### 1.1. Tạo Flutter Project
```bash
flutter create hotel_web_flutter
cd hotel_web_flutter
```

#### 1.2. Thêm Dependencies vào pubspec.yaml
```yaml
dependencies:
  # Network
  http: ^1.1.0
  dio: ^5.4.0
  
  # State Management
  provider: ^6.1.1
  
  # Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # Image
  image_picker: ^1.0.4
  cached_network_image: ^3.3.0
  
  # JSON
  json_annotation: ^4.8.1
  
  # UI
  intl: ^0.18.1

dev_dependencies:
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
```

#### 1.3. Cấu trúc thư mục
```
lib/
├── main.dart
├── models/
│   ├── user.dart
│   ├── post.dart
│   ├── comment.dart
│   ├── mon_an.dart
│   ├── bai_thuoc.dart
│   └── prediction_history.dart
├── services/
│   ├── api_config.dart
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── post_service.dart
│   └── food_analysis_service.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── posts/
│   │   ├── post_list_screen.dart
│   │   └── post_detail_screen.dart
│   ├── food/
│   │   ├── food_analysis_screen.dart
│   │   └── food_history_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── widgets/
│   ├── post_card.dart
│   ├── comment_item.dart
│   └── loading_indicator.dart
└── providers/
    ├── auth_provider.dart
    └── post_provider.dart
```

---

### PHASE 2: MODELS & SERIALIZATION

#### 2.1. Tạo Models
Tham khảo: `FLUTTER_CODE_EXAMPLES.md` - Section 2

**Models cần tạo:**
- ✅ `User` & `AuthResponse`
- ✅ `Post` & `PostPagedResult`
- ✅ `Comment`
- ✅ `PredictionHistory` & `PredictionDetail`
- ✅ `MonAn`
- ✅ `BaiThuoc`

#### 2.2. Generate Serialization Code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### PHASE 3: API SERVICES

#### 3.1. Base API Service
Tham khảo: `FLUTTER_CODE_EXAMPLES.md` - Section 3

**Implement:**
- ✅ `ApiConfig` - Configuration
- ✅ `ApiService` - Base HTTP methods
  - GET
  - POST
  - DELETE
  - Upload File

**Key Features:**
- JWT Token management
- Auto-attach Authorization header
- Error handling
- Timeout configuration

#### 3.2. Feature Services
Tham khảo: `FLUTTER_INTEGRATION_GUIDE.md` + `FLUTTER_CODE_EXAMPLES.md`

**Implement:**
- ✅ `AuthService`
  - register()
  - login()
  - logout()
  - isLoggedIn()

- ✅ `PostService`
  - getPosts() - with pagination
  - getPost()
  - createPost()
  - likePost()
  - getComments()
  - addComment()
  - deletePost()

- ✅ `FoodAnalysisService`
  - analyzeFood()
  - getHistory()
  - deleteHistory()

- ✅ `MonAnService`
  - getMonAn() - with pagination
  - getMonAnDetail()
  - getPopular()
  - getCategories()

---

### PHASE 4: STATE MANAGEMENT

#### 4.1. Auth Provider
```dart
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoggedIn = false;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkLoginStatus() async {
    _isLoggedIn = await _authService.isLoggedIn();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );
      
      if (response.success) {
        _user = response.user;
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
```

#### 4.2. Setup Provider in main.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API Service
  await ApiService().init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Add more providers
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Web',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoggedIn) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        // Add more routes
      },
    );
  }
}
```

---

### PHASE 5: UI SCREENS

#### 5.1. Authentication Screens
Tham khảo: `FLUTTER_CODE_EXAMPLES.md` - Section 7

**Implement:**
- ✅ `LoginScreen` - Email/Password login
- ✅ `RegisterScreen` - Create new account
- ⚠️ Google OAuth - WebView integration

#### 5.2. Main Screens
**Implement:**

**Home Screen:**
- Bottom Navigation Bar
- 4 tabs: Home, Food Analysis, Profile, More

**Post List Screen:**
- Infinite scroll pagination
- Pull to refresh
- Post cards with:
  - Author info
  - Content
  - Image
  - Like/Comment buttons

**Post Detail Screen:**
- Full post info
- Comments list
- Add comment form

**Food Analysis Screen:**
- Camera / Gallery picker
- Image preview
- Analyze button
- Results display:
  - Food name
  - Confidence
  - Nutrition info
  - AI advice

**Food History Screen:**
- List of analyzed foods
- Date grouping
- Delete option

**Profile Screen:**
- User info
- Statistics
- Settings

---

### PHASE 6: ADVANCED FEATURES

#### 6.1. Image Caching
```dart
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

#### 6.2. Pull to Refresh
```dart
RefreshIndicator(
  onRefresh: () async {
    // Reload data
  },
  child: ListView(
    children: [...],
  ),
)
```

#### 6.3. Infinite Scroll
```dart
final _scrollController = ScrollController();

@override
void initState() {
  _scrollController.addListener(() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  });
}
```

#### 6.4. Loading States
```dart
if (_isLoading) {
  return Center(child: CircularProgressIndicator());
}

if (_error != null) {
  return Center(child: Text('Error: $_error'));
}

if (_data.isEmpty) {
  return Center(child: Text('No data'));
}

return ListView(...);
```

---

### PHASE 7: TESTING

#### 7.1. API Testing
```dart
void main() {
  test('Login API Test', () async {
    final authService = AuthService();
    
    final response = await authService.login(
      email: 'test@example.com',
      password: 'password123',
    );
    
    expect(response.success, true);
    expect(response.token, isNotNull);
  });
}
```

#### 7.2. Widget Testing
```dart
testWidgets('Login Screen Test', (WidgetTester tester) async {
  await tester.pumpWidget(const LoginScreen());
  
  expect(find.text('Đăng nhập'), findsOneWidget);
  expect(find.byType(TextFormField), findsNWidgets(2));
});
```

---

## 🐛 COMMON ISSUES & SOLUTIONS

### Issue 1: SSL Certificate Error
**Problem:** Cannot connect to localhost HTTPS

**Solution:**
```dart
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = 
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}
```

### Issue 2: Token Expiration
**Problem:** Token expires after 7 days

**Solution:**
- Catch 401 errors
- Redirect to login
- Clear stored token

```dart
if (response.statusCode == 401) {
  await ApiService().clearToken();
  // Navigate to login
}
```

### Issue 3: Image Upload Failed
**Problem:** Cannot upload large images

**Solution:**
- Compress image before upload
- Use image_picker with maxWidth/maxHeight

```dart
final pickedFile = await ImagePicker().pickImage(
  source: ImageSource.gallery,
  maxWidth: 1920,
  maxHeight: 1080,
  imageQuality: 85,
);
```

---

## 📊 API ENDPOINTS SUMMARY

### Authentication
```
POST /api/Auth/register        - Đăng ký
POST /api/Auth/login          - Đăng nhập
POST /api/Auth/logout         - Đăng xuất
GET  /api/Auth/google-login   - Google OAuth
```

### Posts
```
GET    /api/Post                    - Lấy danh sách bài viết
GET    /api/Post/{id}               - Chi tiết bài viết
POST   /api/Post                    - Tạo bài viết
POST   /api/Post/{id}/like          - Like/Unlike
GET    /api/Post/{id}/comments      - Lấy comments
POST   /api/Post/{id}/comments      - Thêm comment
DELETE /api/Post/{id}               - Xóa bài viết
```

### Food Analysis
```
POST   /api/FoodAnalysis/analyze         - Phân tích món ăn
GET    /api/FoodAnalysis/history/{userId} - Lịch sử
DELETE /api/FoodAnalysis/history/{id}    - Xóa lịch sử
```

### Content
```
GET /api/MonAn              - Danh sách món ăn
GET /api/MonAn/{id}         - Chi tiết món ăn
GET /api/MonAn/popular      - Món ăn phổ biến
GET /api/MonAn/categories   - Danh mục

GET /api/BaiThuoc           - Danh sách bài thuốc
GET /api/BaiThuoc/{id}      - Chi tiết bài thuốc
GET /api/BaiThuoc/popular   - Bài thuốc phổ biến
```

---

## ✅ IMPLEMENTATION CHECKLIST

### Setup
- [ ] Create Flutter project
- [ ] Add dependencies
- [ ] Setup folder structure
- [ ] Configure iOS/Android

### Models
- [ ] User model
- [ ] Post model
- [ ] Comment model
- [ ] PredictionHistory model
- [ ] MonAn model
- [ ] BaiThuoc model
- [ ] Generate .g.dart files

### Services
- [ ] ApiConfig
- [ ] ApiService (base)
- [ ] AuthService
- [ ] PostService
- [ ] FoodAnalysisService
- [ ] MonAnService
- [ ] BaiThuocService

### Providers
- [ ] AuthProvider
- [ ] PostProvider
- [ ] FoodProvider

### Screens
- [ ] LoginScreen
- [ ] RegisterScreen
- [ ] HomeScreen
- [ ] PostListScreen
- [ ] PostDetailScreen
- [ ] FoodAnalysisScreen
- [ ] FoodHistoryScreen
- [ ] ProfileScreen

### Features
- [ ] JWT Authentication
- [ ] Token storage
- [ ] Auto-login
- [ ] Image upload
- [ ] Image caching
- [ ] Infinite scroll
- [ ] Pull to refresh
- [ ] Error handling
- [ ] Loading states

### Testing
- [ ] API integration tests
- [ ] Widget tests
- [ ] User flow tests

---

## 🎨 UI/UX RECOMMENDATIONS

### Colors
```dart
const primaryColor = Color(0xFF2196F3);
const accentColor = Color(0xFFFF9800);
const backgroundColor = Color(0xFFF5F5F5);
const errorColor = Color(0xFFF44336);
const successColor = Color(0xFF4CAF50);
```

### Typography
```dart
textTheme: TextTheme(
  headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
  headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  bodyLarge: TextStyle(fontSize: 16),
  bodyMedium: TextStyle(fontSize: 14),
)
```

### Bottom Navigation
```dart
BottomNavigationBar(
  currentIndex: _selectedIndex,
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
    BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Phân tích'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
  ],
)
```

---

## 📱 PLATFORM-SPECIFIC CONFIGURATION

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS (ios/Runner/Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>Cần quyền camera để chụp ảnh món ăn</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Cần quyền truy cập thư viện ảnh</string>
```

---

## 🚀 DEPLOYMENT

### Build APK (Android)
```bash
flutter build apk --release
```

### Build iOS
```bash
flutter build ios --release
```

---

## 📞 SUPPORT INFORMATION

**API Base URL (Development):** https://localhost:7135/api  
**Swagger Documentation:** https://localhost:7135/  
**Database:** SQL Server (Hotel_Web)  
**External Services:**
- Python API: http://127.0.0.1:5000
- Google Gemini AI

---

## 🔗 USEFUL LINKS

- Flutter Documentation: https://flutter.dev/docs
- HTTP Package: https://pub.dev/packages/http
- Provider: https://pub.dev/packages/provider
- Cached Network Image: https://pub.dev/packages/cached_network_image
- Image Picker: https://pub.dev/packages/image_picker

---

**Tài liệu được tạo:** November 9, 2025  
**Version:** 1.0  
**Author:** Hotel Web API Team

---

## 🤖 FLUTTER AI AGENT INSTRUCTIONS

Khi build project, hãy:

1. **Đọc kỹ 3 tài liệu:**
   - FLUTTER_INTEGRATION_GUIDE.md (API endpoints)
   - DATABASE_SCHEMA.md (Data structure)
   - FLUTTER_CODE_EXAMPLES.md (Code templates)

2. **Follow checklist từ trên xuống**

3. **Copy code examples và customize**

4. **Test từng feature riêng lẻ**

5. **Handle errors properly**

6. **Add loading states**

7. **Implement caching khi cần**

8. **Follow Flutter best practices**

Good luck building! 🚀
