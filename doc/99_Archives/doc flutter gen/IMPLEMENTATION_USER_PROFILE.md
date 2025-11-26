# User Profile Feature - Implementation Summary

## 📋 Tính Năng Đã Thực Hiện

Đã hoàn thành tính năng cho phép người dùng nhấn vào tên/avatar tác giả trên bài post để xem danh sách bài viết của người đó. Giao diện được thiết kế theo phong cách Twitter bio với banner mặc định.

---

## 🏗️ Cấu Trúc Kiến Trúc

### 1. **User Service** (`lib/services/user_service.dart`)
- **Mục đích:** Quản lý các API calls liên quan đến user
- **Phương thức chính:**
  - `getUserPublicPosts(userId, page, pageSize)` - Lấy danh sách bài viết public của user
  - Dùng endpoint: `GET /api/Post/public/{userId}/posts?page=X&pageSize=Y`
  - Hỗ trợ pagination với `page` và `pageSize`

**Ví dụ sử dụng:**
```dart
final userService = UserService();
final posts = await userService.getUserPublicPosts(
  userId: "user-123",
  page: 1,
  pageSize: 10,
);
```

---

### 2. **User Provider** (`lib/providers/user_provider.dart`)
- **Mục đích:** Quản lý state cho user profile và posts
- **State Management:**
  - `selectedUser` - User hiện tại được xem
  - `userPosts` - Danh sách bài viết của user
  - `isLoading`, `hasMore`, `errorMessage`
  - Pagination: `_currentPage`, `_pageSize = 10`

- **Phương thức chính:**
  - `loadUserProfile(userId, refresh)` - Load profile và posts
  - `loadMoreUserPosts(userId)` - Load thêm posts khi scroll
  - `clearUserProfile()` - Clear state khi rời khỏi màn hình

**Ví dụ sử dụng:**
```dart
// Load profile lần đầu
await context.read<UserProvider>().loadUserProfile(userId);

// Load thêm posts khi scroll
await context.read<UserProvider>().loadMoreUserPosts(userId);
```

---

### 3. **User Profile Screen** (`lib/screens/profile/user_profile_screen.dart`)
- **Giao diện:** Twitter-style bio page
- **Thành phần:**
  - **Header:** Banner (`assets/banner/defaultbanner.jpg`) + Avatar + User info
  - **Stats:** Số bài viết, followers, following
  - **Posts List:** Infinite scroll danh sách bài viết của user
  - **Back button:** Navigation bar phía trên

**Layout:**
```
┌─────────────────────────────┐
│ ◄ [Back Button]  [Search]   │
├─────────────────────────────┤
│ ╔════════════════════════╗   │
│ ║    BANNER IMAGE        ║   │
│ ║ (defaultbanner.jpg)    ║   │
│ ╚════════════════════════╝   │
│      ◯                       │  ← Avatar
│      Name                    │
│      @username               │
│                              │
│ 12 Bài viết | 0 Người theo   │
│             dõi | 0 Đang theo│
│             dõi              │
├─────────────────────────────┤
│ ✍ Bài viết 1               │
│ ✍ Bài viết 2               │
│ ✍ Bài viết 3               │
└─────────────────────────────┘
```

---

### 4. **Navigation Flow**
- **Route:** `/profile/:userId` - Dynamic route cho từng user
- **Main.dart changes:**
  - Import `UserProfileScreen`
  - Thêm `ChangeNotifierProvider(create: (_) => UserProvider())`
  - Thêm `onGenerateRoute` để handle `/profile/{userId}` routing

**Ví dụ:**
```dart
// Navigate to user profile
Navigator.pushNamed(context, '/profile/user-123');

// hoặc từ PostCard
GestureDetector(
  onTap: () {
    Navigator.pushNamed(context, '/profile/${post.authorId}');
  },
  child: UserInfo(),
);
```

---

### 5. **PostCard Updates** (`lib/screens/posts/post_feed_screen.dart`)
- **Thay đổi:** Thêm GestureDetector vào header (avatar + name)
- **Tính năng:**
  - Nhấn vào avatar/name → Navigate đến profile
  - Hiển thị avatar thực từ `post.authorAvatar` (nếu có)
  - Fallback: Icon person_rounded nếu không có avatar

---

## 🔄 Data Flow

```
┌─────────────────────────────────────────────────────┐
│ User nhấn vào tên/avatar trên bài post              │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│ PostCard.onTap (Header)                             │
│ Navigator.pushNamed(context, '/profile/$authorId') │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│ onGenerateRoute() catches /profile/:userId          │
│ Create UserProfileScreen(userId: userId)           │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│ UserProfileScreen.initState()                       │
│ userProvider.loadUserProfile(userId, refresh:true) │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│ UserProvider.loadUserProfile()                      │
│ → UserService.getUserPublicPosts()                  │
│ → API call: GET /api/Post/public/{userId}/posts    │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│ Response received                                   │
│ Update state: _userPosts, _selectedUser             │
│ notifyListeners()                                   │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│ UserProfileScreen builds:                           │
│ - Banner + Avatar + Stats                           │
│ - Posts list (CustomScrollView + SliverList)       │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│ User scrolls → 90% of max scroll                    │
│ → loadMoreUserPosts(userId)                         │
│ → Load next page (page 2, 3, ...)                   │
└─────────────────────────────────────────────────────┘
```

---

## 📁 Files Created/Modified

### ✅ Created:
1. `lib/services/user_service.dart` - User API service (68 lines)
2. `lib/providers/user_provider.dart` - User state management (131 lines)
3. `lib/screens/profile/user_profile_screen.dart` - User profile UI (514 lines)

