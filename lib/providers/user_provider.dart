import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/comment_service.dart';
import '../services/post_service.dart';

/// Provider for managing user profile state
class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final CommentService _commentService = CommentService();
  final PostService _postService = PostService();

  // State - Posts
  User? _selectedUser;
  List<Post> _userPosts = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentOffset = 0;
  bool _hasMore = true;
  final int _limit = 100;
  String? _currentUserId;

  // State - Comments
  List<Comment> _userComments = [];
  int _commentsOffset = 0;
  bool _commentsHasMore = true;
  bool _commentsLoading = false;

  // State - Media (posts with images)
  List<Post> _userMedia = [];

  // State - Liked Posts
  List<Post> _likedPosts = [];
  int _likedOffset = 0;
  bool _likedHasMore = true;
  bool _likedLoading = false;

  // Getters - Posts
  User? get selectedUser => _selectedUser;
  List<Post> get userPosts => _userPosts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  // Getters - Comments
  List<Comment> get userComments => _userComments;
  bool get commentsLoading => _commentsLoading;
  bool get commentsHasMore => _commentsHasMore;

  // Getters - Media
  List<Post> get userMedia => _userMedia;

  // Getters - Liked Posts
  List<Post> get likedPosts => _likedPosts;
  bool get likedLoading => _likedLoading;
  bool get likedHasMore => _likedHasMore;

  /// Load user profile and their posts
  /// 
  /// [userId] - The ID of the user to load
  /// [refresh] - If true, reset pagination and reload from offset 0
  Future<void> loadUserProfile(String userId, {bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    // Reset if loading a different user or refreshing
    if (userId != _currentUserId || refresh) {
      _currentOffset = 0;
      _hasMore = true;
      _userPosts.clear();
      _currentUserId = userId;
      _selectedUser = null;
    }

    // Don't load if no more posts and not refreshing
    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // For now, we'll create a basic User object from the posts response
      // In a real app, you might have a dedicated endpoint to get user details
      final result = await _userService.getUserPublicPosts(
        userId: userId,
        offset: _currentOffset,
        limit: _limit,
      );

      if (refresh) {
        _userPosts = result.posts;
      } else {
        _userPosts.addAll(result.posts);
      }

      _currentOffset += result.posts.length;
      _hasMore = result.hasNext;
      
      print('[UserProvider] Loaded ${result.posts.length} posts, offset now: $_currentOffset, hasMore: $_hasMore');

      // Update media posts after loading posts
      updateMediaPosts();

      // Extract user info from the first post (if available)
      if (result.posts.isNotEmpty && _selectedUser == null) {
        final firstPost = result.posts.first;
        _selectedUser = User(
          id: firstPost.authorId,
          userName: firstPost.authorName,
          email: '',
          displayName: firstPost.authorName,
          avatarUrl: firstPost.authorAvatar,
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, s) {
      print('[UserProvider] Error loading user profile: $e');
      print('[UserProvider] Stack trace: $s');
      _errorMessage = 'Failed to load user profile: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more posts for the current user
  Future<void> loadMoreUserPosts(String userId) async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _userService.getUserPublicPosts(
        userId: userId,
        offset: _currentOffset,
        limit: _limit,
      );

      _userPosts.addAll(result.posts);
      _currentOffset += result.posts.length;
      _hasMore = result.hasNext;

      // Update media posts after loading more posts
      updateMediaPosts();

      _isLoading = false;
      notifyListeners();
    } catch (e, s) {
      print('[UserProvider] Error loading more posts: $e');
      print('[UserProvider] Stack trace: $s');
      _errorMessage = 'Failed to load more posts: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear the selected user profile
  void clearUserProfile() {
    _selectedUser = null;
    _userPosts.clear();
    _currentOffset = 0;
    _hasMore = true;
    _errorMessage = null;
    _currentUserId = null;
    _userComments.clear();
    _commentsOffset = 0;
    _commentsHasMore = true;
    _userMedia.clear();
    notifyListeners();
  }

  /// Load comments for the current user
  Future<void> loadUserComments(String userId, {bool refresh = false}) async {
    print('[UserProvider] loadUserComments called for userId=$userId, refresh=$refresh');
    print('[UserProvider] Current state - Loading: $_commentsLoading, HasMore: $_commentsHasMore, Comments: ${_userComments.length}');
    
    if (_commentsLoading && !refresh) {
      print('[UserProvider] Already loading comments and refresh=false, returning early');
      return;
    }

    if (refresh) {
      print('[UserProvider] Refresh=true, clearing offset and comments');
      _commentsOffset = 0;
      _commentsHasMore = true;
      _userComments.clear();
    }

    if (!_commentsHasMore && !refresh) {
      print('[UserProvider] No more comments to load');
      return;
    }

    _commentsLoading = true;
    print('[UserProvider] Starting to load comments...');
    notifyListeners();

    try {
      print('[UserProvider] Calling API for comments...');
      final result = await _commentService.getPublicUserComments(
        userId: userId,
        offset: _commentsOffset,
        limit: 100,
      );

      print('[UserProvider] API returned ${result.comments.length} comments');
      _userComments.addAll(result.comments);
      _commentsOffset += result.comments.length;
      _commentsHasMore = result.hasNext;

      print('[UserProvider] Total comments now: ${_userComments.length}, HasMore: $_commentsHasMore');

      _commentsLoading = false;
      notifyListeners();
    } catch (e) {
      print('[UserProvider] Error loading comments: $e');
      _commentsLoading = false;
      notifyListeners();
    }
  }

  /// Filter posts to get only those with media (loai == 'image')
  void updateMediaPosts() {
    print('[UserProvider] updateMediaPosts() called');
    print('[UserProvider] Total posts: ${_userPosts.length}');
    
    for (var i = 0; i < _userPosts.length; i++) {
      final post = _userPosts[i];
      print('[UserProvider] Post $i: loai=${post.loai}, duongDanMedia=${post.duongDanMedia}');
    }
    
    _userMedia = _userPosts
        .where((post) => post.loai == 'image' && post.duongDanMedia != null && post.duongDanMedia!.isNotEmpty)
        .toList();
    
    print('[UserProvider] Filtered media posts: ${_userMedia.length}');
    notifyListeners();
  }

  /// Clear all user data when switching to a different user
  void clearUserData() {
    print('[UserProvider] ===== clearUserData() START =====');
    print('[UserProvider] BEFORE clear - Comments: ${_userComments.length}, Posts: ${_userPosts.length}, Media: ${_userMedia.length}, Liked: ${_likedPosts.length}');
    
    // Reset all state variables
    _selectedUser = null;
    _userPosts = [];
    _userMedia = [];
    _userComments = [];
    _likedPosts = [];
    
    // Reset pagination
    _currentOffset = 0;
    _commentsOffset = 0;
    _likedOffset = 0;
    _hasMore = true;
    _commentsHasMore = true;  // MUST reset to true for new user
    _likedHasMore = true;
    
    // Reset loading states
    _isLoading = false;
    _commentsLoading = false;
    _likedLoading = false;
    
    // Clear errors
    _errorMessage = null;
    _currentUserId = null;
    
    print('[UserProvider] AFTER clear - Comments: ${_userComments.length}, Posts: ${_userPosts.length}, Media: ${_userMedia.length}, Liked: ${_likedPosts.length}');
    print('[UserProvider] ===== clearUserData() END - notifyListeners() =====');
    notifyListeners();
  }

  /// Load liked posts for the current user
  Future<void> loadLikedPosts({bool refresh = false}) async {
    print('[UserProvider] loadLikedPosts called, refresh=$refresh');
    print('[UserProvider] Current state - Loading: $_likedLoading, HasMore: $_likedHasMore, Posts: ${_likedPosts.length}');
    
    if (_likedLoading && !refresh) {
      print('[UserProvider] Already loading liked posts and refresh=false, returning early');
      return;
    }

    if (refresh) {
      print('[UserProvider] Refresh=true, clearing offset and liked posts');
      _likedOffset = 0;
      _likedHasMore = true;
      _likedPosts.clear();
    }

    if (!_likedHasMore && !refresh) {
      print('[UserProvider] No more liked posts to load');
      return;
    }

    _likedLoading = true;
    print('[UserProvider] Starting to load liked posts...');
    notifyListeners();

    try {
      print('[UserProvider] Calling API for liked posts with offset=$_likedOffset');
      final result = await _postService.getUserLikedPosts(
        offset: _likedOffset,
        limit: 10,
      );

      final posts = result['posts'] as List<Post>;
      final hasMore = result['hasMore'] as bool;

      print('[UserProvider] API returned ${posts.length} liked posts, hasMore=$hasMore');
      
      _likedPosts.addAll(posts);
      _likedOffset += posts.length;
      _likedHasMore = hasMore;

      print('[UserProvider] Total liked posts now: ${_likedPosts.length}, HasMore: $_likedHasMore');

      _likedLoading = false;
      notifyListeners();
    } catch (e) {
      print('[UserProvider] Error loading liked posts: $e');
      _likedLoading = false;
      notifyListeners();
    }
  }

  /// Load more liked posts
  Future<void> loadMoreLikedPosts() async {
    if (_likedLoading || !_likedHasMore) return;
    await loadLikedPosts(refresh: false);
  }

  /// Remove a post from liked posts (for unlike action)
  void removeLikedPost(String postId) {
    _likedPosts.removeWhere((post) => post.id == postId);
    notifyListeners();
  }

  /// Add a post back to liked posts (for undo action)
  void addLikedPost(Post post) {
    _likedPosts.insert(0, post);
    notifyListeners();
  }
}
