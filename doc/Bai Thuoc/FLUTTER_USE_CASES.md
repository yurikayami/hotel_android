# 📋 Use Cases & Workflows: Bài Thuốc & Món Ăn

> Các trường hợp sử dụng thực tế và workflows cho Flutter app.

---

## 🎯 Use Case 1: Xem Danh Sách Bài Thuốc

### Flow

```
User mở app 
    ↓
Tap "Bài Thuốc"
    ↓
API gọi GET /api/BaiThuocAPI?page=1&pageSize=10
    ↓
Server trả về danh sách 10 bài (page 1)
    ↓
App hiển thị danh sách với ảnh, tên, số thích/xem
    ↓
User scroll, load thêm bài (page 2, 3...)
```

### Code Implementation

```dart
class BaiThuocListProvider extends StateNotifier<AsyncValue<List<BaiThuoc>>> {
  final ApiService _apiService;
  int _currentPage = 1;

  BaiThuocListProvider(this._apiService) : super(const AsyncValue.loading());

  Future<void> loadBaiThuocs({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        _currentPage = 1;
      }

      state = const AsyncValue.loading();

      final baiThuocs = await _apiService.getBaiThuocList(page: _currentPage);

      state = AsyncValue.data(baiThuocs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    try {
      _currentPage++;
      final newBaiThuocs =
          await _apiService.getBaiThuocList(page: _currentPage);

      final currentState = state.whenData((data) => data);
      if (currentState is AsyncData) {
        state = AsyncValue.data([...currentState.value, ...newBaiThuocs]);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// UI Usage
class BaiThuocListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baiThuocsAsync = ref.watch(baiThuocListProvider);

    return baiThuocsAsync.when(
      data: (baiThuocs) {
        return ListView.builder(
          itemCount: baiThuocs.length + 1,
          itemBuilder: (context, index) {
            if (index == baiThuocs.length) {
              return Padding(
                padding: EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(baiThuocListProvider.notifier).loadMore();
                  },
                  child: Text('Tải thêm'),
                ),
              );
            }

            final item = baiThuocs[index];
            return BaiThuocCard(baiThuoc: item);
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, st) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lỗi: $error'),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(baiThuocListProvider);
              },
              child: Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🎯 Use Case 2: Xem Chi Tiết Bài Thuốc & Tăng Lượt Xem

### Flow

```
User tap trên bài thuốc trong danh sách
    ↓
Gọi GET /api/BaiThuocAPI/{id}
    ↓
Server tăng soLuotXem lên 1
    ↓
Server trả về chi tiết bài (có soLuotXem mới)
    ↓
App hiển thị toàn bộ nội dung
    ↓
User đọc bài, scroll, or quay lại
```

### Code Implementation

```dart
class BaiThuocDetailScreen extends ConsumerWidget {
  final String baiThuocId;

