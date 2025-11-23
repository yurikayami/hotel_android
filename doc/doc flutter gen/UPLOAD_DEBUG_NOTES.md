# Debug Upload Images Issue

## Problem
- DuongDanMedia vẫn NULL dù đã gửi ảnh
- Flutter gửi Base64 nhưng backend không nhận

## Hypothesis
1. Flutter không gửi Images array → check `post_service.dart`
2. Backend không nhận được Images → check CreatePostDto model binding
3. Backend nhận được nhưng không xử lý → check CreatePost logic

## Debug Steps

### Step 1: Check Flutter Request Body
Open `lib/services/post_service.dart` line 45-56 and verify:
- `body['images']` contains Base64 strings
- `body['imageMimeTypes']` contains MIME types
- `body['loai']` is correctly set to "image"

### Step 2: Check Backend Logs
In `PostController.cs` CreatePost method, added debug logging:
```csharp
System.Diagnostics.Debug.WriteLine($"[PostController] CreatePost - Received model");
System.Diagnostics.Debug.WriteLine($"[PostController] Images count: {model.Images?.Count ?? 0}");
```

When POST is received, should see in Debug Output:
```
[PostController] Images count: X
```

If count is 0 → problem is in Flutter or API binding
If count > 0 → problem is in image processing logic

### Step 3: Backend Image Processing
If Images are received, check:
- Base64 decoding succeeds
- File saved to `wwwroot/uploads/posts/`
- `imagePath` is set correctly (not null)
- `DuongDanMedia` is assigned from `imagePath`

### Step 4: Database Insertion
After `_context.BaiDang.Add(newPost)` and `SaveChangesAsync()`:
- DuongDanMedia should have value from `imagePath`

## To Debug:
1. Make sure both Flutter and Backend are running
2. Create a post with an image
3. Check Visual Studio Debug Output for "[PostController]" messages
4. Check database for the created post
5. If DuongDanMedia is NULL, logs will tell us where it failed

## Fixes Applied:
1. ✅ Added auto-detection of post type (image vs text)
2. ✅ Changed line 201 to set DuongDanMedia from imagePath directly
3. ✅ Added debug logging to see what's received

## Next Steps:
- Run Flutter app and create post with image
- Check Debug Output in Visual Studio
- Verify DuongDanMedia is populated
