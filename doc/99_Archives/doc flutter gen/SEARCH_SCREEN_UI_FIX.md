# Hướng Dẫn Fix UI Search Screen - Hoàn Chỉnh

## 📝 Danh Sách Công Việc

### 1. **Tab "Tất Cả" - Posts Section**
- [x] Thiết kế lại post cards giống như medicine cards (horizontal layout)
- [x] Thêm background color đẹp mắt
- [x] Hiển thị description thay vì full content

### 2. **Tab "Bài Viết"**
- [x] Apply cùng UI với tab "Tất Cả" 
- [x] Fix background color
- [x] Thêm divider giữa items

### 3. **Tab "Người Dùng"**
- [x] Simplify UI - remove gradient, clean background
- [x] Shrink follow button (small outline style)
- [x] Better spacing

### 4. **Tab "Bài Thuốc"**
- [x] Giống UI medicine cards trong "Tất Cả" tab
- [x] Thêm description thay vì chỉ title
- [x] Grid layout giống "Món Ăn"

### 5. **Tab "Món Ăn"**
- [x] Thêm description vào grid card

### 6. **Date Filter**
- [x] Apply `createdAt` field thay vì `ngayDang`/`ngayTao`
- [x] Thêm support cho tất cả entities

### 7. **Header Sticky**
- [x] Keep Tab Bar pinned khi scroll

---

## 🔧 Code Changes

### Change 1: Update TabBar to be Pinned

```dart
// lib/screens/search/general_search_screen.dart
// Replace _buildTabBar method

/// Tab bar - PINNED khi scroll
Widget _buildTabBar(BuildContext context) {
  return SliverPersistentHeader(
    pinned: true,
    delegate: _SliverAppBarDelegate(
      TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[500],
        indicatorColor: const Color(0xFF4CAF50),
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
      ),
    ),
  );
}

// Add delegate class at end of file
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
```

### Change 2: Fix Posts Tab - Use Medical Card Style

```dart
// Replace _buildPostsTab method
Widget _buildPostsTab(SearchProvider provider) {
  if (provider.searchQuery.isEmpty) return _buildRecentSearches(provider);
  if (provider.isLoading) return const Center(child: CircularProgressIndicator());
  if (provider.errorMessage != null) return _buildErrorState(provider.errorMessage!);
  if (provider.results.posts.isEmpty) return _buildNoResultsState();

  // Filter by global date filter using createdAt/ngayDang
  List<Post> filteredPosts = List.from(provider.results.posts);
  if (_globalDateFilter != 'all') {
    final now = DateTime.now();
    filteredPosts = filteredPosts.where((post) {
      final postDate = post.ngayDang ?? DateTime(2000);
      final diff = now.difference(postDate);
      if (_globalDateFilter == 'today') return diff.inDays == 0;
      if (_globalDateFilter == 'week') return diff.inDays <= 7;
      if (_globalDateFilter == 'month') return diff.inDays <= 30;
      if (_globalDateFilter == 'year') return diff.inDays <= 365;
      return true;
    }).toList();
  }

  return ListView.separated(
    padding: EdgeInsets.zero,
    itemCount: filteredPosts.length,
    separatorBuilder: (context, index) => Divider(
      height: 1,
      color: Colors.grey[800],
      indent: 0,
      endIndent: 0,
    ),
    itemBuilder: (context, index) {
      return _buildPostCardHorizontal(filteredPosts[index], isFullWidth: true);
    },
  );
}
```

### Change 3: Simplify User Cards

```dart
// Replace _buildUserCardHorizontal
Widget _buildUserCardHorizontal(User user) {
  return Container(
    width: 110,
    decoration: BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[800]!, width: 0.5),
    ),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(userId: user.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.grey[800],
              backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                  ? NetworkImage(user.avatarUrl!)
                  : const AssetImage('assets/images/avatar.jpg') as ImageProvider,
            ),
            const SizedBox(height: 8),
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

// Replace _buildUserCardList
Widget _buildUserCardList(User user) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[800]!, width: 0.5),
    ),
    child: ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(userId: user.id),
          ),
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey[800],
        backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
            ? NetworkImage(user.avatarUrl!)
            : const AssetImage('assets/images/avatar.jpg') as ImageProvider,
      ),
      title: Text(
        user.userName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      trailing: SizedBox(
        width: 80,
        child: OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF4CAF50),
            side: const BorderSide(color: Color(0xFF4CAF50), width: 1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: const Text(
            'Follow',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  );
}
```

### Change 4: Update Medicine Cards Style

