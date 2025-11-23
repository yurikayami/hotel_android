import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../models/prediction_history.dart';
import 'api_config.dart';

/// Service for food analysis API operations
class FoodAnalysisService {
  final Dio _dio;

  FoodAnalysisService({Dio? dio}) : _dio = dio ?? _createDio();

  static Dio _createDio() {
    final dio = Dio();
    dio.options.connectTimeout = ApiConfig.connectionTimeout;
    dio.options.receiveTimeout = ApiConfig.receiveTimeout;
    dio.options.validateStatus = (status) {
      return status != null && status < 500;
    };

    return dio;
  }

  /// Analyze food image
  ///
  /// Uploads an image and receives AI analysis with nutrition information
  ///
  /// Parameters:
  /// - [userId]: User's unique identifier
  /// - [imageFile]: Image file from camera or gallery
  /// - [mealType]: Optional meal type (breakfast, lunch, dinner, snack)
  ///
  /// Returns [PredictionHistory] with analysis results
  ///
  /// Throws [DioException] on network errors
  Future<PredictionHistory> analyzeFood({
    required String userId,
    required XFile imageFile,
    String mealType = 'lunch',
  }) async {
    try {
      developer.log(
        'Analyzing food image for user: $userId',
        name: 'FoodAnalysisService',
      );

      // Prepare multipart form data
      final formData = FormData.fromMap({
        'userId': userId,
        'mealType': mealType,
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.name,
        ),
      });

      // Send request
      final response = await _dio.post(
        '${ApiConfig.baseUrl}${ApiConfig.foodAnalysis}/analyze',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      developer.log(
        'Analysis response status: ${response.statusCode}',
        name: 'FoodAnalysisService',
      );

      if (response.statusCode == 200) {
        return PredictionHistory.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: response.data['message'] ?? 'Analysis failed',
        );
      }
    } on DioException catch (e) {
      developer.log(
        'Error analyzing food: ${e.message}',
        name: 'FoodAnalysisService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get analysis history for a user
  ///
  /// Retrieves list of past food analyses
  ///
  /// Parameters:
  /// - [userId]: User's unique identifier
  /// - [page]: Page number (default: 1)
  /// - [pageSize]: Items per page (default: 20)
  ///
  /// Returns list of [PredictionHistory]
  Future<List<PredictionHistory>> getHistory({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      developer.log(
        'Fetching history for user: $userId (page: $page)',
        name: 'FoodAnalysisService',
      );

      final response = await _dio.get(
        '${ApiConfig.baseUrl}${ApiConfig.foodAnalysis}/history/user/$userId',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => PredictionHistory.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch history',
        );
      }
    } on DioException catch (e) {
      developer.log(
        'Error fetching history: ${e.message}',
        name: 'FoodAnalysisService',
        error: e,
      );
      rethrow;
    }
  }

  /// Delete an analysis record
  ///
  /// Removes a specific analysis from history
  ///
  /// Parameters:
  /// - [id]: Analysis record ID
  Future<void> deleteAnalysis(int id) async {
    try {
      final url =
          '${ApiConfig.baseUrl}${ApiConfig.foodAnalysis}/prediction/$id';
      developer.log(
        'Deleting analysis: $id at URL: $url',
        name: 'FoodAnalysisService',
      );

      final response = await _dio.delete(url);

      developer.log(
        'Delete response status: ${response.statusCode}',
        name: 'FoodAnalysisService',
      );

      // API returns 200 with success response
      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to delete analysis',
        );
      }

      // Verify response contains success flag
      if (response.data is Map) {
        final success = response.data['success'] ?? false;
        if (!success) {
          throw Exception(response.data['message'] ?? 'Delete failed');
        }
      }

      developer.log(
        'Successfully deleted analysis: $id',
        name: 'FoodAnalysisService',
      );
    } on DioException catch (e) {
      developer.log(
        'Error deleting analysis: ${e.message}',
        name: 'FoodAnalysisService',
        error: e,
      );
      rethrow;
    } catch (e) {
      developer.log(
        'Error deleting analysis: $e',
        name: 'FoodAnalysisService',
        error: e,
      );
      rethrow;
    }
  }
}

