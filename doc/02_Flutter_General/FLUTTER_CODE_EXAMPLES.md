# FLUTTER CODE EXAMPLES

## 📱 Mẫu code Flutter để tích hợp với Hotel Web API

---

## 1️⃣ SETUP & CONFIGURATION

### pubspec.yaml
```yaml
name: hotel_web_flutter
description: Flutter app for Hotel Web API

dependencies:
  flutter:
    sdk: flutter
  
  # HTTP & Network
  http: ^1.1.0
  dio: ^5.4.0  # Alternative to http
  
  # State Management
  provider: ^6.1.1
  # or
  flutter_riverpod: ^2.4.9
  # or
  get: ^4.6.6
  
  # Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # Image
  image_picker: ^1.0.4
  cached_network_image: ^3.3.0
  
  # UI
  flutter_spinkit: ^5.2.0
  intl: ^0.18.1
  
  # JSON
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
```

---

## 2️⃣ MODELS (Data Classes)

### lib/models/user.dart
```dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String userName;
  final String email;
  final int? age;
  final String? gender;
  final String? profilePicture;
  final String? displayName;

  User({
    required this.id,
    required this.userName,
    required this.email,
    this.age,
    this.gender,
    this.profilePicture,
    this.displayName,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final User? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => 
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
```

### lib/models/post.dart
```dart
import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  final String id;
  final String noiDung;
  final String? loai;
  final String? duongDanMedia;
  final DateTime? ngayDang;
  final int? luotThich;
  final int? soBinhLuan;
  final int soChiaSe;
  final bool isLiked;
  final String? hashtags;
  final String authorId;
  final String authorName;
  final String? authorAvatar;

  Post({
    required this.id,
    required this.noiDung,
    this.loai,
    this.duongDanMedia,
    this.ngayDang,
    this.luotThich,
    this.soBinhLuan,
    required this.soChiaSe,
    required this.isLiked,
    this.hashtags,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}

@JsonSerializable()
class PostPagedResult {
  final List<Post> posts;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasPrevious;
  final bool hasNext;

  PostPagedResult({
    required this.posts,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasPrevious,
    required this.hasNext,
  });

  factory PostPagedResult.fromJson(Map<String, dynamic> json) => 
      _$PostPagedResultFromJson(json);
}
```

### lib/models/comment.dart
```dart
import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  final String id;
  final String noiDung;
  final DateTime ngayTao;
  final String? parentCommentId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.noiDung,
    required this.ngayTao,
    this.parentCommentId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
```

### lib/models/prediction_history.dart
```dart
import 'package:json_annotation/json_annotation.dart';

part 'prediction_history.g.dart';

@JsonSerializable()
class PredictionHistory {
  final int id;
  final String userId;
  final String imagePath;
  final String foodName;
  final double confidence;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final String? mealType;
  final String? advice;
  final DateTime createdAt;
  final List<PredictionDetail> details;

  PredictionHistory({
    required this.id,
    required this.userId,
    required this.imagePath,
    required this.foodName,
    required this.confidence,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.mealType,
    this.advice,
    required this.createdAt,
    required this.details,
  });

  factory PredictionHistory.fromJson(Map<String, dynamic> json) => 
      _$PredictionHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$PredictionHistoryToJson(this);
}

@JsonSerializable()
class PredictionDetail {
  final String label;
  final double weight;
  final double confidence;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  PredictionDetail({
    required this.label,
    required this.weight,
    required this.confidence,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  factory PredictionDetail.fromJson(Map<String, dynamic> json) => 
      _$PredictionDetailFromJson(json);
  Map<String, dynamic> toJson() => _$PredictionDetailToJson(this);
}
```

---

## 3️⃣ API SERVICE

### lib/services/api_config.dart
```dart
class ApiConfig {
  static const String baseUrl = 'https://localhost:7135/api';
  
  // Endpoints
  static const String auth = '/Auth';
  static const String posts = '/Post';
  static const String foodAnalysis = '/FoodAnalysis';
  static const String monAn = '/MonAn';
  static const String baiThuoc = '/BaiThuoc';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
```

### lib/services/api_service.dart
```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _storage = const FlutterSecureStorage();
  String? _token;

  // Initialize token from storage
  Future<void> init() async {
    _token = await _storage.read(key: 'jwt_token');
  }

  // Save token
  Future<void> setToken(String token) async {
    _token = token;
    await _storage.write(key: 'jwt_token', value: token);
  }

  // Clear token
  Future<void> clearToken() async {
    _token = null;
    await _storage.delete(key: 'jwt_token');
  }

  // Get headers
  Map<String, String> _getHeaders({bool needsAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (needsAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  // Handle HTTP errors
  void _handleError(http.Response response) {
    if (response.statusCode == 401) {
      throw Exception('Unauthorized - Please login again');
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Client error');
    } else if (response.statusCode >= 500) {
      throw Exception('Server error - Please try again later');
    }
  }

  // GET request
  Future<dynamic> get(
    String endpoint, {
    bool needsAuth = false,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint')
          .replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: _getHeaders(needsAuth: needsAuth),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<dynamic> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool needsAuth = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: _getHeaders(needsAuth: needsAuth),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<dynamic> delete(
    String endpoint, {
    bool needsAuth = true,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: _getHeaders(needsAuth: needsAuth),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        }
        return {'success': true};
      } else {
        _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Upload file with multipart
  Future<dynamic> uploadFile(
    String endpoint, {
    required File file,
    required Map<String, String> fields,
    bool needsAuth = false,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      );

      // Add headers
      if (needsAuth && _token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('image', file.path),
      );

      // Add fields
      request.fields.addAll(fields);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }
}
```

