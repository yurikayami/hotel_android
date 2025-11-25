import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import '../../providers/food_analysis_provider.dart';
import '../../providers/auth_provider.dart';
import 'food_result_screen.dart';
import 'food_history_screen.dart';
//animation phân tích
import 'dart:ui'; // Để dùng ImageFilter (làm mờ)
import 'dart:math' as math; // Để tính toán xoay vòng tròn

/// Camera Screen with real-time preview and AI scanning interface
class FoodCameraScreen extends StatefulWidget {
  const FoodCameraScreen({super.key});

  @override
  State<FoodCameraScreen> createState() => _FoodCameraScreenState();
}

class _FoodCameraScreenState extends State<FoodCameraScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  String _selectedMealType = 'lunch';
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  late AnimationController _scannerController;
  late Animation<double> _scannerAnimation;

  @override
  void initState() {
    super.initState();
    // Khởi động camera sau khi screen được build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCamera();
    });

    // Scanner animation
    _scannerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _scannerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _scannerController, curve: Curves.linear),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.nv21,
        );

        await _cameraController!.initialize();
        
        // Add small delay to ensure preview size is available
        await Future.delayed(const Duration(milliseconds: 100));
        
        if (mounted) {
          setState(() {
            // Camera is ready
          });
        }
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        setState(() {
          // Error initializing camera
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _buildTopBar(colorScheme),

            // Camera preview - main content
            Expanded(
              child: Stack(
                children: [
                  // Camera preview
                  if (_cameraController != null &&
                      _cameraController!.value.isInitialized)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _capturePhoto,
                        child: CameraPreview(_cameraController!),
                      ),
                    )
                  else
                    Positioned.fill(
                      child: Container(
                        color: Colors.black,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.white,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Đang khởi động camera...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Scanner frame overlay
                  Positioned(
                    top: 80,
                    left: 0,
                    right: 0,
                    bottom: 80,
                    child: IgnorePointer(
                      child: Center(
                        child: _buildScannerFrame(colorScheme, size),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom controls
            _buildBottomControls(colorScheme),
          ],
        ),
      ),
    );
  }

  /// Build top bar with back button and settings
  Widget _buildTopBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            Material(
              color: colorScheme.surface.withValues(alpha: 0.9),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                ),
              ),
            ),

            // AI Camera badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flash_on, size: 16, color: colorScheme.onPrimary),
                  const SizedBox(width: 6),
                  Text(
                    'AI Camera',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Settings button
            Material(
              color: colorScheme.surface.withValues(alpha: 0.9),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () {
                  // TODO: Show settings
                },
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(Icons.settings, color: colorScheme.onSurface),
                ),
              ),
            ),
          ],
        ),
      );
    }

  /// Build scanner frame with animation
  Widget _buildScannerFrame(ColorScheme colorScheme, Size size) {
    final frameSize = size.width * 0.6; // Reduced from 0.7 to 0.6

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Scanner frame
        SizedBox(
          width: frameSize,
          height: frameSize,
          child: Stack(
            children: [
              // Corner decorations
              ...List.generate(4, (index) {
                final isTop = index < 2;
                final isLeft = index % 2 == 0;

                return Positioned(
                  top: isTop ? 0 : null,
                  bottom: !isTop ? 0 : null,
                  left: isLeft ? 0 : null,
                  right: !isLeft ? 0 : null,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        top: isTop
                            ? BorderSide(
                                color: Colors.white.withValues(alpha: 0.9),
                                width: 4)
                            : BorderSide.none,
                        bottom: !isTop
                            ? BorderSide(
                                color: Colors.white.withValues(alpha: 0.9),
                                width: 4)
                            : BorderSide.none,
                        left: isLeft
                            ? BorderSide(
                                color: Colors.white.withValues(alpha: 0.9),
                                width: 4)
                            : BorderSide.none,
                        right: !isLeft
                            ? BorderSide(
                                color: Colors.white.withValues(alpha: 0.9),
                                width: 4)
                            : BorderSide.none,
                      ),
                    ),
                  ),
                );
              }),

              // Scanning line animation
              AnimatedBuilder(
                animation: _scannerAnimation,
                builder: (context, child) {
                  return Positioned(
                    top: (frameSize / 2) * (_scannerAnimation.value + 1),
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.8),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16), // Reduced from 24 to 16

        // Hint chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Đặt món ăn vào khung',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build bottom controls panel - Material You 3 minimal style
  Widget _buildBottomControls(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Meal type selector
            _buildMealTypeSelector(colorScheme),

            const SizedBox(height: 20),

            // Action buttons
            _buildActionButtons(colorScheme),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Build meal type selector - Scrollable to fix overflow
  Widget _buildMealTypeSelector(ColorScheme colorScheme) {
    final mealTypes = [
      {'value': 'breakfast', 'label': 'Sáng', 'icon': Icons.wb_sunny_outlined},
      {'value': 'lunch', 'label': 'Trưa', 'icon': Icons.light_mode_outlined},
      {'value': 'dinner', 'label': 'Tối', 'icon': Icons.nightlight_outlined},
      {'value': 'snack', 'label': 'Phụ', 'icon': Icons.coffee_outlined},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: mealTypes.map((meal) {
          final isSelected = _selectedMealType == meal['value'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    meal['icon'] as IconData,
                    size: 14,
                    color: isSelected
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 5),
                  Text(meal['label'] as String),
                ],
              ),
              onSelected: (_) {
                setState(() {
                  _selectedMealType = meal['value'] as String;
                });
              },
              backgroundColor: colorScheme.surface,
              selectedColor: colorScheme.secondaryContainer,
              side: BorderSide(
                color: isSelected
                    ? colorScheme.secondary
                    : colorScheme.outline.withValues(alpha: 0.2),
                width: isSelected ? 1.5 : 1,
              ),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build action buttons - Rebalanced sizing and spacing
  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Gallery button - Larger, better spacing
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            iconSize: 26,
            color: colorScheme.onSurface,
          ),
        ),

        const SizedBox(width: 32),

        // Capture button - More proportional size
        GestureDetector(
          onTap: _capturePhoto,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.camera_alt,
              size: 32,
              color: colorScheme.onPrimary,
            ),
          ),
        ),

        const SizedBox(width: 32),

        // History button - Larger, better spacing
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FoodHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history),
            iconSize: 26,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// Capture photo from camera controller
  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để sử dụng tính năng này'),
          ),
        );
        return;
      }

      // Capture image from camera
      final XFile image = await _cameraController!.takePicture();

      if (mounted) {
        // --- BẮT ĐẦU ĐOẠN SỬA ---
        // Show AI loading animation
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.transparent, // Quan trọng: để trong suốt cho hiệu ứng mờ hoạt động
          builder: (context) => const AIProcessingDialog(), // Gọi cái Widget bạn vừa dán ở bước 1
        );
        // --- KẾT THÚC ĐOẠN SỬA ---

        try {
          await context.read<FoodAnalysisProvider>().analyzeFood(
            userId: authProvider.user!.id.toString(),
            imageFile: image,
            mealType: _selectedMealType,
            userCalorieTarget: 2000,
          );

          if (!mounted) return;
          Navigator.pop(context); // Close loading

          final provider = context.read<FoodAnalysisProvider>();
          if (provider.currentAnalysis != null) {
            // Navigate to result screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodResultScreen(
                  analysis: provider.currentAnalysis!,
                  imagePath: image.path,
                ),
              ),
            );
          } else if (provider.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
          }
        } catch (e) {
          if (!mounted) return;
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể chụp ảnh: $e')));
      }
    }
  }

  /// Pick image from gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để sử dụng tính năng này'),
          ),
        );
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        // --- BẮT ĐẦU ĐOẠN SỬA ---
        // Show AI loading animation
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.transparent, // Quan trọng
          builder: (context) => const AIProcessingDialog(),
        );
        // --- KẾT THÚC ĐOẠN SỬA ---

        try {
          await context.read<FoodAnalysisProvider>().analyzeFood(
            userId: authProvider.user!.id.toString(),
            imageFile: image,
            mealType: _selectedMealType,
            userCalorieTarget: 2000,
          );

          if (!mounted) return;
          Navigator.pop(context); // Close loading

          final provider = context.read<FoodAnalysisProvider>();
          if (provider.currentAnalysis != null) {
            // Navigate to result screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodResultScreen(
                  analysis: provider.currentAnalysis!,
                  imagePath: image.path,
                ),
              ),
            );
          } else if (provider.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
          }
        } catch (e) {
          if (!mounted) return;
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể chọn ảnh: $e')));
      }
    }
  }
}


