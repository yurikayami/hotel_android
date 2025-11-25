import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../providers/search_provider.dart';
import '../../models/post.dart';
import '../../models/mon_an.dart';
import '../../models/user.dart';
import '../../models/medicine.dart';
import '../../utils/image_url_helper.dart';
import '../posts/post_detail_screen.dart';
import '../food/mon_an_detail_screen.dart';
import '../profile/user_profile_screen.dart';
import '../bai_thuoc/bai_thuoc_detail_screen.dart';

/// Màn hình tìm kiếm tổng quát với tabs và filter/sort
class GeneralSearchScreen extends StatefulWidget {
  const GeneralSearchScreen({super.key});

  @override
  State<GeneralSearchScreen> createState() => _GeneralSearchScreenState();
}

class _GeneralSearchScreenState extends State<GeneralSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late TabController _tabController;
  final List<String> _tabLabels = ['Tất cả', 'Người dùng', 'Bài viết', 'Bài thuốc', 'Món ăn'];
  final List<String> _tabTypes = ['all', 'users', 'posts', 'medicines', 'dishes'];
  final _priceFormatter = NumberFormat('#,###', 'vi_VN');

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    // Reset search state when entering screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().clearSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTabChanged() {
    final provider = context.read<SearchProvider>();
    final newType = _tabTypes[_tabController.index];

    if (provider.selectedType != newType) {
      provider.setSearchType(newType);

      // Tìm kiếm lại với loại mới nếu có query
      if (_searchController.text.isNotEmpty) {
        _performSearch(_searchController.text);
      }
    }
  }

  void _onSearchChanged(String query) {
    // Debounce search 500ms
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      context.read<SearchProvider>().clearSearch();
      return;
    }

    context.read<SearchProvider>().search(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Consumer<SearchProvider>(
          builder: (context, provider, child) {
            return DefaultTabController(
              length: _tabLabels.length,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    // App bar with search field
                    _buildAppBar(context, provider),
                    
                    // Tab bar
                    _buildTabBar(context),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllTab(provider),
                    _buildUsersTab(provider),
                    _buildPostsTab(provider),
                    _buildMedicinesTab(provider),
                    _buildDishesTab(provider),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// App bar với search field
  Widget _buildAppBar(BuildContext context, SearchProvider provider) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.black,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm...',
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
            prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: Colors.grey[500]),
                    onPressed: () {
                      _searchController.clear();
                      context.read<SearchProvider>().clearSearch();
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          onChanged: (value) {
            setState(() {});
            _onSearchChanged(value);
          },
        ),
      ),
    );
  }

  /// Tab bar sticky with bottom divider
  Widget _buildTabBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.black,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: 24,
      flexibleSpace: Column(
        children: [
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
          Container(
            height: 1,
            color: const Color.fromARGB(255, 41, 41, 41),
          ),
        ],
      ),
    );
  }

  // ============ TAB BUILDERS ============

  /// Tab "Tất cả" - hiển thị tất cả kết quả theo thứ tự: Users -> Posts -> Medicines -> Dishes
  Widget _buildAllTab(SearchProvider provider) {
    if (provider.searchQuery.isEmpty) {
      return _buildRecentSearches(provider);
    }

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return _buildErrorState(provider.errorMessage!);
    }

    if (provider.results.isEmpty) {
      return _buildNoResultsState();
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 32, top: 0),
      children: [
        // 1. Users section (TikTok style list)
        if (provider.results.users.isNotEmpty) ...[
          _buildSectionHeader('Người dùng', provider.results.users.length, 'users'),
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.results.users.take(5).length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildUserItemTikTok(provider.results.users[index]),
          ),
          const SizedBox(height: 24),
        ],
        
        // 2. Posts section (Magazine style)
        if (provider.results.posts.isNotEmpty) ...[
          _buildSectionHeader('Bài viết nổi bật', provider.results.posts.length, 'posts'),
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.results.posts.take(3).length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[800]),
            itemBuilder: (context, index) => _buildPostMagazineItem(provider.results.posts[index]),
          ),
          const SizedBox(height: 24),
        ],
        
        // 3. Medicines section (Horizontal scroll)
        if (provider.results.medicines.isNotEmpty) ...[
          _buildSectionHeader('Bài thuốc dân gian', provider.results.medicines.length, 'medicines'),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: provider.results.medicines.take(8).length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 140,
                    child: _buildGridContentItem(
                      provider.results.medicines[index],
                      type: 'medicine',
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
        
        // 4. Dishes section (Horizontal scroll)
        if (provider.results.dishes.isNotEmpty) ...[
          _buildSectionHeader('Món ngon mỗi ngày', provider.results.dishes.length, 'dishes'),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: provider.results.dishes.take(8).length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 160,
                    child: _buildGridContentItem(
                      provider.results.dishes[index],
                      type: 'dish',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  /// Tab "Người dùng"
  Widget _buildUsersTab(SearchProvider provider) {
    if (provider.searchQuery.isEmpty) return _buildRecentSearches(provider);
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.errorMessage != null) return _buildErrorState(provider.errorMessage!);
    if (provider.results.users.isEmpty) return _buildNoResultsState();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      itemCount: provider.results.users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _buildUserItemTikTok(provider.results.users[index]);
      },
    );
  }

  /// Tab "Bài viết" với FilterBar
  Widget _buildPostsTab(SearchProvider provider) {
    if (provider.searchQuery.isEmpty) return _buildRecentSearches(provider);
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.errorMessage != null) return _buildErrorState(provider.errorMessage!);
    if (provider.results.posts.isEmpty) return _buildNoResultsState();

    final posts = provider.filteredPosts;

    return ListView.builder(
      itemCount: posts.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildFilterBar(provider, type: 'posts');
        }
        final postIndex = index - 1;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPostMagazineItem(posts[postIndex]),
            if (postIndex < posts.length - 1)
              Divider(height: 1, color: Colors.grey[800]),
          ],
        );
      },
    );
  }

  /// Tab "Bài thuốc" với FilterBar
  Widget _buildMedicinesTab(SearchProvider provider) {
    if (provider.searchQuery.isEmpty) return _buildRecentSearches(provider);
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.errorMessage != null) return _buildErrorState(provider.errorMessage!);
    if (provider.results.medicines.isEmpty) return _buildNoResultsState();

    final medicines = provider.filteredMedicines;

    return ListView(
      padding: const EdgeInsets.only(top: 0),
      children: [
        _buildFilterBar(provider, type: 'medicines'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.62,
            ),
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              return _buildGridContentItem(medicines[index], type: 'medicine');
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  /// Tab "Món ăn" với FilterBar
  Widget _buildDishesTab(SearchProvider provider) {
    if (provider.searchQuery.isEmpty) return _buildRecentSearches(provider);
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.errorMessage != null) return _buildErrorState(provider.errorMessage!);
    if (provider.results.dishes.isEmpty) return _buildNoResultsState();

    final dishes = provider.filteredDishes;

    return ListView(
      padding: const EdgeInsets.only(top: 0),
      children: [
        _buildFilterBar(provider, type: 'dishes'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemCount: dishes.length,
            itemBuilder: (context, index) {
              return _buildGridContentItem(dishes[index], type: 'dish');
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ============ WIDGET BUILDERS ============

  /// User Item - TikTok Style (Avatar tròn, Username @ Display Name, Button Follow)
  Widget _buildUserItemTikTok(User user) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(userId: user.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[800],
              backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                  ? NetworkImage(ImageUrlHelper.formatImageUrl(user.avatarUrl!)) as ImageProvider
                  : const AssetImage('assets/images/avatar.jpg'),
            ),
            const SizedBox(width: 12),
            
            // User info (stacked: username on top, @displayName below)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Username (bold, larger)
                  Text(
                    user.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  
                  // Display Name with @ (smaller)
                  if (user.displayName != null && user.displayName!.isNotEmpty)
                    Text(
                      '@ ${user.displayName}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    const SizedBox(height: 14),
                  const SizedBox(height: 4),
                  
                  // Fake followers stats
                  Row(
                    children: [
                      Text(
                        '1.2K Followers',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        ' • ',
                        style: TextStyle(color: Colors.grey[500], fontSize: 9),
                      ),
                      Text(
                        '342 Following',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Follow button (TikTok red style)
            SizedBox(
              height: 32,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement follow logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFE2C55),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  elevation: 0,
                ),
                child: const Text(
                  'Follow',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Post Item - Magazine Style (Ảnh cao tới phần username, text bên trái)
  Widget _buildPostMagazineItem(Post post) {
    final hasImage = (post.duongDanMedia ?? '').isNotEmpty;
    
    // Strip HTML tags for preview
    String getPreview(String html) {
      final RegExp exp = RegExp(r'<[^>]*>');
      final plainText = html.replaceAll(exp, ' ');
      final cleaned = plainText.replaceAll(RegExp(r'\s+'), ' ').trim();
      return cleaned.length > 100 ? '${cleaned.substring(0, 100)}...' : cleaned;
    }
    
    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          getPreview(post.noiDung),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            height: 1.3,
          ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 16, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              '${post.luotThich ?? 0}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            const SizedBox(width: 12),
            Icon(Icons.comment_outlined, size: 16, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              '${post.soBinhLuan ?? 0}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ],
    );
    
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
        padding: const EdgeInsets.all(12),
        color: Colors.transparent,
        child: hasImage
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: textContent),
                const SizedBox(width: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: _buildImageWidget(post.duongDanMedia ?? ''),
                  ),
                ),
              ],
            )
          : textContent,
      ),
    );
  }

  /// Grid Content Item (For Medicines & Dishes) - với gradient overlay
  Widget _buildGridContentItem(dynamic item, {required String type}) {
    final isMedicine = type == 'medicine';
    final isDish = type == 'dish';
    
    String title = '';
    String? imageUrl;
    String? description;
    double? price;
    int? likes;
    int? views;
    
    if (isMedicine) {
      final medicine = item as Medicine;
      title = medicine.ten;
      imageUrl = medicine.image;
      description = medicine.moTa;
      likes = medicine.soLuotThich;
      views = medicine.soLuotXem;
    } else if (isDish) {
      final dish = item as MonAn;
      title = dish.ten;
      imageUrl = dish.image;
      description = dish.moTa;
      price = dish.gia;
      views = dish.luotXem;
    }
    
    return InkWell(
      onTap: () {
        if (isMedicine) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BaiThuocDetailScreen(baiThuocId: (item as Medicine).id),
            ),
          );
        } else if (isDish) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MonAnDetailScreen(monAn: item as MonAn),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay (Stack with gradient overlay)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 1.0, // Square image
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? _buildImageWidget(imageUrl)
                        : Container(
                            color: Colors.grey[800],
                            child: Icon(
                              isMedicine ? Icons.medical_services_rounded : Icons.restaurant,
                              color: const Color(0xFF4CAF50),
                              size: 40,
                            ),
                          ),
                  ),
                ),
                
                // Gradient overlay từ ảnh xuống content
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.8),
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Heart button (top right)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                
                // Price tag (bottom left) - for dishes only
                if (isDish && price != null)
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_priceFormatter.format(price.toInt())}₫',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Content (minimal padding)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Description (up to 3 lines)
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        height: 1.2,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  // Stats (compact)
                  if (likes != null || views != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (likes != null) ...[
                          Icon(Icons.favorite_outline, color: Colors.grey[500], size: 10),
                          const SizedBox(width: 2),
                          Text(
                            '$likes',
                            style: TextStyle(color: Colors.grey[500], fontSize: 9),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (views != null) ...[
                          Icon(Icons.visibility_outlined, color: Colors.grey[500], size: 10),
                          const SizedBox(width: 2),
                          Text(
                            '$views',
                            style: TextStyle(color: Colors.grey[500], fontSize: 9),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Filter Bar với các ChoiceChip/Buttons
  Widget _buildFilterBar(SearchProvider provider, {required String type}) {
    List<Map<String, String>> filters = [];
    
    if (type == 'posts') {
      filters = [
        {'label': 'Mặc định', 'value': 'default'},
        {'label': 'Mới nhất', 'value': 'newest'},
        {'label': 'Nhiều thích', 'value': 'likes'},
      ];
    } else if (type == 'medicines') {
      filters = [
        {'label': 'Mặc định', 'value': 'default'},
        {'label': 'Mới nhất', 'value': 'newest'},
        {'label': 'Nhiều thích', 'value': 'likes'},
        {'label': 'Nhiều xem', 'value': 'views'},
      ];
    } else if (type == 'dishes') {
      filters = [
        {'label': 'Mặc định', 'value': 'default'},
        {'label': 'Giá tăng', 'value': 'price_asc'},
        {'label': 'Giá giảm', 'value': 'price_desc'},
        {'label': 'Mới nhất', 'value': 'newest'},
        {'label': 'Nhiều xem', 'value': 'views'},
      ];
    } else if (type == 'all' || type == 'users') {
      // No filters for All and Users tabs
      return const SizedBox(height: 0);
    }
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Row(
        children: [
          for (int index = 0; index < filters.length; index++)
            _buildFilterChip(filters[index], provider, index),
        ],
      ),
    );
  }

  /// Helper to build individual filter chip
  Widget _buildFilterChip(Map<String, String> filter, SearchProvider provider, int index) {
    final isSelected = provider.sortOption == filter['value'];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: FilterChip(
        label: Text(
          filter['label']!,
          style: const TextStyle(fontSize: 12),
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            provider.setSort(filter['value']!);
          }
        },
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        backgroundColor: Colors.black,
        selectedColor: const Color(0xFF3b4b38),
        side: BorderSide(
          color: isSelected ? const Color(0xFF3b4b38) : const Color(0xFF3b4b38),
          width: 1,
        ),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[400],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  // ============ HELPER WIDGETS ============

  /// Build image widget với ImageUrlHelper
  Widget _buildImageWidget(String mediaUrl) {
    if (mediaUrl.isEmpty) {
      return Container(
        color: Colors.grey[800],
        child: Icon(Icons.image, color: Colors.grey[600]),
      );
    }

    try {
      // Handle base64 images
      if (mediaUrl.startsWith('data:image')) {
        final base64Data = mediaUrl.split(',').last;
        return Image.memory(
          base64Decode(base64Data),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildImageError(),
        );
      }
      // Use ImageUrlHelper for all other images
      else {
        final formattedUrl = ImageUrlHelper.formatImageUrl(mediaUrl);
        return Image.network(
          formattedUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildImageError(),
        );
      }
    } catch (e) {
      return _buildImageError();
    }
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: Icon(Icons.broken_image, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, String type) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($count)',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              final index = _tabTypes.indexOf(type);
              if (index != -1) {
                _tabController.animateTo(index);
              }
            },
            child: Text(
              'Xem thêm',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(SearchProvider provider) {
    final recent = provider.recentSearches;
    if (recent.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[800]),
            const SizedBox(height: 16),
            Text(
              'Nhập từ khóa để tìm kiếm',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16).copyWith(top: 0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tìm kiếm gần đây',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (recent.isNotEmpty)
              TextButton(
                onPressed: () => provider.clearRecentSearches(),
                child: const Text('Xóa tất cả', style: TextStyle(color: Colors.grey)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recent.map((query) {
            return ActionChip(
              label: Text(query),
              backgroundColor: Colors.grey[900],
              labelStyle: const TextStyle(color: Colors.white),
              onPressed: () {
                _searchController.text = query;
                _performSearch(query);
              },
              avatar: const Icon(Icons.history, size: 16, color: Colors.grey),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============ STATE WIDGETS ============

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[800]),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy kết quả',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[900]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                _performSearch(_searchController.text);
              }
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

