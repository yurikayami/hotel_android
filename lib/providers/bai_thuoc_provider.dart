import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import '../models/bai_thuoc.dart';
import '../services/bai_thuoc_service.dart';

/// Provider for BaiThuoc (Medical Articles) state management
class BaiThuocProvider with ChangeNotifier {
  final BaiThuocService _service;

  BaiThuocProvider({BaiThuocService? service})
      : _service = service ?? BaiThuocService();

  // State
  List<BaiThuoc> _baiThuocList = [];
  BaiThuoc? _currentDetail;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMore = true;

  // Getters
  List<BaiThuoc> get baiThuocList => _baiThuocList;
  BaiThuoc? get currentDetail => _currentDetail;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  /// Load Bai Thuoc list
  Future<void> loadBaiThuocList({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _baiThuocList = [];
      _hasMore = true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      developer.log(
        'Loading BaiThuoc list (page: $_currentPage)',
        name: 'BaiThuocProvider',
      );

      final newItems = await _service.getBaiThuocList(
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        _baiThuocList.addAll(newItems);
        _currentPage++;
      }

      developer.log(
        'Loaded ${newItems.length} items. Total: ${_baiThuocList.length}',
        name: 'BaiThuocProvider',
      );
    } catch (e) {
      _error = _getErrorMessage(e);
      developer.log(
        'Error loading BaiThuoc: $_error',
        name: 'BaiThuocProvider',
        error: e,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load Bai Thuoc detail
  Future<void> loadBaiThuocDetail(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      developer.log(
        'Loading BaiThuoc detail: $id',
        name: 'BaiThuocProvider',
      );

      _currentDetail = await _service.getBaiThuocDetail(id);

      developer.log(
        'Loaded BaiThuoc: ${_currentDetail?.ten}',
        name: 'BaiThuocProvider',
      );
    } catch (e) {
      _error = _getErrorMessage(e);
      developer.log(
        'Error loading detail: $_error',
        name: 'BaiThuocProvider',
        error: e,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new Bai Thuoc
  Future<bool> createBaiThuoc({
    required String ten,
    String? moTa,
    String? huongDanSuDung,
    String? imagePath,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      developer.log(
        'Creating BaiThuoc: $ten',
        name: 'BaiThuocProvider',
      );

      final newBaiThuoc = await _service.createBaiThuoc(
        ten: ten,
        moTa: moTa,
        huongDanSuDung: huongDanSuDung,
        imagePath: imagePath,
      );

      // Add to beginning of list
      _baiThuocList.insert(0, newBaiThuoc);

      developer.log(
        'Created BaiThuoc: ${newBaiThuoc.id}',
        name: 'BaiThuocProvider',
      );

      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      developer.log(
        'Error creating BaiThuoc: $_error',
        name: 'BaiThuocProvider',
        error: e,
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear current detail
  void clearCurrentDetail() {
    _currentDetail = null;
    notifyListeners();
  }

  /// Get error message from exception
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('socketexception') ||
        errorStr.contains('failed host lookup') ||
        errorStr.contains('connection refused')) {
      return 'Không thể kết nối đến server. Vui lòng kiểm tra:\n• Kết nối mạng\n• Địa chỉ API (192.168.1.3:7135)';
    }

    if (errorStr.contains('timeoutexception')) {
      return 'Kết nối quá chậm. Vui lòng thử lại.';
    }

    if (errorStr.contains('401')) {
      return 'Bạn cần đăng nhập để thực hiện thao tác này.';
    }

    if (errorStr.contains('404')) {
      return 'API endpoint không tồn tại: /BaiThuocAPI';
    }

    if (errorStr.contains('500')) {
      return 'Lỗi server. Vui lòng liên hệ quản trị viên.';
    }

    if (errorStr.contains('dioexception')) {
      return 'Lỗi kết nối: ${error.toString()}';
    }

    return 'Đã có lỗi xảy ra: $error';
  }
}

