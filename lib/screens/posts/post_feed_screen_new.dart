import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../../models/post.dart';
import '../../../providers/post_provider.dart';
import '../../../widgets/html_content_viewer.dart';
import 'package:intl/intl.dart';
import 'post_detail_screen.dart';
import 'create_post_screen.dart';

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
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0.95),
      surfaceTintColor: Colors.transparent,
      title: const Text(
        'Cộng đồng',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
      ],
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
          const Text(
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

    return FloatingActionButton.extended(
      heroTag: 'post_feed_new_fab',
      onPressed: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const CreatePostScreen()),
        );

        if (result == true && mounted) {
          await context.read<PostProvider>().loadPosts(refresh: true);
        }
      },
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Tạo bài viết'),
    );
  }
}

/// Twitter-style post card widget
class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
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
      return DateFormat('MMM d').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        InkWell(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 12),
                  _buildContent(context),
                  if (post.duongDanMedia != null &&
                      post.duongDanMedia!.isNotEmpty)
                    _buildMedia(context),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildActions(context),
        ),
        Divider(
          height: 1,
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ],
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
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null
              ? Icon(
                  Icons.person_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 28,
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      post.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
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
        PopupMenuButton(
          icon: Icon(
            Icons.more_vert_rounded,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(child: Text('Báo cáo bài viết')),
            const PopupMenuItem(child: Text('Không quan tâm')),
          ],
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
        final fullUrl = 'https://10.227.9.96:7135$mediaUrl';
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
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final metrics = post;

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            colorScheme,
            icon: Icons.chat_bubble_outline_rounded,
            count: metrics.soBinhLuan ?? 0,
            label: 'Bình luận',
            onTap: () {},
          ),
          _buildActionButton(
            colorScheme,
            icon: Icons.repeat_rounded,
            count: metrics.soChiaSe ?? 0,
            label: 'Chia sẻ',
            onTap: () {},
          ),
          _buildActionButton(
            colorScheme,
            icon: _isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_outline_rounded,
            count: (metrics.luotThich ?? 0),
            label: 'Thích',
            color: _isLiked ? Colors.red : null,
            onTap: () {
              setState(() {
                _isLiked = !_isLiked;
              });
            },
          ),
          _buildActionButton(
            colorScheme,
            icon: Icons.share_outlined,
            label: 'Chia sẻ',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    ColorScheme colorScheme, {
    required IconData icon,
    required String label,
    int count = 0,
    Color? color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: (color ?? colorScheme.primary).withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: color ?? colorScheme.onSurfaceVariant,
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Text(
                  count > 999
                      ? '${(count / 1000).toStringAsFixed(1)}K'
                      : count.toString(),
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
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
