import 'dart:io';
import '../models/post.dart';
import 'api_service.dart';
import 'api_config.dart';

/// Service for managing posts
class PostService {
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

  /// Get paginated list of posts
  ///
  /// [page] - Page number (starting from 1)
  /// [pageSize] - Number of posts per page
  /// Returns [PostPagedResult] containing posts and pagination info
  Future<PostPagedResult> getPosts({int page = 1, int pageSize = 100}) async {
    try {
      final url = '${ApiConfig.posts}?page=$page&pageSize=$pageSize';
      print('[PostService] Fetching posts from: $url');

      final response = await _apiService.get(url);

      print('[PostService] API Response: $response');

      // Handle case where API returns null or empty response
      if (response == null) {
        print('[PostService] Response is null, returning empty result');
        return PostPagedResult(
          posts: [],
          totalCount: 0,
          page: page,
          pageSize: pageSize,
          totalPages: 0,
          hasPrevious: false,
          hasNext: false,
        );
      }

      // API returns wrapped response: {success, message, data: {...}}
      // Extract the data part
      final data = _extractData(response);
      if (data == null) {
        print(
          '[PostService] No data field in response, returning empty result',
        );
        return PostPagedResult(
          posts: [],
          totalCount: 0,
          page: page,
          pageSize: pageSize,
          totalPages: 0,
          hasPrevious: false,
          hasNext: false,
        );
      }

      print('[PostService] Data structure: $data');

      final result = PostPagedResult.fromJson(data);
      print('[PostService] Parsed ${result.posts.length} posts');
      return result;
    } catch (e, s) {
      print('[PostService] Error loading posts: $e');
      print('[PostService] Stack trace: $s');
      throw Exception('Failed to load posts: $e');
    }
  }

  /// Get a single post by ID
  ///
  /// [postId] - The ID of the post to retrieve
  /// Returns [Post] object
  Future<Post> getPost(String postId) async {
    try {
      final response = await _apiService.get('${ApiConfig.posts}/$postId');
      final data = _extractData(response);
      return Post.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load post: $e');
    }
  }

