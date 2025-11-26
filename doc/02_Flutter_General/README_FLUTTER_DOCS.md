# 📱 HOTEL WEB API - FLUTTER INTEGRATION DOCUMENTATION

## 🎯 GIỚI THIỆU

Đây là bộ tài liệu hoàn chỉnh để tích hợp **Hotel Web API** với ứng dụng Flutter. API cung cấp các tính năng về sức khỏe, dinh dưỡng và mạng xã hội.

---

## 📚 CẤU TRÚC TÀI LIỆU

### 1. 🚀 **FLUTTER_AI_AGENT_GUIDE.md** (BẮT ĐẦU TẠI ĐÂY)
**File chính dành cho Flutter AI Agent**

**Nội dung:**
- Tổng quan dự án
- Roadmap chi tiết từng bước
- Implementation checklist
- Common issues & solutions
- Deployment guide

**Khi nào đọc:** ⭐ **ĐỌC ĐẦU TIÊN** - Đây là file hướng dẫn tổng quát nhất

---

### 2. 🔌 **FLUTTER_INTEGRATION_GUIDE.md**
**Tài liệu chi tiết về API**

**Nội dung:**
- Mô tả chi tiết TẤT CẢ endpoints
- Request/Response formats
- Authentication flow
- Error handling
- Media files
- Testing với Swagger

**Khi nào đọc:** Khi cần biết chi tiết về bất kỳ endpoint nào

**Ví dụ use case:**
- "Làm sao để login?" → Đọc section "Authentication APIs"
- "Cách tạo bài viết?" → Đọc section "POST APIs"
- "Upload ảnh phân tích?" → Đọc section "Food Analysis APIs"

---

### 3. 💾 **DATABASE_SCHEMA.md**
**Tài liệu về cấu trúc database**

**Nội dung:**
- Chi tiết tất cả tables
- Columns và data types
- Relationships (Foreign Keys)
- SQL queries mẫu
- Indexes

**Khi nào đọc:** Khi cần hiểu data structure hoặc thiết kế models

**Ví dụ use case:**
- "User có những thuộc tính gì?" → Xem table AspNetUsers
- "Post liên kết với User như thế nào?" → Xem relationships
- "Comment có hỗ trợ replies không?" → Xem table BinhLuan

---

### 4. 💻 **FLUTTER_CODE_EXAMPLES.md**
**Code mẫu hoàn chỉnh cho Flutter**

**Nội dung:**
- Setup dependencies
- Models với JSON serialization
- API Service implementation
- UI Screens examples
- Working code samples

**Khi nào đọc:** Khi cần code để implement

**Ví dụ use case:**
- "Tạo User model?" → Copy từ section Models
- "Gọi API login?" → Copy từ section API Service
- "Build Login Screen?" → Copy từ section UI Examples

---

## 🎯 WORKFLOW ĐỂ BẮT ĐẦU

### Step 1: Đọc hiểu tổng quan
```
📄 Đọc: FLUTTER_AI_AGENT_GUIDE.md
⏱️ Thời gian: 10-15 phút
✅ Mục tiêu: Hiểu project structure, checklist, roadmap
```

### Step 2: Setup project
```
📄 Tham khảo: FLUTTER_AI_AGENT_GUIDE.md (PHASE 1)
⏱️ Thời gian: 5-10 phút
✅ Mục tiêu: Tạo project, add dependencies, folder structure
```

### Step 3: Tạo models
```
📄 Tham khảo: 
   - FLUTTER_CODE_EXAMPLES.md (Section 2) - Copy code
   - DATABASE_SCHEMA.md - Hiểu data structure
⏱️ Thời gian: 20-30 phút
✅ Mục tiêu: Tạo tất cả models và generate .g.dart files
```

### Step 4: Implement API Services
```
📄 Tham khảo:
   - FLUTTER_CODE_EXAMPLES.md (Section 3-6) - Copy code
   - FLUTTER_INTEGRATION_GUIDE.md - Chi tiết endpoints
⏱️ Thời gian: 30-45 phút
✅ Mục tiêu: Hoàn thành tất cả services
```

