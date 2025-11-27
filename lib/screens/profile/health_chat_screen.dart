import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../providers/health_chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bai_thuoc_provider.dart';
import '../../providers/mon_an_provider.dart';

/// Health consultation chatbot screen
class HealthChatScreen extends StatefulWidget {
  const HealthChatScreen({super.key});

  @override
  State<HealthChatScreen> createState() => _HealthChatScreenState();
}

class _HealthChatScreenState extends State<HealthChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  void _initializeChat() {
    final userProvider = context.read<UserProvider>();
    final chatProvider = context.read<HealthChatProvider>();

    if (userProvider.basicProfile != null) {
      chatProvider.loadGreeting(userProvider.basicProfile!);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSendMessage(
    HealthChatProvider chatProvider,
    UserProvider userProvider,
  ) async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    // Get user and health data
    final basicProfile = userProvider.basicProfile;
    final healthProfile = userProvider.healthProfile;

    if (basicProfile == null || healthProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không thể tải thông tin người dùng. Vui lòng tải lại.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Send message
    print('[HealthChatScreen] _handleSendMessage called with: "$message"');
    await chatProvider.sendMessage(message, basicProfile, healthProfile);
    _scrollToBottom();

    // Generate suggestions based on user message
    if (!mounted) return;
    final baiThuocProvider = context.read<BaiThuocProvider>();
    final monAnProvider = context.read<MonAnProvider>();
    print('[HealthChatScreen] Calling generateSuggestions...');
    await chatProvider.generateSuggestions(
      message,
      baiThuocProvider,
      monAnProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tư vấn Sức khỏe',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'AI Health Advisor',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: () {
              context.read<HealthChatProvider>().clearChat();
              _initializeChat();
            },
          ),
        ],
      ),
      body: Consumer3<HealthChatProvider, UserProvider, AuthProvider>(
        builder: (context, chatProvider, userProvider, authProvider, _) {
          return Column(
            children: [
              // Chat messages
              Expanded(
                child: chatProvider.messages.isEmpty
                    ? _buildEmptyState(context, colorScheme)
                    : _buildMessageList(context, colorScheme, chatProvider),
              ),

              // Suggestions
              if (chatProvider.suggestedBaiThuoc.isNotEmpty)
                _buildSuggestions(context, colorScheme, chatProvider),

              // Error message
              if (chatProvider.errorMessage != null)
                _buildErrorBanner(
                  context,
                  colorScheme,
                  chatProvider.errorMessage!,
                ),

              // Message input
              _buildMessageInput(
                context,
                colorScheme,
                chatProvider,
                userProvider,
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.health_and_safety_outlined,
            size: 64,
            color: colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Bắt đầu cuộc trò chuyện',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đặt câu hỏi về sức khỏe của bạn',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build message list
  Widget _buildMessageList(
    BuildContext context,
    ColorScheme colorScheme,
    HealthChatProvider chatProvider,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.messages[index];
        return _buildMessageBubble(context, colorScheme, message);
      },
    );
  }

  /// Build message bubble
  Widget _buildMessageBubble(
    BuildContext context,
    ColorScheme colorScheme,
    dynamic message,
  ) {
    final isUser = message.isUser;
    final isLoading = message.isLoading;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // AI avatar
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 4),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                child: Icon(
                  Icons.health_and_safety_outlined,
                  size: 16,
                  color: colorScheme.primary,
                ),
              ),
            ),

          // Message bubble
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: isUser
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: !isUser ? const Radius.circular(4) : null,
                  bottomRight: isUser ? const Radius.circular(4) : null,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: isLoading
                  ? _buildLoadingIndicator(colorScheme)
                  : isUser
                  ? Text(
                      message.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : _buildMarkdownContent(
                      message.content,
                      colorScheme,
                      context,
                    ),
            ),
          ),

          // User avatar
          if (isUser)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: colorScheme.primary,
                child: Icon(
                  Icons.person,
                  size: 16,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build markdown content with formatting
  Widget _buildMarkdownContent(
    String content,
    ColorScheme colorScheme,
    BuildContext context,
  ) {
    return SelectableText.rich(
      _parseMarkdown(content, colorScheme, context),
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
    );
  }

  /// Parse markdown text into TextSpan
  TextSpan _parseMarkdown(
    String text,
    ColorScheme colorScheme,
    BuildContext context,
  ) {
    final spans = <TextSpan>[];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Parse line-level markdown
      if (line.startsWith('**')) {
        // Bold heading
        final content = line.replaceAll('**', '');
        spans.add(
          TextSpan(
            text: content,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        );
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        // Bullet point
        final content = line.substring(2);
        spans.add(
          TextSpan(
            text:
                '• ${_parseInlineMarkdown(content, colorScheme, context).toPlainText()} ',
            style: const TextStyle(height: 1.5),
          ),
        );
      } else if (line.isEmpty) {
        spans.add(const TextSpan(text: '\n'));
      } else {
        // Normal line with inline markdown
        spans.add(_parseInlineMarkdown(line, colorScheme, context));
      }

      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return TextSpan(children: spans);
  }

  /// Parse inline markdown (bold, italic)
  TextSpan _parseInlineMarkdown(
    String text,
    ColorScheme colorScheme,
    BuildContext context,
  ) {
    final spans = <TextSpan>[];
    var remaining = text;
    var currentIndex = 0;

    while (currentIndex < remaining.length) {
      // Find bold **text**
      final boldStart = remaining.indexOf('**', currentIndex);
      if (boldStart >= 0) {
        // Add text before bold
        if (boldStart > currentIndex) {
          spans.add(
            TextSpan(text: remaining.substring(currentIndex, boldStart)),
          );
        }
        // Find end of bold
        final boldEnd = remaining.indexOf('**', boldStart + 2);
        if (boldEnd >= 0) {
          final boldText = remaining.substring(boldStart + 2, boldEnd);
          spans.add(
            TextSpan(
              text: boldText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
          currentIndex = boldEnd + 2;
        } else {
          break;
        }
      } else {
        // No more bold, add remaining text
        spans.add(TextSpan(text: remaining.substring(currentIndex)));
        break;
      }
    }

    return TextSpan(children: spans.isEmpty ? [TextSpan(text: text)] : spans);
  }

  /// Build message loading indicator
  Widget _buildLoadingIndicator(ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Đang suy nghĩ...',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  /// Build error banner
  Widget _buildErrorBanner(
    BuildContext context,
    ColorScheme colorScheme,
    String errorMessage,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: colorScheme.errorContainer,
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.error),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: colorScheme.error, size: 20),
            onPressed: () {
              // Clear error by reading provider directly in context
              final provider = context.read<HealthChatProvider>();
              // Create a new instance method to clear error
              provider.clearError();
            },
          ),
        ],
      ),
    );
  }

  /// Build suggestions section - larger, better layout
  Widget _buildSuggestions(
    BuildContext context,
    ColorScheme colorScheme,
    HealthChatProvider chatProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
        color: colorScheme.surfaceContainer.withValues(alpha: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Suggested medicines header
          if (chatProvider.suggestedBaiThuoc.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.local_pharmacy_outlined,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Bài thuốc gợi ý',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Horizontal scrollable list - 3 items per row
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 4, right: 4),
                itemCount: chatProvider.suggestedBaiThuoc.length,
                itemBuilder: (context, index) {
                  final baiThuoc = chatProvider.suggestedBaiThuoc[index];
                  return _buildHorizontalCard(
                    context,
                    colorScheme,
                    baiThuoc.ten,
                    baiThuoc.moTa,
                    baiThuoc.image,
                    () {
                      Navigator.pushNamed(
                        context,
                        '/bai-thuoc-detail',
                        arguments: baiThuoc.id,
                      );
                      chatProvider.clearSuggestions();
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build horizontal card - image on top, title and description below
  Widget _buildHorizontalCard(
    BuildContext context,
    ColorScheme colorScheme,
    String title,
    String? description,
    String? imageUrl,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 140,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image on top - larger
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(11),
                    topRight: Radius.circular(11),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 110,
                    child: _buildThumbnailImage(imageUrl, colorScheme),
                  ),
                ),
                // Content below
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Expanded(
                          flex: 2,
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: colorScheme.onSurface,
                                ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Description
                        if (description != null && description.isNotEmpty)
                          Expanded(
                            child: Text(
                              description.length > 40
                                  ? '${description.substring(0, 40)}...'
                                  : description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontSize: 10,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build thumbnail image for card
  Widget _buildThumbnailImage(String? imageUrl, ColorScheme colorScheme) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: colorScheme.primary.withValues(alpha: 0.1),
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 20,
          color: colorScheme.primary.withValues(alpha: 0.5),
        ),
      );
    }

    try {
      if (imageUrl.startsWith('data:image')) {
        // Base64 image
        final base64Data = imageUrl.split(',').last;
        return Image.memory(
          base64Decode(base64Data),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.broken_image_outlined,
                size: 20,
                color: colorScheme.primary.withValues(alpha: 0.5),
              ),
            );
          },
        );
      } else if (imageUrl.startsWith('http')) {
        // Network image
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(color: colorScheme.primary.withValues(alpha: 0.1));
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.broken_image_outlined,
                size: 20,
                color: colorScheme.primary.withValues(alpha: 0.5),
              ),
            );
          },
        );
      } else {
        // Asset image
        return Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.broken_image_outlined,
                size: 20,
                color: colorScheme.primary.withValues(alpha: 0.5),
              ),
            );
          },
        );
      }
    } catch (e) {
      return Container(
        color: colorScheme.primary.withValues(alpha: 0.1),
        child: Icon(
          Icons.image_outlined,
          size: 20,
          color: colorScheme.primary.withValues(alpha: 0.5),
        ),
      );
    }
  }

  /// Build message input
  Widget _buildMessageInput(
    BuildContext context,
    ColorScheme colorScheme,
    HealthChatProvider chatProvider,
    UserProvider userProvider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !chatProvider.isLoading,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Nhập câu hỏi...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.small(
            backgroundColor: colorScheme.primary,
            onPressed: chatProvider.isLoading
                ? null
                : () => _handleSendMessage(chatProvider, userProvider),
            child: Icon(Icons.send, color: colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }
}

