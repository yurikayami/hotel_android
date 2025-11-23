import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/mon_an.dart';
import 'api_config.dart';

/// Service để quản lý các món ăn (dishes)
class MonAnService {
  final Dio _dio;

  MonAnService({Dio? dio}) : _dio = dio ?? Dio();

  /// Lấy danh sách tất cả món ăn
  Future<List<MonAn>> getMonAnList() async {
    try {
      final response = await _dio.get('${ApiConfig.baseUrl}${ApiConfig.monAn}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (kDebugMode) {
          print('[MonAnService] API Response: $data');
        }

        // Xử lý nhiều format response
        List<dynamic> monAnList = [];

        if (data is Map<String, dynamic>) {
          // Format 1: { data: [...] }
          if (data['data'] != null && data['data'] is List) {
            monAnList = data['data'] as List<dynamic>;
          }
          // Format 2: { data: { monAn: [...] } }
          else if (data['data'] is Map<String, dynamic>) {
            final dataMap = data['data'] as Map<String, dynamic>;
            if (dataMap['monAn'] != null && dataMap['monAn'] is List) {
              monAnList = dataMap['monAn'] as List<dynamic>;
            }
          }
        } else if (data is List) {
          // Format 3: direct array
          monAnList = data;
        }

        if (kDebugMode) {
          print('[MonAnService] Parsed ${monAnList.length} dishes');
        }

        return monAnList
            .map((item) => MonAn.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('[MonAnService] DioException: ${e.type}');
        print('[MonAnService] Message: ${e.message}');
        print('[MonAnService] Response: ${e.response?.data}');
      }
      throw _handleDioException(e);
    } catch (e) {
      if (kDebugMode) {
        print('[MonAnService] Exception: $e');
      }
      rethrow;
    }
  }

  /// Lấy chi tiết một món ăn theo ID
  Future<MonAn> getMonAnDetail(String id) async {
    try {
      final response =
          await _dio.get('${ApiConfig.baseUrl}${ApiConfig.monAn}/$id');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle wrapped response
        Map<String, dynamic> monAnData = data is Map<String, dynamic> 
            ? (data['data'] ?? data) 
            : data;

        return MonAn.fromJson(monAnData);
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Lọc món ăn theo loại
  Future<List<MonAn>> getMonAnByLoai(String loai) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}${ApiConfig.monAn}',
        queryParameters: {'loai': loai},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> monAnList = [];

        if (data is Map<String, dynamic>) {
          if (data['data'] != null && data['data'] is List) {
            monAnList = data['data'] as List<dynamic>;
          } else if (data['data'] is Map<String, dynamic>) {
            final dataMap = data['data'] as Map<String, dynamic>;
            if (dataMap['monAn'] != null && dataMap['monAn'] is List) {
              monAnList = dataMap['monAn'] as List<dynamic>;
            }
          }
        } else if (data is List) {
          monAnList = data;
        }

        return monAnList
            .map((item) => MonAn.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Xử lý DioException
  String _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Kết nối hết thời gian';
      case DioExceptionType.receiveTimeout:
        return 'Nhận dữ liệu hết thời gian';
      case DioExceptionType.sendTimeout:
        return 'Gửi dữ liệu hết thời gian';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          return 'Không tìm thấy dữ liệu';
        } else if (statusCode == 500) {
          return 'Lỗi máy chủ';
        }
        return 'Lỗi HTTP $statusCode';
      case DioExceptionType.cancel:
        return 'Yêu cầu bị hủy';
      case DioExceptionType.unknown:
        return 'Lỗi kết nối: ${e.message}';
      default:
        return 'Lỗi không xác định';
    }
  }
}

