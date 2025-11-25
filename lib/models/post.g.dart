// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
  id: json['id'] as String,
  noiDung: json['noiDung'] as String,
  loai: json['loai'] as String?,
  duongDanMedia: json['duongDanMedia'] as String?,
  ngayDang: json['ngayDang'] == null
      ? null
      : DateTime.parse(json['ngayDang'] as String),
  luotThich: (json['luotThich'] as num?)?.toInt() ?? 0,
  soBinhLuan: (json['soBinhLuan'] as num?)?.toInt() ?? 0,
  soChiaSe: (json['soChiaSe'] as num?)?.toInt() ?? 0,
  isLiked: json['isLiked'] as bool? ?? false,
  hashtags: json['hashtags'] as String?,
  authorId: json['authorId'] as String? ?? '',
  authorName: json['authorName'] as String? ?? 'Anonymous',
  authorAvatar: json['authorAvatar'] as String?,
);

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  'id': instance.id,
  'noiDung': instance.noiDung,
  'loai': instance.loai,
  'duongDanMedia': instance.duongDanMedia,
  'ngayDang': instance.ngayDang?.toIso8601String(),
  'luotThich': instance.luotThich,
  'soBinhLuan': instance.soBinhLuan,
  'soChiaSe': instance.soChiaSe,
  'isLiked': instance.isLiked,
  'hashtags': instance.hashtags,
  'authorId': instance.authorId,
  'authorName': instance.authorName,
  'authorAvatar': instance.authorAvatar,
};

PostPagedResult _$PostPagedResultFromJson(Map<String, dynamic> json) =>
    PostPagedResult(
      posts:
          (json['posts'] as List<dynamic>?)
              ?.map((e) => Post.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      hasPrevious: json['hasPrevious'] as bool? ?? false,
      hasNext: json['hasNext'] as bool? ?? false,
    );

Map<String, dynamic> _$PostPagedResultToJson(PostPagedResult instance) =>
    <String, dynamic>{
      'posts': instance.posts,
      'totalCount': instance.totalCount,
      'page': instance.page,
      'pageSize': instance.pageSize,
      'totalPages': instance.totalPages,
      'hasPrevious': instance.hasPrevious,
      'hasNext': instance.hasNext,
    };
