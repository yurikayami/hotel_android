# Image Upload - Bug Fixes Summary

**Date:** November 10, 2025

## Problem
Hình ảnh không gửi được qua server khi tạo bài viết

## Root Cause
- CreatePostScreen sử dụng `XFile` từ image_picker
- Nhưng PostService.createPost() kỳ vọng `List<File>` từ dart:io
- Không có chuyển đổi giữa XFile → File
- Không có logging để debug issue

## Solutions Applied

### 1. ✅ CreatePostScreen - Convert XFile to File
**File:** `lib/screens/posts/create_post_screen.dart`

```dart
// Convert XFile to File before sending
final imageFiles = _selectedImages.map((xfile) => File(xfile.path)).toList();

await postProvider.createPost(
  noiDung: _contentController.text.trim(),
  loai: _postType,
  hinhAnh: imageFiles.isNotEmpty ? imageFiles : null,
);
```

**Changes:**
- Added `import 'dart:io'` for File class
- Convert `List<XFile>` to `List<File>` using `.map((xfile) => File(xfile.path))`
- Pass `hinhAnh` parameter to createPost

### 2. ✅ PostService - Enhanced Logging
**File:** `lib/services/post_service.dart`

```dart
print('[PostService] Creating post - type: $loai, images: ${hinhAnh?.length ?? 0}');
print('[PostService] Uploading ${hinhAnh.length} images');
print('[PostService] Upload response: $response');
```

**Changes:**
- Added logging for post creation flow
- Shows image count being uploaded
- Logs API response for debugging

### 3. ✅ ApiService - Enhanced Logging
**File:** `lib/services/api_service.dart`

```dart
print('[ApiService] Uploading file to: $endpoint');
print('[ApiService] File path: ${file.path}, exists: ${file.existsSync()}');
print('[ApiService] File size: ${file.lengthSync()} bytes');
print('[ApiService] Upload response status: ${response.statusCode}');
print('[ApiService] Upload response body: ${response.body}');
```

**Changes:**
- Added file validation logging
- Shows file exists check
- Shows file size
- Logs HTTP response status and body
- Logs socket errors with details

## Testing

### Test Case 1: Create Text Post (No Images)
1. Open CreatePostScreen
2. Select "Văn bản" type
3. Enter content
4. Click "Đăng"
5. ✅ Should create post without images

### Test Case 2: Create Image Post
1. Open CreatePostScreen
2. Select "Hình ảnh" type
3. Enter content
4. Click "Thêm hình ảnh"
5. Select one or more images
6. Click "Đăng"
7. ✅ Check console logs:
   - `[PostService] Creating post - type: image, images: 1`
   - `[ApiService] Uploading file to: /Post`
   - `[ApiService] File size: XXXX bytes`
   - `[ApiService] Upload response status: 200`
   - ✅ Post should appear in feed with image

### Expected Logs
```
[PostService] Creating post - type: image, images: 1
[PostService] Uploading 1 images
[ApiService] Uploading file to: /Post
[ApiService] File path: /data/user/.../image.jpg, exists: true
[ApiService] File size: 45000 bytes
[ApiService] Request fields: {noiDung: Hello, loai: image}
[ApiService] Sending multipart request...
[ApiService] Upload response status: 200
[ApiService] Upload response body: {"success":true,"data":{"id":"...","noiDung":"Hello",...}}
[PostService] Upload response: {success: true, data: {...}}
[PostService] Create post success!
```

## File Changes Summary

| File | Changes | Status |
|------|---------|--------|
| create_post_screen.dart | ✅ XFile → File conversion, pass hinhAnh param | ✅ No errors |
| post_provider.dart | ✅ Already had hinhAnh support | ✅ No errors |
| post_service.dart | ✅ Added logging to createPost | ✅ No errors |
| api_service.dart | ✅ Added logging to uploadFile | ✅ No errors |

## Debugging Steps If Issues Persist

1. **Check Flutter console logs** for `[PostService]` and `[ApiService]` messages
2. **File exists?** Log shows "exists: true"
3. **File size?** Should be > 0 bytes
4. **Network error?** Check for "No internet connection" message
5. **API error?** Check response status code and body

## Next Steps

- ✅ Test with single image upload
- ⏳ Test with multiple images (TODO: API supports batch upload)
- ⏳ Add image compression validation
- ⏳ Add progress indicator for large files
- ⏳ Support video upload (loai: 'video')

## API Endpoint
- **POST** `/api/Post` - Upload post with image
- **Fields:**
  - `noiDung` (string) - Post content
  - `loai` (string) - Post type (text/image/video)
  - `image` (file) - Image file (multipart)