### Step 5: State Management
```
📄 Tham khảo: FLUTTER_AI_AGENT_GUIDE.md (PHASE 4)
⏱️ Thời gian: 15-20 phút
✅ Mục tiêu: Setup providers
```

### Step 6: Build UI
```
📄 Tham khảo: 
   - FLUTTER_CODE_EXAMPLES.md (Section 7) - Copy screens
   - FLUTTER_AI_AGENT_GUIDE.md (PHASE 5) - UI requirements
⏱️ Thời gian: 1-2 giờ
✅ Mục tiêu: Hoàn thành tất cả screens
```

### Step 7: Testing & Debug
```
📄 Tham khảo: FLUTTER_AI_AGENT_GUIDE.md (PHASE 7)
⏱️ Thời gian: 30 phút
✅ Mục tiêu: Test và fix bugs
```

---

## 📋 QUICK REFERENCE

### API Base URL
```
https://localhost:7135/api
```

### Authentication
```dart
// Header format
Authorization: Bearer {jwt_token}

// Token storage
FlutterSecureStorage().write(key: 'jwt_token', value: token);
```

### Main Endpoints
```
Auth:           /api/Auth/login, /api/Auth/register
Posts:          /api/Post
Food Analysis:  /api/FoodAnalysis/analyze
Content:        /api/MonAn, /api/BaiThuoc
```

### Dependencies
```yaml
http: ^1.1.0
provider: ^6.1.1
shared_preferences: ^2.2.2
flutter_secure_storage: ^9.0.0
image_picker: ^1.0.4
cached_network_image: ^3.3.0
json_annotation: ^4.8.1
```

---

## 🔍 TÌM KIẾM THÔNG TIN NHANH

### "Tôi muốn biết..."

#### "...cách login"
➡️ `FLUTTER_INTEGRATION_GUIDE.md` → Section 1.2 (Đăng nhập)  
➡️ `FLUTTER_CODE_EXAMPLES.md` → Section 4 (AuthService)

#### "...cách lấy danh sách bài viết"
➡️ `FLUTTER_INTEGRATION_GUIDE.md` → Section 2.1  
➡️ `FLUTTER_CODE_EXAMPLES.md` → Section 5 (PostService)

#### "...cách upload ảnh phân tích món ăn"
➡️ `FLUTTER_INTEGRATION_GUIDE.md` → Section 3.1  
➡️ `FLUTTER_CODE_EXAMPLES.md` → Section 6 (FoodAnalysisService)

#### "...User có những field gì"
➡️ `DATABASE_SCHEMA.md` → Table AspNetUsers

#### "...cách build Login Screen"
➡️ `FLUTTER_CODE_EXAMPLES.md` → Section 7.1

#### "...cách xử lý SSL certificate error"
➡️ `FLUTTER_AI_AGENT_GUIDE.md` → Common Issues → Issue 1

---

## 📊 MỐI QUAN HỆ GIỮA CÁC TÀI LIỆU

```
FLUTTER_AI_AGENT_GUIDE.md (Master Guide)
    │
    ├─► FLUTTER_INTEGRATION_GUIDE.md (API Details)
    │   └─► Cung cấp: API endpoints, request/response
    │
    ├─► DATABASE_SCHEMA.md (Data Structure)
    │   └─► Cung cấp: Table structure, relationships
    │
    └─► FLUTTER_CODE_EXAMPLES.md (Code Templates)
        └─► Cung cấp: Ready-to-use code
```

---

## 🎨 FEATURES OVERVIEW

### ✅ Implemented Features

| Feature | Endpoint | Status |
|---------|----------|--------|
| Register | POST /api/Auth/register | ✅ |
| Login | POST /api/Auth/login | ✅ |
| Google OAuth | GET /api/Auth/google-login | ✅ |
| Logout | POST /api/Auth/logout | ✅ |
| Get Posts | GET /api/Post | ✅ |
| Create Post | POST /api/Post | ✅ |
| Like Post | POST /api/Post/{id}/like | ✅ |
| Get Comments | GET /api/Post/{id}/comments | ✅ |
| Add Comment | POST /api/Post/{id}/comments | ✅ |
| Delete Post | DELETE /api/Post/{id} | ✅ |
| Analyze Food | POST /api/FoodAnalysis/analyze | ✅ |
| Food History | GET /api/FoodAnalysis/history/{userId} | ✅ |
| Delete History | DELETE /api/FoodAnalysis/history/{id} | ✅ |
| Get MonAn | GET /api/MonAn | ✅ |
| MonAn Detail | GET /api/MonAn/{id} | ✅ |
| Popular MonAn | GET /api/MonAn/popular | ✅ |
| Get BaiThuoc | GET /api/BaiThuoc | ✅ |
| BaiThuoc Detail | GET /api/BaiThuoc/{id} | ✅ |

