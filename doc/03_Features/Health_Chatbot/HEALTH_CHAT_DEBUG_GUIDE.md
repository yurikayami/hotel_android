# Health Chat Debug Guide - Gợi ý Bài Thuốc

## 🔍 Vấn đề Đã Fix

**Vấn đề:** Bài thuốc không được đề xuất mặc dù user hỏi "tôi bị ho", "bài thuốc trị cảm"
- Chatbot chỉ có nội dung, không show thẻ gợi ý dưới cùng

**Nguyên nhân:** 
- `_shouldGenerateSuggestions()` yêu cầu user phải nói từ "gợi ý" hoặc "nên ăn gì"
- Khi user chỉ nói "tôi bị ho" thì không trigger gợi ý
- Logic không flexible - không phát hiện triệu chứng trực tiếp

---

## ✅ Các Fix Đã Áp Dụng

### 1. Cập Nhật `_shouldGenerateSuggestions()` Logic
**File:** `lib/providers/health_chat_provider.dart`

**Trước:**
```dart
bool _shouldGenerateSuggestions(String message) {
  final suggestionKeywords = [
    'gợi ý',
    'nên ăn gì',
    'nên uống gì',
    // ... (chỉ có ~14 keywords)
  ];
  return suggestionKeywords.any((kw) => lowerMessage.contains(kw));
}
```

**Sau:**
```dart
bool _shouldGenerateSuggestions(String message) {
  final suggestionKeywords = [
    'cảm',    // 🔥 LUÔN gợi ý triệu chứng
    'ho',
    'sốt',
    'đau đầu',
    'mệt mỏi',
    'viêm họng',
    'cảm lạnh',
    'buồn nôn',
    'nôn',
    'tiêu chảy',
    'táo bón',
    'đau bụng',
    'chóng mặt',
    'mất ngủ',
    'stress',
    'lo âu',
    'trầm cảm',
    'thừa cân',
    'béo phì',
    'tiểu đường',
    'huyết áp',
    'tim',
    'phổi',
    'dạ dày',
    'gan',
    'thận',
    'khớp',
    'xương',
    'cơ',
    'gợi ý',     // Vẫn support trường hợp user nói "gợi ý"
  ];
  final hasKeyword = suggestionKeywords.any((kw) => lowerMessage.contains(kw));
  print('[HealthChatProvider] _shouldGenerateSuggestions: $hasKeyword'); // DEBUG
  return hasKeyword;
}
```

**Thay đổi:**
- ✅ Thêm triệu chứng trực tiếp vào keywords (không cần "gợi ý")
- ✅ Thêm print debug để log trong console

---

### 2. Thêm Chi Tiết Debug Print vào `generateSuggestions()`
**File:** `lib/providers/health_chat_provider.dart`

```dart
Future<void> generateSuggestions(...) async {
  try {
    print('[HealthChatProvider] ===== START generateSuggestions ====');
    print('[HealthChatProvider] Message: "$userMessage"');
    
    if (!_shouldGenerateSuggestions(userMessage)) {
      print('[HealthChatProvider] No keywords found, clearing suggestions');
      return;
    }

    final keywords = _extractKeywords(userMessage);
    print('[HealthChatProvider] Extracted keywords: $keywords');

    print('[HealthChatProvider] Total bai thuoc in provider: ${baiThuocProvider.baiThuocList.length}');
    if (baiThuocProvider.baiThuocList.isNotEmpty) {
      print('[HealthChatProvider] BaiThuoc list:');
      for (var i = 0; i < baiThuocProvider.baiThuocList.length; i++) {
        final bt = baiThuocProvider.baiThuocList[i];
        print('[HealthChatProvider]   $i. ${bt.ten} - ${bt.moTa?.substring(0, 50)}...');
      }
    }

    // Tìm bài thuốc liên quan
    final matchedBaiThuoc = <BaiThuoc>[];
    for (var baiThuoc in baiThuocProvider.baiThuocList) {
      // ... logic matching ...
      if (isMatch) {
        print('[HealthChatProvider] ✓ MATCHED: "${baiThuoc.ten}" with keyword "$kw"');
        matchedBaiThuoc.add(baiThuoc);
      }
    }

    _suggestedBaiThuoc = matchedBaiThuoc.take(3).toList();

    print('[HealthChatProvider] ✓✓✓ Found ${_suggestedBaiThuoc.length} suggestions:');
    for (var bt in _suggestedBaiThuoc) {
      print('[HealthChatProvider]   - ${bt.ten}');
    }
    print('[HealthChatProvider] ===== END generateSuggestions ====');

  } catch (e) {
    print('[HealthChatProvider] ERROR in generateSuggestions: $e');
  }
}
```

