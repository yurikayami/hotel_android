// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mon_an.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonAn _$MonAnFromJson(Map<String, dynamic> json) => MonAn(
  id: json['id'] as String,
  ten: json['ten'] as String,
  moTa: json['moTa'] as String?,
  cachCheBien: json['cachCheBien'] as String?,
  loai: json['loai'] as String?,
  ngayTao: json['ngayTao'] == null
      ? null
      : DateTime.parse(json['ngayTao'] as String),
  image: json['image'] as String?,
  gia: (json['gia'] as num?)?.toDouble(),
  soNguoi: (json['soNguoi'] as num?)?.toInt(),
  luotXem: (json['luotXem'] as num?)?.toInt(),
);

Map<String, dynamic> _$MonAnToJson(MonAn instance) => <String, dynamic>{
  'id': instance.id,
  'ten': instance.ten,
  'moTa': instance.moTa,
  'cachCheBien': instance.cachCheBien,
  'loai': instance.loai,
  'ngayTao': instance.ngayTao?.toIso8601String(),
  'image': instance.image,
  'gia': instance.gia,
  'soNguoi': instance.soNguoi,
  'luotXem': instance.luotXem,
};

