# HƯỚNG DẪN TÍCH HỢP API CHO FLUTTER APP

## 📋 TỔNG QUAN DỰ ÁN

**Tên dự án:** Hotel Web API - Health & Food Platform  
**Công nghệ:** ASP.NET Core Web API (.NET 9.0)  
**Database:** SQL Server  
**Authentication:** JWT Bearer Token  
**Base URL:** `https://localhost:7135/api` (Development)

## 🎯 MỤC ĐÍCH

API này cung cấp backend cho ứng dụng Flutter về dinh dưỡng và sức khỏe, bao gồm:
- Quản lý tài khoản người dùng (Đăng ký, Đăng nhập, OAuth Google)
- Mạng xã hội (Bài đăng, Like, Comment)
- Phân tích món ăn bằng AI (Computer Vision + Google Gemini)
- Quản lý nội dung (Món ăn, Bài thuốc, Nước uống)
- Lịch sử phân tích dinh dưỡng

---

## 🔐 XÁC THỰC (AUTHENTICATION)

### Cấu hình JWT

```json
{
  "Jwt": {
    "Issuer": "HotelWebAPI",
    "Audience": "FlutterApp",
    "ExpiryInDays": 7
  }
}
```

### Cách sử dụng Token

Sau khi đăng nhập/đăng ký thành công, API sẽ trả về JWT token. Sử dụng token này trong header của mỗi request:

```
Authorization: Bearer {your_jwt_token}
```

---

## 📡 API ENDPOINTS

### 1. AUTHENTICATION APIs (`/api/Auth`)

#### 1.1. Đăng ký tài khoản
```
POST /api/Auth/register
Content-Type: application/json
```

**Request Body:**
```json
{
  "userName": "string",
  "email": "user@example.com",
  "password": "string",
  "confirmPassword": "string",
  "age": 25,
  "gender": "Nam"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Đăng ký thành công",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "user-guid",
    "userName": "string",
    "email": "user@example.com",
    "age": 25,
    "gender": "Nam",
    "profilePicture": "https://localhost:7135/images/avatar/default-profile-picture.jpg",
    "displayName": null
  }
}
```

**Validation:**
- `userName`: Required
- `email`: Required, Valid email format
- `password`: Required, Min 6 characters
- `confirmPassword`: Must match password
- `age`: Optional, 1-150
- `gender`: Optional

#### 1.2. Đăng nhập
```
POST /api/Auth/login
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "string"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Đăng nhập thành công",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "user-guid",
    "userName": "string",
    "email": "user@example.com",
    "age": 25,
    "gender": "Nam",
    "profilePicture": "https://localhost:7135/images/avatar/default-profile-picture.jpg",
    "displayName": "Display Name"
  }
}
```

**Error Response (401 Unauthorized):**
```json
{
  "success": false,
  "message": "Email hoặc mật khẩu không đúng",
  "token": null,
  "user": null
}
```

#### 1.3. Đăng xuất
```
POST /api/Auth/logout
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Đăng xuất thành công",
  "data": null
}
```

#### 1.4. Đăng nhập Google (Web View)
```
GET /api/Auth/google-login
```

Redirect đến Google OAuth consent screen.

#### 1.5. Google Callback
```
GET /api/Auth/google-callback
```

Được gọi tự động sau khi user đồng ý Google OAuth.

---

### 2. POST APIs (Bài đăng mạng xã hội) (`/api/Post`)

#### 2.1. Lấy danh sách bài viết (có phân trang)
```
GET /api/Post?page=1&pageSize=10
```

