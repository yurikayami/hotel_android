# Hướng Dẫn Khắc Phục Sự Cố Avatar Không Hiển Thị Trong Search Screen

## 📋 Mô Tả Vấn Đề

Avatar của người dùng và tác giả bài viết không hiển thị trong màn hình tìm kiếm tổng quát (`general_search_screen.dart`), trong khi các màn hình khác như `post_feed_screen.dart` và `user_profile_screen.dart` hoạt động bình thường.

## 🔍 Nguyên Nhân Chính

### 1. **Mapping Dữ Liệu Từ API Không Đúng**
- Trong `search_provider.dart`, field `avatar` từ API được map sang `avatarUrl` của model `User`
- API có thể trả về các format khác nhau:
  - `'avatar'` (không có 'Url')
  - `'avatarUrl'` (đầy đủ)
  - Relative URL như `/uploads/avatar.jpg` (không bắt đầu bằng 'http')

### 2. **Logic Kiểm Tra Avatar Không Xử Lý Relative URLs**
- Code kiểm tra `startsWith('http')` để dùng `NetworkImage`
- Nếu API trả về relative URL, sẽ fallback sang `AssetImage('assets/images/avatar.jpg')`
- Điều này làm avatar không hiển thị đúng

### 3. **API Response Khác Nhau**
- API search (`/api/search`) có thể trả về format khác với các API khác
- Log cho thấy `"image": null` nhưng không thấy avatar cho users

## 🛠️ Các Bước Khắc Phục

### Bước 1: Cập Nhật `search_provider.dart`

```dart
// Trong lib/providers/search_provider.dart
// Thêm helper method để normalize avatar URL
String _normalizeAvatarUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  if (url.startsWith('http')) return url;  // Full URL
  if (url.startsWith('/')) return 'https://192.168.1.3:7135$url';  // Relative URL
  return url;  // Other cases
}

// Cập nhật _mapUser method
Map<String, dynamic> _mapUser(Map<String, dynamic> user) {
  return {
    'id': user['id'] ?? user['userId'] ?? '',
    'userName': user['userName'] ?? user['username'] ?? user['name'] ?? '',
    'avatarUrl': _normalizeAvatarUrl(user['avatar'] ?? user['avatarUrl']),
    // ... other fields
  };
}

// Cập nhật _mapPost method
Map<String, dynamic> _mapPost(Map<String, dynamic> post) {
  return {
    // ... other fields
    'authorAvatar': _normalizeAvatarUrl(post['authorAvatar'] ?? post['author']?['avatar'] ?? ''),
    // ... other fields
  };
}
```

### Bước 2: Cập Nhật Logic Hiển Thị Avatar Trong `general_search_screen.dart`

```dart
// Thay thế tất cả CircleAvatar widgets với logic sau:

// Cho user cards
CircleAvatar(
  radius: 24,
  backgroundColor: Colors.grey[800],
  backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
      ? NetworkImage(user.avatarUrl!)
      : const AssetImage('assets/images/avatar.jpg') as ImageProvider,
  child: user.avatarUrl == null || user.avatarUrl!.isEmpty
      ? const Icon(Icons.person, color: Colors.white, size: 24)
      : null,
);

// Cho post cards
CircleAvatar(
  radius: 24,
  backgroundColor: Colors.grey[800],
  backgroundImage: post.authorAvatar != null && post.authorAvatar!.isNotEmpty
      ? NetworkImage(post.authorAvatar!)
      : const AssetImage('assets/images/avatar.jpg') as ImageProvider,
  child: post.authorAvatar == null || post.authorAvatar!.isEmpty
      ? const Icon(Icons.person, color: Colors.white, size: 24)
      : null,
);
```

### Bước 3: Thêm Debug Logging

```dart
// Trong general_search_screen.dart, thêm logging để debug
Widget _buildUserCardHorizontal(User user) {
  print('🔍 User avatarUrl: ${user.avatarUrl}');
  print('👤 User name: ${user.userName}');
  // ... rest of code
}

Widget _buildPostCardHorizontal(Post post) {
  print('🔍 Post authorAvatar: ${post.authorAvatar}');
  print('👤 Post authorName: ${post.authorName}');
  // ... rest of code
}
```

