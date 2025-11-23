/// Medicine model - Bài thuốc/Hướng dẫn sức khỏe
class Medicine {
  final String id;
  final String ten;
  final String moTa;
  final String huongDanSuDung;
  final DateTime ngayTao;
  final String? image;
  final int soLuotThich;
  final int soLuotXem;
  final String authorId;
  final String authorName;
  final String? authorAvatar;

  Medicine({
    required this.id,
    required this.ten,
    required this.moTa,
    required this.huongDanSuDung,
    required this.ngayTao,
    this.image,
    required this.soLuotThich,
    required this.soLuotXem,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
  });

  /// Create Medicine from JSON
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] ?? '',
      ten: json['ten'] ?? '',
      moTa: json['moTa'] ?? '',
      huongDanSuDung: json['huongDanSuDung'] ?? '',
      ngayTao: json['ngayTao'] != null
          ? DateTime.parse(json['ngayTao'])
          : DateTime.now(),
      image: json['image'],
      soLuotThich: json['soLuotThich'] ?? 0,
      soLuotXem: json['soLuotXem'] ?? 0,
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? 'Chưa biết',
      authorAvatar: json['authorAvatar'],
    );
  }

  /// Convert Medicine to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ten': ten,
      'moTa': moTa,
      'huongDanSuDung': huongDanSuDung,
      'ngayTao': ngayTao.toIso8601String(),
      'image': image,
      'soLuotThich': soLuotThich,
      'soLuotXem': soLuotXem,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
    };
  }
}

