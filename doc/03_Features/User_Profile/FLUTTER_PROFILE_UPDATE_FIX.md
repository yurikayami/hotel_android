# Flutter Profile Update Fix Guide

## Vấn Đề
App Flutter không thể update profile vì không gửi đúng định dạng DTO khớp với backend `UpdateProfileDto`. Backend đã fix model `HealthProfile`, giờ cần cập nhật Flutter để gửi request đúng.

## Các File Cần Sửa

### 1. user_profile.dart (Model)
Cập nhật class `UserProfile` để bao gồm tất cả trường từ `UpdateProfileDto`:

```dart
// filepath: d:\Workspace\01 Project\Project Dev\Graduation project\Main Project\Hotel_API v2\Hotel_API\Doc\Flutter code\user_profile.dart

class UserProfile {
  String userId;
  String? userName;
  String displayName;
  String? phoneNumber;
  String? email;
  String? avatarUrl;
  String avatar;
  String gender; // Thêm trường này
  String? gioi_tinh;
  int? age;
  DateTime? lan_hoat_dong_cuoi;
  DateTime? dateOfBirth;
  double? height;
  double? weight;
  String? bloodType;
  String? emergencyContactName;
  String? emergencyContactPhone;
  String? insuranceNumber;
  String? insuranceProvider;
  bool hasDiabetes;
  bool hasHypertension;
  bool hasAsthma;
  bool hasHeartDisease;
  bool? hasFoodAllergy;
  bool? hasDrugAllergy;
  bool hasLatexAllergy;
  String drugAllergies;
  String foodAllergies;
  String otherDiseases;
  String? familyHistory;
  List<String> currentMedications;
  String activityLevel;
  String emergencyNotes;
  DateTime? createdAt;
  DateTime? updatedAt;

  UserProfile({
    required this.userId,
    this.userName,
    required this.displayName,
    this.phoneNumber,
    this.email,
    this.avatarUrl,
    required this.avatar,
    required this.gender, // Thêm required
    this.gioi_tinh,
    this.age,
    this.lan_hoat_dong_cuoi,
    this.dateOfBirth,
    this.height,
    this.weight,
    this.bloodType,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.insuranceNumber,
    this.insuranceProvider,
    required this.hasDiabetes,
    required this.hasHypertension,
    required this.hasAsthma,
    required this.hasHeartDisease,
    this.hasFoodAllergy,
    this.hasDrugAllergy,
    required this.hasLatexAllergy,
    required this.drugAllergies,
    required this.foodAllergies,
    required this.otherDiseases,
    this.familyHistory,
    required this.currentMedications,
    required this.activityLevel,
    required this.emergencyNotes,
    this.createdAt,
    this.updatedAt,
  });

  // Thêm method toJson cho update
  Map<String, dynamic> toUpdateDto() {
    return {
      "DisplayName": displayName,
      "Avatar": avatar,
      "Gender": gender,
      "Age": age,
      "Height": height,
      "Weight": weight,
      "DateOfBirth": dateOfBirth?.toIso8601String(),
      "BloodType": bloodType ?? "",
      "EmergencyContactName": emergencyContactName ?? "",
      "EmergencyContactPhone": emergencyContactPhone ?? "",
      "InsuranceNumber": insuranceNumber ?? "",
      "InsuranceProvider": insuranceProvider ?? "",
      "HasDiabetes": hasDiabetes,
      "HasHypertension": hasHypertension,
      "HasAsthma": hasAsthma,
      "HasHeartDisease": hasHeartDisease,
      "HasLatexAllergy": hasLatexAllergy,
      "DrugAllergies": drugAllergies,
      "FoodAllergies": foodAllergies,
      "OtherDiseases": otherDiseases,
      "ActivityLevel": activityLevel,
      "CurrentMedicationsJson": jsonEncode(currentMedications), // Convert list to JSON string
      "EmergencyNotes": emergencyNotes,
    };
  }

  // ...existing fromJson and toJson methods...
}
```

### 2. edit_profile_screen.dart (UI Logic)
Cập nhật method `_saveProfile` để tạo và gửi DTO đúng:

