import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/bai_thuoc_provider.dart';
import '../../utils/image_url_helper.dart';
import '../profile/user_profile_screen.dart';

/// Bài Thuốc detail screen with modern post-detail-like design
class BaiThuocDetailScreen extends StatefulWidget {
  final String baiThuocId;

  const BaiThuocDetailScreen({
    super.key,
    required this.baiThuocId,
  });

  @override
  State<BaiThuocDetailScreen> createState() => _BaiThuocDetailScreenState();
}

class _BaiThuocDetailScreenState extends State<BaiThuocDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BaiThuocProvider>().loadBaiThuocDetail(widget.baiThuocId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Chi tiết bài thuốc',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: Consumer<BaiThuocProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return _buildErrorView(provider.error!);
          }

          final baiThuoc = provider.currentDetail;
          if (baiThuoc == null) {
            return const Center(child: Text('Không tìm thấy bài thuốc'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Image - Full width with 10 / 6 aspect ratio
                if (baiThuoc.image != null && baiThuoc.image!.isNotEmpty)
                  AspectRatio(
                    aspectRatio: 10 / 6,
                    child: _buildImageWidget(baiThuoc.image, double.infinity),
                  )
                else
                  AspectRatio(
                    aspectRatio: 10 / 6,
                    child: Container(
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.image_outlined,
                        size: 80,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                // Content wrapped in padding
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Title - Bold and prominent
                      Text(
                        baiThuoc.ten,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. Metadata & Actions Row
                      _buildMetadataAndActionsRow(baiThuoc, context),
                      const SizedBox(height: 24),

                      Divider(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        height: 1,
                      ),
                      const SizedBox(height: 24),

                      // 4. Description Section
                      if (baiThuoc.moTa != null && baiThuoc.moTa!.isNotEmpty) ...[
                        _buildSectionHeader('Mô tả', context),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            baiThuoc.moTa!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // 5. Usage Instructions Section
                      if (baiThuoc.huongDanSuDung != null &&
                          baiThuoc.huongDanSuDung!.isNotEmpty) ...[
                        _buildSectionHeader('Hướng dẫn sử dụng', context),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            baiThuoc.huongDanSuDung!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildMetadataAndActionsRow(
    dynamic baiThuoc,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Author info with timestamp
        GestureDetector(
          onTap: () {
            if (baiThuoc.authorId != null && baiThuoc.authorId!.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(
                    userId: baiThuoc.authorId!,
                  ),
                ),
              );
            }
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage: baiThuoc.authorAvatar != null &&
                        baiThuoc.authorAvatar!.isNotEmpty
                    ? NetworkImage(
                        ImageUrlHelper.formatImageUrl(
                          baiThuoc.authorAvatar!,
                        ),
                      )
                    : null,
                child: baiThuoc.authorAvatar == null ||
                        baiThuoc.authorAvatar!.isEmpty
                    ? Icon(
                        Icons.person,
                        color: colorScheme.onPrimaryContainer,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      baiThuoc.authorName ?? 'Ẩn danh',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm')
                          .format(baiThuoc.ngayTao),
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

        // Actions row: Views, Likes, Share
        Row(
          children: [
            Expanded(
              child: _buildActionItem(
                icon: Icons.visibility_outlined,
                label: 'Views',
                value: _formatCount(baiThuoc.soLuotXem ?? 0),
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionItem(
                icon: Icons.favorite_outline,
                label: 'Likes',
                value: _formatCount(baiThuoc.soLuotThich ?? 0),
                color: Colors.red,
                isButton: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionItem(
                icon: Icons.share_outlined,
                label: 'Shares',
                value: '',
                color: colorScheme.tertiary,
                isButton: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isButton = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: isButton
              ? BoxDecoration(
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              if (value.isNotEmpty)
                Text(
                  value,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (value.isNotEmpty) const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String? imageUrl, double height) {
    final colorScheme = Theme.of(context).colorScheme;

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        color: colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.image_outlined,
          size: 64,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    // Check if it's a base64 data URI
    if (imageUrl.startsWith('data:image')) {
      return Image.memory(
        Uint8List.fromList(_base64ToBytes(imageUrl)),
        fit: BoxFit.cover,
        height: height,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: double.infinity,
            color: colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.image_not_supported,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
          );
        },
      );
    }

    // Otherwise treat as URL
    return Image.network(
      ImageUrlHelper.formatImageUrl(imageUrl),
      fit: BoxFit.cover,
      height: height,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          width: double.infinity,
          color: colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.image_not_supported,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
        );
      },
    );
  }

  List<int> _base64ToBytes(String base64String) {
    final data = base64String.contains(',')
        ? base64String.split(',')[1]
        : base64String;
    return base64Decode(data);
  }
}