### Bước 4: Kiểm Tra API Response

Sử dụng Postman hoặc curl để kiểm tra API:

```bash
# Test search users
curl -X GET "https://192.168.1.3:7135/api/search?q=ngocphuc&type=users" \
  -H "Content-Type: application/json"

# Test search posts
curl -X GET "https://192.168.1.3:7135/api/search?q=test&type=posts" \
  -H "Content-Type: application/json"
```

Kiểm tra response có chứa:
- `avatar` hoặc `avatarUrl` cho users
- `authorAvatar` cho posts

### Bước 5: Đảm Bảo Asset File Tồn Tại

Tạo file `assets/images/avatar.jpg` trong project nếu chưa có:
- Kích thước: 100x100px hoặc lớn hơn
- Format: JPG hoặc PNG
- Nên là avatar mặc định đơn giản

### Bước 6: Xử Lý Base64 Images (Nếu Cần)

Nếu API trả về base64, thêm logic decode:

```dart
Widget _buildAvatarImage(String? avatarUrl) {
  if (avatarUrl == null || avatarUrl.isEmpty) {
    return const AssetImage('assets/images/avatar.jpg');
  }

  // Handle base64
  if (avatarUrl.startsWith('data:image')) {
    final base64Data = avatarUrl.split(',').last;
    return MemoryImage(base64Decode(base64Data));
  }

  // Handle relative URLs
  if (avatarUrl.startsWith('/')) {
    return NetworkImage('https://192.168.1.3:7135$avatarUrl');
  }

  // Handle full URLs
  return NetworkImage(avatarUrl);
}
```

## 🧪 Kiểm Tra Sau Khi Fix

### 1. **Restart App**
```bash
flutter clean
flutter pub get
flutter run
```

### 2. **Test Các Tình Huống**
- Tìm kiếm user có avatar
- Tìm kiếm user không có avatar
- Tìm kiếm posts có author avatar
- Tìm kiếm posts không có author avatar

### 3. **Kiểm Tra Console Logs**
- Xem logs từ debug statements
- Kiểm tra network requests trong DevTools
- Xem có lỗi 404 hay không

### 4. **So Sánh Với Các Màn Hình Khác**
- So sánh với `post_feed_screen.dart`
- So sánh với `user_profile_screen.dart`
- Đảm bảo behavior consistent

## 🚨 Các Vấn Đề Thường Gặp

### **Vấn Đề 1: Avatar Vẫn Không Hiển Thị**
- **Nguyên nhân**: API không trả về avatar
- **Giải pháp**: Kiểm tra API response, liên hệ backend team

### **Vấn Đề 2: Avatar Hiển Thị Sai**
- **Nguyên nhân**: URL malformed hoặc network error
- **Giải pháp**: Thêm error handling cho NetworkImage

### **Vấn Đề 3: Avatar Cache Cũ**
- **Nguyên nhân**: Flutter cache old images
- **Giải pháp**: Restart app hoặc clear cache

### **Vấn Đề 4: Base64 Decode Error**
- **Nguyên nhân**: Base64 string malformed
- **Giải pháp**: Thêm try-catch cho base64Decode

## 📝 Code Examples Hoàn Chỉnh

### SearchProvider Updates

```dart
// lib/providers/search_provider.dart
class SearchProvider extends ChangeNotifier {
  // ... existing code ...

  String _normalizeAvatarUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    if (url.startsWith('/')) return 'https://192.168.1.3:7135$url';
    return url;
  }

  Map<String, dynamic> _mapUser(Map<String, dynamic> user) {
    return {
      'id': user['id'] ?? user['userId'] ?? '',
      'userName': user['userName'] ?? user['username'] ?? user['name'] ?? '',
      'avatarUrl': _normalizeAvatarUrl(user['avatar'] ?? user['avatarUrl']),
      // ... other fields
    };
  }

  Map<String, dynamic> _mapPost(Map<String, dynamic> post) {
    return {
      // ... other fields
      'authorAvatar': _normalizeAvatarUrl(post['authorAvatar'] ?? post['author']?['avatar'] ?? ''),
      // ... other fields
    };
  }

  // ... existing code ...
}
```

