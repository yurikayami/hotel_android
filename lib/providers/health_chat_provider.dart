import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import '../models/chat_message.dart';
import '../models/user_basic_model.dart';
import '../models/health_profile_model.dart';
import '../models/bai_thuoc.dart';
import '../services/gemini_health_service.dart';
import 'bai_thuoc_provider.dart';
import 'mon_an_provider.dart';

/// Provider for managing health chat state
class HealthChatProvider extends ChangeNotifier {
  final GeminiHealthService _geminiService = GeminiHealthService();

  // State
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<BaiThuoc> _suggestedBaiThuoc = [];

  // Getters
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<BaiThuoc> get suggestedBaiThuoc => _suggestedBaiThuoc;

  /// Send a message to the health chatbot
  ///
  /// [message] - The user's message
  /// [user] - User's basic profile
  /// [health] - User's health profile
  Future<void> sendMessage(
    String message,
    UserBasicModel user,
    HealthProfileModel health,
  ) async {
    // Validate input
    if (message.trim().isEmpty) {
      _setError('Vui lòng nhập tin nhắn');
      return;
    }

    try {
      // Clear previous error
      _errorMessage = null;

      // Add user message to chat
      final userMessage = ChatMessage.userMessage(message);
      _messages.add(userMessage);
      notifyListeners();

      // Add loading message for AI response
      _isLoading = true;
      notifyListeners();

      // If there are suggested medicines, add them to the context
      String enhancedMessage = message;
      if (_suggestedBaiThuoc.isNotEmpty) {
        final suggestedNames = _suggestedBaiThuoc.map((b) => b.ten).join(', ');
        enhancedMessage = '''$message

[Các bài thuốc gợi ý liên quan: $suggestedNames. Hãy sử dụng thông tin này để đưa ra tư vấn chi tiết hơn.]''';
        print(
          '[HealthChatProvider] ✓ Adding suggestions to message: $suggestedNames',
        );
      }

      // Send to Gemini API
      print('[HealthChatProvider] Sending message to Gemini...');
      final response = await _geminiService.sendMessage(
        enhancedMessage,
        user,
        health,
      );

      // Remove loading message and add actual response
      if (_messages.isNotEmpty && _messages.last.isLoading) {
        _messages.removeLast();
      }

      final aiMessage = ChatMessage.aiResponse(response);
      _messages.add(aiMessage);

      _isLoading = false;
      notifyListeners();

      print('[HealthChatProvider] Message sent successfully');
    } catch (e) {
      print('[HealthChatProvider] Error: $e');

      // Remove loading message if it exists
      if (_messages.isNotEmpty && _messages.last.isLoading) {
        _messages.removeLast();
      }

      _isLoading = false;
      _setError('Lỗi: ${e.toString()}');
      notifyListeners();
    }
  }

  /// Clear all chat messages
  void clearChat() {
    _messages.clear();
    _errorMessage = null;
    _isLoading = false;
    _suggestedBaiThuoc.clear();
    notifyListeners();
  }

  /// Clear error message only
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Kiểm tra xem có từ khóa triệu chứng trong message
  /// LUÔN gợi ý khi phát hiện triệu chứng, không cần user nói "gợi ý"
  bool _shouldGenerateSuggestions(String message) {
    final lowerMessage = message.toLowerCase();
    // Tất cả những từ khóa đều là triệu chứng, không cần user nói "gợi ý"
    final suggestionKeywords = [
      'cảm',
      'ho',
      'sốt',
      'đau đầu',
      'mệt mỏi',
      'viêm họng',
      'cảm lạnh',
      'buồn nôn',
      'nôn',
      'tiêu chảy',
      'táo bón',
      'đau bụng',
      'chóng mặt',
      'mất ngủ',
      'stress',
      'lo âu',
      'trầm cảm',
      'thừa cân',
      'béo phì',
      'tiểu đường',
      'huyết áp',
      'tim',
      'phổi',
      'dạ dày',
      'gan',
      'thận',
      'khớp',
      'xương',
      'cơ',
      'gợi ý',
      'nên ăn gì',
      'nên uống gì',
    ];
    final hasKeyword = suggestionKeywords.any(
      (kw) => lowerMessage.contains(kw),
    );
    print(
      '[HealthChatProvider] _shouldGenerateSuggestions: $hasKeyword for message: "$message"',
    );
    return hasKeyword;
  }