---

## 🔧 DEVELOPMENT TOOLS

### Swagger UI
```
URL: https://localhost:7135/
Purpose: Test API trực tiếp, xem documentation
```

### VS Code Extensions (Recommended)
- Flutter
- Dart
- REST Client
- JSON to Dart Model

### Chrome DevTools
```bash
flutter run -d chrome
```

---

## 🚨 IMPORTANT NOTES

### ⚠️ Lưu ý về API
1. **Base URL** đang là localhost, cần thay đổi khi deploy
2. **SSL Certificate** cần bypass trong development
3. **Token** expires sau 7 ngày
4. **Python API** phải chạy (http://127.0.0.1:5000) để Food Analysis hoạt động

### ⚠️ Lưu ý về Flutter
1. Phải gọi `build_runner` để generate .g.dart files
2. Cần cấu hình permissions (Camera, Storage) cho iOS/Android
3. Sử dụng `flutter_secure_storage` cho JWT token
4. Implement error handling cho tất cả API calls

### ⚠️ Lưu ý về Data
1. User phải có HealthPlan trước khi analyze food
2. Post có thể có ParentCommentId null (root comment)
3. Image URLs đã là full URL từ API
4. DateTime format: ISO 8601 (UTC)

---

## 📞 CONTACT & SUPPORT

**API Documentation:** Xem các file .md trong thư mục này  
**Swagger UI:** https://localhost:7135/  
**Database:** SQL Server - Hotel_Web

---

## 🎯 SUCCESS CRITERIA

### Khi nào coi là hoàn thành?

- [ ] ✅ User có thể register/login
- [ ] ✅ User có thể xem danh sách bài viết
- [ ] ✅ User có thể tạo bài viết
- [ ] ✅ User có thể like/comment
- [ ] ✅ User có thể chụp/chọn ảnh để phân tích
- [ ] ✅ Hiển thị kết quả phân tích món ăn
- [ ] ✅ User có thể xem lịch sử phân tích
- [ ] ✅ User có thể xem danh sách món ăn
- [ ] ✅ User có thể xem profile
- [ ] ✅ App handle errors gracefully
- [ ] ✅ Loading states everywhere
- [ ] ✅ Smooth navigation
- [ ] ✅ Images cached properly

---

## 🔄 VERSION HISTORY

**v1.0** - November 9, 2025
- Initial documentation
- Complete API coverage
- Flutter code examples
- Database schema

---

## 🎓 LEARNING RESOURCES

### Flutter
- [Flutter Documentation](https://flutter.dev/docs)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

### API Integration
- [HTTP Package](https://pub.dev/packages/http)
- [Dio Package](https://pub.dev/packages/dio)
- [JSON Serialization](https://flutter.dev/docs/development/data-and-backend/json)

### State Management
- [Provider](https://pub.dev/packages/provider)
- [Riverpod](https://riverpod.dev/)
- [Bloc](https://bloclibrary.dev/)

---

## 🚀 FINAL CHECKLIST

Trước khi bắt đầu code, hãy chắc chắn bạn đã:

- [x] ✅ Đọc FLUTTER_AI_AGENT_GUIDE.md
- [x] ✅ Hiểu project structure
- [x] ✅ Biết các endpoints chính
- [x] ✅ Đã xem qua code examples
- [x] ✅ Hiểu authentication flow
- [x] ✅ Biết cách handle errors
- [x] ✅ Sẵn sàng coding! 🎉

---

**Happy Coding! 🚀**

*Nếu có vấn đề, tham khảo lại các file documentation hoặc check Swagger UI để test API trực tiếp.*
