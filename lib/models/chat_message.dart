import 'package:json_annotation/json_annotation.dart';

part 'chat_message.g.dart';

/// Chat message model for health consultation
@JsonSerializable()
class ChatMessage {
  final String id;
  final String content;
  final bool isUser; // true for user messages, false for AI responses
  final DateTime timestamp;
  final bool isLoading; // true while waiting for AI response

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  /// Create a user message
  factory ChatMessage.userMessage(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
      isLoading: false,
    );
  }

  /// Create an AI loading message
  factory ChatMessage.aiLoading() {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    );
  }

  /// Create an AI response message
  factory ChatMessage.aiResponse(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: false,
    );
  }

  /// Copy with method
  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