  /// Create a new post with optional images (using Base64 encoding)
  ///
  /// [noiDung] - Post content text
  /// [hinhAnh] - Optional list of image files
  /// [duongDanMedia] - Optional Base64 encoded images as string
  /// Returns the created [Post]
  Future<Post> createPost({
    required String noiDung,
    List<File>? hinhAnh,
    String? duongDanMedia,
  }) async {
    try {
      print('[PostService] Creating post with base64 images');
      print('[PostService] Content: $noiDung');
      print('[PostService] Images count: ${hinhAnh?.length ?? 0}');

      // Build request body
      final Map<String, dynamic> body = {
        'noiDung': noiDung,
        'loai': (hinhAnh != null && hinhAnh.isNotEmpty) ? 'image' : 'text',
        'duongDanMedia': duongDanMedia,
        'images': <String>[], // List of base64 images
        'imageMimeTypes': <String>[], // List of MIME types
      };

      // Convert images to base64 if provided
      if (hinhAnh != null && hinhAnh.isNotEmpty) {
        for (var i = 0; i < hinhAnh.length; i++) {
          try {
            print(
              '[PostService] Converting image ${i + 1}/${hinhAnh.length} to base64',
            );
            final base64Image = await _apiService.fileToBase64(hinhAnh[i]);
            final mimeType = _apiService.getFileMimeType(hinhAnh[i].path);

            body['images'].add(base64Image);
            body['imageMimeTypes'].add(mimeType);

            print(
              '[PostService] Image ${i + 1} converted, size: ${base64Image.length} chars',
            );
          } catch (e) {
            print('[PostService] Error converting image ${i + 1}: $e');
            throw Exception('Failed to process image ${i + 1}: $e');
          }
        }
      }

      print(
        '[PostService] Sending post request with ${body['images'].length} images',
      );
      print(
        '[PostService] DuongDanMedia: ${duongDanMedia?.substring(0, 50) ?? "null"}...',
      );

      // Send request
      final response = await _apiService.post(
        ApiConfig.posts,
        body: body,
        needsAuth: true,
      );

      print('[PostService] Post created successfully');
      final extractedData = _extractData(response);
      return Post.fromJson(extractedData);
    } catch (e) {
      print('[PostService] Create post error: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  /// Update an existing post
  ///
  /// [postId] - ID of the post to update
  /// [noiDung] - Updated content
  /// Returns the updated [Post]
  Future<Post> updatePost({
    required String postId,
    required String noiDung,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.posts}/$postId',
        body: {'noiDung': noiDung},
        needsAuth: true,
      );
      final extractedData = _extractData(response);
      return Post.fromJson(extractedData);
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  /// Delete a post
  ///
  /// [postId] - ID of the post to delete
  Future<void> deletePost(String postId) async {
    try {
      final endpoint = '${ApiConfig.posts}/$postId';
      print('[PostService] Deleting post: $postId');
      print('[PostService] Endpoint: $endpoint');
      print('[PostService] Full URL: ${ApiConfig.baseUrl}$endpoint');
      final response = await _apiService.delete(endpoint);
      print('[PostService] Delete response: $response');
      print('[PostService] Successfully deleted post: $postId');
    } catch (e) {
      print('[PostService] Error deleting post: $e');
      print('[PostService] Error type: ${e.runtimeType}');
      print('[PostService] Error string: ${e.toString()}');
      
      // Extract more helpful error message from exception
      String errorMessage = e.toString();
      
      // Remove "Exception: " prefix if present
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      
      // Parse specific errors
      if (errorMessage.contains('An error occurred while saving')) {
        errorMessage = 'Không thể xóa bài viết. Bài viết có thể chứa bình luận hoặc có vấn đề dữ liệu.';
      } else if (errorMessage.contains('Server error')) {
        errorMessage = 'Lỗi server. Vui lòng thử lại sau.';
      }
      
      throw Exception(errorMessage);
    }
  }

  /// Like or unlike a post
  ///
  /// [postId] - ID of the post to like/unlike
  /// Returns map with isLiked and likeCount
  Future<Map<String, dynamic>> likePost(String postId) async {
    try {
      print('[PostService] Liking post: $postId');
      final response = await _apiService.post(
        '${ApiConfig.posts}/$postId/like',
        body: {},
        needsAuth: true,
      );
      print('[PostService] Like response: $response');

      final extractedData = _extractData(response);
      print('[PostService] Extracted data: $extractedData');

      if (extractedData == null) {
        throw Exception('Like response contains no data');
      }

      if (extractedData is! Map<String, dynamic>) {
        throw Exception(
          'Like response data is not a valid map: $extractedData',
        );
      }

      // Return the like data: {isLiked: true/false, likeCount: number}
      return {
        'isLiked': extractedData['isLiked'] ?? false,
        'likeCount': extractedData['likeCount'] ?? 0,
      };
    } catch (e, s) {
      print('[PostService] Like error: $e');
      print('[PostService] Stack trace: $s');
      throw Exception('Failed to like/unlike post: $e');
    }
  }

  /// Get comments for a post
  ///
  /// [postId] - ID of the post
  /// [page] - Page number for pagination
  /// [pageSize] - Number of comments per page
  /// Returns list of comments
  Future<List<dynamic>> getComments({
    required String postId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.posts}/$postId/comments?page=$page&pageSize=$pageSize',
      );
      final extractedData = _extractData(response);
      if (extractedData is List) {
        return extractedData;
      } else if (extractedData is Map<String, dynamic> &&
          extractedData.containsKey('comments')) {
        return extractedData['comments'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load comments: $e');
    }
  }

  /// Add a comment to a post
  ///
  /// [postId] - ID of the post
  /// [noiDung] - Comment content
  /// Returns the created comment
  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String noiDung,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.posts}/$postId/comments',
        body: {'noiDung': noiDung},
        needsAuth: true,
      );
      final extractedData = _extractData(response);
      return extractedData;
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  /// Search posts by keyword
  ///
  /// [keyword] - Search term
  /// [page] - Page number
  /// [pageSize] - Results per page
  /// Returns [PostPagedResult] with search results
  Future<PostPagedResult> searchPosts({
    required String keyword,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.posts}/search?keyword=$keyword&page=$page&pageSize=$pageSize',
      );
      final extractedData = _extractData(response);
      return PostPagedResult.fromJson(extractedData);
    } catch (e) {
      throw Exception('Failed to search posts: $e');
    }
  }

  /// Get posts by a specific user
  ///
  /// [userId] - ID of the user
  /// [page] - Page number
  /// [pageSize] - Posts per page
  /// Returns [PostPagedResult] with user's posts
  Future<PostPagedResult> getUserPosts({
    required String userId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.posts}/user/$userId?page=$page&pageSize=$pageSize',
      );
      final extractedData = _extractData(response);
      return PostPagedResult.fromJson(extractedData);
    } catch (e) {
      throw Exception('Failed to load user posts: $e');
    }
  }

  /// Get liked posts for the current user
  ///
  /// [offset] - Number of posts to skip (for pagination)
  /// [limit] - Number of posts to return (max 50)
  /// Returns Map with 'posts' (`List<Post>`) and 'hasMore' (bool)
  Future<Map<String, dynamic>> getUserLikedPosts({
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      print('[PostService] Fetching liked posts - offset: $offset, limit: $limit');
      
      final response = await _apiService.get(
        '${ApiConfig.posts}/user/likes?offset=$offset&limit=$limit',
        needsAuth: true,
      );
      
      print('[PostService] Liked posts response: $response');
      
      final extractedData = _extractData(response);
      
      if (extractedData == null) {
        print('[PostService] No liked posts data');
        return {'posts': <Post>[], 'hasMore': false};
      }
      
      // Parse posts
      final postsJson = extractedData['posts'] as List<dynamic>? ?? [];
      final posts = postsJson.map((json) => Post.fromJson(json)).toList();
      final hasMore = extractedData['hasMore'] as bool? ?? false;
      
      print('[PostService] Loaded ${posts.length} liked posts, hasMore: $hasMore');
      
      return {
        'posts': posts,
        'hasMore': hasMore,
      };
    } catch (e) {
      print('[PostService] Error loading liked posts: $e');
      throw Exception('Failed to load liked posts: $e');
    }
  }
}