**Query Parameters:**
- `page` (int, optional): Số trang, mặc định = 1
- `pageSize` (int, optional): Số items/trang, mặc định = 10

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Lấy danh sách bài viết thành công",
  "data": {
    "posts": [
      {
        "id": "post-guid",
        "noiDung": "Nội dung bài viết",
        "loai": "image",
        "duongDanMedia": "https://localhost:7135/uploads/image.jpg",
        "ngayDang": "2024-11-09T10:00:00Z",
        "luotThich": 10,
        "soBinhLuan": 5,
        "soChiaSe": 2,
        "isLiked": false,
        "hashtags": "#healthy #food",
        "authorId": "user-guid",
        "authorName": "username",
        "authorAvatar": "https://localhost:7135/images/avatar/user.jpg"
      }
    ],
    "totalCount": 100,
    "page": 1,
    "pageSize": 10,
    "totalPages": 10,
    "hasPrevious": false,
    "hasNext": true
  },
  "errors": []
}
```

#### 2.2. Lấy chi tiết bài viết
```
GET /api/Post/{id}
```

**Response:** Tương tự item trong danh sách

#### 2.3. Tạo bài viết mới
```
POST /api/Post
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "noiDung": "Nội dung bài viết",
  "loai": "image",
  "duongDanMedia": "/uploads/image.jpg",
  "monAnId": null,
  "hashtags": "#healthy #food"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Tạo bài viết thành công",
  "data": {
    "id": "new-post-guid",
    "noiDung": "...",
    ...
  }
}
```

#### 2.4. Like/Unlike bài viết
```
POST /api/Post/{id}/like
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Đã thích bài viết",
  "data": {
    "isLiked": true,
    "likeCount": 11
  }
}
```

Hoặc khi unlike:
```json
{
  "success": true,
  "message": "Đã bỏ thích bài viết",
  "data": {
    "isLiked": false,
    "likeCount": 10
  }
}
```

#### 2.5. Lấy danh sách comment
```
GET /api/Post/{id}/comments
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Lấy danh sách comment thành công",
  "data": [
    {
      "id": "comment-guid",
      "noiDung": "Nội dung comment",
      "ngayTao": "2024-11-09T10:00:00Z",
      "parentCommentId": null,
      "userId": "user-guid",
      "userName": "username",
      "userAvatar": "https://localhost:7135/images/avatar/user.jpg",
      "replies": [
        {
          "id": "reply-guid",
          "noiDung": "Reply content",
          "ngayTao": "2024-11-09T10:05:00Z",
          "parentCommentId": "comment-guid",
          "userId": "user-guid-2",
          "userName": "username2",
          "userAvatar": "https://localhost:7135/images/avatar/user2.jpg",
          "replies": []
        }
      ]
    }
  ]
}
```

#### 2.6. Thêm comment
```
POST /api/Post/{id}/comments
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "noiDung": "Nội dung comment",
  "parentCommentId": null
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Thêm comment thành công",
  "data": {
    "id": "new-comment-guid",
    "noiDung": "Nội dung comment",
    ...
  }
}
```

#### 2.7. Xóa bài viết
```
DELETE /api/Post/{id}
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Xóa bài viết thành công"
}
```

---

### 3. FOOD ANALYSIS APIs (Phân tích món ăn) (`/api/FoodAnalysis`)

#### 3.1. Phân tích ảnh món ăn
```
POST /api/FoodAnalysis/analyze
Content-Type: multipart/form-data
```

**Form Data:**
- `image` (file): File ảnh (jpeg, jpg, png, gif)
- `userId` (string): ID của user
- `mealType` (string, optional): Loại bữa ăn (breakfast, lunch, dinner, snack)

**Response (200 OK):**
```json
{
  "id": 1,
  "userId": "user-guid",
  "imagePath": "https://localhost:7135/uploads/abc123.jpg",
  "foodName": "Phở Bò",
  "confidence": 0.95,
  "calories": 450.5,
  "protein": 25.3,
  "fat": 15.2,
  "carbs": 55.8,
  "mealType": "lunch",
  "advice": "Lời khuyên dinh dưỡng từ Gemini AI...",
  "createdAt": "2024-11-09T10:00:00Z",
  "details": [
    {
      "label": "Phở",
      "weight": 350.0,
      "confidence": 0.95,
      "calories": 300.0,
      "protein": 15.0,
      "fat": 8.0,
      "carbs": 45.0
    },
    {
      "label": "Thịt bò",
      "weight": 100.0,
      "confidence": 0.92,
      "calories": 150.5,
      "protein": 10.3,
      "fat": 7.2,
      "carbs": 10.8
    }
  ]
}
```

**Lưu ý:**
- Phải tạo Health Plan cho user trước khi gọi API này
- API gọi Python service (http://127.0.0.1:5000/predict) để detect món ăn
- API gọi Google Gemini để lấy lời khuyên dinh dưỡng
- Ảnh được lưu vào folder `Hotel_Web/wwwroot/uploads`

#### 3.2. Lấy lịch sử phân tích
```
GET /api/FoodAnalysis/history/{userId}
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "image": "https://localhost:7135/uploads/abc123.jpg",
    "comfident": 0.95,
    "foodName": "Phở Bò",
    "calories": 450.5,
    "createdAt": "2024-11-09T10:00:00Z",
    "mealType": "lunch",
    "protein": 25.3,
    "fat": 15.2,
    "carbs": 55.8,
    "details": [...]
  }
]
```

#### 3.3. Xóa lịch sử phân tích
```
DELETE /api/FoodAnalysis/history/{id}
```

**Response (204 No Content):**
Không có body, chỉ status code 204

---

### 4. MON AN APIs (Món ăn) (`/api/MonAn`)

#### 4.1. Lấy danh sách món ăn
```
GET /api/MonAn?page=1&pageSize=10&search=phở&loai=Món%20chính
```

**Query Parameters:**
- `page` (int, optional): Số trang
- `pageSize` (int, optional): Số items/trang
- `search` (string, optional): Tìm kiếm theo tên/mô tả
- `loai` (string, optional): Lọc theo loại món

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Lấy danh sách món ăn thành công",
  "data": {
    "items": [
      {
        "id": "monan-guid",
        "ten": "Phở Bò",
        "moTa": "Món phở truyền thống...",
        "cachCheBien": "Hướng dẫn nấu phở...",
        "loai": "Món chính",
        "ngayTao": "2024-01-01T00:00:00Z",
        "image": "https://localhost:7135/uploads/pho.jpg",
        "gia": 50000,
        "soNguoi": 2,
        "luotXem": 150
      }
    ],
    "totalCount": 50,
    "page": 1,
    "pageSize": 10,
    "totalPages": 5,
    "hasNextPage": true,
    "hasPreviousPage": false
  }
}
```

