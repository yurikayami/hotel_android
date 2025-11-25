import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/post.dart';
import '../../providers/post_provider.dart';
import '../../widgets/html_content_viewer.dart';
import '../profile/user_profile_screen.dart';

/// Screen for viewing post details and comments
class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late TextEditingController _commentController;
  late List<dynamic> _comments;
  bool _isLoadingComments = false;
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _comments = [];
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);
    try {
      final provider = context.read<PostProvider>();
      final comments = await provider.getComments(widget.post.id);
      setState(() => _comments = comments);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải bình luận: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingComments = false);
      }
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập bình luận')));
      return;
    }

    setState(() => _isSubmittingComment = true);

    try {
      await context.read<PostProvider>().addComment(
        postId: widget.post.id,
        noiDung: _commentController.text,
      );

      _commentController.clear();
      await _loadComments(); // Reload comments

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bình luận thành công')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmittingComment = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Chi tiết bài viết',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // Post details
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author info
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserProfileScreen(userId: widget.post.authorId),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: colorScheme.primaryContainer,
                            backgroundImage:
                                widget.post.authorAvatar != null &&
                                    widget.post.authorAvatar!.startsWith('http')
                                ? NetworkImage(widget.post.authorAvatar!)
                                : const AssetImage('assets/images/avatar.jpg')
                                      as ImageProvider,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.post.authorName,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.post.ngayDang != null
                                      ? DateFormat(
                                          'dd/MM/yyyy HH:mm',
                                        ).format(widget.post.ngayDang!)
                                      : 'N/A',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Content
                    if (widget.post.noiDung.contains('<') &&
                        widget.post.noiDung.contains('>'))
                      HtmlContentViewer(
                        htmlContent: widget.post.noiDung,
                        baseStyle: theme.textTheme.bodyLarge,
                      )
                    else
                      Text(
                        widget.post.noiDung,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                      ),

                    // Image display (if available)
                    if (widget.post.duongDanMedia != null &&
                        widget.post.duongDanMedia!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _buildPostImage(),
                      ),

                    const SizedBox(height: 24),
                    Divider(color: colorScheme.outlineVariant),
                    const SizedBox(height: 16),

                    // Action buttons - Like, Comment, Share
                    _buildActionButtons(context, colorScheme),
                    const SizedBox(height: 16),
                    Divider(color: colorScheme.outlineVariant),
                    const SizedBox(height: 16),

                    // Comments section title
                    Text(
                      'Bình luận (${_comments.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Comments list
                    if (_isLoadingComments)
                      const Center(child: CircularProgressIndicator())
                    else if (_comments.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'Chưa có bình luận nào',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return _buildCommentTile(context, comment);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Comment input
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Viết bình luận...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    enabled: !_isSubmittingComment,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: colorScheme.primary,
                  child: IconButton(
                    icon: _isSubmittingComment
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                    onPressed: _isSubmittingComment ? null : _submitComment,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(BuildContext context, dynamic comment) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Handle different comment structures
    final authorName = comment is Map
        ? comment['authorName'] ?? comment['userName'] ?? 'Người dùng'
        : 'Người dùng';
    final authorAvatar = comment is Map
        ? comment['authorAvatar'] ?? comment['userAvatar']
        : null;
    final authorId = comment is Map
        ? comment['authorId'] ?? comment['userId']
        : null;
    final content = comment is Map
        ? comment['noiDung'] ?? comment['content'] ?? ''
        : '';
    final createdAt = comment is Map
        ? comment['createdAt'] ??
              comment['ngayTao'] ??
              DateTime.now().toString()
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: authorId != null
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfileScreen(userId: authorId.toString()),
                      ),
                    );
                  }
                : null,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage:
                  authorAvatar != null &&
                      authorAvatar.toString().startsWith('http')
                  ? NetworkImage(authorAvatar.toString())
                  : const AssetImage('assets/images/avatar.jpg')
                        as ImageProvider,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: authorId != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserProfileScreen(userId: authorId.toString()),
                        ),
                      );
                    }
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authorName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(content, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    _formatCommentDate(createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCommentDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inSeconds < 60) {
        return 'Vừa xong';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes} phút trước';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} giờ trước';
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (e) {
      return '';
    }
  }

  Widget _buildPostImage() {
    final mediaUrl = widget.post.duongDanMedia!;
    final colorScheme = Theme.of(context).colorScheme;

    try {
      // Check if it's a Base64 data URI
      if (mediaUrl.startsWith('data:image')) {
        final base64Data = mediaUrl.split(',').last;
        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 400, minHeight: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surfaceVariant,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              base64Decode(base64Data),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildImageError(colorScheme);
              },
            ),
          ),
        );
      }
      // Check if it's a relative path (starts with /upload/)
      else if (mediaUrl.startsWith('/upload/')) {
        final fullUrl = 'https://10.227.9.96:7135$mediaUrl';
        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 400, minHeight: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surfaceVariant,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              fullUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildImageError(colorScheme);
              },
            ),
          ),
        );
      }
      // Otherwise treat as full URL
      else {
        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 400, minHeight: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surfaceVariant,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              mediaUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildImageError(colorScheme);
              },
            ),
          ),
        );
      }
    } catch (e) {
      return _buildImageError(colorScheme);
    }
  }

  Widget _buildImageError(ColorScheme colorScheme) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surfaceVariant,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 48,
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
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Comment',
            count: widget.post.soBinhLuan.toString(),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã chuyển đến phần bình luận')),
              );
            },
            colorScheme: colorScheme,
          ),
        ),
        Expanded(
          child: _buildActionButton(
            icon: Icons.favorite_outline_rounded,
            label: 'Like',
            count: widget.post.luotThich.toString(),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã thích bài viết')),
              );
            },
            colorScheme: colorScheme,
          ),
        ),
        Expanded(
          child: _buildActionButton(
            icon: Icons.share_rounded,
            label: 'Share',
            count: '',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã sao chép link bài viết')),
              );
            },
            colorScheme: colorScheme,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String count,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: colorScheme.onSurfaceVariant, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (count.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  count,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
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
