import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../models/bai_thuoc.dart';
import 'api_config.dart';

/// Service for BaiThuoc (Medical Articles) API operations
class BaiThuocService {
  final Dio _dio;

  BaiThuocService({Dio? dio}) : _dio = dio ?? _createDio();

  static Dio _createDio() {
    final dio = Dio();
    dio.options.connectTimeout = ApiConfig.connectionTimeout;
    dio.options.receiveTimeout = ApiConfig.receiveTimeout;
    dio.options.validateStatus = (status) {
      return status != null && status < 500;
    };
    return dio;
  }

  /// Get list of BaiThuoc with pagination
  /// 
  /// Parameters:
  /// - [page]: Page number (default: 1)
  /// - [pageSize]: Items per page (default: 10, max: 50)
  /// 
  /// Returns list of [BaiThuoc]
  Future<List<BaiThuoc>> getBaiThuocList({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      developer.log(
        'Fetching BaiThuoc list (page: $page, size: $pageSize)',
        name: 'BaiThuocService',
      );

      final url = '${ApiConfig.baseUrl}${ApiConfig.baiThuoc}';
      developer.log('Request URL: $url', name: 'BaiThuocService');

      final response = await _dio.get(
        url,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      developer.log(
        'Response status: ${response.statusCode}',
        name: 'BaiThuocService',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        developer.log(
          'Response type: ${responseData.runtimeType}',
          name: 'BaiThuocService',
        );
        
        // Parse response with multiple format support
        List<BaiThuoc> items = [];
        
        if (responseData is Map<String, dynamic>) {
          // Case 1: { "success": true, "message": "...", "data": [...] }
          if (responseData.containsKey('data')) {
            final data = responseData['data'];
            
            if (data is List) {
              developer.log(
                'Parsed from data field: ${data.length} items',
                name: 'BaiThuocService',
              );
              items = data
                  .map((json) => BaiThuoc.fromJson(json as Map<String, dynamic>))
                  .toList();
            } else if (data is Map<String, dynamic>) {
              // Check if it has 'items' or 'list' nested field
              final itemsList = data['items'] ?? data['list'] ?? data['result'];
              if (itemsList is List) {
                items = itemsList
                    .map((json) =>
                        BaiThuoc.fromJson(json as Map<String, dynamic>))
                    .toList();
              } else {
                // Treat the data object itself as a single item
                items = [BaiThuoc.fromJson(data)];
              }
            }
          } else {
            // Case 2: Response is directly a Map (treat as single item)
            developer.log(
              'Response is Map without data field, treating as single item',
              name: 'BaiThuocService',
            );
            items = [BaiThuoc.fromJson(responseData)];
          }
        } else if (responseData is List) {
          // Case 3: Direct array response
          developer.log(
            'Response is direct array: ${responseData.length} items',
            name: 'BaiThuocService',
          );
          items = responseData
              .map((json) => BaiThuoc.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        developer.log(
          'Successfully loaded ${items.length} items',
          name: 'BaiThuocService',
        );
        return items;
      } else {
        final errorMsg =
            'Server error: ${response.statusCode} - ${response.statusMessage}';
        developer.log(
          errorMsg,
          name: 'BaiThuocService',
          level: 1000,
        );
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      final errorMsg =
          'DioException [${e.type.toString().split('.').last}]: ${e.message}';
      developer.log(
        errorMsg,
        name: 'BaiThuocService',
        error: e,
        level: 1000,
      );
      throw Exception(errorMsg);
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error: $e',
        name: 'BaiThuocService',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
      throw Exception('Failed to fetch BaiThuoc list: $e');
    }
  }

  /// Get BaiThuoc detail by ID
  /// 
  /// Note: This will increment the view count
  /// 
  /// Parameters:
  /// - [id]: BaiThuoc ID
  /// 
  /// Returns [BaiThuoc] detail
  Future<BaiThuoc> getBaiThuocDetail(String id) async {
    try {
      developer.log(
        'Fetching BaiThuoc detail: $id',
        name: 'BaiThuocService',
      );

      final url = '${ApiConfig.baseUrl}${ApiConfig.baiThuoc}/$id';
      developer.log('Request URL: $url', name: 'BaiThuocService');

      final response = await _dio.get(url);

      developer.log(
        'Response status: ${response.statusCode}',
        name: 'BaiThuocService',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            return BaiThuoc.fromJson(
                responseData['data'] as Map<String, dynamic>);
          }
          return BaiThuoc.fromJson(responseData);
        }

        throw Exception('Unexpected response format');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      developer.log(
        'DioException: ${e.message}',
        name: 'BaiThuocService',
        error: e,
        level: 1000,
      );
      throw Exception('Failed to fetch BaiThuoc detail: ${e.message}');
    } catch (e) {
      developer.log(
        'Error: $e',
        name: 'BaiThuocService',
        error: e,
        level: 1000,
      );
      throw Exception('Failed to fetch BaiThuoc detail: $e');
    }
  }

  /// Create new BaiThuoc (requires authentication)
  /// 
  /// Parameters:
  /// - [ten]: Title (required, max 500 characters)
  /// - [moTa]: Description (optional, max 5000 characters)
  /// - [huongDanSuDung]: Usage guide (optional, max 5000 characters)
  /// - [imagePath]: Image file path (optional, max 5MB)
  /// 
  /// Returns created [BaiThuoc]
  Future<BaiThuoc> createBaiThuoc({
    required String ten,
    String? moTa,
    String? huongDanSuDung,
    String? imagePath,
  }) async {
    try {
      developer.log(
        'Creating BaiThuoc: $ten',
        name: 'BaiThuocService',
      );

      final formData = FormData.fromMap({
        'ten': ten,
        if (moTa != null) 'moTa': moTa,
        if (huongDanSuDung != null) 'huongDanSuDung': huongDanSuDung,
        if (imagePath != null)
          'image': await MultipartFile.fromFile(imagePath),
      });

      final url = '${ApiConfig.baseUrl}${ApiConfig.baiThuoc}/create';
      developer.log('Request URL: $url', name: 'BaiThuocService');

      final response = await _dio.post(url, data: formData);

      developer.log(
        'Response status: ${response.statusCode}',
        name: 'BaiThuocService',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            return BaiThuoc.fromJson(
                responseData['data'] as Map<String, dynamic>);
          }
          return BaiThuoc.fromJson(responseData);
        }

        throw Exception('Unexpected response format');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      developer.log(
        'DioException: ${e.message}',
        name: 'BaiThuocService',
        error: e,
        level: 1000,
      );
      throw Exception('Failed to create BaiThuoc: ${e.message}');
    } catch (e) {
      developer.log(
        'Error: $e',
        name: 'BaiThuocService',
        error: e,
        level: 1000,
      );
      throw Exception('Failed to create BaiThuoc: $e');
    }
  }
}

