import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/mon_an.dart';
import '../../providers/mon_an_provider.dart';
import '../../utils/image_url_helper.dart';
import 'dart:convert';
import 'mon_an_detail_screen.dart';

/// Modern screen để hiển thị danh sách món ăn (dishes)
class MonAnScreen extends StatefulWidget {
  const MonAnScreen({super.key});

  @override
  State<MonAnScreen> createState() => _MonAnScreenState();
}

class _MonAnScreenState extends State<MonAnScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _priceFormatter = NumberFormat('#,###', 'vi_VN');

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MonAnProvider>().loadMonAn();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      context.read<MonAnProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Consumer<MonAnProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.allMonAn.isEmpty) {
            return _buildLoadingShimmer();
          }

          if (provider.errorMessage != null && provider.allMonAn.isEmpty) {
            return _buildErrorView(context, provider.errorMessage!);
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Header
              SliverAppBar(
                floating: true,
                snap: true,
                elevation: 0,
                backgroundColor: colorScheme.surface,
                title: Text(
                  'Món ăn',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              // Search bar với filter/sort integrated
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 3, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => provider.search(value),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm món ăn...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                provider.search('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
              // Filter tabs + Sort button in one row
              SliverToBoxAdapter(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      // Category tabs - Horizontal scrolling
                      Expanded(
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // All tab
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FilterChip(
                                label: Text('Tất cả', style: TextStyle(fontSize: 12)),
                                selected: provider.selectedLoai == null,
                                onSelected: (_) => provider.filterByLoai(null),
                                showCheckmark: false,
                                padding: EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                            // Category tabs
                            ...provider.categories.map((loai) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: FilterChip(
                                  label: Text(loai, style: TextStyle(fontSize: 12)),
                                  selected: provider.selectedLoai == loai,
                                  onSelected: (_) => provider.filterByLoai(loai),
                                  showCheckmark: false,
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      // Sort button
                      IconButton(
                        icon: Icon(Icons.sort, size: 22),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => _buildSortSheet(provider),
                          );
                        },
                        tooltip: 'Sắp xếp',
                      ),
                      // Reset button
                      if (provider.selectedLoai != null || provider.sortBy != SortBy.tenAZ)
                        IconButton(
                          icon: Icon(Icons.refresh, size: 20),
                          onPressed: () => provider.resetFilters(),
                          tooltip: 'Đặt lại',
                        ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              // Grid of dishes
              if (provider.monAn.isEmpty)
                SliverFillRemaining(
                  child: Center(
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
                              Icons.restaurant_menu_outlined,
                              size: 64,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Không tìm thấy món ăn',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Thử thay đổi bộ lọc hoặc tìm kiếm',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.95, // Adjusted for landscape image
                    children: provider.monAn.map((mon) {
                      return _buildDishCard(context, mon);
                    }).toList(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDishCard(BuildContext context, MonAn mon) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MonAnDetailScreen(monAn: mon),
            ),
          );
        },
        child: Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 1.5, // Landscape image (3:2)
                child: _buildDishImage(mon.image),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name
                  Text(
                    mon.ten,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Price
                  if (mon.gia != null)
                    Text(
                      '${_priceFormatter.format(mon.gia!.toInt())}₫',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  const SizedBox(height: 3),
                  // Category & Servings - Compact row
                  Row(
                    children: [
                      if (mon.loai != null)
                        Expanded(
                          child: Text(
                            mon.loai!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
                              color: colorScheme.outline,
                            ),
                          ),
                        ),
                      if (mon.soNguoi != null && mon.soNguoi! > 0)
                        Text(
                          'số người: ${mon.soNguoi}',
                          style: TextStyle(
                            fontSize: 9,
                            color: colorScheme.outline,
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

  Widget _buildDishImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: Center(
          child: Icon(
            Icons.restaurant,
            size: 48,
            color: Colors.grey.shade400,
          ),
        ),
      );
    }

    // Handle base64 images (data:image/jpeg;base64,...)
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64Data = imageUrl.split(',').last;
        final bytes = const Base64Decoder().convert(base64Data);
        return Container(
          color: Colors.grey.shade200,
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return _buildImageErrorWidget();
            },
          ),
        );
      } catch (e) {
        return _buildImageErrorWidget();
      }
    }

    // Handle network URLs (http/https)
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Container(
        color: Colors.grey.shade200,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageErrorWidget();
          },
        ),
      );
    }

    // Handle relative URLs (like /images/...)
    return Container(
      color: Colors.grey.shade200,
      child: Image.network(
        ImageUrlHelper.getFullImageUrl(imageUrl),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageErrorWidget();
        },
      ),
    );
  }

  Widget _buildImageErrorWidget() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 48,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Lỗi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<MonAnProvider>().loadMonAn(),
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildSortSheet(MonAnProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sắp xếp theo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.sort_by_alpha),
            title: Text('Tên (A-Z)'),
            onTap: () {
              provider.sort(SortBy.tenAZ);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.sort_by_alpha),
            title: Text('Tên (Z-A)'),
            onTap: () {
              provider.sort(SortBy.tenZA);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.arrow_upward),
            title: Text('Giá cao nhất'),
            onTap: () {
              provider.sort(SortBy.giaThayCao);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.arrow_downward),
            title: Text('Giá thấp nhất'),
            onTap: () {
              provider.sort(SortBy.giaThapCao);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.new_releases),
            title: Text('Mới nhất'),
            onTap: () {
              provider.sort(SortBy.ngayTaoMoi);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Cũ nhất'),
            onTap: () {
              provider.sort(SortBy.ngayTaoCu);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.visibility),
            title: Text('Xem nhiều nhất'),
            onTap: () {
              provider.sort(SortBy.luotXemCao);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // Shimmer loading effect
  Widget _buildLoadingShimmer() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Món ăn',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.95,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildShimmerCard(),
              childCount: 6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image shimmer
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: AspectRatio(
              aspectRatio: 1.5,
              child: Container(
                color: colorScheme.surfaceContainerHighest,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
          // Content shimmer
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 10,
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
    );
  }
}