### ✏️ Modified:
1. `lib/main.dart`
   - Import `UserProvider`, `UserProfileScreen`
   - Add `ChangeNotifierProvider(create: (_) => UserProvider())`
   - Add `onGenerateRoute` for `/profile/:userId` route

2. `lib/screens/posts/post_feed_screen.dart`
   - Modify `_buildHeader()` - Add GestureDetector
   - Add avatar image support with `NetworkImage`
   - Add `Navigator.pushNamed()` for profile navigation

---

## 🎨 UI Features

### Banner & Avatar
- **Banner:** `assets/banner/defaultbanner.jpg` (1:1 aspect ratio in UI)
- **Avatar:** Circular, 80px diameter
  - Real avatar từ `post.authorAvatar` (if available)
  - Fallback: Person icon
- **Overlap:** Avatar overlaps banner (transform.translate offset)

### Stats Display
```
┌─────────────────────┐
│ 12 Bài viết         │
│ 0 Người theo dõi    │
│ 0 Đang theo dõi     │
└─────────────────────┘
```

### Posts Layout
- **Infinite scroll:** Tự động load thêm khi user scroll đến 90%
- **Post card:** Hiển thị như feed (text + image)
- **Pull-to-refresh:** Reload từ page 1
- **Empty state:** Hiển thị message nếu không có bài viết

---

## 🚀 How to Use

### 1. Start your app
```bash
flutter run
```

### 2. Navigate to feed
- Bấm tab "Cộng đồng" (Home feed)

### 3. Tap on post author
- Nhấn vào **avatar hoặc tên tác giả** trên bài post
- App sẽ navigate đến profile của user đó

### 4. Explore user posts
- Xem banner + avatar + stats
- Scroll xuống xem tất cả bài viết
- App tự động load thêm khi scroll

### 5. Go back
- Nhấn back button (arrow) ở top left
- Hoặc dùng Android back button

---

## 🔧 API Integration

### Endpoint Used:
```
GET /api/Post/public/{userId}/posts?page={page}&pageSize={pageSize}
```

### Response Format:
```json
{
  "success": true,
  "message": "Posts retrieved successfully",
  "data": {
    "posts": [
      {
        "id": "post-id",
        "noiDung": "Post content...",
        "authorId": "user-id",
        "authorName": "User Name",
        "authorAvatar": "https://...",
        "luotThich": 15,
        "soBinhLuan": 3,
        "soChiaSe": 2,
        "ngayDang": "2025-11-17T10:30:00",
        "duongDanMedia": "image-url-or-base64"
      }
    ],
    "totalCount": 25,
    "page": 1,
    "pageSize": 10,
    "totalPages": 3,
    "hasPrevious": false,
    "hasNext": true
  }
}
```

---

## 🎯 Key Features Implemented

✅ **User Profile Screen**
- Twitter-style bio layout
- Banner image (assets/banner/defaultbanner.jpg)
- User avatar + name + username
- Stats (posts count, followers, following)
- Back navigation

✅ **Posts List**
- Infinite scroll pagination
- Pull-to-refresh
- Post cards with:
  - Author info
  - Content text (max 4 lines before collapse)
  - Media image
  - Action buttons (like, comment, share)
  - Formatted date/time

✅ **Navigation**
- Tap author name/avatar on post → Profile screen
- Dynamic routing with user ID
- Smooth back navigation

✅ **State Management**
- User profile state
- Posts pagination state
- Loading/error handling
- Refresh capability

---

## 📝 Code Examples

### Navigate to User Profile
```dart
// From any screen
Navigator.pushNamed(context, '/profile/user-123');

// Or with data
final userId = post.authorId;
Navigator.pushNamed(context, '/profile/$userId');
```

### Load User Posts in Widget
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<UserProvider>().loadUserProfile(widget.userId, refresh: true);
  });
}
```

### Listen to User Provider
```dart
Consumer<UserProvider>(
  builder: (context, userProvider, child) {
    if (userProvider.isLoading) {
      return CircularProgressIndicator();
    }
    return ListView(
      children: userProvider.userPosts.map((post) {
        return PostCard(post: post);
      }).toList(),
    );
  },
);
```

---

## 🐛 Troubleshooting

**Issue:** Profile screen shows loading spinner forever
- **Solution:** Check if API endpoint `/api/Post/public/{userId}/posts` is working
- **Debug:** Check console logs for API errors

**Issue:** Avatar not showing
- **Solution:** Check if `post.authorAvatar` is a valid URL
- **Fallback:** App shows person icon

**Issue:** Navigation not working
- **Solution:** Ensure `onGenerateRoute` is properly registered in main.dart
- **Check:** Verify route format is exactly `/profile/{userId}`

**Issue:** Posts not loading on scroll
- **Solution:** Ensure `hasMore` state is true and API returns `hasNext: true`
- **Debug:** Check pagination logic in UserProvider

---

## 📚 Documentation References

- **API Guide:** `doc/like-comment-post.md`
- **Flutter Best Practices:** `.github/instructions/copilot-instructions.md`
- **Project Structure:** Standard Flutter architecture with Provider pattern

---

## ✨ Future Enhancements

1. **Follow/Unfollow Button** - Add follow functionality
2. **Real Stats API** - Replace hardcoded stats with actual API data
3. **User Bio** - Display user bio/description
4. **Message Button** - Send direct message to user
5. **Share Profile** - Share user profile link
6. **Block User** - Block user functionality
7. **User Verification** - Show verified badge
8. **Cached Images** - Add image caching for better performance

---

**Implementation Date:** November 17, 2025  
**Status:** ✅ Complete and error-free  
**Testing:** Ready for QA

