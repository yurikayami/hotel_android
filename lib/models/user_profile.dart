import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

/// User profile DTO combining ApplicationUser and HealthProfile data
/// Maps to backend UserProfileDto
@JsonSerializable(includeIfNull: false)
class UserProfile {
  final String? userId;
  final String? userName;
  final String? displayName;
  final String? phoneNumber;
  final String? email;
  final String? avatarUrl;
  final String? avatar;
  final String? gender;
  @JsonKey(name: 'gioi_tinh')
  final String? gioiTinh;
  final int? age;
  @JsonKey(name: 'lan_hoat_dong_cuoi')
  final DateTime? lanHoatDongCuoi;

  // Health Profile fields
  final DateTime? dateOfBirth;
  final double? height;
  final double? weight;
  final String? bloodType;
  
  // Emergency contact
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  
  // Insurance
  final String? insuranceNumber;
  final String? insuranceProvider;
  
  // Medical conditions (Boolean flags)
  final bool? hasDiabetes;
  final bool? hasHypertension;
  final bool? hasAsthma;
  final bool? hasHeartDisease;
  final bool? hasFoodAllergy;
  final bool? hasDrugAllergy;
  final bool? hasLatexAllergy;
  
  // Medical text info
  final String? drugAllergies;
  final String? foodAllergies;
  final String? otherDiseases;
  final String? familyHistory;
  final List<String>? currentMedications;
  
  // Additional fields from backend
  final String? activityLevel;
  
  // Metadata
  final String? emergencyNotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    this.userId,
    this.userName,
    this.displayName,
    this.phoneNumber,
    this.email,
    this.avatarUrl,
    this.avatar,
    this.gender,
    this.gioiTinh,
    this.age,
    this.lanHoatDongCuoi,
    this.dateOfBirth,
    this.height,
    this.weight,
    this.bloodType,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.insuranceNumber,
    this.insuranceProvider,
    this.hasDiabetes,
    this.hasHypertension,
    this.hasAsthma,
    this.hasHeartDisease,
    this.hasFoodAllergy,
    this.hasDrugAllergy,
    this.hasLatexAllergy,
    this.drugAllergies,
    this.foodAllergies,
    this.otherDiseases,
    this.familyHistory,
    this.currentMedications,
    this.activityLevel,
    this.emergencyNotes,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  /// Convert to UpdateProfileDto format for backend API
  Map<String, dynamic> toUpdateDto() {
    return {
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'age': age,
      'height': height,
      'weight': weight,
      'bloodType': bloodType,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'insuranceNumber': insuranceNumber,
      'insuranceProvider': insuranceProvider,
      'hasDiabetes': hasDiabetes ?? false,
      'hasHypertension': hasHypertension ?? false,
      'hasAsthma': hasAsthma ?? false,
      'hasHeartDisease': hasHeartDisease ?? false,
      'hasFoodAllergy': hasFoodAllergy ?? false,
      'hasDrugAllergy': hasDrugAllergy ?? false,
      'hasLatexAllergy': hasLatexAllergy ?? false,
      'drugAllergies': drugAllergies,
      'foodAllergies': foodAllergies,
      'otherDiseases': otherDiseases,
      'familyHistory': familyHistory,
      'currentMedications': currentMedications ?? [],
      'activityLevel': activityLevel,
      'emergencyNotes': emergencyNotes,
    };
  }

  /// Calculate BMI from height and weight
  double? get bmi {
    if (height != null && weight != null && height! > 0) {
      final heightInMeters = height! / 100;
      return weight! / (heightInMeters * heightInMeters);
    }
    return null;
  }