#### 4.2. Lấy chi tiết món ăn
```
GET /api/MonAn/{id}
```

**Response:** Tương tự item trong danh sách, tự động tăng `luotXem`

#### 4.3. Lấy danh sách món ăn phổ biến
```
GET /api/MonAn/popular?top=10
```

**Response:** Danh sách món ăn có lượt xem nhiều nhất

#### 4.4. Lấy danh sách loại món ăn
```
GET /api/MonAn/categories
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Lấy danh sách loại món ăn thành công",
  "data": ["Món chính", "Món phụ", "Tráng miệng", "Món khai vị"]
}
```

---

### 5. BAI THUOC APIs (Bài thuốc) (`/api/BaiThuoc`)

#### 5.1. Lấy danh sách bài thuốc
```
GET /api/BaiThuoc?page=1&pageSize=10&search=keyword
```

**Query Parameters:**
- `page` (int, optional): Số trang
- `pageSize` (int, optional): Số items/trang
- `search` (string, optional): Tìm kiếm theo tên/mô tả

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Lấy danh sách bài thuốc thành công",
  "data": {
    "items": [
      {
        "id": "baithuoc-guid",
        "ten": "Bài thuốc A",
        "moTa": "Mô tả bài thuốc...",
        "huongDanSuDung": "Hướng dẫn sử dụng...",
        "nguoiDungId": "user-guid",
        "ngayTao": "2024-01-01T00:00:00Z",
        "image": "https://localhost:7135/uploads/baithuoc.jpg",
        "soLuotThich": 50,
        "soLuotXem": 200,
        "trangThai": 1,
        "tenNguoiDung": "username"
      }
    ],
    "totalCount": 30,
    "page": 1,
    "pageSize": 10,
    "totalPages": 3,
    "hasNextPage": true,
    "hasPreviousPage": false
  }
}
```

#### 5.2. Lấy chi tiết bài thuốc
```
GET /api/BaiThuoc/{id}
```

**Response:** Tương tự item trong danh sách, tự động tăng `soLuotXem`

#### 5.3. Lấy danh sách bài thuốc phổ biến
```
GET /api/BaiThuoc/popular?top=10
```

**Response:** Danh sách bài thuốc có lượt xem nhiều nhất

---

### 6. NUOC UONG APIs (Nước uống) (`/api/NuocUong`)

Tương tự như MonAn và BaiThuoc APIs

---

## 🛠️ MODELS & DATA STRUCTURES

### ApplicationUser (User Model)
```csharp
{
  "id": "string (GUID)",
  "userName": "string",
  "email": "string",
  "gioi_tinh": "string",
  "tuoi": "int?",
  "profilePicture": "string",
  "displayName": "string",
  "dang_online": "bool?",
  "trang_thai": "int?",
  "lan_hoat_dong_cuoi": "DateTime?"
}
```

### BaiDang (Post Model)
```csharp
{
  "id": "Guid",
  "nguoiDungId": "string",
  "noiDung": "string",
  "loai": "string",
  "duongDanMedia": "string",
  "ngayDang": "DateTime",
  "luotThich": "int",
  "soBinhLuan": "int",
  "so_chia_se": "int",
  "hashtags": "string",
  "id_MonAn": "Guid?",
  "daDuyet": "bool"
}
```

### PredictionHistory (Lịch sử phân tích)
```csharp
{
  "id": "int",
  "userId": "string",
  "imagePath": "string",
  "foodName": "string",
  "confidence": "double",
  "calories": "double",
  "protein": "double",
  "fat": "double",
  "carbs": "double",
  "mealType": "string",
  "advice": "string",
  "createdAt": "DateTime",
  "details": "List<PredictionDetail>"
}
```

### HealthPlan (Phác đồ sức khỏe)
```csharp
{
  "id": "int",
  "userId": "string",
  "chieuCao": "double",
  "canNang": "double",
  "bmi": "double",
  "mucTieuCalo": "double",
  "mucTieuProtein": "double",
  "mucTieuCarbs": "double",
  "mucTieuFat": "double",
  "ngayTao": "DateTime"
}
```

---

## 🔄 CORS Configuration

API đã được cấu hình CORS cho phép tất cả origins:

```csharp
policy.AllowAnyOrigin()
      .AllowAnyMethod()
      .AllowAnyHeader();
