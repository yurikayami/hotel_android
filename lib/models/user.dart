import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// User model representing application user
@JsonSerializable()
class User {
  final String id;
  final String userName;
  final String email;
  final int? tuoi;
  @JsonKey(name: 'gioi_tinh')
  final String? gioiTinh;
  final String? profilePicture;
  final String? displayName;
  final String? avatarUrl;

  User({
    required this.id,
    required this.userName,
    required this.email,
    this.tuoi,
    this.gioiTinh,
    this.profilePicture,
    this.displayName,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

/// Authentication response from API
@JsonSerializable()
class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final User? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

