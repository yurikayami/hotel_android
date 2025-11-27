import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../../models/post.dart';
import '../../../providers/post_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/api_config.dart';
import '../../../widgets/html_content_viewer.dart';
import 'package:intl/intl.dart';
import 'post_detail_screen.dart';
import 'create_post_screen.dart';
import '../search/general_search_screen.dart';

/// Twitter-style modern post feed screen
class PostFeedScreen extends StatefulWidget {
  const PostFeedScreen({super.key});

  @override
  State<PostFeedScreen> createState() => _PostFeedScreenState();
}

class _PostFeedScreenState extends State<PostFeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().loadPosts(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<PostProvider>().loadPosts();
    }
  }

  Future<void> _handleRefresh() async {
    await context.read<PostProvider>().loadPosts(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          if (postProvider.isLoading && postProvider.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (postProvider.errorMessage != null && postProvider.posts.isEmpty) {
            return _buildErrorView(context, postProvider.errorMessage!);
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildAppBar(context),
                _buildPostList(postProvider),
                if (postProvider.isLoading && postProvider.posts.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

Widget _buildAppBar(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;

  return SliverAppBar(
    // --- CẤU HÌNH STICKY ---
    pinned: true,      // Giữ thanh này dính ở trên cùng khi cuộn
    floating: true,    // Cho phép hiện lại ngay khi vuốt nhẹ lên
    snap: true,        // Hiệu ứng hiện nhanh
    // -----------------------

    elevation: 0,
    backgroundColor: colorScheme.surface.withValues(alpha: 0.95),
    surfaceTintColor: Colors.transparent,
    
    // THAY THẾ 'bottom' BẰNG 'shape' ĐỂ VẼ VIỀN DƯỚI
    // Cách này không làm thay đổi chiều cao logic của AppBar, giúp sticky hoạt động đúng
    shape: Border(
      bottom: BorderSide(
        color: Colors.grey.withValues(alpha: 0.2), // Màu viền xám nhạt
        width: 1.0, // Độ dày 1px
      ),
    ),

    centerTitle: false, 
    
    // Tiêu đề 2 dòng
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sống Khỏe', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22, 
            color: colorScheme.primary, 
          ),
        ),
        Text(
          'Dành cho bạn', 
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 13, 
            color: colorScheme.onSurface.withValues(alpha: 0.6), 
          ),
        ),
      ],
    ),

    // Các nút bên phải
    actions: [
      _buildCircleActionButton(
        context,
        icon: Icons.search_rounded,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GeneralSearchScreen(),
              ),
            );
        },
      ),
      
      const SizedBox(width: 8),

      Stack(
        children: [
          _buildCircleActionButton(
            context,
            icon: Icons.notifications_outlined,
            onPressed: () {},
          ),
        ],
      ),
      const SizedBox(width: 16),
    ],
    // LƯU Ý: ĐÃ XÓA PHẦN 'bottom: PreferredSize...' ĐỂ TRÁNH LỖI
  );
}

// Widget con để vẽ cái nút tròn xám cho gọn code
Widget _buildCircleActionButton(BuildContext context, {required IconData icon, required VoidCallback onPressed}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8), // Căn giữa theo chiều dọc
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5), // Màu nền tròn xám nhẹ
      shape: BoxShape.circle,
    ),
    child: IconButton(
      icon: Icon(icon, size: 24),
      color: Theme.of(context).colorScheme.onSurface,
      onPressed: onPressed,
    ),
  );
}

  Widget _buildPostList(PostProvider postProvider) {
    if (postProvider.posts.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.post_add_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Chưa có bài viết nào',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hãy tạo bài viết đầu tiên của bạn!',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList.separated(
      itemCount: postProvider.posts.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        indent: 0,
        endIndent: 0,
      ),
      itemBuilder: (context, index) {
        final post = postProvider.posts[index];
        return PostCard(post: post);
      },
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Đã có lỗi xảy ra',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<PostProvider>().loadPosts(refresh: true),
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        heroTag: 'post_feed_fab',
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );

          // Refresh feed if post was created
          if (result == true && context.mounted) {
            await context.read<PostProvider>().loadPosts(refresh: true);
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add),
        label: const Text('Tạo bài viết'),
      ),
    );
  }
}