```

Flutter app có thể gọi API từ bất kỳ domain nào.

---

## 📝 ERROR HANDLING

### Cấu trúc Error Response

```json
{
  "success": false,
  "message": "Error message",
  "data": null,
  "errors": ["Error detail 1", "Error detail 2"]
}
```

### HTTP Status Codes

- `200 OK`: Success
- `201 Created`: Resource created successfully
- `204 No Content`: Success with no response body
- `400 Bad Request`: Validation error or invalid input
- `401 Unauthorized`: Authentication required or token invalid
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

---

## 🖼️ MEDIA FILES

### Upload File Location
Files được lưu tại: `Hotel_Web/wwwroot/uploads/`

### Media URL Format
```
https://localhost:7135/uploads/{filename}
```

### Supported Image Types
- image/jpeg
- image/jpg
- image/png
- image/gif

### File Size Limit
Maximum: 100MB (cấu hình trong Program.cs)

---

## 🔗 EXTERNAL SERVICES

### 1. Python API (Food Detection)
- **URL:** http://127.0.0.1:5000/predict
- **Method:** POST
- **Content-Type:** multipart/form-data
- **Purpose:** Phát hiện và phân tích món ăn từ ảnh

### 2. Google Gemini AI
- **Purpose:** Tạo lời khuyên dinh dưỡng cá nhân hóa
- **API Key:** Được cấu hình trong appsettings.json
- **Service:** NutritionService

### 3. Google OAuth
- **Purpose:** Đăng nhập bằng Google
- **Flow:** OAuth 2.0
- **Endpoints:** 
  - `/api/Auth/google-login`
  - `/api/Auth/google-callback`

---

## 📦 DEPENDENCIES

### NuGet Packages
```xml
<PackageReference Include="Microsoft.AspNetCore.Authentication.Google" />
<PackageReference Include="Microsoft.AspNetCore.Authentication.JwtBearer" />
<PackageReference Include="Microsoft.AspNetCore.Identity.EntityFrameworkCore" />
<PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" />
<PackageReference Include="Swashbuckle.AspNetCore" />
```

---

## 🚀 FLUTTER INTEGRATION CHECKLIST

### Bước 1: Setup HTTP Client
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://localhost:7135/api';
  String? _token;
  
  void setToken(String token) {
    _token = token;
  }
  
  Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }
}
```