  /// Get BMI category
  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return 'N/A';
    if (bmiValue < 18.5) return 'Thiếu cân';
    if (bmiValue < 25) return 'Bình thường';
    if (bmiValue < 30) return 'Thừa cân';
    return 'Béo phì';
  }

  /// Copy with method for easy updates
  UserProfile copyWith({
    String? userId,
    String? userName,
    String? displayName,
    String? phoneNumber,
    String? email,
    String? avatarUrl,
    String? gender,
    String? gioiTinh,
    int? age,
    DateTime? lanHoatDongCuoi,
    DateTime? dateOfBirth,
    double? height,
    double? weight,
    String? bloodType,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? insuranceNumber,
    String? insuranceProvider,
    bool? hasDiabetes,
    bool? hasHypertension,
    bool? hasAsthma,
    bool? hasHeartDisease,
    bool? hasFoodAllergy,
    bool? hasDrugAllergy,
    bool? hasLatexAllergy,
    String? drugAllergies,
    String? foodAllergies,
    String? otherDiseases,
    String? familyHistory,
    List<String>? currentMedications,
    String? emergencyNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      gioiTinh: gioiTinh ?? this.gioiTinh,
      age: age ?? this.age,
      lanHoatDongCuoi: lanHoatDongCuoi ?? this.lanHoatDongCuoi,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bloodType: bloodType ?? this.bloodType,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      insuranceNumber: insuranceNumber ?? this.insuranceNumber,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      hasDiabetes: hasDiabetes ?? this.hasDiabetes,
      hasHypertension: hasHypertension ?? this.hasHypertension,
      hasAsthma: hasAsthma ?? this.hasAsthma,
      hasHeartDisease: hasHeartDisease ?? this.hasHeartDisease,
      hasFoodAllergy: hasFoodAllergy ?? this.hasFoodAllergy,
      hasDrugAllergy: hasDrugAllergy ?? this.hasDrugAllergy,
      hasLatexAllergy: hasLatexAllergy ?? this.hasLatexAllergy,
      drugAllergies: drugAllergies ?? this.drugAllergies,
      foodAllergies: foodAllergies ?? this.foodAllergies,
      otherDiseases: otherDiseases ?? this.otherDiseases,
      familyHistory: familyHistory ?? this.familyHistory,
      currentMedications: currentMedications ?? this.currentMedications,
      emergencyNotes: emergencyNotes ?? this.emergencyNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Update profile DTO for sending data to backend
/// Maps to backend UpdateProfileDto
@JsonSerializable(includeIfNull: false)
class UpdateProfileDto {
  final String? displayName;
  final String? phoneNumber;
  final String? gender;
  final DateTime? dateOfBirth;
  final int? age;
  final double? height;
  final double? weight;
  final String? bloodType;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? insuranceNumber;
  final String? insuranceProvider;
  final bool? hasDiabetes;
  final bool? hasHypertension;
  final bool? hasAsthma;
  final bool? hasHeartDisease;
  final bool? hasFoodAllergy;
  final bool? hasDrugAllergy;
  final bool? hasLatexAllergy;
  final String? drugAllergies;
  final String? foodAllergies;
  final String? otherDiseases;
  final String? familyHistory;
  final List<String>? currentMedications;
  final String? emergencyNotes;

  UpdateProfileDto({
    this.displayName,
    this.phoneNumber,
    this.gender,
    this.dateOfBirth,
    this.age,
    this.height,
    this.weight,
    this.bloodType,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.insuranceNumber,
    this.insuranceProvider,
    this.hasDiabetes,
    this.hasHypertension,
    this.hasAsthma,
    this.hasHeartDisease,
    this.hasFoodAllergy,
    this.hasDrugAllergy,
    this.hasLatexAllergy,
    this.drugAllergies,
    this.foodAllergies,
    this.otherDiseases,
    this.familyHistory,
    this.currentMedications,
    this.emergencyNotes,
  });

  factory UpdateProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileDtoFromJson(json);
  
  /// Custom toJson that excludes null AND empty string values
  /// This prevents backend from receiving empty strings that would overwrite existing data
  Map<String, dynamic> toJson() {
    final json = _$UpdateProfileDtoToJson(this);
    // Remove null entries (already done by includeIfNull: false)
    // Also remove empty string entries to prevent data loss
    json.removeWhere((key, value) {
      return value == null || (value is String && value.isEmpty);
    });
    return json;
  }

  /// Merge with old profile data to avoid sending null values to backend
  /// This ensures we don't accidentally clear fields that the user didn't modify
  /// 
  /// [oldProfile] - The previous profile data from server
  /// Returns a new UpdateProfileDto with non-empty values merged from old profile
  UpdateProfileDto mergeWithOldProfile(UserProfile oldProfile) {
    return UpdateProfileDto(
      displayName: (displayName?.isNotEmpty ?? false) ? displayName : oldProfile.displayName,
      phoneNumber: (phoneNumber?.isNotEmpty ?? false) ? phoneNumber : oldProfile.phoneNumber,
      gender: gender ?? oldProfile.gender,
      dateOfBirth: dateOfBirth ?? oldProfile.dateOfBirth,
      age: age ?? oldProfile.age,
      height: height ?? oldProfile.height,
      weight: weight ?? oldProfile.weight,
      bloodType: bloodType ?? oldProfile.bloodType,
      emergencyContactName: (emergencyContactName?.isNotEmpty ?? false) ? emergencyContactName : oldProfile.emergencyContactName,
      emergencyContactPhone: (emergencyContactPhone?.isNotEmpty ?? false) ? emergencyContactPhone : oldProfile.emergencyContactPhone,
      insuranceNumber: (insuranceNumber?.isNotEmpty ?? false) ? insuranceNumber : oldProfile.insuranceNumber,
      insuranceProvider: (insuranceProvider?.isNotEmpty ?? false) ? insuranceProvider : oldProfile.insuranceProvider,
      hasDiabetes: hasDiabetes ?? oldProfile.hasDiabetes ?? false,
      hasHypertension: hasHypertension ?? oldProfile.hasHypertension ?? false,
      hasAsthma: hasAsthma ?? oldProfile.hasAsthma ?? false,
      hasHeartDisease: hasHeartDisease ?? oldProfile.hasHeartDisease ?? false,
      hasFoodAllergy: hasFoodAllergy ?? oldProfile.hasFoodAllergy ?? false,
      hasDrugAllergy: hasDrugAllergy ?? oldProfile.hasDrugAllergy ?? false,
      hasLatexAllergy: hasLatexAllergy ?? oldProfile.hasLatexAllergy ?? false,
      drugAllergies: (drugAllergies?.isNotEmpty ?? false) ? drugAllergies : oldProfile.drugAllergies,
      foodAllergies: (foodAllergies?.isNotEmpty ?? false) ? foodAllergies : oldProfile.foodAllergies,
      otherDiseases: (otherDiseases?.isNotEmpty ?? false) ? otherDiseases : oldProfile.otherDiseases,
      familyHistory: (familyHistory?.isNotEmpty ?? false) ? familyHistory : oldProfile.familyHistory,
      currentMedications: (currentMedications?.isNotEmpty ?? false) ? currentMedications : oldProfile.currentMedications,
      emergencyNotes: (emergencyNotes?.isNotEmpty ?? false) ? emergencyNotes : oldProfile.emergencyNotes,
    );
  }

  /// Create from UserProfile for editing
  factory UpdateProfileDto.fromProfile(UserProfile profile) {
    return UpdateProfileDto(
      displayName: profile.displayName,
      phoneNumber: profile.phoneNumber,
      gender: profile.gender,
      dateOfBirth: profile.dateOfBirth,
      age: profile.age,
      height: profile.height,
      weight: profile.weight,
      bloodType: profile.bloodType,
      emergencyContactName: profile.emergencyContactName,
      emergencyContactPhone: profile.emergencyContactPhone,
      insuranceNumber: profile.insuranceNumber,
      insuranceProvider: profile.insuranceProvider,
      hasDiabetes: profile.hasDiabetes,
      hasHypertension: profile.hasHypertension,
      hasAsthma: profile.hasAsthma,
      hasHeartDisease: profile.hasHeartDisease,
      hasFoodAllergy: profile.hasFoodAllergy,
      hasDrugAllergy: profile.hasDrugAllergy,
      hasLatexAllergy: profile.hasLatexAllergy,
      drugAllergies: profile.drugAllergies,
      foodAllergies: profile.foodAllergies,
      otherDiseases: profile.otherDiseases,
      familyHistory: profile.familyHistory,
      currentMedications: profile.currentMedications,
      emergencyNotes: profile.emergencyNotes,
    );
  }
}