---

## 🧪 Cách Test và Xem Debug Output

### Trong VS Code Console

**Test Case 1: Hỏi về ho**
```
User: "Tôi bị ho"

Console Output:
[HealthChatProvider] _handleSendMessage called with: "Tôi bị ho"
[HealthChatProvider] Sending message to Gemini...
[HealthChatProvider] Calling generateSuggestions...
[HealthChatProvider] ===== START generateSuggestions ====
[HealthChatProvider] Message: "Tôi bị ho"
[HealthChatProvider] _shouldGenerateSuggestions: true for message: "Tôi bị ho"
[HealthChatProvider] Extracted keywords: [ho]
[HealthChatProvider] Total bai thuoc in provider: 15
[HealthChatProvider] BaiThuoc list:
[HealthChatProvider]   0. Bài thuốc trị cảm nặng - Giúp giảm triệu chứng cảm lạnh...
[HealthChatProvider]   1. Bài thuốc trị ho dữ dội - Chứa các thành phần...
[HealthChatProvider]   2. Bài thuốc trị sốt cao - Hỗ trợ hạ sốt...
...
[HealthChatProvider] ✓ MATCHED: "Bài thuốc trị ho dữ dội" with keyword "ho"
[HealthChatProvider] ✓✓✓ Found 1 suggestions:
[HealthChatProvider]   - Bài thuốc trị ho dữ dội
[HealthChatProvider] ===== END generateSuggestions ====
```

**Test Case 2: Hỏi về cảm**
```
User: "Bài thuốc trị cảm?"

[HealthChatProvider] ===== START generateSuggestions ====
[HealthChatProvider] Message: "Bài thuốc trị cảm?"
[HealthChatProvider] _shouldGenerateSuggestions: true
[HealthChatProvider] Extracted keywords: [cảm]
[HealthChatProvider] ✓ MATCHED: "Bài thuốc trị cảm nặng" with keyword "cảm"
[HealthChatProvider] ✓✓✓ Found 1 suggestions:
[HealthChatProvider]   - Bài thuốc trị cảm nặng
[HealthChatProvider] ===== END generateSuggestions ====
```

---

## 📋 Console Print Tags

| Tag | Ý Nghĩa |
|-----|---------|
| `[HealthChatProvider]` | Thông báo chính |
| `_shouldGenerateSuggestions: true` | Phát hiện keyword |
| `Extracted keywords: [...]` | Từ khóa triệu chứng tìm được |
| `Total bai thuoc in provider:` | Số lượng bài thuốc trong DB |
| `BaiThuoc list:` | Danh sách bài thuốc có sẵn |
| `✓ MATCHED:` | Tìm thấy bài thuốc khớp |
| `✓✓✓ Found X suggestions:` | Kết quả cuối cùng |

---

## 🚀 Expected Output - Khi Hoạt Động Đúng

