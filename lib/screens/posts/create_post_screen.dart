import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/post_provider.dart';
import '../../providers/auth_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  final List<XFile> _selectedImages = [];
  bool _isLoading = false;
  final ImagePicker _imagePicker = ImagePicker();
  late final FocusNode _contentFocusNode;

  @override
  void initState() {
    super.initState();
    _contentFocusNode = FocusNode();
    // Request focus after frame is built to ensure widget tree is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _contentFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      setState(() => _isLoading = true);

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 1920,
        maxWidth: 1920,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImages.clear();
          _selectedImages.add(image);
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('[CreatePostScreen] Image pick error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _captureImageFromCamera() async {
    try {
      setState(() => _isLoading = true);

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxHeight: 1920,
        maxWidth: 1920,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImages.clear();
          _selectedImages.add(image);
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('[CreatePostScreen] Camera capture error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<String> _convertImageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('[CreatePostScreen] Error converting image to base64: $e');
      rethrow;
    }
  }

  Future<String?> _saveImagesToBase64() async {
    if (_selectedImages.isEmpty) {
      return null;
    }

    try {
      print('[CreatePostScreen] Converting image to Base64...');

      final file = File(_selectedImages[0].path);
      final base64String = await _convertImageToBase64(file);

      final mimeType = _getImageMimeType(_selectedImages[0].path);
      final dataUri = 'data:$mimeType;base64,$base64String';

      print(
        '[CreatePostScreen] Image converted successfully, length: ${base64String.length} chars',
      );
      return dataUri;
    } catch (e) {
      print('[CreatePostScreen] Error saving image to base64: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lỗi: Không thể lưu ảnh')));
      }
      return null;
    }
  }

  String _getImageMimeType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  String _getContentFromQuill() {
    try {
      return _contentController.text;
    } catch (e) {
      print('[CreatePostScreen] Error getting content: $e');
      return '';
    }
  }

  Future<void> _submitPost() async {
    final content = _getContentFromQuill();

    if (content.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập nội dung')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final postProvider = context.read<PostProvider>();

      String? duongDanMedia;
      if (_selectedImages.isNotEmpty) {
        print('[CreatePostScreen] Starting to save image to Base64...');
        duongDanMedia = await _saveImagesToBase64();

        if (duongDanMedia == null) {
          throw Exception('Không thể chuyển đổi ảnh sang Base64');
        }

        print(
          '[CreatePostScreen] Image saved to Base64, length: ${duongDanMedia.length} chars',
        );
      }

      print('[CreatePostScreen] Creating post with:');
      print('[CreatePostScreen] - Content: ${content.trim()}');
      print('[CreatePostScreen] - Images: ${_selectedImages.length}');

      await postProvider.createPost(
        noiDung: content.trim(),
        duongDanMedia: duongDanMedia,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bài viết đã được tạo thành công')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  ImageProvider _getAvatarImage(String? avatarUrl) {
    if (avatarUrl != null &&
        avatarUrl.isNotEmpty &&
        avatarUrl.startsWith('http')) {
      return NetworkImage(avatarUrl);
    }
    return const AssetImage('assets/images/avatar.jpg');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasContent =
        _contentController.text.trim().isNotEmpty || _selectedImages.isNotEmpty;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilledButton(
              onPressed: (_isLoading || !hasContent) ? null : _submitPost,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                disabledBackgroundColor: colorScheme.primary.withValues(
                  alpha: 0.3,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Text(
                      'Đăng',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info header
                _buildUserInfo(context),
                const SizedBox(height: 16),

                // Quill rich text editor
                _buildQuillEditor(),
                const SizedBox(height: 16),

                // Image preview section
                if (_selectedImages.isNotEmpty) ...[
                  _buildImagePreview(),
                  const SizedBox(height: 16),
                ],

                // Media actions
                _buildMediaActions(),

                const SizedBox(height: 24),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        if (user == null) return const SizedBox.shrink();

        return Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: _getAvatarImage(user.avatarUrl),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName ?? user.userName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    DateTime.now().toString().split('.')[0],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuillEditor() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextField(
      controller: _contentController,
      focusNode: _contentFocusNode,
      maxLines: null,
      minLines: 5,
      maxLength: 500,
      enabled: !_isLoading,
      autofocus: true,
      textInputAction: TextInputAction.newline,
      style: textTheme.bodyLarge,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Bạn đang nghĩ gì?',
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildMediaActions() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            'Thêm vào bài viết',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          // Camera button
          Material(
            color: _selectedImages.isEmpty
                ? colorScheme.primaryContainer
                : colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: _isLoading ? null : _captureImageFromCamera,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: _selectedImages.isEmpty
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSecondaryContainer,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Gallery button
          Material(
            color: _selectedImages.isEmpty
                ? colorScheme.primaryContainer
                : colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: _isLoading ? null : _pickImageFromGallery,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.image_rounded,
                  color: _selectedImages.isEmpty
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSecondaryContainer,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(_selectedImages[0].path),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.image_not_supported_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 48,
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () => _removeImage(0),
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Material(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: _pickImageFromGallery,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