  const BaiThuocDetailScreen({required this.baiThuocId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(baiThuocDetailProvider(baiThuocId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi Tiết'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Implement like feature
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share('Đọc bài này: $baiThuocId');
            },
          ),
        ],
      ),
      body: detailAsync.when(
        data: (baiThuoc) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero image
                if (baiThuoc.image != null)
                  Hero(
                    tag: baiThuocId,
                    child: Image.network(
                      baiThuoc.image!,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),

                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        baiThuoc.ten,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 12),

                      // Author info
                      _buildAuthorInfo(baiThuoc),

                      SizedBox(height: 16),

                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn('❤️', baiThuoc.soLuotThich),
                          _buildStatColumn('👁️', baiThuoc.soLuotXem),
                          _buildStatColumn('📅',
                              '${baiThuoc.ngayTao.day}/${baiThuoc.ngayTao.month}'),
                        ],
                      ),

                      Divider(height: 32),

                      // Description
                      if (baiThuoc.moTa != null) ...[
                        Text(
                          'Mô Tả',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        SizedBox(height: 8),
                        Text(baiThuoc.moTa!),
                        SizedBox(height: 16),
                      ],

                      // Guide
                      if (baiThuoc.huongDanSuDung != null) ...[
                        Text(
                          'Hướng Dẫn Sử Dụng',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        SizedBox(height: 8),
                        Text(baiThuoc.huongDanSuDung!),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, st) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }

  Widget _buildAuthorInfo(BaiThuoc baiThuoc) {
    return Row(
      children: [
        if (baiThuoc.authorAvatar != null)
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(baiThuoc.authorAvatar!),
          )
        else
          CircleAvatar(
            radius: 24,
            child: Icon(Icons.person),
          ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              baiThuoc.authorName ?? 'Unknown',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${baiThuoc.ngayTao.day}/${baiThuoc.ngayTao.month}/${baiThuoc.ngayTao.year}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatColumn(String icon, dynamic value) {
    return Column(
      children: [
        Text(icon, style: TextStyle(fontSize: 20)),
        SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
```

---

## 🎯 Use Case 3: Tạo Bài Thuốc Mới

### Flow

```
User đăng nhập thành công (có token)
    ↓
Tap "Tạo Bài Thuốc"
    ↓
App mở form với trường:
  - Tiêu đề (bắt buộc)
  - Mô tả
  - Hướng dẫn
  - Ảnh (upload)
    ↓
User điền thông tin + chọn ảnh
    ↓
User tap "Tạo"
    ↓
App gửi POST /api/BaiThuocAPI/create (multipart/form-data)
    ↓
Server xác minh token, lưu bài
    ↓
Server trả về bài mới được tạo
    ↓
App hiển thị thông báo thành công
    ↓
User quay về danh sách
```

### Code Implementation

```dart
class CreateBaiThuocScreen extends ConsumerStatefulWidget {
  const CreateBaiThuocScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateBaiThuocScreen> createState() =>
      _CreateBaiThuocScreenState();
}

class _CreateBaiThuocScreenState extends ConsumerState<CreateBaiThuocScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  bool _isLoading = false;

  final _tenController = TextEditingController();
  final _moTaController = TextEditingController();
  final _huongDanController = TextEditingController();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiService = ref.read(apiServiceProvider);

      final newBaiThuoc = await apiService.createBaiThuoc(
        ten: _tenController.text,
        moTa: _moTaController.text,
        huongDanSuDung: _huongDanController.text,
        imageFile: _selectedImage,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Tạo bài thành công!')),
        );

        // Navigate back and refresh list
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tạo Bài Thuốc')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Tap để chọn ảnh'),
                            ],
                          ),
                        ),
                ),
              ),

              SizedBox(height: 24),

              // Title field
              TextFormField(
                controller: _tenController,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Tiêu đề không được trống';
                  }
                  if ((value?.length ?? 0) > 500) {
                    return 'Tiêu đề quá dài (max 500 ký tự)';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _moTaController,
                decoration: InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                  hintText: 'Mô tả chi tiết bài viết...',
                ),
                maxLines: 4,
                maxLength: 5000,
              ),

              SizedBox(height: 16),

              // Guide field
              TextFormField(
                controller: _huongDanController,
                decoration: InputDecoration(
                  labelText: 'Hướng dẫn sử dụng',
                  border: OutlineInputBorder(),
                  hintText: 'Hướng dẫn bước từng bước...',
                ),
                maxLines: 4,
                maxLength: 5000,
              ),

              SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Tạo Bài Thuốc'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tenController.dispose();
    _moTaController.dispose();
    _huongDanController.dispose();
    super.dispose();
  }
}
```

---

## 🎯 Use Case 4: Phân Tích Ảnh Món Ăn

### Flow

```
User mở "Phân Tích Món Ăn"
    ↓
Tap "Chụp ảnh" hoặc "Chọn từ thư viện"
    ↓
User chọn/chụp ảnh
    ↓
Tap "Phân Tích"
    ↓
App nén ảnh (optimize)
    ↓
App gửi POST /api/FoodAnalysis/analyze (multipart/form-data):
  - image: File
  - userId: string
  - mealType: string (breakfast|lunch|dinner|snack)
    ↓
Server gọi AI model để phân tích
    ↓
Server tính dinh dưỡng, điểm phù hợp, gợi ý
    ↓
Server lưu vào PredictionHistory & PredictionDetail
    ↓
Server trả về kết quả chi tiết
    ↓
App hiển thị:
  - Ảnh được phân tích
  - Tên món ăn + độ tin cậy
  - Thông tin dinh dưỡng (calo, protein, carbs, fat)
  - Điểm phù hợp (0-100%)
  - Gợi ý & lời khuyên
  - Chi tiết từng thành phần
    ↓
User có thể:
  - Save kết quả
  - Share
  - Phân tích ảnh khác
```

### Code Implementation

```dart
class FoodAnalysisScreen extends ConsumerStatefulWidget {
  const FoodAnalysisScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FoodAnalysisScreen> createState() => _FoodAnalysisScreenState();
}

