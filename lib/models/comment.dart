import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

/// Comment model for post comments
@JsonSerializable()
class Comment {
  final String id;
  @JsonKey(name: 'noiDung')
  final String noiDung;
  @JsonKey(name: 'ngayTao')
  final DateTime ngayTao;
  final String? parentCommentId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.noiDung,
    required this.ngayTao,
    this.parentCommentId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

