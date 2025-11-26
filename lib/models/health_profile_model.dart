import 'package:json_annotation/json_annotation.dart';

part 'health_profile_model.g.dart';

/// Health Profile DTO from /api/userprofile/health endpoint
/// Contains medical history and body metrics from HealthProfiles table
/// 
/// Important: `age` is AUTO-CALCULATED from dateOfBirth by the backend
/// Always has a valid value - do NOT send age in updates
@JsonSerializable()
class HealthProfileModel {
  final String? id;
  final DateTime? dateOfBirth;
  final String? bloodType;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final bool? hasDiabetes;
  final bool? hasHypertension;
  final bool? hasAsthma;
  final bool? hasHeartDisease;
  final String? foodAllergies;
  final int? age; // ✅ Auto-calculated from dateOfBirth
  final double? height;
  final double? weight;
  final String? gender;
  final String? otherDiseases;

  HealthProfileModel({
    this.id,
    this.dateOfBirth,
    this.bloodType,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.hasDiabetes,
    this.hasHypertension,
    this.hasAsthma,
    this.hasHeartDisease,
    this.foodAllergies,
    this.age,
    this.height,
    this.weight,
    this.gender,
    this.otherDiseases,
  });

  factory HealthProfileModel.fromJson(Map<String, dynamic> json) =>
      _$HealthProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$HealthProfileModelToJson(this);

  /// Calculate BMI from height and weight
  double? get bmi {
    if (height != null && weight != null && height! > 0) {
      final heightInMeters = height! / 100;
      return weight! / (heightInMeters * heightInMeters);
    }
    return null;
  }

  /// Get BMI category in Vietnamese
  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) {
      return 'N/A';
    }
    if (bmiValue < 18.5) {
      return 'Thiếu cân';
    }
    if (bmiValue < 25) {
      return 'Bình thường';
    }
    if (bmiValue < 30) {
      return 'Thừa cân';
    }
    return 'Béo phì';
  }

  /// Copy with method for easy updates
  HealthProfileModel copyWith({
    String? id,
    DateTime? dateOfBirth,
    String? bloodType,
    String? emergencyContactName,
    String? emergencyContactPhone,
    bool? hasDiabetes,
    bool? hasHypertension,
    bool? hasAsthma,
    bool? hasHeartDisease,
    String? foodAllergies,
    int? age,
    double? height,
    double? weight,
    String? gender,
    String? otherDiseases,
  }) {
    return HealthProfileModel(
      id: id ?? this.id,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodType: bloodType ?? this.bloodType,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      hasDiabetes: hasDiabetes ?? this.hasDiabetes,
      hasHypertension: hasHypertension ?? this.hasHypertension,
      hasAsthma: hasAsthma ?? this.hasAsthma,
      hasHeartDisease: hasHeartDisease ?? this.hasHeartDisease,
      foodAllergies: foodAllergies ?? this.foodAllergies,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      otherDiseases: otherDiseases ?? this.otherDiseases,
    );
  }
}

/// Update Health Profile DTO for sending data to /api/userprofile/health endpoint
/// Only includes health-related fields
/// 
/// ⚠️ IMPORTANT: Do NOT include `age` - it's auto-calculated from dateOfBirth
@JsonSerializable()
class UpdateHealthProfileDto {
  final DateTime? dateOfBirth;
  final String? bloodType;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final bool? hasDiabetes;
  final bool? hasHypertension;
  final bool? hasAsthma;
  final bool? hasHeartDisease;
  final String? foodAllergies;
  final double? height;
  final double? weight;
  final String? gender;
  final String? otherDiseases;

  UpdateHealthProfileDto({
    this.dateOfBirth,
    this.bloodType,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.hasDiabetes,
    this.hasHypertension,
    this.hasAsthma,
    this.hasHeartDisease,
    this.foodAllergies,
    this.height,
    this.weight,
    this.gender,
    this.otherDiseases,
  });

  factory UpdateHealthProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateHealthProfileDtoFromJson(json);

  /// Custom toJson that excludes null AND empty string values
  Map<String, dynamic> toJson() {
    final json = _$UpdateHealthProfileDtoToJson(this);
    json.removeWhere((key, value) {
      return value == null || (value is String && value.isEmpty);
    });
    return json;
  }

  /// Create from HealthProfileModel
  factory UpdateHealthProfileDto.fromModel(HealthProfileModel model) {
    return UpdateHealthProfileDto(
      dateOfBirth: model.dateOfBirth,
      bloodType: model.bloodType,
      emergencyContactName: model.emergencyContactName,
      emergencyContactPhone: model.emergencyContactPhone,
      hasDiabetes: model.hasDiabetes,
      hasHypertension: model.hasHypertension,
      hasAsthma: model.hasAsthma,
      hasHeartDisease: model.hasHeartDisease,
      foodAllergies: model.foodAllergies,
      height: model.height,
      weight: model.weight,
      gender: model.gender,
      otherDiseases: model.otherDiseases,
    );
  }
}
