import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/medicine.dart';

/// Service for handling Medicine/Health Tips API calls
import '../services/api_config.dart';

class MedicineService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Get public medicines for a specific user
  static Future<List<Medicine>> getPublicMedicines(
    String userId, {
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/BaiThuocAPI/public/$userId/medicine?offset=$offset&limit=$limit',
      );

      print('[MedicineService] Fetching medicines for user: $userId from: ${url.path}?offset=$offset&limit=$limit');

      final response = await http.get(url);

      print('[MedicineService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print('[MedicineService] API Response: $json');

        if (json['success'] == true && json['data'] != null) {
          final data = json['data'];
          if (data['medicines'] != null) {
            final medicines = (data['medicines'] as List)
                .map((m) => Medicine.fromJson(m))
                .toList();
            print('[MedicineService] Parsed ${medicines.length} medicines');
            return medicines;
          }
        }
        print('[MedicineService] No medicines data in response');
        return [];
      } else {
        throw Exception('Failed to load medicines: ${response.statusCode}');
      }
    } catch (e) {
      print('[MedicineService] Error: $e');
      rethrow;
    }
  }

  /// Get current user's medicines (requires authentication)
  static Future<List<Medicine>> getMyMedicines({
    required String token,
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/BaiThuocAPI/user/myMedicine?offset=$offset&limit=$limit',
      );

      print('[MedicineService] Fetching my medicines from: ${url.path}?offset=$offset&limit=$limit');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('[MedicineService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print('[MedicineService] API Response: $json');

        if (json['success'] == true && json['data'] != null) {
          final data = json['data'];
          if (data['medicines'] != null) {
            final medicines = (data['medicines'] as List)
                .map((m) => Medicine.fromJson(m))
                .toList();
            print('[MedicineService] Parsed ${medicines.length} medicines');
            return medicines;
          }
        }
        print('[MedicineService] No medicines data in response');
        return [];
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Token không hợp lệ hoặc hết hạn');
      } else {
        throw Exception('Failed to load medicines: ${response.statusCode}');
      }
    } catch (e) {
      print('[MedicineService] Error: $e');
      rethrow;
    }
  }
}

