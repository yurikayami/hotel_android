import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../models/post.dart';
import '../../models/medicine.dart';
import '../../providers/user_provider.dart';
import '../../services/comment_service.dart';
import '../../services/medicine_service.dart';
import '../posts/post_detail_screen.dart';
import '../bai_thuoc/bai_thuoc_detail_screen.dart';
import '../../widgets/html_content_viewer.dart';
import '../../utils/image_url_helper.dart';

/// Twitter-style user profile screen showing user bio and their posts
class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  final Set<int> _loadedTabs = {};  // Track which tabs have been loaded
  String? _lastLoadedUserId;  // Track last loaded user to detect changes

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);
    
    // ALWAYS clear old data when creating new screen instance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('[UserProfileScreen] initState: Loading profile for user ${widget.userId}');
      final provider = context.read<UserProvider>();
      
      // Clear any old data from previous user
      print('[UserProfileScreen] initState: Clearing old user data...');
      provider.clearUserData();
      
      // Load new user profile and posts
      provider.loadUserProfile(widget.userId, refresh: true);
      provider.updateMediaPosts();
      _loadedTabs.add(0);  // Mark Posts tab as loaded
      _lastLoadedUserId = widget.userId;
    });
    
    // Listen to tab changes
    _tabController.addListener(_onTabChanged);
  }

  @override
  void didUpdateWidget(UserProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If user ID changed, reset everything and reload
    if (oldWidget.userId != widget.userId) {
      print('[UserProfileScreen] didUpdateWidget: User ID changed from ${oldWidget.userId} to ${widget.userId}');
      final provider = context.read<UserProvider>();
      
      // Step 1: Clear all old data immediately
      print('[UserProfileScreen] Clearing old user data...');
      provider.clearUserData();
      
      // Step 2: Reset tab tracking cache
      _loadedTabs.clear();
      
      // Step 3: Load new user profile and media
      print('[UserProfileScreen] Loading new user profile for ${widget.userId}');
      provider.loadUserProfile(widget.userId, refresh: true);
      provider.updateMediaPosts();
      _loadedTabs.add(0);  // Mark Posts tab as loaded
      
      // Step 4: If currently on Replies tab, load comments for new user
      if (_tabController.index == 1) {
        print('[UserProfileScreen] Currently on Replies tab, loading comments for new user');
        provider.loadUserComments(widget.userId, refresh: true);
        _loadedTabs.add(1);  // Mark Replies tab as loaded
      }
      
      // Step 5: If currently on Media tab, update media posts
      if (_tabController.index == 3) {
        print('[UserProfileScreen] Currently on Media tab, updating media for new user');
        provider.updateMediaPosts();
        _loadedTabs.add(3);  // Mark Media tab as loaded
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    final provider = context.read<UserProvider>();
    final currentTab = _tabController.index;
    
    // Load only if not loaded yet
    if (!_loadedTabs.contains(currentTab)) {
      _loadedTabs.add(currentTab);
      
      // Load comments if Replies tab (tab 1)
      if (currentTab == 1 && provider.userComments.isEmpty) {
        provider.loadUserComments(widget.userId, refresh: true);
      }
      // Update media if Media tab (tab 3)
      else if (currentTab == 3 && provider.userMedia.isEmpty) {
        provider.updateMediaPosts();
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final provider = context.read<UserProvider>();
      if (!provider.isLoading && provider.hasMore) {
        provider.loadMoreUserPosts(widget.userId);
      }
    }
  }

  Future<void> _handleRefresh() async {
    await context.read<UserProvider>().loadUserProfile(widget.userId, refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    // Check if userId changed from last load - if so, clear old data
    if (_lastLoadedUserId != null && _lastLoadedUserId != widget.userId) {
      print('[UserProfileScreen] BUILD: User ID changed from $_lastLoadedUserId to ${widget.userId}');
      print('[UserProfileScreen] BUILD: Clearing old user data...');
      
      // Schedule clear for next frame to avoid calling during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<UserProvider>();
        provider.clearUserData();
        _loadedTabs.clear();
        _lastLoadedUserId = widget.userId;
        
        // Load new user data
        provider.loadUserProfile(widget.userId, refresh: true);
        provider.updateMediaPosts();
        _loadedTabs.add(0);
        
        // Load current tab data if needed
        if (_tabController.index == 1) {
          provider.loadUserComments(widget.userId, refresh: true);
          _loadedTabs.add(1);
        }
      });
    } else if (_lastLoadedUserId == null) {
      // First load
      _lastLoadedUserId = widget.userId;
    }
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading && userProvider.userPosts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userProvider.errorMessage != null && userProvider.userPosts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    userProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  _buildAppBar(context, userProvider),
                  _buildProfileInfo(context, userProvider),
                  _buildTabBar(context),
                ];
              },
              body: TabBarView(
                key: ValueKey(widget.userId),  // Force rebuild when user changes
                controller: _tabController,
                children: [
                  KeyedSubtree(
                    key: ValueKey('posts_${widget.userId}'),
                    child: _buildPostsTab(userProvider),
                  ),
                  KeyedSubtree(
                    key: ValueKey('replies_${widget.userId}'),
                    child: _buildRepliesTab(userProvider),
                  ),
                  KeyedSubtree(
                    key: ValueKey('highlights_${widget.userId}'),
                    child: _buildHighlightsTab(),
                  ),
                  KeyedSubtree(
                    key: ValueKey('media_${widget.userId}'),
                    child: _buildMediaTab(userProvider),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// App bar with back button, username, post count, and search
  Widget _buildAppBar(BuildContext context, UserProvider userProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = userProvider.selectedUser;
    final postsCount = userProvider.userPosts.length;

    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            user?.userName ?? 'Loading...',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          Text(
            '$postsCount bài post',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () {
            // TODO: Implement search
          },
        ),
      ],
    );
  }

  /// Profile info section with banner, avatar, bio, and stats
  Widget _buildProfileInfo(BuildContext context, UserProvider userProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = userProvider.selectedUser;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner with overlapping avatar using Stack
          SizedBox(
            height: 150,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Banner image
                Container(
                  height: 150,
                  width: double.infinity,
                  color: colorScheme.primaryContainer,
                  child: Image(
                    image: const AssetImage('assets/banner/defaultbanner.jpg'),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: colorScheme.primaryContainer,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Avatar overlapping banner
                Positioned(
                  left: 16,
                  bottom: -40,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.surface,
                        width: 4,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: colorScheme.primaryContainer,
                      backgroundImage: _getAvatarImage(user?.avatarUrl),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Profile content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and username
                Text(
                  user?.displayName ?? user?.userName ?? 'Unknown User',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${user?.userName ?? 'username'}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                // Bio (hardcoded for now)
                Text(
                  'Người yêu thích sức khỏe 🩺\nChia sẻ những bài thuốc và mẹo vặt hay\nHãy cùng nhau sống khỏe mạnh nhé! 🌿',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                // Following and Followers
                Row(
                  children: [
                    _buildFollowStat(context, '47.1k', 'Following'),
                    const SizedBox(width: 20),
                    _buildFollowStat(context, '42M', 'Follower'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowStat(BuildContext context, String count, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /// Tab bar for Posts/Replies/Media/Likes
  Widget _buildTabBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: _buildTabBarContent(context),
    );
  }

  Widget _buildTabBarContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return TabBar(
      controller: _tabController,
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      indicatorColor: colorScheme.primary,
      indicatorWeight: 3,
      tabs: const [
        Tab(text: 'Posts'),
        Tab(text: 'Replies'),
        Tab(text: 'Highlights'),
        Tab(text: 'Media'),
      ],
    );
  }

  /// Get avatar image from URL or use default
  ImageProvider _getAvatarImage(String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty && avatarUrl.startsWith('http')) {
      return NetworkImage(avatarUrl);
    }
    // Use default avatar asset
    return const AssetImage('assets/images/avatar.jpg');
  }

  // Posts tab
  Widget _buildPostsTab(UserProvider userProvider) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        if (provider.userPosts.isEmpty && !provider.isLoading) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không có bài viết',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: provider.userPosts.length + (provider.isLoading ? 1 : 0),
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          itemBuilder: (context, index) {
            if (index >= provider.userPosts.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final post = provider.userPosts[index];
            return UserProfilePostCard(post: post);
          },
        );
      },
    );
  }

  // Replies/Comments tab
  Widget _buildRepliesTab(UserProvider userProvider) {
    // Use Consumer to ensure fresh data when clearUserData() is called
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        print('[UserProfileScreen] _buildRepliesTab Consumer builder - Comments: ${provider.userComments.length}, Loading: ${provider.commentsLoading}');
        
        if (provider.userComments.isEmpty && !provider.commentsLoading) {
          print('[UserProfileScreen] Showing empty comments message');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.comment_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không có bình luận',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: provider.userComments.length + (provider.commentsLoading ? 1 : 0),
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          itemBuilder: (context, index) {
            if (index >= provider.userComments.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final comment = provider.userComments[index];
            return _buildCommentCard(comment);
          },
        );
      },
    );
  }

  // Comment card widget
  Widget _buildCommentCard(Comment comment) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage: comment.userAvatar != null && comment.userAvatar!.startsWith('http')
                    ? NetworkImage(comment.userAvatar!)
                    : const AssetImage('assets/images/avatar.jpg') as ImageProvider,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.noiDung,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(comment.ngayTao),
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Highlights tab
  Widget _buildHighlightsTab() {
    return _buildMedicinesTab();
  }

  /// Medicines tab - Shows user's health tips/medicines
  Widget _buildMedicinesTab() {
    return FutureBuilder<List<Medicine>>(
      future: MedicineService.getPublicMedicines(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi tải bài thuốc',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final medicines = snapshot.data ?? [];

        if (medicines.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có bài thuốc',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: medicines.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          itemBuilder: (context, index) {
            final medicine = medicines[index];
            return _buildMedicineCard(context, medicine);
          },
        );
      },
    );
  }

  /// Medicine card widget
  Widget _buildMedicineCard(BuildContext context, Medicine medicine) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (context, animation, secondaryAnimation) => 
                  BaiThuocDetailScreen(baiThuocId: medicine.id),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                );
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
                  child: FadeTransition(
                    opacity: curvedAnimation,
                    child: child,
                  ),
                );
              },
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image thumbnail
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: colorScheme.surfaceVariant,
                ),
                child: _buildMedicineImageThumbnail(medicine.image),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.ten,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medicine.moTa,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_rounded,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          medicine.soLuotXem > 999
                              ? '${(medicine.soLuotXem / 1000).toStringAsFixed(1)}K'
                              : '${medicine.soLuotXem}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.favorite_rounded,
                          size: 14,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          medicine.soLuotThich > 999
                              ? '${(medicine.soLuotThich / 1000).toStringAsFixed(1)}K'
                              : '${medicine.soLuotThich}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build medicine image thumbnail with proper error handling
  Widget _buildMedicineImageThumbnail(String? imageUrl) {
    final colorScheme = Theme.of(context).colorScheme;

    if (imageUrl == null || imageUrl.isEmpty) {
      return Icon(
        Icons.medical_services_rounded,
        color: colorScheme.primary,
      );
    }

    // Check if it's a base64 data URI
    if (imageUrl.startsWith('data:image')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          Uint8List.fromList(_base64ToBytes(imageUrl)),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.image_not_supported,
              color: colorScheme.primary,
            );
          },
        ),
      );
    }

    // Otherwise treat as URL
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        ImageUrlHelper.formatImageUrl(imageUrl),
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.image_not_supported,
            color: colorScheme.primary,
          );
        },
      ),
    );
  }

  /// Convert base64 string to bytes
  List<int> _base64ToBytes(String base64String) {
    final data = base64String.contains(',')
        ? base64String.split(',')[1]
        : base64String;
    return base64Decode(data);
  }

  // Media tab - Grid 3 columns
  Widget _buildMediaTab(UserProvider userProvider) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        if (provider.userMedia.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không có ảnh',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            childAspectRatio: 1,
          ),
          itemCount: provider.userMedia.length,
          itemBuilder: (context, index) {
            final post = provider.userMedia[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailScreen(post: post),
                  ),
                );
              },
              child: Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: _buildMediaGridImage(post.duongDanMedia!),
              ),
            );
          },
        );
      },
    );
  }

  // Build media grid image
  Widget _buildMediaGridImage(String mediaUrl) {
    try {
      if (mediaUrl.startsWith('data:image')) {
        final base64Data = mediaUrl.split(',').last;
        return Image.memory(
          base64Decode(base64Data),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Center(child: Icon(Icons.broken_image_outlined)),
        );
      } else if (mediaUrl.startsWith('/upload/')) {
        final fullUrl = 'https://192.168.1.3:7135$mediaUrl';
        return Image.network(
          fullUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Center(child: Icon(Icons.broken_image_outlined)),
        );
      } else {
        return Image.network(
          mediaUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Center(child: Icon(Icons.broken_image_outlined)),
        );
      }
    } catch (e) {
      return const Center(child: Icon(Icons.broken_image_outlined));
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return 'Vừa xong';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}


/// Post card widget for user profile (similar to post_feed_screen_new.dart)
class UserProfilePostCard extends StatefulWidget {
  final Post post;

  const UserProfilePostCard({super.key, required this.post});

  @override
  State<UserProfilePostCard> createState() => _UserProfilePostCardState();
}

class _UserProfilePostCardState extends State<UserProfilePostCard> {
  late bool _isExpanded;
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _isExpanded = false;
    _isLiked = widget.post.isLiked;
  }

  Post get post => widget.post;

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return 'Vừa xong';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
        color: colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            _buildContent(context),
            if (post.duongDanMedia != null && post.duongDanMedia!.isNotEmpty) ...
              [const SizedBox(height: 8), _buildMedia(context)],
            const SizedBox(height: 4),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    String? avatarUrl = post.authorAvatar;
    if (avatarUrl != null && !avatarUrl.startsWith('http')) {
      avatarUrl = null;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: colorScheme.primaryContainer,
          backgroundImage: avatarUrl != null
              ? NetworkImage(avatarUrl)
              : const AssetImage('assets/images/avatar.jpg') as ImageProvider,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Text(
                    '@${post.authorName.toLowerCase().replaceAll(' ', '')}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '·',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(post.ngayDang),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    const maxContentLength = 200;
    final shouldCollapse = post.noiDung.length > maxContentLength;
    final isHtml = post.noiDung.contains('<') && post.noiDung.contains('>');

    Widget buildContentWidget(String content) {
      if (isHtml) {
        return HtmlContentViewer(
          htmlContent: content,
          baseStyle: TextStyle(
            height: 1.5,
            color: colorScheme.onSurface,
            fontSize: 15,
          ),
        );
      } else {
        return SelectableText(
          content,
          style: TextStyle(
            height: 1.5,
            color: colorScheme.onSurface,
            fontSize: 15,
          ),
        );
      }
    }

    final displayText = (!shouldCollapse || _isExpanded)
        ? post.noiDung
        : post.noiDung.substring(0, maxContentLength) + '...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildContentWidget(displayText),
        if (shouldCollapse)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(
                _isExpanded ? 'Thu gọn' : 'Xem thêm',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMedia(BuildContext context) {
    if (post.duongDanMedia == null || post.duongDanMedia!.isEmpty) {
      return const SizedBox.shrink();
    }

    final mediaUrl = post.duongDanMedia!;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: colorScheme.surfaceVariant,
            child: _buildImageWidget(mediaUrl),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(String mediaUrl) {
    try {
      if (mediaUrl.startsWith('data:image')) {
        final base64Data = mediaUrl.split(',').last;
        return Image.memory(
          base64Decode(base64Data),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageError();
          },
        );
      } else if (mediaUrl.startsWith('/upload/')) {
        final fullUrl = 'https://192.168.1.3:7135$mediaUrl';
        return Image.network(
          fullUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageError();
          },
        );
      } else {
        return Image.network(
          mediaUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageError();
          },
        );
      }
    } catch (e) {
      return _buildImageError();
    }
  }

  Widget _buildImageError() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 32,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'Không thể tải ảnh',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            count: post.soBinhLuan ?? 0,
            color: colorScheme.onSurfaceVariant,
            onTap: () {},
          ),
        ),
        Expanded(
          child: _buildActionButton(
            icon: Icons.repeat_rounded,
            count: post.soChiaSe ?? 0,
            color: colorScheme.onSurfaceVariant,
            onTap: () {},
          ),
        ),
        Expanded(
          child: _buildActionButton(
            icon: _isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_outline_rounded,
            count: post.luotThich ?? 0,
            color: _isLiked ? Colors.red : colorScheme.onSurfaceVariant,
            onTap: () {
              setState(() {
                _isLiked = !_isLiked;
              });
            },
          ),
        ),
        Expanded(
          child: _buildActionButton(
            icon: Icons.share_outlined,
            count: 0,
            color: colorScheme.onSurfaceVariant,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: color),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Text(
                  count > 999
                      ? '${(count / 1000).toStringAsFixed(1)}K'
                      : count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