```
[HealthChatProvider] ===== START generateSuggestions ====
[HealthChatProvider] Message: "tôi bị sốt cao"
[HealthChatProvider] _shouldGenerateSuggestions: true for message: "tôi bị sốt cao"
[HealthChatProvider] Extracted keywords: [sốt]
[HealthChatProvider] Total bai thuoc in provider: 8
[HealthChatProvider] BaiThuoc list:
[HealthChatProvider]   0. Bài thuốc hạ sốt - Giúp giảm sốt hiệu quả...
[HealthChatProvider]   1. Bài thuốc trị cảm lạnh - Chứa thảo dược...
[HealthChatProvider]   2. Bài thuốc mạnh ...
[HealthChatProvider] ✓ MATCHED: "Bài thuốc hạ sốt" with keyword "sốt"
[HealthChatProvider] ✓✓✓ Found 1 suggestions:
[HealthChatProvider]   - Bài thuốc hạ sốt
[HealthChatProvider] ===== END generateSuggestions ====
```

**Điều này chứng tỏ:**
- ✅ Keyword được phát hiện
- ✅ Bài thuốc được tìm thấy
- ✅ Card gợi ý sẽ hiển thị dưới cùng chat

---

## ❌ Nếu Không Hoạt Động - Troubleshooting

### Problem 1: `_shouldGenerateSuggestions: false` mặc dù user nói "ho"

**Nguyên nhân:** 
- Từ khóa "ho" không trong danh sách
- Có dấu lạ hoặc encoding khác

**Fix:**
1. Kiểm tra console xem message là gì
2. Thêm keyword vào danh sách `suggestionKeywords`

```dart
final suggestionKeywords = [
  'ho',      // Chắc chắn có này
  'hồ',      // Thêm variant nếu có dấu
];
```

---

### Problem 2: `Total bai thuoc in provider: 0`

**Nguyên nhân:** 
- BaiThuocProvider chưa load data
- Database trống

**Fix:**
1. Kiểm tra `bai_thuoc_provider.dart` xem `baiThuocList` có data không
2. Thêm print trong initState:
```dart
void _initializeChat() {
  final baiThuocProvider = context.read<BaiThuocProvider>();
  print('[DEBUG] BaiThuoc count: ${baiThuocProvider.baiThuocList.length}');
}
```

---

### Problem 3: Keyword phát hiện nhưng không match bài thuốc

**Nguyên nhân:**
- Bài thuốc `tên` hoặc `mô tả` không chứa keyword
- Case sensitivity issue

**Fix:**
Kiểm tra console:
```
[HealthChatProvider] Extracted keywords: [ho]
[HealthChatProvider] BaiThuoc list:
[HealthChatProvider]   0. Bài thuốc XYZ - description không có "ho"...
```

Cần update bài thuốc hoặc thêm keyword vào `_extractKeywords()`

---

## 📝 Keyword Hiện Có

```dart
// Triệu chứng
'cảm', 'ho', 'sốt', 'đau đầu', 'mệt mỏi', 'viêm họng', 
'cảm lạnh', 'buồn nôn', 'nôn', 'tiêu chảy', 'táo bón', 
'đau bụng', 'chóng mặt', 'mất ngủ', 'stress', 'lo âu', 
'trầm cảm', 'thừa cân', 'béo phì', 'tiểu đường', 'huyết áp', 
'tim', 'phổi', 'dạ dày', 'gan', 'thận', 'khớp', 'xương', 'cơ'

// Yêu cầu gợi ý
'gợi ý', 'nên ăn gì', 'nên uống gì'
```

---

## 🎯 Kết Luận

✅ **Lý do gợi ý không hoạt động trước:** Logic `_shouldGenerateSuggestions()` quá hạn chế - chỉ trigger khi user nói "gợi ý"

✅ **Fix:** Thêm tất cả triệu chứng vào keywords - LUÔN gợi ý khi phát hiện triệu chứng

✅ **Debug:** Print chi tiết ở mỗi bước để dễ track lỗi

**Test ngay bằng cách nói:**
- "Tôi bị ho" → Sẽ show bài thuốc trị ho
- "Tôi bị sốt cao" → Sẽ show bài thuốc hạ sốt
- "Bài thuốc trị cảm?" → Sẽ show bài thuốc trị cảm
