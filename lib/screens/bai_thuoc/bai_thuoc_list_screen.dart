import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BaiThuocDetailScreen(baiThuocId: baiThuoc.id),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image - left side (square 1:1 aspect ratio)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                  width: 140,
                  height: 140,
                  child: baiThuoc.image != null && baiThuoc.image!.isNotEmpty
                      ? _buildImageWidget(baiThuoc.image, 300)
                      : Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
              ),
              // Content - right side
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title + Description
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category badge with read time
                          Row(
                            children: [
                              // Badge
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0A2A18), // Dark green
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: const Text(
                                  'BÀI THUỐC',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Read time
                              Text(
                                '3 phút đọc',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Title
                          Text(
                            baiThuoc.ten,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Description - 3 lines
                          if (baiThuoc.moTa != null && baiThuoc.moTa!.isNotEmpty)
                            Text(
                              baiThuoc.moTa!,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.onSurfaceVariant,
                                height: 1.3,
                              ),
                            ),
                        ],
                      ),
                      // Author + Stats footer
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          // Author info + Stats in one row
                          Row(
                            children: [
                              // Author avatar - smaller
                              if (baiThuoc.authorAvatar != null && baiThuoc.authorAvatar!.isNotEmpty)
                                CircleAvatar(
                                  radius: 10,
                                  backgroundImage: NetworkImage(
                                    ImageUrlHelper.formatImageUrl(baiThuoc.authorAvatar),
                                  ),
                                )
                              else
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.person,
                                    size: 8,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              const SizedBox(width: 4),
                              // Author name - smaller
                              Expanded(
                                child: Text(
                                  baiThuoc.authorName ?? 'Dr. Herbal',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Views stat
                              Icon(
                                Icons.visibility_outlined,
                                size: 10,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _formatCount(baiThuoc.soLuotXem ?? 0),
                                style: TextStyle(
                                  fontSize: 8,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Likes stat
                              Icon(
                                Icons.favorite_outline,
                                size: 10,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _formatCount(baiThuoc.soLuotThich ?? 0),
                                style: TextStyle(
                                  fontSize: 8,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
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

