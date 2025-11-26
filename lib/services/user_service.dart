import '../models/post.dart';
import '../models/user_basic_model.dart';
import '../models/health_profile_model.dart';
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

  /// Get user basic profile (Account info from /api/userprofile/basic)
  ///
  /// Returns [UserBasicModel] containing account and identity information
  /// Note: age will be null in this endpoint
  Future<UserBasicModel> getBasicProfile() async {
    try {
      const url = '${ApiConfig.userProfile}/basic';
      print('[UserService] Fetching basic profile from: $url');

      final response = await _apiService.get(url, needsAuth: true);
      print('[UserService] Basic Profile Response: $response');

      if (response == null) {
        throw Exception('Basic profile response is null');
      }

      final data = _extractData(response) ?? response;
      final profile = UserBasicModel.fromJson(data);
      print('[UserService] Successfully loaded basic profile for user: ${profile.id}');
      return profile;
    } catch (e, s) {
      print('[UserService] Error loading basic profile: $e');
      print('[UserService] Stack trace: $s');
      throw Exception('Failed to load basic profile: $e');
    }
  }

  /// Update user basic profile (Account info to /api/userprofile/basic)
  ///
  /// [updateDto] - The basic profile data to update
  /// Returns updated [UserBasicModel]
  Future<UserBasicModel> updateBasicProfile(
    UpdateBasicProfileDto updateDto,
  ) async {
    try {
      const url = '${ApiConfig.userProfile}/basic';
      print('[UserService] Updating basic profile to: $url');

      final requestBody = updateDto.toJson();
      print('[UserService] Basic Update REQUEST: $requestBody');

      final response = await _apiService.put(
        url,
        data: requestBody,
        needsAuth: true,
      );

      if (response == null) {
        throw Exception('Basic profile update response is null');
      }

      final data = _extractData(response) ?? response;
      final profile = UserBasicModel.fromJson(data);
      print('[UserService] Successfully updated basic profile for user: ${profile.id}');
      return profile;
    } catch (e, s) {
      print('[UserService] Error updating basic profile: $e');
      print('[UserService] Stack trace: $s');
      throw Exception('Failed to update basic profile: $e');
    }
  }

  /// Get user health profile (Medical info from /api/userprofile/health)
  ///
  /// Returns [HealthProfileModel] containing medical history and body metrics
  /// Note: age is auto-calculated from dateOfBirth
  Future<HealthProfileModel> getHealthProfile() async {
    try {
      const url = '${ApiConfig.userProfile}/health';
      print('[UserService] Fetching health profile from: $url');

      final response = await _apiService.get(url, needsAuth: true);
      print('[UserService] Health Profile Response: $response');

      if (response == null) {
        throw Exception('Health profile response is null');
      }

      final data = _extractData(response) ?? response;
      final profile = HealthProfileModel.fromJson(data);
      print('[UserService] Successfully loaded health profile for user: ${profile.id}');
      return profile;
    } catch (e, s) {
      print('[UserService] Error loading health profile: $e');
      print('[UserService] Stack trace: $s');
      throw Exception('Failed to load health profile: $e');
    }
  }

  /// Update user health profile (Medical info to /api/userprofile/health)
  ///
  /// [updateDto] - The health profile data to update
  /// Returns updated [HealthProfileModel]
  /// 
  /// Important: Do NOT include age - it's auto-calculated from dateOfBirth
  Future<HealthProfileModel> updateHealthProfile(
    UpdateHealthProfileDto updateDto,
  ) async {
    try {
      const url = '${ApiConfig.userProfile}/health';
      print('[UserService] Updating health profile to: $url');

      final requestBody = updateDto.toJson();
      print('[UserService] Health Update REQUEST: $requestBody');

      final response = await _apiService.put(
        url,
        data: requestBody,
        needsAuth: true,
      );

      if (response == null) {
        throw Exception('Health profile update response is null');
      }

      final data = _extractData(response) ?? response;
      final profile = HealthProfileModel.fromJson(data);
      print('[UserService] Successfully updated health profile for user: ${profile.id}');
      return profile;
    } catch (e, s) {
      print('[UserService] Error updating health profile: $e');
      print('[UserService] Stack trace: $s');
      throw Exception('Failed to update health profile: $e');
    }
  }
}

