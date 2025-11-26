// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  userId: json['userId'] as String?,
  userName: json['userName'] as String?,
  displayName: json['displayName'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  email: json['email'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  avatar: json['avatar'] as String?,
  gender: json['gender'] as String?,
  gioiTinh: json['gioi_tinh'] as String?,
  age: (json['age'] as num?)?.toInt(),
  lanHoatDongCuoi: json['lan_hoat_dong_cuoi'] == null
      ? null
      : DateTime.parse(json['lan_hoat_dong_cuoi'] as String),
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
  height: (json['height'] as num?)?.toDouble(),
  weight: (json['weight'] as num?)?.toDouble(),
  bloodType: json['bloodType'] as String?,
  emergencyContactName: json['emergencyContactName'] as String?,
  emergencyContactPhone: json['emergencyContactPhone'] as String?,
  insuranceNumber: json['insuranceNumber'] as String?,
  insuranceProvider: json['insuranceProvider'] as String?,
  hasDiabetes: json['hasDiabetes'] as bool?,
  hasHypertension: json['hasHypertension'] as bool?,
  hasAsthma: json['hasAsthma'] as bool?,
  hasHeartDisease: json['hasHeartDisease'] as bool?,
  hasFoodAllergy: json['hasFoodAllergy'] as bool?,
  hasDrugAllergy: json['hasDrugAllergy'] as bool?,
  hasLatexAllergy: json['hasLatexAllergy'] as bool?,
  drugAllergies: json['drugAllergies'] as String?,
  foodAllergies: json['foodAllergies'] as String?,
  otherDiseases: json['otherDiseases'] as String?,
  familyHistory: json['familyHistory'] as String?,
  currentMedications: (json['currentMedications'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  activityLevel: json['activityLevel'] as String?,
  emergencyNotes: json['emergencyNotes'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'userId': ?instance.userId,
      'userName': ?instance.userName,
      'displayName': ?instance.displayName,
      'phoneNumber': ?instance.phoneNumber,
      'email': ?instance.email,
      'avatarUrl': ?instance.avatarUrl,
      'avatar': ?instance.avatar,
      'gender': ?instance.gender,
      'gioi_tinh': ?instance.gioiTinh,
      'age': ?instance.age,
      'lan_hoat_dong_cuoi': ?instance.lanHoatDongCuoi?.toIso8601String(),
      'dateOfBirth': ?instance.dateOfBirth?.toIso8601String(),
      'height': ?instance.height,
      'weight': ?instance.weight,
      'bloodType': ?instance.bloodType,
      'emergencyContactName': ?instance.emergencyContactName,
      'emergencyContactPhone': ?instance.emergencyContactPhone,
      'insuranceNumber': ?instance.insuranceNumber,
      'insuranceProvider': ?instance.insuranceProvider,
      'hasDiabetes': ?instance.hasDiabetes,
      'hasHypertension': ?instance.hasHypertension,
      'hasAsthma': ?instance.hasAsthma,
      'hasHeartDisease': ?instance.hasHeartDisease,
      'hasFoodAllergy': ?instance.hasFoodAllergy,
      'hasDrugAllergy': ?instance.hasDrugAllergy,
      'hasLatexAllergy': ?instance.hasLatexAllergy,
      'drugAllergies': ?instance.drugAllergies,
      'foodAllergies': ?instance.foodAllergies,
      'otherDiseases': ?instance.otherDiseases,
      'familyHistory': ?instance.familyHistory,
      'currentMedications': ?instance.currentMedications,
      'activityLevel': ?instance.activityLevel,
      'emergencyNotes': ?instance.emergencyNotes,
      'createdAt': ?instance.createdAt?.toIso8601String(),
      'updatedAt': ?instance.updatedAt?.toIso8601String(),
    };

UpdateProfileDto _$UpdateProfileDtoFromJson(Map<String, dynamic> json) =>
    UpdateProfileDto(
      displayName: json['displayName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      age: (json['age'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      bloodType: json['bloodType'] as String?,
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactPhone: json['emergencyContactPhone'] as String?,
      insuranceNumber: json['insuranceNumber'] as String?,
      insuranceProvider: json['insuranceProvider'] as String?,
      hasDiabetes: json['hasDiabetes'] as bool?,
      hasHypertension: json['hasHypertension'] as bool?,
      hasAsthma: json['hasAsthma'] as bool?,
      hasHeartDisease: json['hasHeartDisease'] as bool?,
      hasFoodAllergy: json['hasFoodAllergy'] as bool?,
      hasDrugAllergy: json['hasDrugAllergy'] as bool?,
      hasLatexAllergy: json['hasLatexAllergy'] as bool?,
      drugAllergies: json['drugAllergies'] as String?,
      foodAllergies: json['foodAllergies'] as String?,
      otherDiseases: json['otherDiseases'] as String?,
      familyHistory: json['familyHistory'] as String?,
      currentMedications: (json['currentMedications'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      emergencyNotes: json['emergencyNotes'] as String?,
    );

Map<String, dynamic> _$UpdateProfileDtoToJson(UpdateProfileDto instance) =>
    <String, dynamic>{
      'displayName': ?instance.displayName,
      'phoneNumber': ?instance.phoneNumber,
      'gender': ?instance.gender,
      'dateOfBirth': ?instance.dateOfBirth?.toIso8601String(),
      'age': ?instance.age,
      'height': ?instance.height,
      'weight': ?instance.weight,
      'bloodType': ?instance.bloodType,
      'emergencyContactName': ?instance.emergencyContactName,
      'emergencyContactPhone': ?instance.emergencyContactPhone,
      'insuranceNumber': ?instance.insuranceNumber,
      'insuranceProvider': ?instance.insuranceProvider,
      'hasDiabetes': ?instance.hasDiabetes,
      'hasHypertension': ?instance.hasHypertension,
      'hasAsthma': ?instance.hasAsthma,
      'hasHeartDisease': ?instance.hasHeartDisease,
      'hasFoodAllergy': ?instance.hasFoodAllergy,
      'hasDrugAllergy': ?instance.hasDrugAllergy,
      'hasLatexAllergy': ?instance.hasLatexAllergy,
      'drugAllergies': ?instance.drugAllergies,
      'foodAllergies': ?instance.foodAllergies,
      'otherDiseases': ?instance.otherDiseases,
      'familyHistory': ?instance.familyHistory,
      'currentMedications': ?instance.currentMedications,
      'emergencyNotes': ?instance.emergencyNotes,
    };
