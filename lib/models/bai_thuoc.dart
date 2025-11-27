import 'package:json_annotation/json_annotation.dart';

part 'bai_thuoc.g.dart';

/// BaiThuoc (Medicine Article) model
@JsonSerializable(explicitToJson: true)
class BaiThuoc {
  final String id;
  @JsonKey(name: 'ten')
  final String ten;
  @JsonKey(name: 'moTa')
  final String? moTa;
  @JsonKey(name: 'huongDanSuDung')
  final String? huongDanSuDung;
  final String? nguoiDungId;
  @JsonKey(name: 'ngayTao')
  final DateTime ngayTao;
  final String? image; // Supports both URL and base64 data URIs
  @JsonKey(name: 'soLuotThich')
  final int? soLuotThich;
  @JsonKey(name: 'soLuotXem')
  final int? soLuotXem;
  @JsonKey(name: 'trangThai')
  final int trangThai;
  final String? authorId;
  final String? authorName;
  final String? authorAvatar;

  BaiThuoc({
    required this.id,
    required this.ten,
    this.moTa,
    this.huongDanSuDung,
    this.nguoiDungId,
    required this.ngayTao,
    this.image,
    this.soLuotThich,
    this.soLuotXem,
    required this.trangThai,
    this.authorId,
    this.authorName,
    this.authorAvatar,
  });

  factory BaiThuoc.fromJson(Map<String, dynamic> json) {
    // ignore: unused_local_variable
    final _ = _$BaiThuocFromJson; // Suppress unused element warning
    try {
      return BaiThuoc(
        id: json['id'] as String? ?? '',
        ten: json['ten'] as String? ?? 'Không có tiêu đề',
        moTa: json['moTa'] as String?,
        huongDanSuDung: json['huongDanSuDung'] as String?,
        nguoiDungId: json['nguoiDungId'] as String?,
        ngayTao: json['ngayTao'] != null
            ? DateTime.parse(json['ngayTao'] as String)
            : DateTime.now(),
        image: json['image'] as String?,
        soLuotThich: json['soLuotThich'] as int? ?? 0,
        soLuotXem: json['soLuotXem'] as int? ?? 0,
        trangThai: json['trangThai'] as int? ?? 1,
        authorId: json['authorId'] as String?,
        authorName: json['authorName'] as String?,
        authorAvatar: json['authorAvatar'] as String?,
      );
    } catch (e) {
      throw FormatException('Error parsing BaiThuoc: $e');
    }
  }
  
  Map<String, dynamic> toJson() => _$BaiThuocToJson(this);

  /// Check if image is a base64 data URI
  bool get isBase64Image => image?.startsWith('data:image') ?? false;

  /// Get image URL or return the image as-is (could be base64 or URL)
  String? get imageUrl => image;
}

