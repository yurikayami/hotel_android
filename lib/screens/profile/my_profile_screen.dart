import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../models/post.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../services/comment_service.dart';
import '../../widgets/html_content_viewer.dart';
import '../auth/login_screen.dart';
import '../posts/post_detail_screen.dart';
import '../settings/settings_screen.dart';
import 'user_profile_screen.dart';

/// My profile screen - User's own profile with additional features
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  final Set<int> _loadedTabs = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);
    
    _loadData();
    _tabController.addListener(_onTabChanged);
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();
      
      if (authProvider.user != null) {
        print('[MyProfileScreen] Loading profile for current user: ${authProvider.user!.id}');
        
        // Chỉ load những tab đã được xem trước đây
        // Không xóa dữ liệu để giữ cache
        if (_loadedTabs.isEmpty) {
          // Lần đầu tiên vào, load tab Posts
          await userProvider.loadUserProfile(authProvider.user!.id, refresh: true);
          userProvider.updateMediaPosts();
          _loadedTabs.add(0);
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload data khi quay lại app
      _loadData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final currentTab = _tabController.index;
    
    if (authProvider.user == null) return;
    
    if (!_loadedTabs.contains(currentTab)) {
      _loadedTabs.add(currentTab);
      
      // Load comments if Replies tab (tab 1)
      if (currentTab == 1) {
        print('[MyProfileScreen] Loading comments for tab 1');
        userProvider.loadUserComments(authProvider.user!.id, refresh: true);
      }
      // Load liked posts if Liked tab (tab 2)
      else if (currentTab == 2) {
        print('[MyProfileScreen] Loading liked posts for tab 2');
        userProvider.loadLikedPosts(refresh: true);
      }
      // Update media if Media tab (tab 3)
      else if (currentTab == 3) {
        print('[MyProfileScreen] Loading media for tab 3');
        userProvider.updateMediaPosts();
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final authProvider = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();
      
      if (authProvider.user != null && !userProvider.isLoading && userProvider.hasMore) {
        userProvider.loadMoreUserPosts(authProvider.user!.id);
      }
    }
  }

  Future<void> _handleRefresh() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      await context.read<UserProvider>().loadUserProfile(
        authProvider.user!.id,
        refresh: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer2<UserProvider, AuthProvider>(
        builder: (context, userProvider, authProvider, child) {
          if (authProvider.user == null) {
            return const Center(child: Text('Chưa đăng nhập'));
          }

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
                  _buildAppBar(context, authProvider),
                  _buildProfileInfo(context, userProvider, authProvider),
                  _buildTabBar(context),
                ];
              },
              body: TabBarView(
                key: ValueKey(authProvider.user!.id),
                controller: _tabController,
                children: [
                  KeyedSubtree(
                    key: ValueKey('posts_${authProvider.user!.id}'),
                    child: _buildPostsTab(userProvider),
                  ),
                  KeyedSubtree(
                    key: ValueKey('replies_${authProvider.user!.id}'),
                    child: _buildRepliesTab(userProvider),
                  ),
                  KeyedSubtree(
                    key: ValueKey('liked_${authProvider.user!.id}'),
                    child: _buildLikedTab(),
                  ),
                  KeyedSubtree(
                    key: ValueKey('media_${authProvider.user!.id}'),
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

  /// App bar with title and settings button
  Widget _buildAppBar(BuildContext context, AuthProvider authProvider) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          const Text(
            'Tài khoản',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 20),
            tooltip: 'Đăng xuất',
            onPressed: () {
              _handleLogout(context);
            },
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AuthProvider>().logout().then((_) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                });
              },
              child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// Profile info with banner, avatar, bio and stats
  Widget _buildProfileInfo(
    BuildContext context,
    UserProvider userProvider,
    AuthProvider authProvider,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = userProvider.selectedUser;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner with overlapping avatar and action icons using Stack
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
                    image: const AssetImage('assets/banner/userbanner.jpg'),
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
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and username
                Text(
                  user?.displayName ?? user?.userName ?? 'Người dùng',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${user?.userName ?? 'username'}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                // Bio
                Text(
                  '🌿 Đam mê ẩm thực & sức khỏe\n'
                  '🍜 Khám phá món ăn truyền thống Việt Nam\n'
                  '💚 Sống xanh, ăn sạch, khỏe đẹp mỗi ngày',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Follow stats
                Row(
                  children: [
                    _buildFollowStat(context, '180', 'Following'),
                    const SizedBox(width: 20),
                    _buildFollowStat(context, '248', 'Followers'),
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

  /// Quick access actions - REMOVED (icons moved to banner)

  /// Tab bar
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
        Tab(text: 'Liked'),
        Tab(text: 'Media'),
      ],
    );
  }



  ImageProvider _getAvatarImage(String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty && avatarUrl.startsWith('http')) {
      return NetworkImage(avatarUrl);
    }
    // Use default avatar asset
    return const AssetImage('assets/images/avatar.jpg');
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
                    'Chưa có bài viết',
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

  // Replies tab
  Widget _buildRepliesTab(UserProvider userProvider) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        if (provider.userComments.isEmpty && !provider.commentsLoading) {
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
                    'Chưa có bình luận',
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

  // Liked posts tab
  Widget _buildLikedTab() {
    print('[MyProfileScreen] Building liked tab');
    
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      print('[MyProfileScreen] Liked tab - Liked posts: ${userProvider.likedPosts.length}');
      print('[MyProfileScreen] Liked tab - Loading: ${userProvider.likedLoading}');
      print('[MyProfileScreen] Liked tab - HasMore: ${userProvider.likedHasMore}');
      
      // Show loading on initial load
      if (userProvider.likedLoading && userProvider.likedPosts.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      }
      
      // Show empty state
      if (userProvider.likedPosts.isEmpty && !userProvider.likedLoading) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_outline_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có bài viết yêu thích',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Các bài viết bạn thích sẽ hiển thị ở đây',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }
      
      // Show liked posts list with infinite scroll support
      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.9) {
            if (!userProvider.likedLoading && userProvider.likedHasMore) {
              print('[MyProfileScreen] Loading more liked posts...');
              userProvider.loadMoreLikedPosts();
            }
          }
          return false;
        },
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: userProvider.likedPosts.length + (userProvider.likedLoading ? 1 : 0),
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          itemBuilder: (context, index) {
            // Show loading indicator at the end
            if (index >= userProvider.likedPosts.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            
            final post = userProvider.likedPosts[index];
            print('[MyProfileScreen] Rendering liked post $index - ID: ${post.id}, isLiked: ${post.isLiked}');
            return _LikedPostCard(
              post: post,
              onUnlike: () => _handleUnlike(context, post),
            );
          },
        ),
      );
    });
  }

  void _handleUnlike(BuildContext context, Post post) {
    print('[MyProfileScreen] Unliking post: ${post.id}');
    
    final userProvider = context.read<UserProvider>();
    final postProvider = context.read<PostProvider>();
    
    // Remove post from liked list immediately for better UX
    userProvider.removeLikedPost(post.id);
    
    // Update the post in PostProvider's feed (if it exists there)
    postProvider.updatePostLikeStatus(post.id, false);
    
    // Show snackbar with undo option
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã bỏ thích bài viết'),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: 'Hoàn tác',
          onPressed: () {
            print('[MyProfileScreen] Undo unlike for post: ${post.id}');
            userProvider.addLikedPost(post);
            postProvider.updatePostLikeStatus(post.id, true);
          },
        ),
      ),
    );
  }

  // Media tab
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
                    'Chưa có ảnh',
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
        final fullUrl = 'https://10.227.9.96:7135$mediaUrl';
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
}

