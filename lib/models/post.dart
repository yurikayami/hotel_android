import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

/// Post model representing a social media post
@JsonSerializable()
class Post {
  final String id;
  @JsonKey(name: 'noiDung')
  final String noiDung;
  @JsonKey(name: 'loai')
  final String? loai;
  @JsonKey(name: 'duongDanMedia')
  final String? duongDanMedia;
  @JsonKey(name: 'ngayDang')
  final DateTime? ngayDang;
  @JsonKey(name: 'luotThich', defaultValue: 0)
  final int? luotThich;
  @JsonKey(name: 'soBinhLuan', defaultValue: 0)
  final int? soBinhLuan;
  @JsonKey(name: 'soChiaSe', defaultValue: 0)
  final int? soChiaSe;
  @JsonKey(defaultValue: false)
  final bool isLiked;
  final String? hashtags;
  @JsonKey(defaultValue: '')
  final String authorId;
  @JsonKey(defaultValue: 'Anonymous')
  final String authorName;
  final String? authorAvatar;

  Post({
    required this.id,
    required this.noiDung,
    this.loai,
    this.duongDanMedia,
    this.ngayDang,
    this.luotThich,
    this.soBinhLuan,
    this.soChiaSe,
    required this.isLiked,
    this.hashtags,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}

/// Paginated result for posts
@JsonSerializable()
class PostPagedResult {
  @JsonKey(defaultValue: [])
  final List<Post> posts;
  @JsonKey(defaultValue: 0)
  final int totalCount;
  @JsonKey(defaultValue: 1)
  final int page;
  @JsonKey(defaultValue: 10)
  final int pageSize;
  @JsonKey(defaultValue: 0)
  final int totalPages;
  @JsonKey(defaultValue: false)
  final bool hasPrevious;
  @JsonKey(defaultValue: false)
  final bool hasNext;

  PostPagedResult({
    this.posts = const [],
    this.totalCount = 0,
    this.page = 1,
    this.pageSize = 10,
    this.totalPages = 0,
    this.hasPrevious = false,
    this.hasNext = false,
  });

  factory PostPagedResult.fromJson(Map<String, dynamic> json) =>
      _$PostPagedResultFromJson(json);
  Map<String, dynamic> toJson() => _$PostPagedResultToJson(this);
}

