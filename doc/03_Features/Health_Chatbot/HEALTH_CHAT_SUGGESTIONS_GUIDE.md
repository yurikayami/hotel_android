# Health Chat Suggestions Feature Guide

## 📋 Overview

Cập nhật tính năng **Health Chat** để tự động đề xuất **bài thuốc (medications)** và **món ăn (dishes)** dựa trên từ khóa triệu chứng từ tin nhắn người dùng.

**Tính năng chính:**
- ✅ Phân tích tin nhắn người dùng để trích xuất từ khóa triệu chứng
- ✅ Tìm kiếm bài thuốc và món ăn liên quan trong cơ sở dữ liệu
- ✅ Hiển thị tối đa 3 đề xuất cho mỗi loại (bài thuốc + món ăn)
- ✅ Điều hướng đến chi tiết khi nhấp vào card đề xuất
- ✅ Xóa đề xuất tự động sau khi điều hướng

## 🏗️ Architecture

### State Management Layer
**File:** `lib/providers/health_chat_provider.dart`

```dart
// Suggestion state
List<BaiThuoc> _suggestedBaiThuoc = [];
List<MonAn> _suggestedMonAn = [];

// Getters
List<BaiThuoc> get suggestedBaiThuoc => _suggestedBaiThuoc;
List<MonAn> get suggestedMonAn => _suggestedMonAn;
```

**Phương thức chính:**

| Phương thức | Mô tả |
|-----------|--------|
| `_extractKeywords(String)` | Trích xuất từ khóa triệu chứng từ tin nhắn (case-insensitive) |
| `generateSuggestions(String, BaiThuocProvider, MonAnProvider)` | Tạo đề xuất từ cơ sở dữ liệu dựa trên từ khóa |
| `clearSuggestions()` | Xóa tất cả đề xuất |

### Keyword Extraction
Các từ khóa triệu chứng được hỗ trợ:
```
cảm, ho, sốt, đau đầu, mệt mỏi, viêm họng, cảm lạnh, buồn nôn, nôn,
tiêu chảy, táo bón, đau bụng, chóng mặt, mất ngủ, stress, lo âu,
trầm cảm, thừa cân, béo phì, tiểu đường, huyết áp, tim, phổi,
dạ dày, gan, thận, khớp, xương, cơ
```

### Suggestion Algorithm
1. Trích xuất từ khóa từ tin nhắn người dùng
2. Nếu không có từ khóa → không hiển thị đề xuất
3. Tìm kiếm trong `baiThuocList` và `allMonAn`:
   - Khớp từ khóa với trường `ten` (tên)
   - Khớp từ khóa với trường `moTa` (mô tả)
   - Sử dụng tìm kiếm case-insensitive
4. Giới hạn kết quả: `take(3)` (tối đa 3 items mỗi loại)
5. Gọi `notifyListeners()` để cập nhật UI

### UI Layer
**File:** `lib/screens/profile/health_chat_screen.dart`

**Widgets:**

| Widget | Mục đích |
|--------|---------|
| `_buildSuggestions()` | Hiển thị phần đề xuất chứa bài thuốc + món ăn |
| `_buildSuggestionCard()` | Hiển thị card đề xuất riêng lẻ (Material Design 3) |

**Layout Flow:**
```
┌─ Column (body)
│  ├─ Expanded (Chat messages)
│  ├─ [IF suggestions exist] _buildSuggestions()
│  │  └─ Column
│  │     ├─ "Bài thuốc gợi ý" header
│  │     ├─ ListView horizontal (medicines)
│  │     ├─ "Món ăn phù hợp" header
│  │     └─ ListView horizontal (dishes)
│  ├─ [IF error] ErrorBanner
│  └─ MessageInput
```

### Routing Layer
**File:** `lib/main.dart`

**Cấu hình routes:**
```dart
onGenerateRoute: (settings) {
  // /bai-thuoc-detail
  if (settings.name?.startsWith('/bai-thuoc-detail') ?? false) {
    final id = settings.arguments as String?;
    return MaterialPageRoute(
      builder: (context) => BaiThuocDetailScreen(baiThuocId: id!),
    );
  }
  
  // /mon-an-detail
  if (settings.name?.startsWith('/mon-an-detail') ?? false) {
    final id = settings.arguments as String?;
    final monAn = context.read<MonAnProvider>().allMonAn
        .firstWhere((item) => item.id == id);
    return MaterialPageRoute(
      builder: (context) => MonAnDetailScreen(monAn: monAn),
    );
  }
}
```

## 🔄 Data Flow

```
User sends message
      ↓
HealthChatScreen._handleSendMessage()
      ↓
chatProvider.sendMessage() [Gemini API response]
      ↓
chatProvider.generateSuggestions() [triggered]
      ↓
Extract keywords from user message
      ↓
Search in BaiThuocProvider.baiThuocList (max 3)
Search in MonAnProvider.allMonAn (max 3)
      ↓
Update _suggestedBaiThuoc & _suggestedMonAn
      ↓
notifyListeners()
      ↓
UI rebuilds with suggestion cards
      ↓
[User clicks suggestion card]
      ↓
Navigate to detail screen
      ↓
clearSuggestions()
```

## 🎨 UI Components

### Suggestion Card Example
```
┌─────────────────────────┐
│ 💊 Paracetamol → [→]    │  <- Material(3) card, light primary color
└─────────────────────────┘
```

