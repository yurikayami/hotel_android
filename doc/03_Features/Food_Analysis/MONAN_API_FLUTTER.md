# API Tài Liệu - MonAn (Món Ăn) cho Flutter

## 📋 Mục Lục
1. [Giới Thiệu](#giới-thiệu)
2. [Cấu Hình Cơ Bản](#cấu-hình-cơ-bản)
3. [Các Endpoint](#các-endpoint)
4. [Response Format](#response-format)
5. [Ví Dụ Thực Tế](#ví-dụ-thực-tế)
6. [Xử Lý Lỗi](#xử-lý-lỗi)
7. [Mã Lỗi (Error Codes)](#mã-lỗi)
8. [Best Practices](#best-practices)

---

## 📖 Giới Thiệu

API MonAn cung cấp các chức năng quản lý và lấy thông tin về các món ăn trong hệ thống. Bao gồm các endpoint để:
- Lấy danh sách các món ăn
- Lấy chi tiết món ăn
- Tìm kiếm món ăn
- Lấy danh sách món ăn được đề xuất
- Lấy giá của món ăn

**Base URL**: `https://yourdomain.com/api/MonAn`

---

## 🔧 Cấu Hình Cơ Bản

### Headers

Tất cả các request nên bao gồm các headers sau:

```
Content-Type: application/json
Accept: application/json
```

### Pagination

Các endpoint danh sách hỗ trợ pagination với các tham số:
- `page` (int, default: 1): Trang thứ mấy
- `pageSize` (int, default: 10, max: 50): Số item trên mỗi trang

### Base URL Environment

```dart
// Development
const String API_BASE_URL = 'http://localhost:5000/api';

// Production
const String API_BASE_URL = 'https://yourdomain.com/api';

const String MONAN_ENDPOINT = '$API_BASE_URL/MonAn';
```

---

## 🔗 Các Endpoint

### 1. Lấy Danh Sách Món Ăn

Lấy danh sách tất cả các món ăn với phân trang.

**Endpoint**: `GET /api/MonAn`

**Parameters** (Query):
| Tham số | Kiểu | Bắt buộc | Mô tả | Default |
|---------|------|---------|-------|---------|
| page | integer | ❌ | Số trang | 1 |
| pageSize | integer | ❌ | Số item trên trang (1-50) | 10 |

**Response Status**: `200 OK`

**Success Response**:
```json
{
  "success": true,
  "message": "Lấy danh sách món ăn thành công",
  "data": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "ten": "Phở Bò",
      "moTa": "Phở bò truyền thống Hà Nội",
      "gia": 45000.00,
      "image": "https://yourdomain.com/uploads/pho-bo.jpg",
      "loai": "Chung",
      "cachCheBien": "Nước dùng 12 tiếng, tẩm gia vị chuẩn Hà Nội",
      "soNguoi": 1,
      "luotXem": 152
    },
    {
      "id": "223e4567-e89b-12d3-a456-426614174001",
      "ten": "Cơm Tấm",
      "moTa": "Cơm tấm nướng sườn",
      "gia": 35000.00,
      "image": "https://yourdomain.com/uploads/com-tam.jpg",
      "loai": "Chung",
      "cachCheBien": "Sườn nướng trên than hoa",
      "soNguoi": 1,
      "luotXem": 98
    }
  ],
  "errors": null
}
```

**Error Response** (500):
```json
{
  "success": false,
  "message": "Có lỗi xảy ra",
  "data": null,
  "errors": ["Chi tiết lỗi..."]
}
```

---

### 2. Lấy Chi Tiết Món Ăn

Lấy thông tin chi tiết của một món ăn cụ thể.

**Endpoint**: `GET /api/MonAn/{id}`

**Parameters** (URL):
| Tham số | Kiểu | Bắt buộc | Mô tả |
|---------|------|---------|-------|
| id | string (GUID) | ✅ | ID của món ăn |

**Response Status**: 
- `200 OK` - Thành công
- `404 Not Found` - Không tìm thấy

**Success Response** (200):
```json
{
  "success": true,
  "message": "Lấy chi tiết món ăn thành công",
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "ten": "Phở Bò",
    "moTa": "Phở bò truyền thống Hà Nội với thịt bò tươi sống được lựa chọn kỹ lưỡng",
    "gia": 45000.00,
    "image": "https://yourdomain.com/uploads/pho-bo.jpg",
    "loai": "Chung",
    "cachCheBien": "Nước dùng được nấu từ xương bò trong 12 tiếng, thêm gia vị chuẩn Hà Nội",
    "soNguoi": 1,
    "luotXem": 152
  },
  "errors": null
}
```

**Error Response** (404):
```json
{
  "success": false,
  "message": "Không tìm thấy món ăn",
  "data": null
}
```

---

### 3. Tìm Kiếm Món Ăn

Tìm kiếm món ăn theo tên, mô tả hoặc loại.

**Endpoint**: `GET /api/MonAn/search`

**Parameters** (Query):
| Tham số | Kiểu | Bắt buộc | Mô tả | Default |
|---------|------|---------|-------|---------|
| keyword | string | ❌ | Từ khóa tìm kiếm | "" |
| page | integer | ❌ | Số trang | 1 |
| pageSize | integer | ❌ | Số item trên trang (1-50) | 10 |

**Response Status**: `200 OK`

**Success Response**:
```json
{
  "success": true,
  "message": "Tìm thấy 3 món ăn",
  "data": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "ten": "Phở Bò",
      "moTa": "Phở bò truyền thống Hà Nội",
      "gia": 45000.00,
      "image": "https://yourdomain.com/uploads/pho-bo.jpg",
      "loai": "Chung"
    },
    {
      "id": "323e4567-e89b-12d3-a456-426614174002",
      "ten": "Phở Gà",
      "moTa": "Phở gà ngon",
      "gia": 40000.00,
      "image": "https://yourdomain.com/uploads/pho-ga.jpg",
      "loai": "Chung"
    }
  ],
  "errors": null
}
```

---

### 4. Lấy Danh Sách Món Ăn Được Đề Xuất

Lấy danh sách các món ăn được đề xuất ngẫu nhiên.

**Endpoint**: `GET /api/MonAn/recommended`

**Parameters** (Query):
| Tham số | Kiểu | Bắt buộc | Mô tả | Default | Max |
|---------|------|---------|-------|---------|-----|
| limit | integer | ❌ | Số lượng món được đề xuất | 5 | 20 |

**Response Status**: `200 OK`

**Success Response**:
```json
{
  "success": true,
  "message": "Lấy món ăn đề xuất thành công",
  "data": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "ten": "Phở Bò",
      "moTa": "Phở bò truyền thống Hà Nội",
      "gia": 45000.00,
      "image": "https://yourdomain.com/uploads/pho-bo.jpg",
      "loai": "Chung"
    },
    {
      "id": "423e4567-e89b-12d3-a456-426614174003",
      "ten": "Bánh Mì",
      "moTa": "Bánh mì nướng giòn",
      "gia": 15000.00,
      "image": "https://yourdomain.com/uploads/banh-mi.jpg",
      "loai": "Chung"
    },
    {
      "id": "523e4567-e89b-12d3-a456-426614174004",
      "ten": "Chả Cá Lã Vọng",
      "moTa": "Chả cá truyền thống Lã Vọng",
      "gia": 65000.00,
      "image": "https://yourdomain.com/uploads/cha-ca.jpg",
      "loai": "Chung"
    }
  ],
  "errors": null
}
```

---

### 5. Lấy Giá Của Món Ăn

Lấy thông tin giá của một món ăn.

**Endpoint**: `GET /api/MonAn/price/{id}`

**Parameters** (URL):
| Tham số | Kiểu | Bắt buộc | Mô tả |
|---------|------|---------|-------|
| id | string (GUID) | ✅ | ID của món ăn |

**Response Status**:
- `200 OK` - Thành công
- `404 Not Found` - Không tìm thấy

**Success Response** (200):
```json
{
  "success": true,
  "message": "Lấy giá món ăn thành công",
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "ten": "Phở Bò",
    "gia": 45000.00
  },
  "errors": null
}
```

**Error Response** (404):
```json
{
  "success": false,
  "message": "Không tìm thấy món ăn",
  "data": null
}
```

---

## 📦 Response Format

### Success Response Structure

```json
{
  "success": true,
  "message": "Thông báo thành công",
  "data": {},
  "errors": null
}
```

### Error Response Structure

```json
{
  "success": false,
  "message": "Thông báo lỗi",
  "data": null,
  "errors": ["Chi tiết lỗi 1", "Chi tiết lỗi 2"]
}
```

### MonAn Model

```json
{
  "id": "string (GUID)",
  "ten": "string (max 500 chars)",
  "moTa": "string (max 2000 chars)",
  "cachCheBien": "string (max 5000 chars)",
  "loai": "string (max 100 chars)",
  "gia": "decimal (10,2)",
  "image": "string URL",
  "soNguoi": "integer",
  "luotXem": "integer"
}
```

---

## 💻 Ví Dụ Thực Tế

### Flutter Implementation

#### 1. Model Class

```dart
class MonAn {
  final String id;
  final String ten;
  final String moTa;
  final double gia;
  final String image;
  final String loai;
  final String cachCheBien;
  final int soNguoi;
  final int luotXem;

  MonAn({
    required this.id,
    required this.ten,
    required this.moTa,
    required this.gia,
    required this.image,
    required this.loai,
    required this.cachCheBien,
    required this.soNguoi,
    required this.luotXem,
  });

  factory MonAn.fromJson(Map<String, dynamic> json) {
    return MonAn(
      id: json['id'] ?? '',
      ten: json['ten'] ?? '',
      moTa: json['moTa'] ?? '',
      gia: (json['gia'] ?? 0.0).toDouble(),
      image: json['image'] ?? '',
      loai: json['loai'] ?? '',
      cachCheBien: json['cachCheBien'] ?? '',
      soNguoi: json['soNguoi'] ?? 0,
      luotXem: json['luotXem'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ten': ten,
      'moTa': moTa,
      'gia': gia,
      'image': image,
      'loai': loai,
      'cachCheBien': cachCheBien,
      'soNguoi': soNguoi,
      'luotXem': luotXem,
    };
  }
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<String>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, Function fromJsonT) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errors: List<String>.from(json['errors'] ?? []),
    );
  }
}
```

#### 2. API Service

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class MonAnService {
  static const String baseUrl = 'https://yourdomain.com/api/MonAn';

  // Lấy danh sách món ăn
  static Future<ApiResponse<List<MonAn>>> getMonAns({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?page=$page&pageSize=$pageSize'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<MonAn> monAns = (jsonData['data'] as List)
            .map((item) => MonAn.fromJson(item))
            .toList();
        
        return ApiResponse(
          success: true,
          message: jsonData['message'],
          data: monAns,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Lỗi: ${response.statusCode}',
          errors: ['Không thể lấy danh sách'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi kết nối',
        errors: [e.toString()],
      );
    }
  }

  // Lấy chi tiết món ăn
  static Future<ApiResponse<MonAn>> getMonAnDetail(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final monAn = MonAn.fromJson(jsonData['data']);
        
        return ApiResponse(
          success: true,
          message: jsonData['message'],
          data: monAn,
        );
      } else if (response.statusCode == 404) {
        return ApiResponse(
          success: false,
          message: 'Không tìm thấy món ăn',
          errors: ['404 Not Found'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Lỗi: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi kết nối',
        errors: [e.toString()],
      );
    }
  }

  // Tìm kiếm món ăn
  static Future<ApiResponse<List<MonAn>>> searchMonAns({
    String keyword = '',
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/search?keyword=$keyword&page=$page&pageSize=$pageSize',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<MonAn> monAns = (jsonData['data'] as List)
            .map((item) => MonAn.fromJson(item))
            .toList();
        
        return ApiResponse(
          success: true,
          message: jsonData['message'],
          data: monAns,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Lỗi tìm kiếm',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi kết nối',
        errors: [e.toString()],
      );
    }
  }

  // Lấy danh sách đề xuất
  static Future<ApiResponse<List<MonAn>>> getRecommended({
    int limit = 5,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recommended?limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<MonAn> monAns = (jsonData['data'] as List)
            .map((item) => MonAn.fromJson(item))
            .toList();
        
        return ApiResponse(
          success: true,
          message: jsonData['message'],
          data: monAns,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Lỗi lấy đề xuất',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi kết nối',
        errors: [e.toString()],
      );
    }
  }

  // Lấy giá của món ăn
  static Future<ApiResponse<Map<String, dynamic>>> getPrice(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/price/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        return ApiResponse(
          success: true,
          message: jsonData['message'],
          data: jsonData['data'],
        );
      } else if (response.statusCode == 404) {
        return ApiResponse(
          success: false,
          message: 'Không tìm thấy món ăn',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Lỗi: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi kết nối',
        errors: [e.toString()],
      );
    }
  }
}
```

#### 3. Widget Example - List View

```dart
import 'package:flutter/material.dart';

class MonAnListScreen extends StatefulWidget {
  @override
  State<MonAnListScreen> createState() => _MonAnListScreenState();
}

class _MonAnListScreenState extends State<MonAnListScreen> {
  late Future<ApiResponse<List<MonAn>>> _monAnsFuture;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadMonAns();
  }

  void _loadMonAns() {
    _monAnsFuture = MonAnService.getMonAns(page: _currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh Sách Món Ăn'),
      ),
      body: FutureBuilder<ApiResponse<List<MonAn>>>(
        future: _monAnsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.success) {
            return Center(
              child: Text(snapshot.data?.message ?? 'Không tìm thấy dữ liệu'),
            );
          }

          final monAns = snapshot.data!.data ?? [];

          return ListView.builder(
            itemCount: monAns.length,
            itemBuilder: (context, index) {
              final monAn = monAns[index];
              return MonAnCard(monAn: monAn);
            },
          );
        },
      ),
    );
  }
}

class MonAnCard extends StatelessWidget {
  final MonAn monAn;

  const MonAnCard({Key? key, required this.monAn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          Image.network(
            monAn.image,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey[300],
                child: Icon(Icons.image_not_supported),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monAn.ten,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  monAn.moTa,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${monAn.gia.toStringAsFixed(0)} VND',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to detail
                      },
                      child: Text('Chi tiết'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 4. Widget Example - Search

```dart
class MonAnSearchScreen extends StatefulWidget {
  @override
  State<MonAnSearchScreen> createState() => _MonAnSearchScreenState();
}

class _MonAnSearchScreenState extends State<MonAnSearchScreen> {
  final _searchController = TextEditingController();
  late Future<ApiResponse<List<MonAn>>> _searchFuture;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String keyword) {
    if (keyword.isEmpty) {
      setState(() => _isSearching = false);
      return;
    }

    setState(() {
      _isSearching = true;
      _searchFuture = MonAnService.searchMonAns(keyword: keyword);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm món ăn...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (value) {
            _performSearch(value);
          },
        ),
      ),
      body: _isSearching
          ? FutureBuilder<ApiResponse<List<MonAn>>>(
              future: _searchFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.success) {
                  return Center(
                    child: Text('Không tìm thấy kết quả'),
                  );
                }

                final results = snapshot.data!.data ?? [];

                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return MonAnCard(monAn: results[index]);
                  },
                );
              },
            )
          : Center(
              child: Text('Nhập từ khóa để tìm kiếm'),
            ),
    );
  }
}
```

#### 5. Widget Example - Detail

```dart
class MonAnDetailScreen extends StatefulWidget {
  final String monAnId;

  const MonAnDetailScreen({Key? key, required this.monAnId}) : super(key: key);

  @override
  State<MonAnDetailScreen> createState() => _MonAnDetailScreenState();
}

class _MonAnDetailScreenState extends State<MonAnDetailScreen> {
  late Future<ApiResponse<MonAn>> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = MonAnService.getMonAnDetail(widget.monAnId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi Tiết Món Ăn'),
      ),
      body: FutureBuilder<ApiResponse<MonAn>>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.success) {
            return Center(
              child: Text(snapshot.data?.message ?? 'Lỗi tải dữ liệu'),
            );
          }

          final monAn = snapshot.data!.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  monAn.image,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        monAn.ten,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${monAn.gia.toStringAsFixed(0)} VND',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildInfoRow('Loại', monAn.loai),
                      _buildInfoRow('Số người', '${monAn.soNguoi}'),
                      _buildInfoRow('Lượt xem', '${monAn.luotXem}'),
                      SizedBox(height: 16),
                      Text(
                        'Mô Tả',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(monAn.moTa),
                      SizedBox(height: 16),
                      Text(
                        'Cách Chế Biến',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(monAn.cachCheBien),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Add to cart or order
                          },
                          child: Text('Thêm vào giỏ hàng'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(value),
        ],
      ),
    );
  }
}
```

---

## ❌ Xử Lý Lỗi

### Network Error

```dart
Future<void> handleNetworkError(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Lỗi Kết Nối'),
      content: Text('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Đóng'),
        ),
      ],
    ),
  );
}
```

### Timeout Error

```dart
Future<void> handleTimeoutError(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Hết Thời Gian'),
      content: Text('Yêu cầu mất quá lâu. Vui lòng thử lại.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Đóng'),
        ),
      ],
    ),
  );
}
```

### API Error

```dart
Future<void> handleApiError(BuildContext context, String message) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Lỗi'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Đóng'),
        ),
      ],
    ),
  );
}
```

---

## 📊 Mã Lỗi

| Mã | Ý Nghĩa | Giải Pháp |
|----|---------|---------| 
| 200 | Success | OK |
| 400 | Bad Request | Kiểm tra lại tham số |
| 404 | Not Found | Món ăn không tồn tại |
| 500 | Server Error | Thử lại sau |
| Timeout | Kết nối quá lâu | Kiểm tra internet |
| NetworkException | Lỗi mạng | Kiểm tra kết nối |

---

## 🎯 Best Practices

### 1. Caching

```dart
class MonAnCache {
  static final _cache = <String, MonAn>{};

  static void put(MonAn monAn) {
    _cache[monAn.id] = monAn;
  }

  static MonAn? get(String id) {
    return _cache[id];
  }

  static bool contains(String id) {
    return _cache.containsKey(id);
  }

  static void clear() {
    _cache.clear();
  }
}
```

### 2. Pagination

```dart
class PaginationHelper {
  int currentPage = 1;
  int pageSize = 10;
  int totalPages = 0;

  bool hasNextPage() {
    return currentPage < totalPages;
  }

  bool hasPreviousPage() {
    return currentPage > 1;
  }

  void nextPage() {
    if (hasNextPage()) currentPage++;
  }

  void previousPage() {
    if (hasPreviousPage()) currentPage--;
  }

  void reset() {
    currentPage = 1;
  }
}
```

### 3. Error Handling

```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
```

### 4. Request Timeout

```dart
const Duration requestTimeout = Duration(seconds: 30);

final response = await http.get(url).timeout(
  requestTimeout,
  onTimeout: () {
    throw ApiException(
      message: 'Request timeout',
      statusCode: 408,
    );
  },
);
```

### 5. Image Caching

```dart
precacheImage(
  NetworkImage(monAn.image),
  context,
).then((_) {
  // Image cached
}).catchError((e) {
  // Handle error
});
```

### 6. State Management (Provider Example)

```dart
class MonAnProvider extends ChangeNotifier {
  List<MonAn> _monAns = [];
  bool _isLoading = false;

  List<MonAn> get monAns => _monAns;
  bool get isLoading => _isLoading;

  Future<void> loadMonAns({int page = 1}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await MonAnService.getMonAns(page: page);
      if (response.success) {
        _monAns = response.data ?? [];
      }
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }
}
```

---

## 📝 Ghi Chú Quan Trọng

1. **Authentication**: Hiện tại API không yêu cầu authentication, nhưng chuẩn bị thêm JWT nếu cần.

2. **Rate Limiting**: Không có rate limiting hiện tại, nhưng nên thực hiện request một cách hợp lý.

3. **HTTPS**: Luôn sử dụng HTTPS trong production.

4. **Image URL**: Tất cả ảnh được trả về dạng URL đầy đủ (full URL), không cần ghép thêm.

5. **Currency**: Giá được tính bằng VND (Việt Nam Đồng).

6. **Pagination**: Nên caches danh sách để giảm request.

---

## 📞 Hỗ Trợ

Nếu gặp bất kỳ vấn đề nào, vui lòng liên hệ với nhóm phát triển backend.

**Version**: 1.0  
**Last Updated**: November 16, 2025

