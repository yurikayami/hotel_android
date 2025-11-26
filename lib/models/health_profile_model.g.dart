// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthProfileModel _$HealthProfileModelFromJson(Map<String, dynamic> json) =>
    HealthProfileModel(
      id: json['id'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      bloodType: json['bloodType'] as String?,
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactPhone: json['emergencyContactPhone'] as String?,
      hasDiabetes: json['hasDiabetes'] as bool?,
      hasHypertension: json['hasHypertension'] as bool?,
      hasAsthma: json['hasAsthma'] as bool?,
      hasHeartDisease: json['hasHeartDisease'] as bool?,
      foodAllergies: json['foodAllergies'] as String?,
      age: (json['age'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      gender: json['gender'] as String?,
      otherDiseases: json['otherDiseases'] as String?,
    );

Map<String, dynamic> _$HealthProfileModelToJson(HealthProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'bloodType': instance.bloodType,
      'emergencyContactName': instance.emergencyContactName,
      'emergencyContactPhone': instance.emergencyContactPhone,
      'hasDiabetes': instance.hasDiabetes,
      'hasHypertension': instance.hasHypertension,
      'hasAsthma': instance.hasAsthma,
      'hasHeartDisease': instance.hasHeartDisease,
      'foodAllergies': instance.foodAllergies,
      'age': instance.age,
      'height': instance.height,
      'weight': instance.weight,
      'gender': instance.gender,
      'otherDiseases': instance.otherDiseases,
    };

UpdateHealthProfileDto _$UpdateHealthProfileDtoFromJson(
  Map<String, dynamic> json,
) => UpdateHealthProfileDto(
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
  bloodType: json['bloodType'] as String?,
  emergencyContactName: json['emergencyContactName'] as String?,
  emergencyContactPhone: json['emergencyContactPhone'] as String?,
  hasDiabetes: json['hasDiabetes'] as bool?,
  hasHypertension: json['hasHypertension'] as bool?,
  hasAsthma: json['hasAsthma'] as bool?,
  hasHeartDisease: json['hasHeartDisease'] as bool?,
  foodAllergies: json['foodAllergies'] as String?,
  height: (json['height'] as num?)?.toDouble(),
  weight: (json['weight'] as num?)?.toDouble(),
  gender: json['gender'] as String?,
  otherDiseases: json['otherDiseases'] as String?,
);

Map<String, dynamic> _$UpdateHealthProfileDtoToJson(
  UpdateHealthProfileDto instance,
) => <String, dynamic>{
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
  'bloodType': instance.bloodType,
  'emergencyContactName': instance.emergencyContactName,
  'emergencyContactPhone': instance.emergencyContactPhone,
  'hasDiabetes': instance.hasDiabetes,
  'hasHypertension': instance.hasHypertension,
  'hasAsthma': instance.hasAsthma,
  'hasHeartDisease': instance.hasHeartDisease,
  'foodAllergies': instance.foodAllergies,
  'height': instance.height,
  'weight': instance.weight,
  'gender': instance.gender,
  'otherDiseases': instance.otherDiseases,
};
