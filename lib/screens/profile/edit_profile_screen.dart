import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_basic_model.dart';
import '../../models/health_profile_model.dart';
import '../../providers/user_provider.dart';

/// Screen for editing user profile information
/// Combines editing of both Basic Profile (account) and Health Profile (medical)
/// Uses tab-based UI with separate tabs for account info and health info
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Basic Profile controllers
  late TextEditingController _phoneController;
  String? _selectedGender;
  late TextEditingController _bioController;

  // Health Profile controllers
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String? _selectedBloodType;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _foodAllergiesController;
  late TextEditingController _otherDiseasesController;

  // Date of birth
  DateTime? _selectedDateOfBirth;

  // Medical conditions
  late bool _hasDiabetes;
  late bool _hasHypertension;
  late bool _hasAsthma;
  late bool _hasHeartDisease;

  // Loading state
  bool _isLoading = false;
  bool _isSaving = false;

  final List<String> _genderOptions = ['Nam', 'Nữ', 'Khác'];
  final List<String> _bloodTypeOptions = [
    'O+',
    'O-',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeControllers();
    // Load profile after the first frame is built to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  void _initializeControllers() {
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _emergencyNameController = TextEditingController();
    _emergencyPhoneController = TextEditingController();
    _foodAllergiesController = TextEditingController();
    _otherDiseasesController = TextEditingController();

    _hasDiabetes = false;
    _hasHypertension = false;
    _hasAsthma = false;
    _hasHeartDisease = false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _foodAllergiesController.dispose();
    _otherDiseasesController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();

      // Load both basic and health profiles
      await userProvider.loadFullProfile();

      // Load bio from local storage
      final prefs = await SharedPreferences.getInstance();
      final bio = prefs.getString('user_bio') ?? '🌿 Đam mê ẩm thực & sức khỏe\n🍜 Khám phá món ăn truyền thống Việt Nam\n💚 Sống xanh, ăn sạch, khỏe đẹp mỗi ngày';
      _bioController.text = bio;

      if (mounted) {
        _populateFormData(userProvider);
      }
    } catch (e) {
      print('[EditProfileScreen] Error loading profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải hồ sơ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _populateFormData(UserProvider userProvider) {
    // Load basic profile data
    if (userProvider.basicProfile != null) {
      final basic = userProvider.basicProfile!;
      _phoneController.text = basic.phoneNumber ?? '';
      _selectedGender = basic.gender;
    }

    // Load health profile data
    if (userProvider.healthProfile != null) {
      final health = userProvider.healthProfile!;
      _selectedDateOfBirth = health.dateOfBirth;
      _selectedBloodType = health.bloodType;
      _heightController.text = health.height?.toString() ?? '';
      _weightController.text = health.weight?.toString() ?? '';
      _emergencyNameController.text = health.emergencyContactName ?? '';
      _emergencyPhoneController.text = health.emergencyContactPhone ?? '';
      _foodAllergiesController.text = health.foodAllergies ?? '';
      _otherDiseasesController.text = health.otherDiseases ?? '';

      _hasDiabetes = health.hasDiabetes ?? false;
      _hasHypertension = health.hasHypertension ?? false;
      _hasAsthma = health.hasAsthma ?? false;
      _hasHeartDisease = health.hasHeartDisease ?? false;
    }

    setState(() {});
  }

  Future<void> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) {
      setState(() => _selectedDateOfBirth = picked);
    }
  }

  double? get _currentBMI {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    if (height != null && weight != null && height > 0) {
      final heightInMeters = height / 100;
      return weight / (heightInMeters * heightInMeters);
    }
    return null;
  }

  String get _bmiCategory {
    final bmi = _currentBMI;
    if (bmi == null) return 'N/A';
    if (bmi < 18.5) return 'Thiếu cân';
    if (bmi < 25) return 'Bình thường';
    if (bmi < 30) return 'Thừa cân';
    return 'Béo phì';
  }

  Color _getBMIColor(String category) {
    switch (category) {
      case 'Thiếu cân':
        return Colors.blue;
      case 'Bình thường':
        return Colors.green;
      case 'Thừa cân':
        return Colors.orange;
      case 'Béo phì':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userProvider = context.read<UserProvider>();

      // Update basic profile
      final basicUpdate = UpdateBasicProfileDto(
        phoneNumber:
            _phoneController.text.isEmpty ? null : _phoneController.text,
        gender: _selectedGender,
      );
      await userProvider.updateBasicProfile(basicUpdate);

      // Update health profile
      final healthUpdate = UpdateHealthProfileDto(
        dateOfBirth: _selectedDateOfBirth,
        bloodType: _selectedBloodType,
        height: _heightController.text.isEmpty
            ? null
            : double.tryParse(_heightController.text),
        weight: _weightController.text.isEmpty
            ? null
            : double.tryParse(_weightController.text),
        emergencyContactName: _emergencyNameController.text.isEmpty
            ? null
            : _emergencyNameController.text,
        emergencyContactPhone: _emergencyPhoneController.text.isEmpty
            ? null
            : _emergencyPhoneController.text,
        foodAllergies: _foodAllergiesController.text.isEmpty
            ? null
            : _foodAllergiesController.text,
        otherDiseases: _otherDiseasesController.text.isEmpty
            ? null
            : _otherDiseasesController.text,
        hasDiabetes: _hasDiabetes,
        hasHypertension: _hasHypertension,
        hasAsthma: _hasAsthma,
        hasHeartDisease: _hasHeartDisease,
      );
      await userProvider.updateHealthProfile(healthUpdate);

      // Save bio to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_bio', _bioController.text);

      if (!mounted) return;

      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Cập nhật hồ sơ thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      print('[EditProfileScreen] Error saving profile: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giới tính',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _genderOptions.map((gender) {
            return ChoiceChip(
              label: Text(gender),
              selected: _selectedGender == gender,
              onSelected: (selected) {
                setState(() => _selectedGender = selected ? gender : null);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBloodTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nhóm máu',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _bloodTypeOptions.map((bloodType) {
            return FilterChip(
              label: Text(bloodType),
              selected: _selectedBloodType == bloodType,
              onSelected: (selected) {
                setState(
                    () => _selectedBloodType = selected ? bloodType : null);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    final age = _selectedDateOfBirth != null
        ? DateTime.now().year - _selectedDateOfBirth!.year
        : null;

    return GestureDetector(
      onTap: _selectDateOfBirth,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.outline,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 20, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ngày sinh',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedDateOfBirth != null
                        ? '${_selectedDateOfBirth!.day.toString().padLeft(2, '0')}/${_selectedDateOfBirth!.month.toString().padLeft(2, '0')}/${_selectedDateOfBirth!.year}'
                        : 'Chọn ngày sinh',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _selectedDateOfBirth != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (age != null)
                    Text(
                      'Tuổi: $age',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMICard() {
    final bmi = _currentBMI;
    if (bmi == null) return const SizedBox.shrink();

    final category = _bmiCategory;
    final color = _getBMIColor(category);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BMI: ${bmi.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                category,
                style: TextStyle(fontSize: 12, color: color),
              ),
            ],
          ),
          Icon(Icons.info_outline, color: color, size: 20),
        ],
      ),
    );
  }

  Widget _buildMedicalConditionsSelector() {
    final medicalConditions = [
      {'label': 'Tiểu đường', 'icon': Icons.medical_services, 'value': _hasDiabetes, 'setter': (bool v) => _hasDiabetes = v},
      {'label': 'Huyết áp cao', 'icon': Icons.favorite, 'value': _hasHypertension, 'setter': (bool v) => _hasHypertension = v},
      {'label': 'Hen suyễn', 'icon': Icons.air, 'value': _hasAsthma, 'setter': (bool v) => _hasAsthma = v},
      {'label': 'Bệnh tim', 'icon': Icons.heart_broken, 'value': _hasHeartDisease, 'setter': (bool v) => _hasHeartDisease = v},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tình trạng sức khỏe',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: medicalConditions.map((condition) {
            final isSelected = condition['value'] as bool;
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(condition['icon'] as IconData, size: 16),
                  const SizedBox(width: 4),
                  Text(condition['label'] as String),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  (condition['setter'] as Function(bool))(selected);
                });
              },
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _saveProfile,
            icon: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            tooltip: 'Lưu',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: 'Tài Khoản'),
            Tab(text: 'Hồ Sơ Sức Khỏe'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Tài khoản
            _buildAccountTab(),
            // Tab 2: Sức khỏe
            _buildHealthTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Số điện thoại
          const Text(
            'Số điện thoại',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _phoneController,
            label: 'Số điện thoại',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          // Giới tính
          _buildGenderSelector(),
          const SizedBox(height: 16),

          // Bio
          const Text(
            'Tiểu sử',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _bioController,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: 'Tiểu sử',
              prefixIcon: const Icon(Icons.description, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              hintText: 'Nhập tiểu sử của bạn...',
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHealthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ngày sinh
          _buildDateSelector(),
          const SizedBox(height: 16),

          // Nhóm máu
          _buildBloodTypeSelector(),
          const SizedBox(height: 24),

          // Chiều cao và cân nặng
          const Text(
            'Chỉ số cơ thể',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _heightController,
                  label: 'Chiều cao (cm)',
                  icon: Icons.height,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _weightController,
                  label: 'Cân nặng (kg)',
                  icon: Icons.monitor_weight,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBMICard(),
          const SizedBox(height: 24),

          // Bệnh lý
          _buildMedicalConditionsSelector(),
          const SizedBox(height: 24),

          // Liên hệ khẩn cấp
          const Text(
            'Liên hệ khẩn cấp',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _emergencyNameController,
            label: 'Tên người liên hệ',
            icon: Icons.person,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _emergencyPhoneController,
            label: 'Số điện thoại',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),

          // Thông tin bổ sung
          const Text(
            'Thông tin bổ sung',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _foodAllergiesController,
            label: 'Dị ứng thực phẩm',
            icon: Icons.restaurant,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _otherDiseasesController,
            label: 'Bệnh lý khác',
            icon: Icons.healing,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