---

## 4️⃣ AUTHENTICATION SERVICE

### lib/services/auth_service.dart
```dart
import '../models/user.dart';
import 'api_service.dart';
import 'api_config.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Register
  Future<AuthResponse> register({
    required String userName,
    required String email,
    required String password,
    required String confirmPassword,
    int? age,
    String? gender,
  }) async {
    final response = await _apiService.post(
      '${ApiConfig.auth}/register',
      body: {
        'userName': userName,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
      },
    );

    final authResponse = AuthResponse.fromJson(response);
    
    if (authResponse.success && authResponse.token != null) {
      await _apiService.setToken(authResponse.token!);
    }

    return authResponse;
  }

  // Login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      '${ApiConfig.auth}/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    final authResponse = AuthResponse.fromJson(response);
    
    if (authResponse.success && authResponse.token != null) {
      await _apiService.setToken(authResponse.token!);
    }

    return authResponse;
  }

  // Logout
  Future<void> logout() async {
    await _apiService.post(
      '${ApiConfig.auth}/logout',
      body: {},
      needsAuth: true,
    );
    
    await _apiService.clearToken();
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    await _apiService.init();
    return _apiService._token != null;
  }
}
```

---

## 5️⃣ POST SERVICE

### lib/services/post_service.dart
```dart
import '../models/post.dart';
import '../models/comment.dart';
import 'api_service.dart';
import 'api_config.dart';

class PostService {
  final ApiService _apiService = ApiService();

  // Get posts with pagination
  Future<PostPagedResult> getPosts({
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _apiService.get(
      ApiConfig.posts,
      queryParams: {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    return PostPagedResult.fromJson(response['data']);
  }

  // Get post detail
  Future<Post> getPost(String id) async {
    final response = await _apiService.get(
      '${ApiConfig.posts}/$id',
    );

    return Post.fromJson(response['data']);
  }

  // Create post
  Future<Post> createPost({
    required String noiDung,
    String? loai,
    String? duongDanMedia,
    String? monAnId,
    String? hashtags,
  }) async {
    final response = await _apiService.post(
      ApiConfig.posts,
      needsAuth: true,
      body: {
        'noiDung': noiDung,
        if (loai != null) 'loai': loai,
        if (duongDanMedia != null) 'duongDanMedia': duongDanMedia,
        if (monAnId != null) 'monAnId': monAnId,
        if (hashtags != null) 'hashtags': hashtags,
      },
    );

    return Post.fromJson(response['data']);
  }

  // Like/Unlike post
  Future<Map<String, dynamic>> likePost(String postId) async {
    final response = await _apiService.post(
      '${ApiConfig.posts}/$postId/like',
      needsAuth: true,
      body: {},
    );

    return response['data'];
  }

  // Get comments
  Future<List<Comment>> getComments(String postId) async {
    final response = await _apiService.get(
      '${ApiConfig.posts}/$postId/comments',
    );

    final List<dynamic> data = response['data'];
    return data.map((json) => Comment.fromJson(json)).toList();
  }

  // Add comment
  Future<Comment> addComment({
    required String postId,
    required String noiDung,
    String? parentCommentId,
  }) async {
    final response = await _apiService.post(
      '${ApiConfig.posts}/$postId/comments',
      needsAuth: true,
      body: {
        'noiDung': noiDung,
        if (parentCommentId != null) 'parentCommentId': parentCommentId,
      },
    );

    return Comment.fromJson(response['data']);
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    await _apiService.delete(
      '${ApiConfig.posts}/$postId',
      needsAuth: true,
    );
  }
}
```

---

## 6️⃣ FOOD ANALYSIS SERVICE

### lib/services/food_analysis_service.dart
```dart
import 'dart:io';
import '../models/prediction_history.dart';
import 'api_service.dart';
import 'api_config.dart';

class FoodAnalysisService {
  final ApiService _apiService = ApiService();

  // Analyze food image
  Future<PredictionHistory> analyzeFood({
    required File image,
    required String userId,
    String? mealType,
  }) async {
    final response = await _apiService.uploadFile(
      '${ApiConfig.foodAnalysis}/analyze',
      file: image,
      fields: {
        'userId': userId,
        if (mealType != null) 'mealType': mealType,
      },
    );

    return PredictionHistory.fromJson(response);
  }

  // Get history
  Future<List<PredictionHistory>> getHistory(String userId) async {
    final response = await _apiService.get(
      '${ApiConfig.foodAnalysis}/history/$userId',
    );

    final List<dynamic> data = response;
    return data.map((json) => PredictionHistory.fromJson(json)).toList();
  }

  // Delete history item
  Future<void> deleteHistory(int id) async {
    await _apiService.delete(
      '${ApiConfig.foodAnalysis}/history/$id',
    );
  }
}
```