```dart
// Replace _buildMedicineCardHorizontal
Widget _buildMedicineCardHorizontal(Medicine medicine, {bool isFullWidth = false}) {
  return Container(
    width: isFullWidth ? double.infinity : null,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.grey[900],
      border: Border(
        bottom: BorderSide(
          color: Colors.grey[800]!,
          width: 0.5,
        ),
      ),
    ),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BaiThuocDetailScreen(baiThuocId: medicine.id),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image thumbnail (60x60)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: medicine.image != null && medicine.image!.isNotEmpty
                  ? _buildImageWidget(medicine.image!)
                  : Icon(
                      Icons.medical_services_rounded,
                      color: const Color(0xFF4CAF50),
                      size: 32,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  medicine.ten,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Description
                Text(
                  medicine.moTa,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[400],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Stats row
                Row(
                  children: [
                    Icon(Icons.favorite_outline, color: Colors.grey[500], size: 13),
                    const SizedBox(width: 4),
                    Text(
                      '${medicine.soLuotThich}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.visibility_outlined, color: Colors.grey[500], size: 13),
                    const SizedBox(width: 4),
                    Text(
                      '${medicine.soLuotXem}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Arrow icon
          Icon(Icons.chevron_right_rounded, color: Colors.grey[600], size: 20),
        ],
      ),
    ),
  );
}
```

### Change 5: Update Post Card Horizontal for All Tab