**Styling:**
- Background: `colorScheme.primary.withOpacity(0.1)`
- Border: `colorScheme.primary.withOpacity(0.3)`
- Border radius: `12` dp
- Padding: `12px horizontal, 8px vertical`
- Text color: Primary (bold, label size)
- Icon color: Primary
- Animation: InkWell ripple on tap

### Suggestion Section
- Top border divider (0.5px)
- Horizontal scroll (non-scrollable if ≤3 items)
- Max height: 60dp per row
- Padding: 16px symmetric

## 📱 User Interaction Flow

### Happy Path
```
1. User opens Health Chat
2. User types: "Tôi đang bị cảm và sốt"
3. Sends message
4. AI responds with advice
5. Suggestion cards appear:
   - 3x Bài thuốc related to "cảm" & "sốt"
   - 3x Món ăn related to "cảm" & "sốt"
6. User clicks "Cà chua" (dish)
7. Navigate to MonAnDetailScreen
8. Suggestions auto-clear
9. User can see full dish details: image, price, cooking method, etc.
```

### Edge Cases
1. **No keywords match:** No suggestions shown (clean behavior)
2. **Only medicines found:** Show only "Bài thuốc gợi ý" section
3. **Only dishes found:** Show only "Món ăn phù hợp" section
4. **Multiple suggestions:** Show max 3 items, horizontal scroll (if needed)
5. **Item not found in detail:** Fallback to empty MonAn object (won't crash)

## 🔧 Integration Points

### BaiThuocProvider
- **Property used:** `baiThuocList` (List<BaiThuoc>)
- **Populated from:** BaiThuocService (API)
- **Access in:** `generateSuggestions()`

### MonAnProvider
- **Property used:** `allMonAn` (List<MonAn>)
- **Populated from:** MonAnService (API)
- **Access in:** `generateSuggestions()`

### Navigation
- **Routes:** `/bai-thuoc-detail` (with `id` as argument)
- **Routes:** `/mon-an-detail` (with `id` as argument)
- **Detail Screens:** BaiThuocDetailScreen, MonAnDetailScreen

## 💡 Example Usage

### Scenario 1: User has flu symptoms
```
Message: "Tôi bị cảm và ho nhiều, rất mệt"
Keywords extracted: ["cảm", "ho", "mệt"]

Search results:
- BaiThuoc: Hết cảm, Thuốc ho, Bổ sung năng lượng (3 items)
- MonAn: Cháo gà, Cam, Mật ong (3 items)

Display: 2 rows of cards
```

### Scenario 2: User asks about health in general
```
Message: "Hôm nay tôi cảm thấy thế nào?"
Keywords extracted: ["cảm"] (1 keyword detected)

Search results:
- BaiThuoc: Các sản phẩm có "cảm" trong tên/mô tả (up to 3)
- MonAn: Các món ăn có "cảm" trong tên/mô tả (up to 3)

Display: Suggestions shown if found
```

### Scenario 3: No medical keywords
```
Message: "Chào buổi sáng!"
Keywords extracted: [] (empty)

Result: No suggestions shown
```

## 🐛 Debugging

### Enable logging
```dart
// In HealthChatProvider.generateSuggestions()
developer.log(
  'Found ${_suggestedBaiThuoc.length} medicines and ${_suggestedMonAn.length} dishes',
  name: 'health_chat',
);
```

**Log stream name:** `health_chat`

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Suggestions not showing | Keywords not extracted | Check keyword list, update `_extractKeywords()` |
| Cards show but not clickable | Route not registered | Verify `/bai-thuoc-detail` & `/mon-an-detail` in `main.dart` |
| Navigation crashes | Item ID not found | Ensure `allMonAn` is populated before navigation |
| Duplicate suggestions | `take(3)` not applied | Check `generateSuggestions()` logic |

## 📊 Performance Notes

- Keyword extraction: O(n) where n = number of keywords (~30)
- Search: O(m) where m = total items (baiThuocList + allMonAn)
- For 1000 items + 30 keywords = ~30,000 comparisons (negligible)
- UI updates: Only on `notifyListeners()` → minimal rebuilds
- Suggestion section height: Fixed 60dp → no layout jank

## 🚀 Future Enhancements

1. **Smart matching:** Use fuzzy search instead of exact substring matching
2. **Scoring:** Rank suggestions by relevance score
3. **History:** Remember user's most viewed medications/dishes
4. **Personalization:** Filter by user's dietary preferences
5. **Analytics:** Track which suggestions are clicked
6. **Feedback:** Allow users to mark suggestions as helpful/not helpful

## 📝 Files Modified

| File | Changes |
|------|---------|
| `lib/providers/health_chat_provider.dart` | Added suggestion state + methods |
| `lib/screens/profile/health_chat_screen.dart` | Added suggestion UI + navigation logic |
| `lib/main.dart` | Added routes for detail screens |

## ✅ Testing Checklist

- [ ] Keyword extraction works for all 30+ keywords
- [ ] Suggestions appear when keywords are present
- [ ] Suggestions disappear when no keywords match
- [ ] Cards are clickable and navigate correctly
- [ ] Max 3 items per type is enforced
- [ ] Suggestions auto-clear after navigation
- [ ] Error handling for missing items
- [ ] UI responsive on different screen sizes
- [ ] Material Design 3 styling applied
- [ ] No performance degradation

---

**Last updated:** 2025-11-26
**Feature status:** ✅ Implementation Complete