---

## 7️⃣ UI EXAMPLES

### lib/screens/login_screen.dart
```dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.success) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showError(response.message);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Đăng nhập'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

### lib/screens/post_list_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';
import '../services/post_service.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({Key? key}) : super(key: key);

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final _postService = PostService();
  final _scrollController = ScrollController();
  
  List<Post> _posts = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadPosts() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final result = await _postService.getPosts(
        page: _currentPage,
        pageSize: 10,
      );

      setState(() {
        _posts.addAll(result.posts);
        _currentPage++;
        _hasMore = result.hasNext;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadPosts();
    }
  }

  Future<void> _likePost(Post post, int index) async {
    try {
      final result = await _postService.likePost(post.id);
      
      setState(() {
        _posts[index] = Post(
          id: post.id,
          noiDung: post.noiDung,
          loai: post.loai,
          duongDanMedia: post.duongDanMedia,
          ngayDang: post.ngayDang,
          luotThich: result['likeCount'],
          soBinhLuan: post.soBinhLuan,
          soChiaSe: post.soChiaSe,
          isLiked: result['isLiked'],
          hashtags: post.hashtags,
          authorId: post.authorId,
          authorName: post.authorName,
          authorAvatar: post.authorAvatar,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bài viết')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _posts.clear();
            _currentPage = 1;
            _hasMore = true;
          });
          await _loadPosts();
        },
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _posts.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _posts.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final post = _posts[index];
            return PostCard(
              post: post,
              onLike: () => _likePost(post, index),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;

  const PostCard({
    Key? key,
    required this.post,
    required this.onLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post.authorAvatar != null
                  ? CachedNetworkImageProvider(post.authorAvatar!)
                  : null,
              child: post.authorAvatar == null
                  ? Text(post.authorName[0].toUpperCase())
                  : null,
            ),
            title: Text(post.authorName),
            subtitle: Text(
              post.ngayDang?.toString() ?? '',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(post.noiDung),
          ),
          
          // Image
          if (post.duongDanMedia != null)
            CachedNetworkImage(
              imageUrl: post.duongDanMedia!,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          
          // Actions
          Row(
            children: [
              IconButton(
                icon: Icon(
                  post.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: post.isLiked ? Colors.red : null,
                ),
                onPressed: onLike,
              ),
              Text('${post.luotThich ?? 0}'),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.comment),
                onPressed: () {
                  // Navigate to comments
                },
              ),
              Text('${post.soBinhLuan ?? 0}'),
            ],
          ),
        ],
      ),
    );
  }
}
```

### lib/screens/food_analysis_screen.dart
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/food_analysis_service.dart';
import '../models/prediction_history.dart';

class FoodAnalysisScreen extends StatefulWidget {
  final String userId;

  const FoodAnalysisScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<FoodAnalysisScreen> createState() => _FoodAnalysisScreenState();
}

class _FoodAnalysisScreenState extends State<FoodAnalysisScreen> {
  final _foodAnalysisService = FoodAnalysisService();
  final _imagePicker = ImagePicker();
  
  File? _selectedImage;
  PredictionHistory? _result;
  bool _isAnalyzing = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _result = null;
        });
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() => _isAnalyzing = true);

    try {
      final result = await _foodAnalysisService.analyzeFood(
        image: _selectedImage!,
        userId: widget.userId,
        mealType: 'lunch',
      );

      setState(() => _result = result);
    } catch (e) {
      _showError('Error analyzing image: $e');
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phân tích món ăn')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image picker buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Chụp ảnh'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Thư viện'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Selected image
            if (_selectedImage != null) ...[
              Image.file(
                _selectedImage!,
                height: 300,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzeImage,
                child: _isAnalyzing
                    ? const CircularProgressIndicator()
                    : const Text('Phân tích'),
              ),
            ],
            
            // Result
            if (_result != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _result!.foodName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Độ tin cậy: ${(_result!.confidence * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Divider(height: 24),
                      _buildNutritionRow('Calories', _result!.calories),
                      _buildNutritionRow('Protein', _result!.protein),
                      _buildNutritionRow('Fat', _result!.fat),
                      _buildNutritionRow('Carbs', _result!.carbs),
                      if (_result!.advice != null) ...[
                        const Divider(height: 24),
                        Text(
                          'Lời khuyên:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(_result!.advice!),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '${value.toStringAsFixed(1)}${label == 'Calories' ? ' kcal' : ' g'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
```

---

## 8️⃣ GENERATE JSON SERIALIZATION

Run this command to generate `.g.dart` files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📝 NOTES

1. **SSL Certificate:** Trong development, cần bypass SSL certificate validation
2. **Error Handling:** Implement proper error handling và retry logic
3. **State Management:** Sử dụng Provider/Riverpod/Bloc để quản lý state tốt hơn
4. **Caching:** Implement caching cho images và data
5. **Offline Support:** Consider using local database (sqflite/hive)

---

**Last Updated:** November 9, 2025