### Bước 2: Tạo Models (Data Classes)
Tạo Dart classes tương ứng với C# models:
- `User`
- `Post`
- `Comment`
- `MonAn`
- `BaiThuoc`
- `PredictionHistory`

### Bước 3: Implement Authentication
```dart
Future<AuthResponse> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/Auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    setToken(data['token']);
    return AuthResponse.fromJson(data);
  } else {
    throw Exception('Login failed');
  }
}
```

### Bước 4: Implement API Calls
Tạo methods cho từng endpoint:
- `getPosts()`
- `createPost()`
- `likePost()`
- `getComments()`
- `analyzeFood()`
- `getMonAn()`
- ...

### Bước 5: State Management
Sử dụng Provider, Riverpod, Bloc, hoặc GetX để quản lý state

### Bước 6: Handle Token Storage
```dart
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('jwt_token', token);
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwt_token');
}
```

### Bước 7: Implement Image Upload
```dart
Future<PredictionHistory> analyzeFood(File image, String userId) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/FoodAnalysis/analyze'),
  );
  
  request.files.add(await http.MultipartFile.fromPath('image', image.path));
  request.fields['userId'] = userId;
  request.fields['mealType'] = 'lunch';
  
  var response = await request.send();
  var responseData = await response.stream.bytesToString();
  
  if (response.statusCode == 200) {
    return PredictionHistory.fromJson(jsonDecode(responseData));
  } else {
    throw Exception('Analysis failed');
  }
}
```

---

## 📚 TESTING với Swagger

API được trang bị Swagger UI tại:
```
https://localhost:7135/
```

Sử dụng Swagger để:
1. Xem tất cả endpoints
2. Test API trực tiếp
3. Xem request/response schemas
4. Thử nghiệm authentication

---

## 🔒 SECURITY NOTES

1. **JWT Token:** Lưu trữ an toàn, không expose trong logs
2. **HTTPS:** Sử dụng HTTPS trong production
3. **Password:** Minimum 6 characters, được hash bằng Identity
4. **File Upload:** Validate file type và size
5. **Authorization:** Kiểm tra ownership trước khi delete/update

---

## 📱 RECOMMENDED FLUTTER PACKAGES

```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
  provider: ^6.1.1
  image_picker: ^1.0.4
  cached_network_image: ^3.3.0
  intl: ^0.18.1
  flutter_secure_storage: ^9.0.0
```

---

## 🐛 COMMON ISSUES & SOLUTIONS

### Issue 1: SSL Certificate Error
**Solution:** Trong development, thêm:
```dart
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}
```

### Issue 2: Token Expired
**Solution:** Implement refresh token hoặc handle 401 error để redirect login

### Issue 3: CORS Error
**Solution:** API đã config AllowAnyOrigin, kiểm tra URL đúng chưa

---

## 📞 SUPPORT

Nếu có vấn đề, kiểm tra:
1. API có đang chạy không (https://localhost:7135)
2. Database connection string đúng chưa
3. Python API đang chạy chưa (http://127.0.0.1:5000)
4. Token có hợp lệ không

---

**Tài liệu được tạo:** November 9, 2025  
**API Version:** v1  
**Framework:** ASP.NET Core 9.0