  /// Trích xuất từ khóa triệu chứng từ tin nhắn người dùng
  List<String> _extractKeywords(String message) {
    final lowerMessage = message.toLowerCase();
    final symptomKeywords = [
      'cảm',
      'ho',
      'sốt',
      'đau đầu',
      'mệt mỏi',
      'viêm họng',
      'cảm lạnh',
      'buồn nôn',
      'nôn',
      'tiêu chảy',
      'táo bón',
      'đau bụng',
      'chóng mặt',
      'mất ngủ',
      'stress',
      'lo âu',
      'trầm cảm',
      'thừa cân',
      'béo phì',
      'tiểu đường',
      'huyết áp',
      'tim',
      'phổi',
      'dạ dày',
      'gan',
      'thận',
      'khớp',
      'xương',
      'cơ',
    ];
    return symptomKeywords.where((kw) => lowerMessage.contains(kw)).toList();
  }

  /// Tạo đề xuất bài thuốc dựa trên từ khóa
  Future<void> generateSuggestions(
    String userMessage,
    BaiThuocProvider baiThuocProvider,
    MonAnProvider monAnProvider,
  ) async {
    try {
      print('[HealthChatProvider] ===== START generateSuggestions ====');
      print('[HealthChatProvider] Message: "$userMessage"');

      // Chỉ gợi ý khi user yêu cầu
      if (!_shouldGenerateSuggestions(userMessage)) {
        print('[HealthChatProvider] No keywords found, clearing suggestions');
        _suggestedBaiThuoc.clear();
        notifyListeners();
        return;
      }

      final keywords = _extractKeywords(userMessage);
      print('[HealthChatProvider] Extracted keywords: $keywords');

      if (keywords.isEmpty) {
        print(
          '[HealthChatProvider] No extracted keywords, clearing suggestions',
        );
        _suggestedBaiThuoc.clear();
        notifyListeners();
        return;
      }

      print(
        '[HealthChatProvider] Total bai thuoc in provider: ${baiThuocProvider.baiThuocList.length}',
      );
      if (baiThuocProvider.baiThuocList.isNotEmpty) {
        print('[HealthChatProvider] BaiThuoc list:');
        for (var i = 0; i < baiThuocProvider.baiThuocList.length; i++) {
          final bt = baiThuocProvider.baiThuocList[i];
          final desc = bt.moTa?.substring(0, 50) ?? 'N/A';
          print('[HealthChatProvider]   $i. ${bt.ten} - $desc...');
        }
      }

      // Tìm bài thuốc liên quan (khớp trong tên hoặc mô tả)
      final matchedBaiThuoc = <BaiThuoc>[];
      for (var baiThuoc in baiThuocProvider.baiThuocList) {
        final title = baiThuoc.ten.toLowerCase();
        final desc = baiThuoc.moTa?.toLowerCase() ?? '';
        final shortDesc = desc.length > 100 ? desc.substring(0, 100) : desc;

        for (var kw in keywords) {
          if (title.contains(kw) || shortDesc.contains(kw)) {
            print(
              '[HealthChatProvider] ✓ MATCHED: "${baiThuoc.ten}" with keyword "$kw"',
            );
            matchedBaiThuoc.add(baiThuoc);
            break;
          }
        }
      }

      _suggestedBaiThuoc = matchedBaiThuoc.take(3).toList();

      print(
        '[HealthChatProvider] ✓✓✓ Found ${_suggestedBaiThuoc.length} suggestions:',
      );
      for (var bt in _suggestedBaiThuoc) {
        print('[HealthChatProvider]   - ${bt.ten}');
      }
      print('[HealthChatProvider] ===== END generateSuggestions ====');

      notifyListeners();
    } catch (e) {
      print('[HealthChatProvider] ERROR in generateSuggestions: $e');
      developer.log(
        'Error generating suggestions: $e',
        name: 'health_chat',
        error: e,
      );
    }
  }

  /// Xóa đề xuất
  void clearSuggestions() {
    _suggestedBaiThuoc.clear();
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Load initial greeting message
  void loadGreeting(UserBasicModel user) {
    _messages.clear();

    final greeting =
        'Xin chào ${user.userName ?? 'bạn'}! 👋\nTôi là trợ lý y tế AI của bạn. Tôi có thể giúp bạn tư vấn về sức khỏe, dinh dưỡng, và lối sống lành mạnh dựa trên thông tin sức khỏe của bạn.';

    final aiMessage = ChatMessage.aiResponse(greeting);
    _messages.add(aiMessage);
    notifyListeners();
  }
}
