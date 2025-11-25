import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/mon_an.dart';
import '../models/user.dart';
import '../models/medicine.dart';
import '../services/api_config.dart';

/// Model để hold search results từ tất cả các loại
class SearchResults {
  final List<User> users;
  final List<Post> posts;
  final List<MonAn> dishes;
  final List<Medicine> medicines;

  SearchResults({
    required this.users,
    required this.posts,
    required this.dishes,
    required this.medicines,
  });

  bool get isEmpty =>
      users.isEmpty && posts.isEmpty && dishes.isEmpty && medicines.isEmpty;

  factory SearchResults.empty() {
    return SearchResults(
      users: [],
      posts: [],
      dishes: [],
      medicines: [],
    );
  }
}

/// Provider quản lý tìm kiếm tổng quát
class SearchProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  SearchResults _results = SearchResults.empty();
  String _searchQuery = '';
  String _selectedType = 'all'; // all, users, posts, dishes, medicines
  List<String> _recentSearches = [];
  
  // Filter & Sort states for client-side filtering
  String _filterCategory = 'Tất cả';
  String _sortOption = 'default'; // default, price_asc, price_desc, likes, views, newest

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SearchResults get results => _results;
  String get searchQuery => _searchQuery;
  String get selectedType => _selectedType;
  List<String> get recentSearches => _recentSearches;
  String get filterCategory => _filterCategory;
  String get sortOption => _sortOption;

  /// Set loại tìm kiếm được chọn
  void setSearchType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  /// Set filter category
  void setFilter(String category) {
    _filterCategory = category;
    notifyListeners();
  }

  /// Set sort option
  void setSort(String option) {
    _sortOption = option;
    notifyListeners();
  }

  /// Get filtered and sorted dishes
  List<MonAn> get filteredDishes {
    List<MonAn> list = List.from(_results.dishes);
    
    // Apply sorting
    switch (_sortOption) {
      case 'price_asc':
        list.sort((a, b) => (a.gia ?? 0).compareTo(b.gia ?? 0));
        break;
      case 'price_desc':
        list.sort((a, b) => (b.gia ?? 0).compareTo(a.gia ?? 0));
        break;
      case 'views':
        list.sort((a, b) => (b.luotXem ?? 0).compareTo(a.luotXem ?? 0));
        break;
      case 'newest':
        list.sort((a, b) => (b.ngayTao ?? DateTime(2000)).compareTo(a.ngayTao ?? DateTime(2000)));
        break;
      case 'default':
      default:
        // Keep original order
        break;
    }
    
    return list;
  }

  /// Get filtered and sorted posts
  List<Post> get filteredPosts {
    List<Post> list = List.from(_results.posts);
    
    // Apply sorting
    switch (_sortOption) {
      case 'likes':
        list.sort((a, b) => (b.luotThich ?? 0).compareTo(a.luotThich ?? 0));
        break;
      case 'newest':
        list.sort((a, b) => (b.ngayDang ?? DateTime(2000)).compareTo(a.ngayDang ?? DateTime(2000)));
        break;
      case 'default':
      default:
        // Keep original order
        break;
    }
    
    return list;
  }

  /// Get filtered and sorted medicines
  List<Medicine> get filteredMedicines {
    List<Medicine> list = List.from(_results.medicines);
    
    // Apply sorting
    switch (_sortOption) {
      case 'likes':
        list.sort((a, b) => b.soLuotThich.compareTo(a.soLuotThich));
        break;
      case 'views':
        list.sort((a, b) => b.soLuotXem.compareTo(a.soLuotXem));
        break;
      case 'newest':
        list.sort((a, b) => b.ngayTao.compareTo(a.ngayTao));
        break;
      case 'default':
      default:
        // Keep original order
        break;
    }
    
    return list;
  }

  /// Clear tất cả kết quả tìm kiếm
  void clearSearch() {
    _searchQuery = '';
    _results = SearchResults.empty();
    _errorMessage = null;
    notifyListeners();
  }

  void addRecentSearch(String query) {
    if (query.isEmpty) return;
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
      notifyListeners();
    }
  }

  void removeRecentSearch(String query) {
    _recentSearches.remove(query);
    notifyListeners();
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  /// Thực hiện tìm kiếm (có debouncing ngoài)
  Future<void> search(String query) async {
    if (query.isEmpty) {
      _results = SearchResults.empty();
      _searchQuery = '';
      notifyListeners();
      return;
    }

    if (query.length < 2) {
      _errorMessage = 'Vui lòng nhập ít nhất 2 ký tự';
      notifyListeners();
      return;
    }

    addRecentSearch(query);
    _searchQuery = query;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Gọi API tổng quát - dùng queryParameters để encode đúng
      final Uri uri = Uri.https(
        ApiConfig.ipComputer,
        '/api/search',
        {
          'query': query,
          'type': _selectedType,
          'page': '1',
          'limit': '20',
        },
      );

      print('[SearchProvider] Search URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print('[SearchProvider] Response Status: ${response.statusCode}');
      print('[SearchProvider] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];

          // Parse từng loại dữ liệu
          final users = (data['users'] as List?)
                  ?.map((e) {
                    final Map<String, dynamic> userJson = Map<String, dynamic>.from(e);
                    if (userJson['userName'] == null && userJson['name'] != null) {
                      userJson['userName'] = userJson['name'];
                    }
                    if (userJson['avatarUrl'] == null && userJson['avatar'] != null) {
                      userJson['avatarUrl'] = userJson['avatar'];
                    }
                    return User.fromJson(userJson);
                  })
                  .toList() ??
              [];

          final posts = (data['posts'] as List?)
                  ?.map((e) {
                    final Map<String, dynamic> postJson = Map<String, dynamic>.from(e);
                    // Map fields for Search API response compatibility
                    if (postJson['noiDung'] == null) {
                      postJson['noiDung'] = postJson['content'] ?? postJson['title'] ?? '';
                    }
                    // Map image/media fields
                    if (postJson['duongDanMedia'] == null) {
                      postJson['duongDanMedia'] = postJson['image'] ?? postJson['mediaUrl'] ?? postJson['media'];
                    }
                    // Map author avatar
                    if (postJson['authorAvatar'] == null && postJson['author'] != null) {
                      postJson['authorAvatar'] = postJson['author']['avatar'] ?? postJson['author']['avatarUrl'];
                    } else if (postJson['authorAvatar'] == null) {
                      postJson['authorAvatar'] = postJson['avatar'] ?? postJson['avatarUrl'];
                    }
                    // Provide defaults for required fields if missing
                    postJson['authorId'] ??= '';
                    postJson['authorName'] ??= postJson['userName'] ?? 'Anonymous';
                    postJson['isLiked'] ??= false;
                    
                    return Post.fromJson(postJson);
                  })
                  .toList() ??
              [];

          final dishes = (data['dishes'] as List?)
                  ?.map((e) {
                    final Map<String, dynamic> dishJson = Map<String, dynamic>.from(e);
                    // Map fields
                    if (dishJson['ten'] == null) {
                      dishJson['ten'] = dishJson['name'] ?? dishJson['title'] ?? '';
                    }
                    // Map image
                    if (dishJson['image'] == null) {
                      dishJson['image'] = dishJson['duongDanMedia'] ?? dishJson['mediaUrl'];
                    }
                    // Map description
                    if (dishJson['moTa'] == null) {
                      dishJson['moTa'] = dishJson['description'] ?? dishJson['content'] ?? '';
                    }
                    // Map price - ensure it's double
                    if (dishJson['gia'] != null) {
                      if (dishJson['gia'] is String) {
                        dishJson['gia'] = double.tryParse(dishJson['gia']) ?? 0.0;
                      } else if (dishJson['gia'] is int) {
                        dishJson['gia'] = (dishJson['gia'] as int).toDouble();
                      }
                    } else {
                      dishJson['gia'] = dishJson['price'] != null
                          ? (dishJson['price'] is String ? double.tryParse(dishJson['price']) : dishJson['price'].toDouble())
                          : 0.0;
                    }
                    return MonAn.fromJson(dishJson);
                  })
                  .toList() ??
              [];

          final medicines = (data['medicines'] as List?)
                  ?.map((e) {
                    final Map<String, dynamic> medJson = Map<String, dynamic>.from(e);
                    // Map fields
                    if (medJson['ten'] == null) {
                      medJson['ten'] = medJson['name'] ?? medJson['title'] ?? '';
                    }
                    if (medJson['moTa'] == null) {
                      medJson['moTa'] = medJson['description'] ?? medJson['content'] ?? '';
                    }
                    // Map image
                    if (medJson['image'] == null) {
                      medJson['image'] = medJson['duongDanMedia'] ?? medJson['mediaUrl'];
                    }
                    // Map author avatar
                    if (medJson['authorAvatar'] == null && medJson['author'] != null) {
                      medJson['authorAvatar'] = medJson['author']['avatar'] ?? medJson['author']['avatarUrl'];
                    } else if (medJson['authorAvatar'] == null) {
                      medJson['authorAvatar'] = medJson['avatar'] ?? medJson['avatarUrl'];
                    }
                    // Provide defaults
                    medJson['huongDanSuDung'] ??= '';
                    medJson['authorId'] ??= '';
                    medJson['authorName'] ??= 'Anonymous';
                    // Map likeCount/viewCount from API
                    if (medJson['soLuotThich'] == null && medJson['likeCount'] != null) {
                      medJson['soLuotThich'] = medJson['likeCount'];
                    }
                    if (medJson['soLuotXem'] == null && medJson['viewCount'] != null) {
                      medJson['soLuotXem'] = medJson['viewCount'];
                    }
                    medJson['soLuotThich'] ??= 0;
                    medJson['soLuotXem'] ??= 0;
                    
                    return Medicine.fromJson(medJson);
                  })
                  .toList() ??
              [];

          _results = SearchResults(
            users: users,
            posts: posts,
            dishes: dishes,
            medicines: medicines,
          );
          _errorMessage = null;
        } else {
          _errorMessage = jsonResponse['message'] ?? 'Không tìm thấy kết quả';
          _results = SearchResults.empty();
        }
      } else {
        print('[SearchProvider] Server Error: ${response.statusCode}');
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody['errors'] != null) {
            final errors = errorBody['errors'] as Map<String, dynamic>;
            _errorMessage =
                errors.values.expand((e) => (e as List).cast<String>()).join('\n');
          } else {
            _errorMessage = errorBody['message'] ??
                errorBody['title'] ??
                'Lỗi server: ${response.statusCode}';
          }
          print('[SearchProvider] Server Message: $_errorMessage');
        } catch (e) {
          _errorMessage = 'Lỗi server: ${response.statusCode}';
          print('[SearchProvider] Could not parse error body: $e');
        }
        _results = SearchResults.empty();
      }
    } catch (e) {
      _errorMessage = 'Lỗi kết nối: $e';
      _results = SearchResults.empty();
      print('[SearchProvider] Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Lấy suggestions cho autocomplete
  Future<List<String>> getSuggestions(String query) async {
    if (query.isEmpty || query.length < 2) return [];

    try {
      final Uri uri = Uri.https(
        ApiConfig.ipComputer,
        '/api/search/suggestions',
        {
          'query': query,
          'type': _selectedType,
          'limit': '10',
        },
      );

      print('[SearchProvider] Suggestions URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print('[SearchProvider] Suggestions Status: ${response.statusCode}');
      // print('[SearchProvider] Suggestions Body: ${response.body}'); // Uncomment if needed

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          final suggestions = List<String>.from(
            jsonResponse['data']['suggestions'] ?? [],
          );
          return suggestions;
        }
      }
    } catch (e) {
      print('[SearchProvider] Suggestions error: $e');
    }

    return [];
  }
}