```dart
// filepath: d:\Workspace\01 Project\Project Dev\Graduation project\Main Project\Hotel_API v2\Hotel_API\Doc\Flutter code\edit_profile_screen.dart

// ...existing code...

void _saveProfile() async {
  print("[EditProfileScreen] Save button pressed");

  // Tạo profile object từ form controllers
  final updatedProfile = UserProfile(
    userId: widget.userId,
    displayName: _displayNameController.text,
    avatar: _avatarController.text, // Giả sử có controller này
    gender: _genderController.text,
    age: int.tryParse(_ageController.text),
    height: double.tryParse(_heightController.text),
    weight: double.tryParse(_weightController.text),
    dateOfBirth: _selectedDateOfBirth,
    bloodType: _bloodTypeController.text,
    emergencyContactName: _emergencyContactNameController.text,
    emergencyContactPhone: _emergencyContactPhoneController.text,
    insuranceNumber: _insuranceNumberController.text,
    insuranceProvider: _insuranceProviderController.text,
    hasDiabetes: _hasDiabetes,
    hasHypertension: _hasHypertension,
    hasAsthma: _hasAsthma,
    hasHeartDisease: _hasHeartDisease,
    hasLatexAllergy: _hasLatexAllergy,
    drugAllergies: _drugAllergiesController.text,
    foodAllergies: _foodAllergiesController.text,
    otherDiseases: _otherDiseasesController.text,
    currentMedications: _currentMedications, // List<String>
    activityLevel: _activityLevelController.text,
    emergencyNotes: _emergencyNotesController.text,
    // Các trường khác giữ nguyên từ profile hiện tại
    userName: _userProvider.userProfile?.userName,
    phoneNumber: _userProvider.userProfile?.phoneNumber,
    email: _userProvider.userProfile?.email,
    avatarUrl: _userProvider.userProfile?.avatarUrl,
    gioi_tinh: _userProvider.userProfile?.gioi_tinh,
    lan_hoat_dong_cuoi: _userProvider.userProfile?.lan_hoat_dong_cuoi,
    hasFoodAllergy: _userProvider.userProfile?.hasFoodAllergy,
    hasDrugAllergy: _userProvider.userProfile?.hasDrugAllergy,
    familyHistory: _userProvider.userProfile?.familyHistory,
    createdAt: _userProvider.userProfile?.createdAt,
    updatedAt: DateTime.now(),
  );

  final updateDto = updatedProfile.toUpdateDto();
  print("[EditProfileScreen] Sending update DTO: $updateDto");

  try {
    await _userProvider.saveProfile(updateDto);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully!')),
    );
    Navigator.pop(context); // Quay lại màn hình trước
  } catch (e) {
    print("[EditProfileScreen] Error saving profile: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update profile: $e')),
    );
  }
}

// ...existing code...
```

### 3. user_service.dart (API Call)
Cập nhật method `updateUserProfile` để gửi đúng endpoint và body:

```dart
// filepath: d:\Workspace\01 Project\Project Dev\Graduation project\Main Project\Hotel_API v2\Hotel_API\Doc\Flutter code\user_service.dart

// ...existing code...

Future<void> updateUserProfile(String userId, Map<String, dynamic> updateDto) async {
  print("[UserService] Updating profile for user: $userId");

  final url = Uri.parse('$baseUrl/api/user/profile'); // Đảm bảo endpoint đúng
  final token = await _getToken(); // Giả sử có method lấy token

  try {
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Nếu cần auth
      },
      body: jsonEncode(updateDto),
    );

    print("[UserService] Response status: ${response.statusCode}");
    print("[UserService] Response body: ${response.body}");

    if (response.statusCode == 200) {
      print("[UserService] Profile updated successfully");
    } else {
      throw Exception('Server error - Status: ${response.statusCode}, Body: ${response.body}');
    }
  } catch (e) {
    print("[UserService] Error updating profile: $e");
    throw e;
  }
}

// ...existing code...
```

## Bước Thực Hiện
1. Áp dụng các thay đổi trên vào code Flutter.
2. Build lại app: `flutter clean && flutter pub get && flutter run`.
3. Test: Load profile, chỉnh sửa (ví dụ: Gender = "Nam"), nhấn Save.
4. Kiểm tra log Flutter và backend để đảm bảo request gửi đúng.

## Lưu Ý
- Đảm bảo tất cả controllers (TextEditingController) được khai báo và bind với form fields trong `edit_profile_screen.dart`.
- Nếu dùng JSON serialization, regenerate `user_profile.g.dart`: `flutter pub run build_runner build`.
- Endpoint backend: `PUT /api/user/profile` (kiểm tra controller backend để xác nhận).
- Nếu vẫn lỗi, kiểm tra log backend chi tiết để debug DTO mismatch.</content>
<parameter name="filePath">d:\Workspace\01 Project\Project Dev\Graduation project\Main Project\Hotel_API v2\Hotel_API\Doc\FLUTTER_PROFILE_UPDATE_FIX.md