import 'package:json_annotation/json_annotation.dart';

part 'mon_an.g.dart';

/// MonAn (Dish) model
@JsonSerializable()
class MonAn {
  final String id;
  @JsonKey(name: 'ten')
  final String ten;
  @JsonKey(name: 'moTa')
  final String? moTa;
  @JsonKey(name: 'cachCheBien')
  final String? cachCheBien;
  @JsonKey(name: 'loai')
  final String? loai;
  @JsonKey(name: 'ngayTao')
  final DateTime? ngayTao;
  final String? image;
  @JsonKey(name: 'gia')
  final double? gia;
  @JsonKey(name: 'soNguoi')
  final int? soNguoi;
  @JsonKey(name: 'luotXem')
  final int? luotXem;

  MonAn({
    required this.id,
    required this.ten,
    this.moTa,
    this.cachCheBien,
    this.loai,
    this.ngayTao,
    this.image,
    this.gia,
    this.soNguoi,
    this.luotXem,
  });

  factory MonAn.fromJson(Map<String, dynamic> json) => _$MonAnFromJson(json);
  Map<String, dynamic> toJson() => _$MonAnToJson(this);
}

