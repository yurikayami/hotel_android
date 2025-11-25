import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/prediction_history.dart';
import '../services/food_analysis_service.dart';

/// Provider for managing food analysis state and operations
class FoodAnalysisProvider extends ChangeNotifier {
  final FoodAnalysisService _service;

  FoodAnalysisProvider(this._service);

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  PredictionHistory? _currentAnalysis;
  List<PredictionHistory> _history = [];
  List<PredictionHistory> _filteredHistory = [];
  String _selectedTimeFilter = 'all'; // all, today, week, month
  String _selectedMealFilter = 'all'; // all, breakfast, lunch, dinner, snack

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PredictionHistory? get currentAnalysis => _currentAnalysis;
  List<PredictionHistory> get history => _history;
  List<PredictionHistory> get filteredHistory => _filteredHistory;
  String get selectedTimeFilter => _selectedTimeFilter;
  String get selectedMealFilter => _selectedMealFilter;

  /// Analyze a food image
  /// 
  /// Takes an image file and sends it to the backend for AI analysis.
  Future<void> analyzeFood({
    required String userId,
    required XFile imageFile,
    String mealType = 'lunch',
    double userCalorieTarget = 2000,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      developer.log(
        'Starting food analysis for user: $userId',
        name: 'FoodAnalysisProvider',
      );

      final result = await _service.analyzeFood(
        userId: userId,
        imageFile: imageFile,
        mealType: mealType,
      );

      _currentAnalysis = result;
      
      // Add to history list if not already present
      if (!_history.any((h) => h.id == result.id)) {
        _history.insert(0, result);
      }

      developer.log(
        'Analysis completed: ${result.foodName} (confidence: ${result.confidence})',
        name: 'FoodAnalysisProvider',
      );

      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      developer.log(
        'Error analyzing food',
        name: 'FoodAnalysisProvider',
        error: e,
        stackTrace: stackTrace,
      );

      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch analysis history for a user
  /// 
  /// Retrieves past food analyses from the backend
  Future<void> fetchHistory(String userId, {int page = 1, int pageSize = 20}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      developer.log(
        'Fetching history for user: $userId',
        name: 'FoodAnalysisProvider',
      );

      final results = await _service.getHistory(
        userId: userId,
        page: page,
        pageSize: pageSize,
      );

      _history = results;
      _applyFilters(); // Apply current filters to new data

      developer.log(
        'Fetched ${results.length} history items',
        name: 'FoodAnalysisProvider',
      );

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching history',
        name: 'FoodAnalysisProvider',
        error: e,
        stackTrace: stackTrace,
      );

      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete an analysis record
  /// 
  /// Removes a specific analysis from history
  Future<void> deleteAnalysis(int id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _service.deleteAnalysis(id);

      // Remove from local history
      _history.removeWhere((h) => h.id == id);
      _applyFilters(); // Reapply filters after deletion
      
      // Clear current analysis if it's the deleted one
      if (_currentAnalysis?.id == id) {
        _currentAnalysis = null;
      }

      developer.log(
        'Deleted analysis: $id',
        name: 'FoodAnalysisProvider',
      );

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      developer.log(
        'Error deleting analysis',
        name: 'FoodAnalysisProvider',
        error: e,
        stackTrace: stackTrace,
      );

      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear current analysis
  void clearCurrentAnalysis() {
    _currentAnalysis = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Set time filter and apply filtering
  /// 
  /// Filters history by time range:
  /// - 'all': Show all records
  /// - 'today': Records from today
  /// - 'week': Records from the past 7 days
  /// - 'month': Records from the past 30 days
  void setTimeFilter(String timeFilter) {
    _selectedTimeFilter = timeFilter;
    _applyFilters();
    notifyListeners();
  }

  /// Set meal type filter and apply filtering
  /// 
  /// Filters history by meal type:
  /// - 'all': All meal types
  /// - 'breakfast': Breakfast items
  /// - 'lunch': Lunch items
  /// - 'dinner': Dinner items
  /// - 'snack': Snack items
  void setMealFilter(String mealFilter) {
    _selectedMealFilter = mealFilter;
    _applyFilters();
    notifyListeners();
  }

  /// Apply both filters to the history list
  void _applyFilters() {
    _filteredHistory = _history.where((item) {
      // Apply time filter
      final now = DateTime.now();
      final itemDate = item.createdAt;
      
      bool timeFilterMatch = false;
      switch (_selectedTimeFilter) {
        case 'today':
          timeFilterMatch = itemDate.year == now.year &&
              itemDate.month == now.month &&
              itemDate.day == now.day;
          break;
        case 'week':
          final sevenDaysAgo = now.subtract(const Duration(days: 7));
          timeFilterMatch = itemDate.isAfter(sevenDaysAgo) && 
                            itemDate.isBefore(now.add(const Duration(days: 1)));
          break;
        case 'month':
          final thirtyDaysAgo = now.subtract(const Duration(days: 30));
          timeFilterMatch = itemDate.isAfter(thirtyDaysAgo) && 
                            itemDate.isBefore(now.add(const Duration(days: 1)));
          break;
        default: // 'all'
          timeFilterMatch = true;
      }

      // Apply meal type filter
      bool mealFilterMatch = _selectedMealFilter == 'all' ||
          item.mealType?.toLowerCase() == _selectedMealFilter.toLowerCase();

      return timeFilterMatch && mealFilterMatch;
    }).toList();
  }

  /// Reset all filters to default values
  void resetFilters() {
    _selectedTimeFilter = 'all';
    _selectedMealFilter = 'all';
    _applyFilters();
    notifyListeners();
  }

  /// Extract user-friendly error message from exception
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();
    
    developer.log(
      'Full error: $errorString',
      name: 'FoodAnalysisProvider',
      level: 1000,
    );
    
    if (errorString.contains('SocketException') || 
        errorString.contains('Failed host lookup')) {
      return 'Không thể kết nối đến máy chủ.\nKiểm tra:\n• Kết nối mạng\n• Backend đang chạy\n• IP address trong api_config.dart';
    }
    
    if (errorString.contains('TimeoutException') ||
        errorString.contains('timeout')) {
      return 'Yêu cầu quá thời gian chờ.\n• Kiểm tra kết nối mạng\n• Backend có thể đang xử lý chậm';
    }
    
    if (errorString.contains('401') || errorString.contains('Unauthorized')) {
      return 'Phiên đăng nhập đã hết hạn.\nVui lòng đăng nhập lại.';
    }
    
    if (errorString.contains('404') || errorString.contains('Not found')) {
      return 'Không tìm thấy API endpoint.\nKiểm tra backend URL.';
    }
    
    if (errorString.contains('500') || errorString.contains('Internal Server Error')) {
      return 'Lỗi máy chủ.\n• Backend có thể chưa sẵn sàng\n• Kiểm tra logs backend';
    }
    
    if (errorString.contains('DioException') || errorString.contains('DioError')) {
      return 'Lỗi kết nối API.\n• Kiểm tra URL backend\n• Kiểm tra SSL certificate\n\nChi tiết: ${errorString.substring(0, errorString.length > 100 ? 100 : errorString.length)}';
    }
    
    return 'Đã xảy ra lỗi.\n\nChi tiết: ${errorString.substring(0, errorString.length > 150 ? 150 : errorString.length)}...';
  }
}