/// Liked post card widget with unlike functionality
class _LikedPostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onUnlike;

  const _LikedPostCard({
    required this.post,
    required this.onUnlike,
  });

  @override
  State<_LikedPostCard> createState() => _LikedPostCardState();
}

class _LikedPostCardState extends State<_LikedPostCard> {
  late bool _isLiked;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _isExpanded = false;
  }

  Post get post => widget.post;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            if (post.noiDung.isNotEmpty) _buildContent(context),
            if (post.duongDanMedia != null && post.duongDanMedia!.isNotEmpty)
              _buildMedia(context),
            const SizedBox(height: 12),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: colorScheme.primaryContainer,
          backgroundImage: post.authorAvatar != null &&
                  post.authorAvatar!.startsWith('http')
              ? NetworkImage(post.authorAvatar!)
              : const AssetImage('assets/images/avatar.jpg') as ImageProvider,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: [
              Text(
                post.authorName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '·',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _formatDate(post.ngayDang),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isHtml = post.noiDung.contains('<') && post.noiDung.contains('>');
    
    const maxContentLength = 200;
    final shouldCollapse = post.noiDung.length > maxContentLength;

    // For collapsed view, create a plain text preview
    String getPreviewText() {
      if (isHtml) {
        // Strip HTML tags to get plain text
        String plainText = post.noiDung.replaceAll(RegExp(r'<[^>]*>'), '');
        // Decode entities
        plainText = plainText
            .replaceAll('&nbsp;', ' ')
            .replaceAll('&amp;', '&')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .replaceAll('&quot;', '"')
            .replaceAll('&#39;', "'")
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
        return plainText.length > maxContentLength
            ? plainText.substring(0, maxContentLength) + '...'
            : plainText;
      } else {
        return post.noiDung.length > maxContentLength
            ? post.noiDung.substring(0, maxContentLength) + '...'
            : post.noiDung;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!shouldCollapse || _isExpanded)
          // Show full formatted content
          if (isHtml)
            HtmlContentViewer(
              htmlContent: post.noiDung,
              baseStyle: TextStyle(
                height: 1.5,
                color: colorScheme.onSurface,
                fontSize: 15,
              ),
            )
          else
            SelectableText(
              post.noiDung,
              style: TextStyle(
                height: 1.5,
                color: colorScheme.onSurface,
                fontSize: 15,
              ),
            )
        else
          // Show preview text
          SelectableText(
            getPreviewText(),
            style: TextStyle(
              height: 1.5,
              color: colorScheme.onSurface,
              fontSize: 15,
            ),
          ),
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
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildMedia(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mediaUrl = post.duongDanMedia!;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: colorScheme.surfaceVariant,
            child: _buildImageWidget(mediaUrl, colorScheme),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(String mediaUrl, ColorScheme colorScheme) {
    try {
      if (mediaUrl.startsWith('data:image')) {
        final base64Data = mediaUrl.split(',').last;
        return Image.memory(
          base64Decode(base64Data),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageError(colorScheme);
          },
        );
      } else if (mediaUrl.startsWith('/upload/')) {
        final fullUrl = 'https://10.227.9.96:7135$mediaUrl';
        return Image.network(
          fullUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageError(colorScheme);
          },
        );
      } else {
        return Image.network(
          mediaUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageError(colorScheme);
          },
        );
      }
    } catch (e) {
      return _buildImageError(colorScheme);
    }
  }

  Widget _buildImageError(ColorScheme colorScheme) {
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailScreen(post: post),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _buildActionButton(
            icon: Icons.repeat_rounded,
            count: post.soChiaSe ?? 0,
            color: colorScheme.onSurfaceVariant,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng chia sẻ đang phát triển'),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _buildActionButton(
            icon: _isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_outline_rounded,
            count: post.luotThich ?? 0,
            color: _isLiked ? Colors.red : colorScheme.onSurfaceVariant,
            onTap: () => _handleUnlike(context),
          ),
        ),
        Expanded(
          child: _buildActionButton(
            icon: Icons.share_outlined,
            count: 0,
            color: colorScheme.onSurfaceVariant,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng chia sẻ đang phát triển'),
                ),
              );
            },
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

  void _handleUnlike(BuildContext context) {
    print('[_LikedPostCard] Toggling like for post: ${post.id}');

    final postProvider = context.read<PostProvider>();

    // Toggle local state immediately for better UX
    setState(() {
      _isLiked = !_isLiked;
    });

    // Call likePost to sync with PostProvider
    postProvider.likePost(post.id).then((_) {
      print('[_LikedPostCard] Like toggled successfully');
      // Call the unlike callback to handle cleanup (remove from liked list if unliking)
      if (!_isLiked) {
        widget.onUnlike();
      }
    }).catchError((e) {
      print('[_LikedPostCard] Like error: $e');
      // Revert the local state on error
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
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

