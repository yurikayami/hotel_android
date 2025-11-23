import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/bai_thuoc_provider.dart';
import '../../models/bai_thuoc.dart';
import '../../utils/image_url_helper.dart';
import '../search/general_search_screen.dart';
import 'bai_thuoc_detail_screen.dart';

/// Bài Thuốc list screen with modern Twitter-style design
class BaiThuocListScreen extends StatefulWidget {
  const BaiThuocListScreen({super.key});

  @override
  State<BaiThuocListScreen> createState() => _BaiThuocListScreenState();
}

class _BaiThuocListScreenState extends State<BaiThuocListScreen> {
  final ScrollController _scrollController = ScrollController();
  String _sortBy = 'newest'; // newest, mostLiked, mostViewed

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BaiThuocProvider>().loadBaiThuocList(refresh: true);
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
      // Load more when scrolled 90%
      final provider = context.read<BaiThuocProvider>();
      if (!provider.isLoading && provider.hasMore) {
        provider.loadBaiThuocList();
      }
    }
  }

  Future<void> _onRefresh() async {
    await context.read<BaiThuocProvider>().loadBaiThuocList(refresh: true);
  }

  List<BaiThuoc> _getSortedList(List<BaiThuoc> items) {
    final sorted = List<BaiThuoc>.from(items);
    switch (_sortBy) {
      case 'mostLiked':
        sorted.sort((a, b) => (b.soLuotThich ?? 0).compareTo(a.soLuotThich ?? 0));
        break;
      case 'mostViewed':
        sorted.sort((a, b) => (b.soLuotXem ?? 0).compareTo(a.soLuotXem ?? 0));
        break;
      case 'newest':
      default:
        sorted.sort((a, b) => b.ngayTao.compareTo(a.ngayTao));
    }
    return sorted;
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Sắp xếp theo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            _buildSortOption('newest', 'Mới nhất', Icons.schedule_outlined),
            _buildSortOption('mostLiked', 'Lượt thích', Icons.favorite_outline),
            _buildSortOption('mostViewed', 'Lượt xem', Icons.visibility_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon) {
    final isSelected = _sortBy == value;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _sortBy = value);
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(Icons.check, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<BaiThuocProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.baiThuocList.isEmpty) {
            return _buildLoadingShimmer();
          }

          if (provider.error != null && provider.baiThuocList.isEmpty) {
            return _buildErrorView(provider.error!);
          }

          final sortedList = _getSortedList(provider.baiThuocList);

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildAppBar(),
                if (sortedList.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyView(),
                  )
                else
                  SliverList.separated(
                    itemCount: sortedList.length + (provider.hasMore ? 1 : 0),
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                      indent: 16,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      if (index == sortedList.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _buildBaiThuocCard(sortedList[index]);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      title: const Text(
        'Bài Thuốc',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GeneralSearchScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.sort_rounded),
          onPressed: _showSortMenu,
        ),
      ],
    );
  }

  Widget _buildBaiThuocCard(BaiThuoc baiThuoc) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BaiThuocDetailScreen(baiThuocId: baiThuoc.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with author info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author avatar
                if (baiThuoc.authorAvatar != null && baiThuoc.authorAvatar!.isNotEmpty)
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      ImageUrlHelper.formatImageUrl(baiThuoc.authorAvatar),
                    ),
                  )
                else
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 20,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                const SizedBox(width: 12),
                
                // Author name and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        baiThuoc.authorName ?? 'Ẩn danh',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatDate(baiThuoc.ngayTao),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              baiThuoc.ten,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Description
            if (baiThuoc.moTa != null && baiThuoc.moTa!.isNotEmpty)
              Text(
                baiThuoc.moTa!,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 12),

            // Image if available
            if (baiThuoc.image != null && baiThuoc.image!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImageWidget(baiThuoc.image, 200),
              ),
            
            if (baiThuoc.image != null && baiThuoc.image!.isNotEmpty)
              const SizedBox(height: 12),

            // Stats row
            Row(
              children: [
                _buildStatButton(
                  Icons.favorite_outline,
                  _formatCount(baiThuoc.soLuotThich ?? 0),
                  Colors.red,
                  colorScheme,
                ),
                const SizedBox(width: 16),
                _buildStatButton(
                  Icons.visibility_outlined,
                  _formatCount(baiThuoc.soLuotXem ?? 0),
                  colorScheme.primary,
                  colorScheme,
                ),
                const Spacer(),
                Icon(
                  Icons.share_outlined,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatButton(
    IconData icon,
    String count,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                count,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
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

  String _formatDate(DateTime date) {
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

  Widget _buildEmptyView() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_hospital_outlined,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa có bài thuốc nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy thêm bài thuốc đầu tiên của bạn!',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
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
        color: colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    // Check if it's a base64 data URI
    if (imageUrl.startsWith('data:image')) {
      return Image.memory(
        Uint8List.fromList(_base64ToBytes(imageUrl)),
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            color: colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.image_not_supported,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
          );
        },
      );
    }

    // Otherwise treat as URL
    return Image.network(
      ImageUrlHelper.formatImageUrl(imageUrl),
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          color: colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.image_not_supported,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
        );
      },
    );
  }

  List<int> _base64ToBytes(String base64String) {
    // Remove the data URI prefix if present
    final data = base64String.contains(',')
        ? base64String.split(',')[1]
        : base64String;

    // Use dart:convert for base64 decoding
    return base64Decode(data);
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
              onPressed: _onRefresh,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: colorScheme.outline.withValues(alpha: 0.1),
      ),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header shimmer
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14,
                          width: 100,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 12,
                          width: 60,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Title shimmer
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 14,
                width: 200,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

