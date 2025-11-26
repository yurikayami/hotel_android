// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_basic_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserBasicModel _$UserBasicModelFromJson(Map<String, dynamic> json) =>
    UserBasicModel(
      id: json['id'] as String?,
      userName: json['userName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      gender: json['gender'] as String?,
      age: (json['age'] as num?)?.toInt(),
      profilePicture: json['profilePicture'] as String?,
    );

Map<String, dynamic> _$UserBasicModelToJson(UserBasicModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userName': instance.userName,
      'phoneNumber': instance.phoneNumber,
      'gender': instance.gender,
      'profilePicture': instance.profilePicture,
    };

UpdateBasicProfileDto _$UpdateBasicProfileDtoFromJson(
  Map<String, dynamic> json,
) => UpdateBasicProfileDto(
  phoneNumber: json['phoneNumber'] as String?,
  gender: json['gender'] as String?,
  profilePicture: json['profilePicture'] as String?,
);

Map<String, dynamic> _$UpdateBasicProfileDtoToJson(
  UpdateBasicProfileDto instance,
) => <String, dynamic>{
  'phoneNumber': instance.phoneNumber,
  'gender': instance.gender,
  'profilePicture': instance.profilePicture,
};
