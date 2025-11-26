import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_basic_model.dart';
import '../models/health_profile_model.dart';

/// Service for communicating with Google Gemini API for health consultations
class GeminiHealthService {
  static const String _geminiApiKey =
      'AIzaSyBsNWRR5jKjQUMRjrCWnb63QyrIiiOztK8'; // Replace with actual API key
  static const String _geminiModel = 'gemini-2.5-flash';
  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// Send a message to Gemini with health context
  ///
  /// [userMessage] - The user's question/message
  /// [user] - User's basic profile (age, gender, name)
  /// [health] - User's health profile (BMI, diseases, allergies)
  ///
  /// Returns the AI's response as a string
  Future<String> sendMessage(
    String userMessage,
    UserBasicModel user,
    HealthProfileModel health,
  ) async {
    // Build system instruction from user and health data
    final systemInstruction = _buildSystemInstruction(user, health);

    // Build the request payload
    final requestBody = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': userMessage},
          ],
        },
      ],
      'systemInstruction': {
        'parts': [
          {'text': systemInstruction},
        ],
      },
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 1024,
      },
    };

    // Make the API request
    final url = Uri.parse(
      '$_geminiBaseUrl/$_geminiModel:generateContent?key=$_geminiApiKey',
    );

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Extract the response text
        final candidates = data['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) {
          throw Exception('No response from Gemini API');
        }

        final content = candidates.first['content'] as Map<String, dynamic>?;
        if (content == null) {
          throw Exception('Invalid response format from Gemini API');
        }

        final parts = content['parts'] as List?;
        if (parts == null || parts.isEmpty) {
          throw Exception('No text in Gemini response');
        }

        var text = parts.first['text'] as String?;
        if (text == null) {
          throw Exception('No text content in Gemini response');
        }

        // Cắt text nếu quá dài để tránh RangeError
        final preview = text.length > 100
            ? '${text.substring(0, 100)}...'
            : text;
        print('[GeminiHealthService] Response received: $preview');
        return text;
      } else if (response.statusCode == 429) {
        throw Exception(
          'Gemini API rate limit exceeded. Please try again later.',
        );
      } else if (response.statusCode == 401) {
        throw Exception(
          'Gemini API key is invalid. Please check your API key.',
        );
      } else {
        print('[GeminiHealthService] Error - Status: ${response.statusCode}');
        print('[GeminiHealthService] Response: ${response.body}');

        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          final error = errorData['error'] as Map<String, dynamic>?;
          final message = error?['message'] as String?;
          throw Exception(
            'Gemini API Error: ${message ?? response.statusCode}',
          );
        } catch (e) {
          throw Exception('Gemini API Error: ${response.statusCode}');
        }
      }
    } on TimeoutException {
      throw Exception(
        'Gemini API request timeout. Please check your connection.',
      );
    } catch (e) {
      print('[GeminiHealthService] Exception: $e');
      rethrow;
    }
  }

  /// Build system instruction from user and health data
  String _buildSystemInstruction(
    UserBasicModel user,
    HealthProfileModel health,
  ) {
    final buffer = StringBuffer();

    buffer.writeln(
      'Bạn là bác sĩ AI chuyên tư vấn sức khỏe. Bạn là trợ lý y tế đáng tin cậy, thân thiện và chuyên nghiệp.',
    );
    buffer.writeln('');
    buffer.writeln('Thông tin bệnh nhân:');

    // Add personal information
    if (user.userName?.isNotEmpty ?? false) {
      buffer.writeln('- Tên: ${user.userName}');
    }

    if (health.age != null) {
      buffer.writeln('- Tuổi: ${health.age}');
    }

    if (user.gender?.isNotEmpty ?? false) {
      buffer.writeln('- Giới tính: ${user.gender}');
    }

    buffer.writeln('');
    buffer.writeln('Chỉ số sức khỏe:');

    // Add health metrics
    if (health.height != null) {
      buffer.writeln('- Chiều cao: ${health.height} cm');
    }

    if (health.weight != null) {
      buffer.writeln('- Cân nặng: ${health.weight} kg');
    }

    if (health.bmi != null) {
      buffer.writeln(
        '- BMI: ${health.bmi?.toStringAsFixed(1)} (${health.bmiCategory})',
      );
    }

    if (health.bloodType?.isNotEmpty ?? false) {
      buffer.writeln('- Nhóm máu: ${health.bloodType}');
    }

    buffer.writeln('');
    buffer.writeln('Tiền sử bệnh:');

    // Add medical history
    if (health.hasDiabetes == true) {
      buffer.writeln('- Bệnh tiểu đường: Có');
    }
    if (health.hasHypertension == true) {
      buffer.writeln('- Tăng huyết áp: Có');
    }
    if (health.hasAsthma == true) {
      buffer.writeln('- Hen suyễn: Có');
    }
    if (health.hasHeartDisease == true) {
      buffer.writeln('- Bệnh tim mạch: Có');
    }
    if (health.foodAllergies?.isNotEmpty ?? false) {
      buffer.writeln('- Dị ứng thực phẩm: ${health.foodAllergies}');
    }
    if (health.otherDiseases?.isNotEmpty ?? false) {
      buffer.writeln('- Bệnh khác: ${health.otherDiseases}');
    }

    buffer.writeln('');
    buffer.writeln('Hướng dẫn:');
    buffer.writeln(
      '1. Tư vấn dựa trên thông tin sức khỏe của bệnh nhân ở trên',
    );
    buffer.writeln('2. Luôn lưu ý đến các bệnh nền và dị ứng');
    buffer.writeln(
      '3. Cho lời khuyên dinh dưỡng phù hợp với tình trạng sức khỏe',
    );
    buffer.writeln(
      '4. Nếu bệnh nhân hỏi về bệnh lạ hoặc tình trạng nghiêm trọng, khuyên tìm gặp bác sĩ',
    );
    buffer.writeln('5. Trả lời bằng tiếng Việt, ngắn gọn, dễ hiểu');
    buffer.writeln(
      '6. Không chẩn đoán bệnh, chỉ cung cấp lời khuyên sức khỏe chung',
    );

    return buffer.toString();
  }
}
