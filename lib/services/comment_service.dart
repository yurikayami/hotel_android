import 'api_service.dart';
import 'api_config.dart';

/// Comment model
class Comment {
  final String id;
  final String noiDung;
  final DateTime ngayTao;
  final String? parentCommentId;
  final String userId;
  final String userName;
  final String? userAvatar;

  Comment({
    required this.id,
    required this.noiDung,
    required this.ngayTao,
    this.parentCommentId,
    required this.userId,
    required this.userName,
    this.userAvatar,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      noiDung: json['noiDung'] ?? '',
      ngayTao: json['ngayTao'] != null 
          ? DateTime.parse(json['ngayTao']) 
          : DateTime.now(),
      parentCommentId: json['parentCommentId'],
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Unknown',
      userAvatar: json['userAvatar'],
    );
  }
}

/// Paged result for comments
class CommentPagedResult {
  final List<Comment> comments;
  final int totalCount;
  final bool hasNext;
  final bool hasPrevious;

  CommentPagedResult({
    required this.comments,
    required this.totalCount,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory CommentPagedResult.fromJson(Map<String, dynamic> json) {
    final commentsList = (json['comments'] as List?)
        ?.map((c) => Comment.fromJson(c as Map<String, dynamic>))
        .toList() ?? [];

    return CommentPagedResult(
      comments: commentsList,
      totalCount: json['totalCount'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrevious: json['hasPrevious'] ?? false,
    );
  }
}

/// Service for managing comments
class CommentService {
  final ApiService _apiService = ApiService();

  /// Extract data from wrapped API response
  dynamic _extractData(dynamic response) {
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  /// Get public comments for a specific user
  /// 
  /// [userId] - The ID of the user
  /// [offset] - Number of comments to skip (default: 0)
  /// [limit] - Number of comments to return (default: 100)
  Future<CommentPagedResult> getPublicUserComments({
    required String userId,
    int offset = 0,
    int limit = 100,
  }) async {
    try {
      final url = '${ApiConfig.posts}/public/$userId/comments?offset=$offset&limit=$limit';
      print('[CommentService] Fetching comments for user: $userId from: $url');

      final response = await _apiService.get(url);

      print('[CommentService] API Response: $response');

      if (response == null) {
        print('[CommentService] Response is null, returning empty result');
        return CommentPagedResult(
          comments: [],
          totalCount: 0,
          hasNext: false,
          hasPrevious: false,
        );
      }

      final data = _extractData(response);
      if (data == null) {
        print('[CommentService] No data field in response, returning empty result');
        return CommentPagedResult(
          comments: [],
          totalCount: 0,
          hasNext: false,
          hasPrevious: false,
        );
      }

      print('[CommentService] Data structure: $data');

      final result = CommentPagedResult.fromJson(data);
      print('[CommentService] Parsed ${result.comments.length} comments for user $userId');
      return result;
    } catch (e, s) {
      print('[CommentService] Error loading comments for user $userId: $e');
      print('[CommentService] Stack trace: $s');
      throw Exception('Failed to load comments: $e');
    }
  }
}

