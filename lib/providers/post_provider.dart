import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../services/post_service.dart';

/// Provider for managing posts state
class PostProvider extends ChangeNotifier {
  final PostService _postService = PostService();

  // State
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  final int _pageSize = 10;

  // Getters
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  /// Load posts with pagination
  Future<void> loadPosts({bool refresh = false}) async {
    if (_isLoading) return;

    // If refresh, reset pagination
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _posts.clear();
    }

    // Don't load if no more posts
    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _postService.getPosts(
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (refresh) {
        _posts = result.posts;
      } else {
        _posts.addAll(result.posts);
      }

      // Update pagination
      _currentPage++;
      _hasMore = result.posts.length >= _pageSize;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new post
  Future<void> createPost({
    required String noiDung,
    List<File>? hinhAnh,
    String? duongDanMedia,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newPost = await _postService.createPost(
        noiDung: noiDung,
        hinhAnh: hinhAnh,
        duongDanMedia: duongDanMedia,
      );

      // Add to top of list
      _posts.insert(0, newPost);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Like or unlike a post
  Future<void> likePost(String postId) async {
    try {
      print('[PostProvider] Calling likePost for: $postId');
      
      // First, find the post in list and get current state
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index == -1) {
        print('[PostProvider] WARNING: Post not found in list with id: $postId');
        throw Exception('Post not found in cache');
      }
      
      final currentPost = _posts[index];
      print('[PostProvider] Current post isLiked: ${currentPost.isLiked}, likes: ${currentPost.luotThich}');
      
      // Call the like API - returns {isLiked: bool, likeCount: int}
      final likeData = await _postService.likePost(postId);
      print('[PostProvider] API returned like data: $likeData');
      
      // Create updated post with new like status
      final updatedPost = Post(
        id: currentPost.id,
        noiDung: currentPost.noiDung,
        loai: currentPost.loai,
        duongDanMedia: currentPost.duongDanMedia,
        ngayDang: currentPost.ngayDang,
        luotThich: likeData['likeCount'],
        soBinhLuan: currentPost.soBinhLuan,
        soChiaSe: currentPost.soChiaSe,
        isLiked: likeData['isLiked'],
        hashtags: currentPost.hashtags,
        authorId: currentPost.authorId,
        authorName: currentPost.authorName,
        authorAvatar: currentPost.authorAvatar,
      );
      
      // Update the post in list
      _posts[index] = updatedPost;
      print('[PostProvider] Post updated at index $index, new isLiked: ${updatedPost.isLiked}, new likes: ${updatedPost.luotThich}');
      notifyListeners();
      
    } catch (e) {
      print('[PostProvider] Error in likePost: $e');
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    try {
      await _postService.deletePost(postId);

      // Remove from list
      _posts.removeWhere((p) => p.id == postId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Add comment to a post
  Future<void> addComment({
    required String postId,
    required String noiDung,
  }) async {
    try {
      await _postService.addComment(
        postId: postId,
        noiDung: noiDung,
      );

      // Increment comment count in post
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _posts[index];
        _posts[index] = Post(
          id: post.id,
          noiDung: post.noiDung,
          loai: post.loai,
          duongDanMedia: post.duongDanMedia,
          ngayDang: post.ngayDang,
          luotThich: post.luotThich,
          soBinhLuan: (post.soBinhLuan ?? 0) + 1,
          soChiaSe: post.soChiaSe,
          isLiked: post.isLiked,
          hashtags: post.hashtags,
          authorId: post.authorId,
          authorName: post.authorName,
          authorAvatar: post.authorAvatar,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Get comments for a post
  Future<List<dynamic>> getComments(String postId) async {
    try {
      return await _postService.getComments(postId: postId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Search posts
  Future<void> searchPosts(String keyword) async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    notifyListeners();

    try {
      final result = await _postService.searchPosts(
        keyword: keyword,
        page: 1,
        pageSize: _pageSize,
      );

      _posts = result.posts;
      _hasMore = result.posts.length >= _pageSize;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Update a post's like status
  void updatePostLikeStatus(String postId, bool isLiked) {
    try {
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _posts[index];
        _posts[index] = Post(
          id: post.id,
          noiDung: post.noiDung,
          loai: post.loai,
          duongDanMedia: post.duongDanMedia,
          ngayDang: post.ngayDang,
          luotThich: post.luotThich,
          soBinhLuan: post.soBinhLuan,
          soChiaSe: post.soChiaSe,
          isLiked: isLiked,
          hashtags: post.hashtags,
          authorId: post.authorId,
          authorName: post.authorName,
          authorAvatar: post.authorAvatar,
        );
        print('[PostProvider] Updated post $postId like status to $isLiked');
        notifyListeners();
      }
    } catch (e) {
      print('[PostProvider] Error updating post like status: $e');
    }
  }

  /// Reset state
  void reset() {
    _posts = [];
    _currentPage = 1;
    _hasMore = true;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}

