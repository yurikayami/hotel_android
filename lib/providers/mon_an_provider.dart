import 'package:flutter/foundation.dart';
import '../models/mon_an.dart';
import '../services/mon_an_service.dart';

/// Enum cho sắp xếp
enum SortBy {
  tenAZ,
  tenZA,
  giaThayCao,
  giaThapCao,
  ngayTaoMoi,
  ngayTaoCu,
  luotXemCao,
}

/// Provider cho các món ăn
class MonAnProvider extends ChangeNotifier {
  final MonAnService _service = MonAnService();

  List<MonAn> _allMonAn = [];
  List<MonAn> _filteredMonAn = [];
  List<MonAn> _paginatedMonAn = [];
  String? _selectedLoai;
  SortBy _sortBy = SortBy.tenAZ;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _pageSize = 20;
  String? _errorMessage;

  // Getters
  List<MonAn> get monAn => _paginatedMonAn;
  List<MonAn> get allMonAn => _allMonAn;
  String? get selectedLoai => _selectedLoai;
  SortBy get sortBy => _sortBy;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  /// Lấy danh sách loại (categories) duy nhất
  Set<String> get categories {
    final categories = <String>{};
    for (final mon in _allMonAn) {
      if (mon.loai != null && mon.loai!.isNotEmpty) {
        categories.add(mon.loai!);
      }
    }
    return categories;
  }

  /// Load tất cả món ăn
  Future<void> loadMonAn() async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    notifyListeners();

    try {
      _allMonAn = await _service.getMonAnList();
      if (kDebugMode) {
        print('[MonAnProvider] Loaded ${_allMonAn.length} dishes from API');
      }
      _applyFiltersAndSort();
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('[MonAnProvider] Error: $_errorMessage');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Lọc theo loại
  void filterByLoai(String? loai) {
    _selectedLoai = loai;
    _applyFiltersAndSort();
  }

  /// Tìm kiếm
  void search(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
  }

  /// Sắp xếp
  void sort(SortBy sortBy) {
    _sortBy = sortBy;
    _applyFiltersAndSort();
  }

  /// Áp dụng lọc và sắp xếp
  void _applyFiltersAndSort() {
    _filteredMonAn = [..._allMonAn];

    // Lọc theo loại
    if (_selectedLoai != null) {
      _filteredMonAn = _filteredMonAn
          .where((mon) => mon.loai?.toLowerCase() == _selectedLoai?.toLowerCase())
          .toList();
    }

    // Tìm kiếm theo tên
    if (_searchQuery.isNotEmpty) {
      _filteredMonAn = _filteredMonAn
          .where((mon) =>
              mon.ten.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (mon.moTa?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                  false))
          .toList();
    }

    // Sắp xếp
    switch (_sortBy) {
      case SortBy.tenAZ:
        _filteredMonAn.sort((a, b) => a.ten.compareTo(b.ten));
        break;
      case SortBy.tenZA:
        _filteredMonAn.sort((a, b) => b.ten.compareTo(a.ten));
        break;
      case SortBy.giaThayCao:
        _filteredMonAn.sort((a, b) => (b.gia ?? 0).compareTo(a.gia ?? 0));
        break;
      case SortBy.giaThapCao:
        _filteredMonAn.sort((a, b) => (a.gia ?? 0).compareTo(b.gia ?? 0));
        break;
      case SortBy.ngayTaoMoi:
        _filteredMonAn.sort(
            (a, b) => (b.ngayTao ?? DateTime(1970)).compareTo(a.ngayTao ?? DateTime(1970)));
        break;
      case SortBy.ngayTaoCu:
        _filteredMonAn.sort(
            (a, b) => (a.ngayTao ?? DateTime(1970)).compareTo(b.ngayTao ?? DateTime(1970)));
        break;
      case SortBy.luotXemCao:
        _filteredMonAn.sort((a, b) => (b.luotXem ?? 0).compareTo(a.luotXem ?? 0));
        break;
    }

    // Reset pagination khi filter/sort thay đổi
    _currentPage = 1;
    _updatePaginatedList();
    notifyListeners();
  }

  /// Cập nhật danh sách phân trang
  void _updatePaginatedList() {
    final endIndex = _currentPage * _pageSize;
    _paginatedMonAn = _filteredMonAn.take(endIndex).toList();
    _hasMore = endIndex < _filteredMonAn.length;
  }

  /// Load thêm món ăn (infinite scroll)
  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _currentPage++;
      _updatePaginatedList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset filters
  void resetFilters() {
    _selectedLoai = null;
    _sortBy = SortBy.tenAZ;
    _searchQuery = '';
    _applyFiltersAndSort();
  }
}