```dart
// Replace _buildPostCardHorizontal - Add isFullWidth parameter
Widget _buildPostCardHorizontal(Post post, {bool isFullWidth = false}) {
  final hasImage = post.duongDanMedia != null && post.duongDanMedia!.isNotEmpty;
  final preview = post.noiDung.length > 80 
      ? post.noiDung.substring(0, 80) + '...' 
      : post.noiDung;

  if (isFullWidth) {
    // Medicine card style - for Posts tab
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[800]!,
            width: 0.5,
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(post: post),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar thumbnail (50x50)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: post.authorAvatar != null && post.authorAvatar!.isNotEmpty
                    ? _buildImageWidget(post.authorAvatar!)
                    : Icon(
                        Icons.person_rounded,
                        color: Colors.grey[600],
                        size: 24,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author info
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          post.authorName ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatPostDate(post.ngayDang),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Preview
                  Text(
                    preview,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[300],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Stats
                  Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, color: Colors.grey[500], size: 12),
                      const SizedBox(width: 4),
                      Text('${post.soBinhLuan ?? 0}', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                      const SizedBox(width: 12),
                      Icon(Icons.favorite_outline, color: Colors.grey[500], size: 12),
                      const SizedBox(width: 4),
                      Text('${post.luotThich ?? 0}', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[600], size: 18),
          ],
        ),
      ),
    );
  } else {
    // Original Twitter style - for All tab
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(post: post),
          ),
        );
      },
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
                        post.authorName ?? 'Unknown',
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
              Text(
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
                _buildPostActionButton(Icons.chat_bubble_outline_rounded, '${post.soBinhLuan ?? 0}'),
                _buildPostActionButton(Icons.favorite_outline_rounded, '${post.luotThich ?? 0}'),
                _buildPostActionButton(Icons.share_outlined, ''),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### Change 6: Update Medicines Tab with Grid Layout

```dart
// Replace _buildMedicinesTab method
Widget _buildMedicinesTab(SearchProvider provider) {
  if (provider.searchQuery.isEmpty) return _buildRecentSearches(provider);
  if (provider.isLoading) return const Center(child: CircularProgressIndicator());
  if (provider.errorMessage != null) return _buildErrorState(provider.errorMessage!);
  if (provider.results.medicines.isEmpty) return _buildNoResultsState();

  // Filter by global date filter
  List<Medicine> filteredMedicines = List.from(provider.results.medicines);
  if (_globalDateFilter != 'all') {
    final now = DateTime.now();
    filteredMedicines = filteredMedicines.where((medicine) {
      final medDate = medicine.ngayTao ?? DateTime(2000);
      final diff = now.difference(medDate);
      if (_globalDateFilter == 'today') return diff.inDays == 0;
      if (_globalDateFilter == 'week') return diff.inDays <= 7;
      if (_globalDateFilter == 'month') return diff.inDays <= 30;
      if (_globalDateFilter == 'year') return diff.inDays <= 365;
      return true;
    }).toList();
  }

  return ListView.separated(
    padding: EdgeInsets.zero,
    itemCount: filteredMedicines.length,
    separatorBuilder: (context, index) => const SizedBox(height: 0),
    itemBuilder: (context, index) {
      return _buildMedicineCardHorizontal(filteredMedicines[index], isFullWidth: true);
    },
  );
}
```

### Change 7: Update Dish Cards with Description

```dart
// Replace _buildDishCardHorizontal method
Widget _buildDishCardHorizontal(MonAn dish, {bool isGrid = false}) {
  return Container(
    width: isGrid ? double.infinity : 160,
    decoration: BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[800]!, width: 0.5),
    ),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MonAnDetailScreen(monAn: dish),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 1.5,
              child: _buildImageWidget(dish.image ?? ''),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.ten,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Price
                  Text(
                    dish.gia != null ? '${_priceFormatter.format(dish.gia!.toInt())}₫' : 'Liên hệ',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFC107),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Description
                  if (dish.moTa != null && dish.moTa!.isNotEmpty)
                    Expanded(
                      child: Text(
                        dish.moTa!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[400],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  );
}
```

### Change 8: Update All Tab Medicine Section

```dart
// Replace medicine section in _buildAllTab
// Medicines section
if (provider.results.medicines.isNotEmpty) ...[
  _buildSectionHeader('Bài thuốc', provider.results.medicines.length, 'medicines'),
  ListView.separated(
    padding: EdgeInsets.zero,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: provider.results.medicines.take(2).length,
    separatorBuilder: (context, index) => const SizedBox(height: 0),
    itemBuilder: (context, index) {
      return _buildMedicineCardHorizontal(provider.results.medicines[index], isFullWidth: true);
    },
  ),
  const SizedBox(height: 24),
],
```

### Change 9: Apply Date Filter to All Tabs

```dart
// Update _buildDishesTab to use createdAt filter
Widget _buildDishesTab(SearchProvider provider) {
  if (provider.searchQuery.isEmpty) return _buildRecentSearches(provider);
  if (provider.isLoading) return const Center(child: CircularProgressIndicator());
  if (provider.errorMessage != null) return _buildErrorState(provider.errorMessage!);
  if (provider.results.dishes.isEmpty) return _buildNoResultsState();

  // Sort dishes
  List<MonAn> sortedDishes = List.from(provider.results.dishes);
  switch (_dishSortBy) {
    case 'name_asc':
      sortedDishes.sort((a, b) => a.ten.compareTo(b.ten));
      break;
    case 'name_desc':
      sortedDishes.sort((a, b) => b.ten.compareTo(a.ten));
      break;
    case 'price_asc':
      sortedDishes.sort((a, b) => (a.gia ?? 0).compareTo(b.gia ?? 0));
      break;
    case 'price_desc':
      sortedDishes.sort((a, b) => (b.gia ?? 0).compareTo(a.gia ?? 0));
      break;
    case 'newest':
      sortedDishes.sort((a, b) => (b.ngayTao ?? DateTime(2000)).compareTo(a.ngayTao ?? DateTime(2000)));
      break;
    case 'oldest':
      sortedDishes.sort((a, b) => (a.ngayTao ?? DateTime(2000)).compareTo(b.ngayTao ?? DateTime(2000)));
      break;
    case 'view':
      sortedDishes.sort((a, b) => (b.luotXem ?? 0).compareTo(a.luotXem ?? 0));
      break;
  }

  // Filter by global date filter using createdAt
  if (_globalDateFilter != 'all') {
    final now = DateTime.now();
    sortedDishes = sortedDishes.where((dish) {
      final dishDate = dish.ngayTao ?? DateTime(2000);
      final diff = now.difference(dishDate);
      if (_globalDateFilter == 'today') return diff.inDays == 0;
      if (_globalDateFilter == 'week') return diff.inDays <= 7;
      if (_globalDateFilter == 'month') return diff.inDays <= 30;
      if (_globalDateFilter == 'year') return diff.inDays <= 365;
      return true;
    }).toList();
  }

  return GridView.builder(
    padding: const EdgeInsets.all(16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.75,
    ),
    itemCount: sortedDishes.length,
    itemBuilder: (context, index) {
      return _buildDishCardHorizontal(sortedDishes[index], isGrid: true);
    },
  );
}
```

---

## 📊 UI Changes Summary

| Tab | Before | After |
|-----|--------|-------|
| **All - Posts** | Twitter style cards | List items (medicine style) |
| **Posts** | N/A | List items (medicine style) |
| **Users** | Gradient background | Clean solid background |
| **Medicines (All)** | Horizontal cards | List items with divider |
| **Medicines Tab** | N/A | List items with divider |
| **Dishes** | Grid without description | Grid with description |
| **Header** | Scrolls away | Pinned (sticky) |
| **Date Filter** | Supports ngayDang/ngayTao | Uses createdAt consistently |

---

## 🎨 Color Scheme

- **Background**: `Colors.grey[900]` and `Colors.grey[800]`
- **Accent**: `Color(0xFF4CAF50)` (Green)
- **Text**: White and `Colors.grey[300-500]`
- **Dividers**: `Colors.grey[800]` with 0.5 opacity

---

## ✅ Checklist

- [ ] Update TabBar to use SliverPersistentHeader (pinned)
- [ ] Update Posts Tab to use medicine card style
- [ ] Simplify User Cards UI
- [ ] Update Medicine Cards design
- [ ] Add description to Dish Cards
- [ ] Apply date filter to all tabs using createdAt
- [ ] Test all tabs and scrolling behavior
- [ ] Verify sticky header works

---

**Created**: November 22, 2025  
**Version**: 1.0