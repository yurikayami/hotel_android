import 'package:json_annotation/json_annotation.dart';

part 'user_basic_model.g.dart';

/// User Basic Profile DTO from /api/userprofile/basic endpoint
/// Contains account and identity information from AspNetUsers table
/// 
/// Note: `age` will be null in this endpoint - use HealthProfileModel for age
@JsonSerializable()
class UserBasicModel {
  final String? id;
  final String? userName;
  final String? phoneNumber;
  final String? gender;
  @JsonKey(includeFromJson: true, includeToJson: false)
  final int? age; // ⚠️ Will be null - age comes from health profile only
  final String? profilePicture;

  UserBasicModel({
    this.id,
    this.userName,
    this.phoneNumber,
    this.gender,
    this.age,
    this.profilePicture,
  });

  factory UserBasicModel.fromJson(Map<String, dynamic> json) =>
      _$UserBasicModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserBasicModelToJson(this);

  /// Copy with method for easy updates
  UserBasicModel copyWith({
    String? id,
    String? userName,
    String? phoneNumber,
    String? gender,
    int? age,
    String? profilePicture,
  }) {
    return UserBasicModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}

/// Update Basic Profile DTO for sending data to /api/userprofile/basic endpoint
/// Only includes account-related fields
@JsonSerializable()
class UpdateBasicProfileDto {
  final String? phoneNumber;
  final String? gender;
  final String? profilePicture;

  UpdateBasicProfileDto({
    this.phoneNumber,
    this.gender,
    this.profilePicture,
  });

  factory UpdateBasicProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateBasicProfileDtoFromJson(json);

  /// Custom toJson that excludes null AND empty string values
  Map<String, dynamic> toJson() {
    final json = _$UpdateBasicProfileDtoToJson(this);
    json.removeWhere((key, value) {
      return value == null || (value is String && value.isEmpty);
    });
    return json;
  }

  /// Create from UserBasicModel
  factory UpdateBasicProfileDto.fromModel(UserBasicModel model) {
    return UpdateBasicProfileDto(
      phoneNumber: model.phoneNumber,
      gender: model.gender,
      profilePicture: model.profilePicture,
    );
  }
}
