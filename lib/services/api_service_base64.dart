import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';

/// Base API service for handling HTTP requests with Base64 image support
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    // Configure HTTPS certificate handling for development
    _setupHttpClient();
  }

  final _storage = const FlutterSecureStorage();
  String? _token;

  /// Setup HttpClient with certificate bypass for development
  void _setupHttpClient() {
    HttpOverrides.global = _MyHttpOverrides();
  }

  /// Initialize token from storage
  Future<void> init() async {
    _token = await _storage.read(key: 'jwt_token');
  }

  /// Save authentication token
  Future<void> setToken(String token) async {
    _token = token;
    await _storage.write(key: 'jwt_token', value: token);
  }

  /// Clear authentication token
  Future<void> clearToken() async {
    _token = null;
    await _storage.delete(key: 'jwt_token');
  }

  /// Get HTTP headers
  Map<String, String> _getHeaders({bool needsAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (needsAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  /// Handle HTTP errors
  void _handleError(http.Response response) {
    if (response.statusCode == 401) {
      throw Exception('Unauthorized - Please login again');
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      try {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Client error');
      } catch (e) {
        throw Exception('Error: ${response.statusCode}');
      }
    } else if (response.statusCode >= 500) {
      throw Exception('Server error - Please try again later');
    }
  }

  /// GET request
  Future<dynamic> get(
    String endpoint, {
    bool needsAuth = false,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint')
          .replace(queryParameters: queryParams);

      final response = await http
          .get(
            uri,
            headers: _getHeaders(needsAuth: needsAuth),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        _handleError(response);
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// POST request with JSON body
  Future<dynamic> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool needsAuth = false,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: _getHeaders(needsAuth: needsAuth),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        _handleError(response);
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// DELETE request
  Future<dynamic> delete(
    String endpoint, {
    bool needsAuth = true,
  }) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: _getHeaders(needsAuth: needsAuth),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        }
        return {'success': true};
      } else {
        _handleError(response);
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Convert file to base64 string
  Future<String> fileToBase64(File file) async {
    try {
      print('[ApiService] Converting file to base64: ${file.path}');
      final bytes = await file.readAsBytes();
      print('[ApiService] File size: ${bytes.length} bytes');
      final base64String = base64Encode(bytes);
      print('[ApiService] Base64 encoded length: ${base64String.length}');
      return base64String;
    } catch (e) {
      print('[ApiService] Error converting file to base64: $e');
      throw Exception('Failed to convert image to base64: $e');
    }
  }

  /// Get file MIME type from extension
  String getFileMimeType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    final mimeTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'bmp': 'image/bmp',
    };
    return mimeTypes[extension] ?? 'image/jpeg';
  }
}

/// HttpOverrides for bypassing certificate validation in development
class _MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        print('[HttpOverrides] Certificate validation bypassed for $host:$port');
        return true; // Accept all certificates (development only)
      };
  }
}

