import '../models/post.dart';
import 'api_service.dart';
import 'api_config.dart';

/// Service for managing user-related operations
class UserService {
  final ApiService _apiService = ApiService();

  /// Extract data from wrapped API response
  /// API returns: {success, message, data: {...}}
  /// This extracts the data part
  dynamic _extractData(dynamic response) {
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  /// Get paginated list of public posts for a specific user
  ///
  /// [userId] - The ID of the user
  /// [offset] - Number of posts to skip (default: 0)
  /// [limit] - Number of posts to return (default: 10, max: 50)
  /// Returns [PostPagedResult] containing user's posts and pagination info
  /// 
  /// Based on API: GET /api/Post/public/{userId}/posts?offset=X&limit=Y
  Future<PostPagedResult> getUserPublicPosts({
    required String userId,
    int offset = 0,
    int limit = 100,
  }) async {
    try {
      // Use ApiConfig.posts which is '/Post' and base URL already has '/api'
      final url = '${ApiConfig.posts}/public/$userId/posts?offset=$offset&limit=$limit';
      print('[UserService] Fetching public posts for user: $userId from: $url');

      final response = await _apiService.get(url);

      print('[UserService] API Response: $response');

      // Handle case where API returns null or empty response
      if (response == null) {
        print('[UserService] Response is null, returning empty result');
        return PostPagedResult(
          posts: [],
          totalCount: 0,
          page: 1,
          pageSize: limit,
          totalPages: 0,
          hasPrevious: false,
          hasNext: false,
        );
      }

      // API returns wrapped response: {success, message, data: {...}}
      // Extract the data part
      final data = _extractData(response);
      if (data == null) {
        print('[UserService] No data field in response, returning empty result');
        return PostPagedResult(
          posts: [],
          totalCount: 0,
          page: 1,
          pageSize: limit,
          totalPages: 0,
          hasPrevious: false,
          hasNext: false,
        );
      }

      print('[UserService] Data structure: $data');

      final result = PostPagedResult.fromJson(data);
      print('[UserService] Parsed ${result.posts.length} posts for user $userId');
      return result;
    } catch (e, s) {
      print('[UserService] Error loading public posts for user $userId: $e');
      print('[UserService] Stack trace: $s');
      throw Exception('Failed to load user posts: $e');
    }
  }
}

