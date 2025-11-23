# Bài Thuốc Refactoring - Implementation Guide

## Quick Reference

### File Updates
✅ `lib/screens/bai_thuoc/bai_thuoc_list_screen.dart` - Complete redesign
✅ `lib/screens/bai_thuoc/bai_thuoc_detail_screen.dart` - Design alignment
✅ Sorting feature with 3 options
✅ Search integration with GeneralSearchScreen
✅ Modern Material 3 design

---

## bai_thuoc_list_screen.dart - Key Changes

### Before: Card-based Grid Layout
```
┌─────────────────────┐
│ [IMAGE]             │
├─────────────────────┤
│ Title               │
│ Description text... │
│ Avatar | Author     │
│ ❤️ 123  👁️ 456     │
│ Date                │
└─────────────────────┘
```

### After: Twitter-style Feed Layout
```
┌─────────────────────────────────┐
│ [Avatar] Author          [time] │
│ Title                           │
│ Description text...             │
│ [IMAGE - if available]          │
│ ❤️123  👁️456  📤              │
└─────────────────────────────────┘
```

### Header Features
```
┌──────────────────────────┐
│ Bài Thuốc    🔍    🔀   │  ← Search & Sort buttons
└──────────────────────────┘
```

### Sorting Menu (Bottom Sheet)
```
┌─ Sắp xếp theo ─┐
│ Mới nhất  (default)
│ Lượt thích
│ Lượt xem
└────────────────┘
```

---

## bai_thuoc_detail_screen.dart - Key Changes

### Before: Custom ScrollView with SliverAppBar
```
┌──────────────────────────┐
│ [LARGE IMAGE - expandable]
├──────────────────────────┤
│ Title
│ Author Info with Avatar
│ Stats: ❤️ thích | 👁️ xem
│ Description
│ Image
│ Usage Guide
└──────────────────────────┘
```

### After: Single Scroll with Modern Layout
```
┌──────────────────────────────┐
│ ◄ Chi tiết bài thuốc         │
├──────────────────────────────┤
│ [Avatar] Author     [dd/MM]  │ ← Clickable
│ Title                        │
│ ❤️ Thích | 👁️ Xem | 📤 Chia│ ← Stat Buttons
├──────────────────────────────┤
│ Mô tả                        │
│ [Description Box]            │
│ [IMAGE]                      │
│ Hướng dẫn sử dụng            │
│ [Usage Box]                  │
└──────────────────────────────┘
```

---

## UI Components

### Card Item (List Screen)
```dart
InkWell(
  child: Container(
    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    child: Column(
      children: [
        // Header: Avatar + Name + Date
        Row(
          children: [
            CircleAvatar(radius: 20),
            Column(
              children: [
                Text(authorName),
                Text(_formatDate(date)),
              ],
            ),
          ],
        ),
        // Title
        Text(title, style: fontSize 16, fontWeight w600),
        // Description
        Text(description, maxLines: 2),
        // Image (if available)
        ClipRRect(borderRadius: 12, child: Image),
        // Stats
        Row(
          children: [
            _buildStatButton(favorite),
            _buildStatButton(view),
            Icon(share),
          ],
        ),
      ],
    ),
  ),
)
```

### Stat Button
```dart
Material(
  child: InkWell(
    child: Padding(
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 4),
          Text(_formatCount(count), fontSize: 12),
        ],
      ),
    ),
  ),
)
```

---

## Sorting Implementation

### State Variable
```dart
String _sortBy = 'newest'; // newest, mostLiked, mostViewed
```

### Sort Logic
```dart
List<BaiThuoc> _getSortedList(List<BaiThuoc> items) {
  final sorted = List<BaiThuoc>.from(items);
  switch (_sortBy) {
    case 'mostLiked':
      sorted.sort((a, b) => 
        (b.soLuotThich ?? 0).compareTo(a.soLuotThich ?? 0));
      break;
    case 'mostViewed':
      sorted.sort((a, b) => 
        (b.soLuotXem ?? 0).compareTo(a.soLuotXem ?? 0));
      break;
    case 'newest':
    default:
      sorted.sort((a, b) => b.ngayTao.compareTo(a.ngayTao));
  }
  return sorted;
}
```

### Using Sorted List
```dart
final sortedList = _getSortedList(provider.baiThuocList);
// Build list with sortedList instead of provider.baiThuocList
```

---

## Search Integration

### Navigation to Search Screen
```dart
IconButton(
  icon: const Icon(Icons.search_rounded),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GeneralSearchScreen(),
      ),
    );
  },
)
```

---

## Helper Methods

### Format Count (1000+ → 1K, 1000000+ → 1M)
```dart
String _formatCount(int count) {
  if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1)}M';
  } else if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}K';
  }
  return count.toString();
}
```

### Format Date (Relative time display)
```dart
String _formatDate(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inSeconds < 60) return 'Vừa xong';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return DateFormat('MMM d').format(date);
}
```

---

## Color Scheme Usage

- **Primary Color**: Main accent (buttons, selected state)
- **Red**: Favorite/Like count
- **Tertiary**: Share button
- **OnSurfaceVariant**: Secondary text, timestamps
- **SurfaceVariant**: Backgrounds for sections
- **PrimaryContainer**: Author section, headers

---

## Testing Checklist

- [ ] List displays articles with modern layout
- [ ] Sorting works for all three options (newest, likes, views)
- [ ] Search icon navigates to GeneralSearchScreen
- [ ] Detail screen shows all content sections
- [ ] Author profile navigation works
- [ ] Images load correctly (URL and base64)
- [ ] Error states display properly
- [ ] Loading shimmer appears
- [ ] Empty state shows when no articles
- [ ] Responsive on different screen sizes

---

## Performance Notes

- Uses `SliverList.separated` for efficient rendering
- Sorting is done in-memory (list < 500 items acceptable)
- Images loaded with proper error handling
- Loading shimmer prevents blank state
- Dividers use efficient painting

---

## Accessibility Improvements

- Clear visual hierarchy
- Sufficient color contrast
- Descriptive labels
- Proper touch targets (min 48dp)
- Readable font sizes
- Semantic content structure

