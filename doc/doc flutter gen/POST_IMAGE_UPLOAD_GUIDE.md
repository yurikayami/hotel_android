# 📤 Post Image Upload - Implementation Guide

**Date:** November 10, 2025  
**Based on:** FOOD_ANALYSIS_IMPLEMENTATION pattern

---

## 📋 Overview

Viết lại phần upload ảnh cho bài viết theo pattern từ Food Analysis API - sử dụng **multipart/form-data** thay vì JSON để gửi file lên server.

---

## 🔧 Changes Made

### 1️⃣ Backend - PostController.cs (NEW ENDPOINT)

**Added endpoint:** `POST /api/Post/upload`

```csharp
[HttpPost("upload")]
[Authorize]
[Consumes("multipart/form-data")]
public async Task<ActionResult<ApiResponse<PostDto>>> CreatePostWithImage(
    [FromForm] string noiDung,
    [FromForm] string loai = "text",
    [FromForm] IFormFile? image = null)
```

**Features:**
- ✅ Accept **multipart/form-data** (files + fields)
- ✅ **Validate** content, file type, file size
- ✅ **Save** image to `wwwroot/uploads/posts/`
- ✅ **Generate** unique filename with GUID
- ✅ **Return** full PostDto with image path

**File Type Support:**
- JPEG ✅
- PNG ✅
- GIF ✅
- WebP ✅

**File Size Limit:** 10 MB

**Image Save Location:** `wwwroot/uploads/posts/{guid}_{filename}`

---

### 2️⃣ Flutter Client - PostService.dart (UPDATED)

**Change endpoint:**
```dart
// OLD
final response = await _apiService.uploadFile(
  ApiConfig.posts,  // /api/Post
  ...
);

// NEW
final response = await _apiService.uploadFile(
  '${ApiConfig.posts}/upload',  // /api/Post/upload
  ...
);
```

**Flow:**
```
1. User selects images in CreatePostScreen
2. Convert XFile → File
3. Call PostService.createPost(noiDung, loai, hinhAnh)
4. Check if images provided:
   - YES: Call ApiService.uploadFile() → POST /api/Post/upload
   - NO: Call ApiService.post() → POST /api/Post (JSON)
5. Return created Post with image path
```

---

## 🎯 API Endpoints

### POST /api/Post (JSON - Text Only)
```http
POST /api/Post HTTP/1.1
Content-Type: application/json
Authorization: Bearer {token}

{
  "noiDung": "Hello world",
  "loai": "text",
  "duongDanMedia": null
}
```

**Response:**
```json
{
  "success": true,
  "message": "Tạo bài viết thành công",
  "data": {
    "id": "guid",
    "noiDung": "Hello world",
    "loai": "text",
    "duongDanMedia": null,
    "authorId": "user-id",
    "authorName": "username"
  }
}
```

### POST /api/Post/upload (Multipart - With Image)
```http
POST /api/Post/upload HTTP/1.1
Content-Type: multipart/form-data
Authorization: Bearer {token}

--boundary
Content-Disposition: form-data; name="noiDung"

Hello with image
--boundary
Content-Disposition: form-data; name="loai"

image
--boundary
Content-Disposition: form-data; name="image"; filename="photo.jpg"
Content-Type: image/jpeg

{binary image data}
--boundary--
```

**Response:**
```json
{
  "success": true,
  "message": "Tạo bài viết thành công",
  "data": {
    "id": "guid",
    "noiDung": "Hello with image",
    "loai": "image",
    "duongDanMedia": "https://server/images/uploads/posts/guid_photo.jpg",
    "authorId": "user-id",
    "authorName": "username"
  }
}
```

---

## 📁 Folder Structure

**Server uploads folder:**
```
wwwroot/
├── uploads/
│   └── posts/
│       ├── {guid}_{filename1}.jpg
│       ├── {guid}_{filename2}.png
│       └── {guid}_{filename3}.jpg
```

**Note:** Folder created automatically when first image uploaded.

---

## ✅ Validation

### Frontend (Flutter)
```dart
✅ Content not empty
✅ Image file exists
✅ Image file size > 0
✅ Convert XFile → File
```

### Backend (C#)
```dart
✅ noiDung not empty
✅ File type in [jpeg, png, gif, webp]
✅ File size ≤ 10MB
✅ Authentication token valid
✅ User exists
```

---

## 🔐 Error Handling

**Frontend Errors:**
- Content empty → "Vui lòng nhập nội dung"
- No image selected → "Vui lòng chọn ít nhất một hình ảnh"
- Image not removed properly → Show console logs

**Backend Errors:**
- Invalid file type → 400 "Định dạng ảnh không được hỗ trộ"
- File too large → 400 "Kích thước ảnh không được vượt quá 10MB"
- Not authenticated → 401 "Bạn cần đăng nhập"
- File save failed → 500 "Lỗi khi lưu hình ảnh"

---

## 🧪 Testing