class _FoodAnalysisScreenState extends ConsumerState<FoodAnalysisScreen> {
  File? _selectedImage;
  FoodAnalysisResult? _analysisResult;
  bool _isAnalyzing = false;
  String _selectedMealType = 'lunch';

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      _showError('Lỗi chọn ảnh: $e');
    }
  }

  Future<void> _analyzeFood() async {
    if (_selectedImage == null) {
      _showError('Vui lòng chọn ảnh trước');
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final apiService = ref.read(apiServiceProvider);
      final userId = ref.read(userIdProvider);

      if (userId == null) {
        throw Exception('User ID not found');
      }

      final result = await apiService.analyzeFoodImage(
        imageFile: _selectedImage!,
        userId: userId,
        mealType: _selectedMealType,
      );

      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      _showError('Lỗi phân tích: $e');
      setState(() => _isAnalyzing = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phân Tích Món Ăn')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image display
              Container(
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : Center(
                        child: Text('Chưa chọn ảnh'),
                      ),
              ),

              SizedBox(height: 16),

              // Image picker buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: Icon(Icons.photo_library),
                      label: Text('Thư viện'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: Icon(Icons.camera_alt),
                      label: Text('Chụp'),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Meal type selector
              Text(
                'Loại bữa ăn',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              DropdownButton<String>(
                value: _selectedMealType,
                isExpanded: true,
                items: [
                  DropdownMenuItem(value: 'breakfast', child: Text('🌅 Sáng')),
                  DropdownMenuItem(value: 'lunch', child: Text('🌞 Trưa')),
                  DropdownMenuItem(value: 'dinner', child: Text('🌙 Tối')),
                  DropdownMenuItem(value: 'snack', child: Text('🍪 Ăn nhẹ')),
                ],
                onChanged: (value) {
                  setState(() => _selectedMealType = value ?? 'lunch');
                },
              ),

              SizedBox(height: 24),

              // Analyze button
              ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzeFood,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isAnalyzing
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Phân Tích'),
              ),

              SizedBox(height: 24),

              // Results
              if (_analysisResult != null) ...[
                _buildResultsSection(_analysisResult!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection(FoodAnalysisResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        SizedBox(height: 16),
        Text(
          'Kết Quả Phân Tích',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 16),

        // Food name card
        Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Món ăn được nhận diện'),
                SizedBox(height: 8),
                Text(
                  result.foodName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Độ tin cậy: ${(result.confidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        // Nutrition info
        Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông Tin Dinh Dưỡng',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                _buildNutritionRow(
                    'Năng lượng', '${result.calories.toStringAsFixed(1)} kcal'),
                _buildNutritionRow(
                    'Protein', '${result.protein.toStringAsFixed(1)}g'),
                _buildNutritionRow(
                    'Chất béo', '${result.fat.toStringAsFixed(1)}g'),
                _buildNutritionRow(
                    'Carbohydrate', '${result.carbs.toStringAsFixed(1)}g'),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        // Suitability score
        Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Phù Hợp Với Phác Đồ Sức Khỏe'),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: result.suitable / 100,
                        minHeight: 8,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${result.suitable}%',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        // Suggestions
        if (result.suggestions.isNotEmpty)
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💡 Gợi Ý',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(result.suggestions),
                ],
              ),
            ),
          ),

        SizedBox(height: 16),

        // Advice
        if (result.advice.isNotEmpty)
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('👨‍⚕️ Lời Khuyên',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(result.advice),
                ],
              ),
            ),
          ),

        SizedBox(height: 16),

        // Details
        if (result.details.isNotEmpty)
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📊 Chi Tiết Từng Thành Phần',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  ...result.details.map((detail) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                detail.label,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                  '${detail.weight.toStringAsFixed(0)}g'),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Calo: ${detail.calories.toStringAsFixed(1)} | Protein: ${detail.protein.toStringAsFixed(1)}g | Carbs: ${detail.carbs.toStringAsFixed(1)}g',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Độ tin cậy: ${(detail.confidence * 100).toStringAsFixed(1)}%',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
```

---

## 🔄 Use Case 5: Offline Mode & Caching

### Implementation

```dart
// Cache layer
class CachedApiService {
  final ApiService _apiService;
  final Map<String, CachedData> _cache = {};

  Future<List<BaiThuoc>> getBaiThuocsWithCache({int page = 1}) async {
    final key = 'bai_thuoc_page_$page';
    
    // Check cache
    if (_cache.containsKey(key)) {
      final cached = _cache[key];
      if (DateTime.now().difference(cached!.timestamp).inHours < 1) {
        return cached.data;
      }
    }

    try {
      final data = await _apiService.getBaiThuocList(page: page);
      _cache[key] = CachedData(data, DateTime.now());
      return data;
    } catch (e) {
      // Return cached data if available
      if (_cache.containsKey(key)) {
        return _cache[key]!.data;
      }
      rethrow;
    }
  }
}

class CachedData {
  final List<BaiThuoc> data;
  final DateTime timestamp;

  CachedData(this.data, this.timestamp);
}
```

---

## 📊 Data Flow Diagram

```
┌─────────────┐
│   Flutter   │
│     App     │
└──────┬──────┘
       │ 1. HTTP Request
       │ (GET/POST)
       ↓
┌─────────────────────────┐
│  .NET API Server        │
│  (Hotel_API)            │
├─────────────────────────┤
│ ✓ BaiThuocAPI           │
│ ✓ FoodAnalysisAPI       │
│ ✓ AuthAPI               │
└──────┬──────────────────┘
       │ 2. Process Request
       │ (Validate, Query DB,
       │  Call AI Model)
       ↓
┌─────────────────────────┐
│  SQL Server Database    │
│  (Hotel_Web)            │
├─────────────────────────┤
│ • BaiThuocs             │
│ • PredictionHistories   │
│ • PredictionDetails     │
│ • Users                 │
└──────┬──────────────────┘
       │ 3. Return JSON
       │ (200 OK)
       ↓
┌─────────────┐
│   Flutter   │
│ Parse JSON  │
└──────┬──────┘
       │ 4. Display in UI
       ↓
┌─────────────┐
│   User      │
│   Screen    │
└─────────────┘
```

---

**Version**: 1.0  
**Last Updated**: 16/01/2025