### GeneralSearchScreen Avatar Widgets

```dart
// lib/screens/search/general_search_screen.dart
class _GeneralSearchScreenState extends State<GeneralSearchScreen> {
  // ... existing code ...

  Widget _buildUserCardHorizontal(User user) {
    print('🔍 User avatarUrl: ${user.avatarUrl}');
    print('👤 User name: ${user.userName}');

    return Container(
      width: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[900]!, Colors.grey[850]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(userId: user.id),
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                      ? NetworkImage(user.avatarUrl!)
                      : const AssetImage('assets/images/avatar.jpg') as ImageProvider,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                user.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostCardHorizontal(Post post) {
    print('🔍 Post authorAvatar: ${post.authorAvatar}');
    print('👤 Post authorName: ${post.authorName}');

    final isHtml = post.noiDung.contains('<') && post.noiDung.contains('>');
    final hasImage = post.duongDanMedia != null && post.duongDanMedia!.isNotEmpty;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailScreen(post: post),
        ),
      ),
      child: Container(
        color: Colors.black,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF4CAF50), width: 1),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: post.authorAvatar != null && post.authorAvatar!.isNotEmpty
                        ? NetworkImage(post.authorAvatar!)
                        : const AssetImage('assets/images/avatar.jpg') as ImageProvider,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatPostDate(post.ngayDang),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (post.noiDung.isNotEmpty)
              isHtml
                  ? HtmlContentViewer(
                      htmlContent: post.noiDung,
                      baseStyle: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    )
                  : Text(
                      post.noiDung,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
            if (hasImage) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _buildImageWidget(post.duongDanMedia!),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPostActionButton(
                  Icons.chat_bubble_outline_rounded,
                  '${post.soBinhLuan ?? 0}',
                ),
                _buildPostActionButton(
                  Icons.favorite_outline_rounded,
                  '${post.luotThich ?? 0}',
                ),
                _buildPostActionButton(
                  Icons.share_outlined,
                  '',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ... existing code ...
}
```

## 🔧 Tools và Commands

### Flutter Commands
```bash
# Clean và rebuild
flutter clean
flutter pub get
flutter run

# Debug network
flutter run --debug
# Mở DevTools trong browser
```

### API Testing
```bash
# Test search API
curl -X GET "https://192.168.1.3:7135/api/search?q=test&type=users" \
  -H "Content-Type: application/json" \
  -v

# Check response format
curl -X GET "https://192.168.1.3:7135/api/search?q=test&type=posts" \
  -H "Content-Type: application/json" | jq .
```

## 📞 Liên Hệ Support

Nếu sau khi thực hiện các bước trên vẫn gặp vấn đề:

1. **Paste console logs** từ debug statements
2. **API response samples** từ Postman/curl
3. **Screenshots** của UI hiện tại
4. **Flutter version**: `flutter --version`

## ✅ Checklist Hoàn Thành

- [ ] Cập nhật `search_provider.dart` với `_normalizeAvatarUrl`
- [ ] Fix mapping trong `_mapUser` và `_mapPost`
- [ ] Cập nhật tất cả `CircleAvatar` widgets trong `general_search_screen.dart`
- [ ] Thêm debug logging
- [ ] Test API responses
- [ ] Đảm bảo `assets/images/avatar.jpg` tồn tại
- [ ] Restart app và test
- [ ] Verify avatar hiển thị đúng

---

**Tạo bởi**: AI Assistant  
**Ngày**: November 22, 2025  
**Version**: 1.0  
**Áp dụng cho**: Hotel Android App - Search Screen Avatar Issue</content>
<parameter name="filePath">d:\Workspace\01 Project\Project Dev\Graduation project\Main Project\Hotel_Android\hotel_android\AVATAR_FIX_GUIDE.md