### Test Case 1: Text Post (No Image)
```
1. Open CreatePostScreen
2. Select "Văn bản"
3. Enter: "Hello world"
4. Click "Đăng"
✅ Expect: POST to /api/Post (JSON)
✅ Response: Post created with loai=text
```

### Test Case 2: Image Post
```
1. Open CreatePostScreen
2. Select "Hình ảnh"
3. Enter: "Check this out"
4. Click "Thêm hình ảnh" → Select image.jpg
5. Click "Đăng"
✅ Expect: POST to /api/Post/upload (multipart)
✅ File saved to: wwwroot/uploads/posts/{guid}_image.jpg
✅ Response: Post with duongDanMedia = full URL
✅ Image visible in feed
```

### Test Case 3: Multiple Images (Future)
```
1. Select multiple images
✅ Currently: Only first image uploaded
⏳ TODO: Support 2-5 images
```

---

## 🔍 Console Logs

**Flutter Logs:**
```
[PostService] Creating post - type: image, images: 1
[PostService] Uploading 1 images
[ApiService] Uploading file to: /api/Post/upload
[ApiService] File path: /data/user/.../image.jpg, exists: true
[ApiService] File size: 2048000 bytes
[ApiService] Request fields: {noiDung: Hello, loai: image}
[ApiService] Sending multipart request...
[ApiService] Upload response status: 201
[ApiService] Upload response body: {"success":true,"data":{...}}
```

---

## 📊 Implementation Status

| Component | Status | Notes |
|-----------|--------|-------|
| Backend Endpoint | ✅ Done | POST /api/Post/upload |
| Frontend Logic | ✅ Done | CreatePostScreen upload |
| Image Validation | ✅ Done | Type + size checks |
| File Upload | ✅ Done | Multipart request |
| Error Handling | ✅ Done | Both sides |
| Logging | ✅ Done | Debug info in logs |
| Database | ✅ Done | Saves path in DuongDanMedia |
| URL Service | ✅ Done | Converts to full URLs |

---

## 🔄 Request Flow Diagram

```
Frontend (Flutter)
    ↓
CreatePostScreen.dart
    ↓
User selects image + enters content
    ↓
_submitPost() called
    ↓
Convert XFile → File
    ↓
PostProvider.createPost(noiDung, loai, hinhAnh)
    ↓
PostService.createPost(noiDung, loai, hinhAnh)
    ↓
ImageUpload? YES
    ↓
ApiService.uploadFile(
  endpoint: /api/Post/upload,
  file: File,
  fields: {noiDung, loai}
)
    ↓
HTTP MultipartRequest
    ↓
Backend (C#)
    ↓
PostController.CreatePostWithImage()
    ↓
Validate input
    ↓
Save file to wwwroot/uploads/posts/
    ↓
Generate imagePath: /uploads/posts/{guid}_{filename}
    ↓
Create BaiDang record with imagePath
    ↓
Return PostDto with full URL
    ↓
Frontend receives
    ↓
Update feed UI with new post + image
```

---

## 💾 Database

**BaiDang Table:**
```sql
[DuongDanMedia] NVARCHAR(MAX)
-- Examples:
-- NULL (for text posts)
-- "/uploads/posts/guid_photo.jpg" (stored in DB)
-- "https://server/images/uploads/posts/guid_photo.jpg" (full URL when returned)
```

---

## 🚀 Next Steps (TODOs)

### Immediate
- ✅ Test text post creation
- ✅ Test single image post creation
- ✅ Verify images display in feed

### Short Term
- ⏳ Support multiple images (upload all, not just first)
- ⏳ Add image compression before upload
- ⏳ Add progress indicator for large files
- ⏳ Add retry logic for failed uploads

### Long Term
- ⏳ Support video uploads (loai: 'video')
- ⏳ Support drag & drop image upload
- ⏳ Add image cropping tool
- ⏳ Add image filter effects

---

## 📞 Troubleshooting

**Problem:** 500 error when uploading  
**Solution:** Check that `wwwroot/uploads/posts/` exists and is writable

**Problem:** Image not appearing in feed  
**Solution:** Clear app cache, verify MediaUrlService converts path to full URL

**Problem:** Large images fail to upload  
**Solution:** Increase MultipartBodyLengthLimit in Program.cs (currently 100MB)

**Problem:** Wrong file type accepted  
**Solution:** Verify allowedMimeTypes in backend matches frontend selection

---

## 📚 Related Files

### Backend
- `/Controllers/PostController.cs` - New CreatePostWithImage endpoint
- `/Services/MediaUrlService.cs` - Converts paths to URLs
- `/Program.cs` - FormOptions configuration

### Frontend
- `/lib/screens/posts/create_post_screen.dart` - UI & upload trigger
- `/lib/services/post_service.dart` - Business logic
- `/lib/services/api_service.dart` - HTTP & multipart handling

---

**Status:** ✅ Ready for Testing  
**Created:** November 10, 2025  
**Version:** 1.0