/// Modern post card widget with social media styling
class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
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

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/profile/${post.authorId}');
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage:
                post.authorAvatar != null &&
                    post.authorAvatar!.startsWith('http')
                ? NetworkImage(post.authorAvatar!)
                : const AssetImage('assets/images/avatar.jpg') as ImageProvider,
          ),
          const SizedBox(width: 10),
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
                ),
                const SizedBox(height: 2),
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
          IconButton(
            icon: Icon(
              Icons.more_horiz_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: () => _showMoreOptions(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    const maxContentLength = 200;
    final shouldCollapse = post.noiDung.length > maxContentLength;
    final isHtml = post.noiDung.contains('<') && post.noiDung.contains('>');

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
            ? '${plainText.substring(0, maxContentLength)}...'
            : plainText;
      } else {
        return post.noiDung.length > maxContentLength
            ? '${post.noiDung.substring(0, maxContentLength)}...'
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
    if (post.duongDanMedia == null || post.duongDanMedia!.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final mediaUrl = post.duongDanMedia!;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9, // Fixed Twitter-style aspect ratio
          child: Container(
            color: colorScheme.surfaceContainerHighest,
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
        final fullUrl = '${ApiConfig.baseUrl}$mediaUrl';
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
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
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
            onTap: () => _handleComment(context),
          ),
        ),
        Expanded(
          child: _buildActionButton(
            icon: Icons.repeat_rounded,
            count: post.soChiaSe ?? 0,
            color: colorScheme.onSurfaceVariant,
            onTap: () => _handleShare(context),
          ),
        ),
        Expanded(
          child: _buildActionButton(
            icon: post.isLiked == true
                ? Icons.favorite_rounded
                : Icons.favorite_outline_rounded,
            count: post.luotThich ?? 0,
            color: post.isLiked == true
                ? Colors.red
                : colorScheme.onSurfaceVariant,
            onTap: () => _handleLike(context),
          ),
        ),
        Expanded(
          child: _buildActionButton(
            icon: Icons.share_outlined,
            count: 0,
            color: colorScheme.onSurfaceVariant,
            onTap: () => _handleShare(context),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      return DateFormat('MMM d').format(date);
    }
  }

  void _handleLike(BuildContext context) {
    final postProvider = context.read<PostProvider>();
    final currentPost = post;

    print(
      '[PostCard] Liking post: ${currentPost.id}, current isLiked: ${currentPost.isLiked}',
    );

    // Call the like function
    postProvider
        .likePost(currentPost.id)
        .then((_) {
          print('[PostCard] Like success');
          if (mounted) {
            setState(() {});
          }
        })
        .catchError((e) {
          print('[PostCard] Like error: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi thích bài viết: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
  }

  void _handleComment(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
    );
  }

  void _handleShare(BuildContext context) {
    // TODO: Implement share
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng chia sẻ đang phát triển')),
    );
  }

  void _showMoreOptions(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final currentUserId = authProvider.user?.id ?? '';
    final isAuthor = currentUserId == post.authorId;

    print('[PostFeed] Current user ID: $currentUserId');
    print('[PostFeed] Post author ID: ${post.authorId}');
    print('[PostFeed] Is author: $isAuthor');

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isAuthor) ...[
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Chỉnh sửa'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Edit post
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Xóa', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _handleDelete(context);
                  },
                ),
              ],
              if (!isAuthor)
                ListTile(
                  leading: const Icon(Icons.report),
                  title: const Text('Báo cáo'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Report post
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa bài viết'),
          content: const Text('Bạn có chắc chắn muốn xóa bài viết này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await context.read<PostProvider>().deletePost(post.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã xóa bài viết')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    String errorMsg = e.toString().replaceAll(
                      'Exception: ',
                      '',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMsg),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                }
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