// --- DÁN ĐOẠN NÀY VÀO TẬN CÙNG FILE (THAY THẾ CLASS CŨ) ---

class AIProcessingDialog extends StatefulWidget {
  const AIProcessingDialog({super.key});

  @override
  State<AIProcessingDialog> createState() => _AIProcessingDialogState();
}

class _AIProcessingDialogState extends State<AIProcessingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  final List<String> _loadingMessages = [
    "Đang phân tích...",
    "Nhận diện nguyên liệu...",
    "Tính toán dinh dưỡng...",
    "Tổng hợp kết quả..."
  ];
  int _currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Xoay chậm rãi, thanh lịch
    )..repeat();
    _cycleMessages();
  }

  void _cycleMessages() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _loadingMessages.length;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      child: Dialog(
        // CHUẨN M3: Dùng màu surfaceContainerHigh thay vì nền đen
        backgroundColor: colorScheme.surfaceContainerHigh,
        elevation: 0, // M3 ít dùng shadow đậm
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28), // Bo góc lớn chuẩn M3
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. ANIMATION GEMINI STYLE
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Vòng Gradient xoay (Primary + Tertiary)
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (_, child) => Transform.rotate(
                        angle: _controller.value * 2 * math.pi,
                        child: child,
                      ),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              colorScheme.primary.withValues(alpha: 0.1),
                              colorScheme.primary,
                              colorScheme.tertiary, // Pha màu thứ 3 cho giống AI
                              colorScheme.primary.withValues(alpha: 0.1),
                            ],
                            stops: const [0.0, 0.4, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                    
                    // Lớp che bên trong để tạo thành cái nhẫn (Ring)
                    Container(
                      width: 72, // Nhỏ hơn vòng ngoài 8px -> viền dày 4px
                      height: 72,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh, // Cùng màu nền dialog
                        shape: BoxShape.circle,
                      ),
                    ),

                    // Icon AI ở giữa (Có hiệu ứng Pulse nhẹ)
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Opacity(
                          opacity: (0.5 + 0.5 * math.sin(_controller.value * 2 * math.pi)).abs(),
                          child: child,
                        );
                      },
                      child: Icon(
                        Icons.auto_awesome, 
                        color: colorScheme.primary, 
                        size: 32
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. TEXT TITLE
              Text(
                "AI Assistant",
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              
              const SizedBox(height: 8),

              // 3. DYNAMIC MESSAGE
              SizedBox(
                height: 24,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _loadingMessages[_currentMessageIndex],
                    key: ValueKey<int>(_currentMessageIndex),
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}