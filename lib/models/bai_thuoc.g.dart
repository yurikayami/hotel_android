// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bai_thuoc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaiThuoc _$BaiThuocFromJson(Map<String, dynamic> json) => BaiThuoc(
  id: json['id'] as String,
  ten: json['ten'] as String,
  moTa: json['moTa'] as String?,
  huongDanSuDung: json['huongDanSuDung'] as String?,
  nguoiDungId: json['nguoiDungId'] as String?,
  ngayTao: DateTime.parse(json['ngayTao'] as String),
  image: json['image'] as String?,
  soLuotThich: (json['soLuotThich'] as num?)?.toInt(),
  soLuotXem: (json['soLuotXem'] as num?)?.toInt(),
  trangThai: (json['trangThai'] as num).toInt(),
  authorId: json['authorId'] as String?,
  authorName: json['authorName'] as String?,
  authorAvatar: json['authorAvatar'] as String?,
);

Map<String, dynamic> _$BaiThuocToJson(BaiThuoc instance) => <String, dynamic>{
  'id': instance.id,
  'ten': instance.ten,
  'moTa': instance.moTa,
  'huongDanSuDung': instance.huongDanSuDung,
  'nguoiDungId': instance.nguoiDungId,
  'ngayTao': instance.ngayTao.toIso8601String(),
  'image': instance.image,
  'soLuotThich': instance.soLuotThich,
  'soLuotXem': instance.soLuotXem,
  'trangThai': instance.trangThai,
  'authorId': instance.authorId,
  'authorName': instance.authorName,
  'authorAvatar': instance.authorAvatar,
};
