# 💻 Detailed Code Changes Reference

## 📄 File 1: `lib/screens/home/home_screen.dart`

### Change 1: Added FloatingActionButton with Center Docking

**Location:** In `build()` method, after `Scaffold(body:` line

```dart
floatingActionButton: FloatingActionButton(
  onPressed: () {
    // Navigate to food analysis screen when camera button is pressed
    if (_currentIndex != 2) {
      setState(() => _currentIndex = 2);
    }
  },
  elevation: 8,
  shape: const CircleBorder(),
  backgroundColor: colorScheme.primary,
  foregroundColor: colorScheme.onPrimary,
  child: const Icon(Icons.camera_alt_rounded, size: 28),
),
floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
```

**Purpose:**
- Creates a camera button in the center of the bottom navigation
- Elevation of 8 for depth effect
- Uses primary color scheme
- 28px icon size

### Change 2: Enhanced Glassmorphism Effect

**Location:** Bottom navigation bar decoration

**Before:**
```dart
filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
color: colorScheme.surface.withValues(alpha: 0.9),
border: BorderSide(
  color: Colors.white.withValues(alpha: 0.1),
  width: 1,
),
boxShadow: [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.1),
    blurRadius: 10,
    offset: const Offset(0, -2),
  ),
],
```

**After:**
```dart
filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
color: colorScheme.surface.withValues(alpha: 0.7),
border: Border(
  top: BorderSide(
    color: Colors.white.withValues(alpha: 0.15),
    width: 1.2,
  ),
),
boxShadow: [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.15),
    blurRadius: 20,
    offset: const Offset(0, -4),
    spreadRadius: 2,
  ),
],
```

**Changes:**
- Blur: 10 → 15 (more glass-like)
- Alpha: 0.9 → 0.7 (more transparent)
- Border opacity: 0.1 → 0.15 (more visible)
- Border width: 1 → 1.2 (slightly thicker)
- Shadow blur: 10 → 20 (softer shadow)
- Shadow offset: (0, -2) → (0, -4) (more depth)
- Shadow spread: 0 → 2 (larger shadow area)
- Shadow opacity: 0.1 → 0.15 (darker shadow)

### Change 3: Updated Navigation Index Logic

**Location:** NavigationBar destinations and onDestinationSelected

**Navigation Flow:**
```dart
onDestinationSelected: (index) {
  setState(() {
    // Map navigation bar indices accounting for center FAB
    _currentIndex = index < 1 ? index : index == 1 ? 1 : index + 1;
  });
}
```

**Index Mapping:**
```
Navigation Bar Position  →  Screen Index
0 (Home)                 →  0
1 (Remedies)             →  1
[Center FAB - Camera]    →  2 (triggered separately)
2 (Food)                 →  3
3 (Profile)              →  4
```

---

## 📄 File 2: `lib/providers/food_analysis_provider.dart`

### Change 1: Added Filter State Variables

**Location:** In class, after `List<PredictionHistory> _history = [];`

```dart
List<PredictionHistory> _filteredHistory = [];
String _selectedTimeFilter = 'all'; // all, today, week, month
String _selectedMealFilter = 'all'; // all, breakfast, lunch, dinner, snack
```

**Purpose:**
- Store filtered results separately
- Track current filter selections

### Change 2: Added Filter Getters

**Location:** In getters section

```dart
List<PredictionHistory> get filteredHistory => _filteredHistory;
String get selectedTimeFilter => _selectedTimeFilter;
String get selectedMealFilter => _selectedMealFilter;
```

**Purpose:**
- Expose filter state to UI widgets
- Allow Consumer widget to access filter data

### Change 3: Added setTimeFilter Method

```dart
void setTimeFilter(String timeFilter) {
  _selectedTimeFilter = timeFilter;
  _applyFilters();
  notifyListeners();
}
```

**Time Filters Supported:**
- `'all'`: All records
- `'today'`: Today only
- `'week'`: Last 7 days
- `'month'`: Last 30 days

### Change 4: Added setMealFilter Method

```dart
void setMealFilter(String mealFilter) {
  _selectedMealFilter = mealFilter;
  _applyFilters();
  notifyListeners();
}
```

**Meal Filters Supported:**
- `'all'`: All meal types
- `'breakfast'`: Breakfast items
- `'lunch'`: Lunch items
- `'dinner'`: Dinner items
- `'snack'`: Snack items

### Change 5: Added resetFilters Method

```dart
void resetFilters() {
  _selectedTimeFilter = 'all';
  _selectedMealFilter = 'all';
  _applyFilters();
  notifyListeners();
}
```

**Purpose:**
- Clear all filters back to default
- Useful for "Reset" buttons

### Change 6: Core Filtering Logic - _applyFilters Method

```dart
void _applyFilters() {
  _filteredHistory = _history.where((item) {
    // Apply time filter
    final now = DateTime.now();
    final itemDate = item.createdAt;
    
    bool timeFilterMatch = false;
    switch (_selectedTimeFilter) {
      case 'today':
        timeFilterMatch = itemDate.year == now.year &&
            itemDate.month == now.month &&
            itemDate.day == now.day;
        break;
      case 'week':
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        timeFilterMatch = itemDate.isAfter(sevenDaysAgo) && 
                          itemDate.isBefore(now.add(const Duration(days: 1)));
        break;
      case 'month':
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        timeFilterMatch = itemDate.isAfter(thirtyDaysAgo) && 
                          itemDate.isBefore(now.add(const Duration(days: 1)));
        break;
      default: // 'all'
        timeFilterMatch = true;
    }

    // Apply meal type filter
    bool mealFilterMatch = _selectedMealFilter == 'all' ||
        item.mealType?.toLowerCase() == _selectedMealFilter.toLowerCase();

    return timeFilterMatch && mealFilterMatch;
  }).toList();
}
```

**Filtering Algorithm:**
1. Iterate through all history items
2. Check time range:
   - **Today**: Compare year, month, day
   - **Week**: Calculate 7 days ago, check if between that and tomorrow
   - **Month**: Calculate 30 days ago, check if between that and tomorrow
   - **All**: Always true
3. Check meal type:
   - **All**: Always true
   - **Specific**: Compare with item's mealType (case-insensitive)
4. Return items matching BOTH conditions (AND logic)

### Change 7: Updated fetchHistory Method

**Added after fetching:**
```dart
_applyFilters(); // Apply current filters to new data
```

**Purpose:**
- Ensure filters are applied to newly fetched data
- Maintains filter state across data updates

### Change 8: Updated deleteAnalysis Method

**Added after deletion:**
```dart
_applyFilters(); // Reapply filters after deletion
```

**Purpose:**
- Remove deleted item from filtered list
- Prevent showing deleted items in results

---

## 📄 File 3: `lib/screens/food/food_analysis_screen.dart`

### Change 1: Replaced _buildHistoryTab Method

**Before:** Simple ListView with all items

**After:** Enhanced version with:
- Dual filter UI (time + meal type)
- Result counter
- Empty state handling
- Filtered list display

### Change 2: Added _buildFilterChip Method

```dart
Widget _buildFilterChip(
  String label,
  bool isSelected,
  ColorScheme colorScheme, {
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isSelected
            ? colorScheme.primary.withValues(alpha: 0.9)
            : colorScheme.surface,
        border: Border.all(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
        ),
      ),
    ),
  );
}
```

**Styling:**
- Rounded corners (20dp radius)
- Selected: Primary color background + white text
- Unselected: Surface color + outline border
- Padding: 14h × 8v
- Font: 13sp, weight 500

### Change 3: Filter UI Structure

**Time Filter Section:**
```dart
Text('Thời gian'), // Label
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      _buildFilterChip('Tất cả', ...),
      _buildFilterChip('Hôm nay', ...),
      _buildFilterChip('Tuần này', ...),
      _buildFilterChip('Tháng này', ...),
    ],
  ),
),
```

**Meal Type Filter Section:**
```dart
Text('Loại bữa ăn'), // Label
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      _buildFilterChip('Tất cả', ...),
      _buildFilterChip('Sáng', ...),
      _buildFilterChip('Trưa', ...),
      _buildFilterChip('Tối', ...),
      _buildFilterChip('Phụ', ...),
    ],
  ),
),
```

### Change 4: Results Counter

```dart
Text(
  'Tìm thấy ${provider.filteredHistory.length} kết quả',
  style: TextStyle(
    fontSize: 12,
    color: colorScheme.onSurfaceVariant,
    fontStyle: FontStyle.italic,
  ),
),
```

**Purpose:**
- Shows number of items matching filters
- Updates in real-time
- Helps user understand filter impact

### Change 5: Updated ListView to Use Filtered Data

**Before:**
```dart
ListView.builder(
  itemCount: provider.history.length,
  itemBuilder: (context, index) {
    final item = provider.history[index];
    ...
  },
)
```

**After:**
```dart
if (provider.filteredHistory.isEmpty)
  // Empty state widget
else
  ListView.builder(
    itemCount: provider.filteredHistory.length,
    itemBuilder: (context, index) {
      final item = provider.filteredHistory[index];
      return _buildHistoryItem(item, colorScheme, provider);
    },
  )
```

### Change 6: Empty State Handling

```dart
if (provider.filteredHistory.isEmpty)
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 32.0),
    child: Center(
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'Không có kết quả phù hợp',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  )
```

**Purpose:**
- Show friendly message when no items match
- Icon for better UX
- Centered layout

---

## 🔄 Data Flow Diagram

```
User Interface
    ↓
FilterChip Tapped
    ↓
provider.setTimeFilter('today')  OR  provider.setMealFilter('lunch')
    ↓
FoodAnalysisProvider._applyFilters()
    ↓
Loop through history:
├─ Check time condition
├─ Check meal condition
└─ Include if both match
    ↓
Update filteredHistory list
    ↓
notifyListeners()
    ↓
Consumer rebuilds ListView
    ↓
UI shows filtered results
```

---

## 🎯 Key Implementation Points

### 1. Separation of Concerns
- **Provider**: Business logic (filtering)
- **Widget**: UI rendering (chips, list)
- **Model**: Data structure (PredictionHistory)

### 2. Reactive Programming
- Changes trigger `notifyListeners()`
- Consumer widget rebuilds automatically
- No manual UI updates needed

### 3. Performance
- Filtering done in provider (not UI)
- No unnecessary rebuilds of entire list
- Local filtering (no API calls)

### 4. User Experience
- Instant filter application
- Visual feedback (selected state)
- Result counter for clarity
- Empty state messaging

### 5. Code Maintainability
- Clear naming conventions
- Well-commented code
- Single responsibility per method
- Easy to extend (add new filters)

---

## 📊 State Management Flow

```
Initial State:
├─ history: []
├─ filteredHistory: []
├─ selectedTimeFilter: 'all'
└─ selectedMealFilter: 'all'

↓ User loads history

After fetchHistory:
├─ history: [Item1, Item2, Item3, ...]
├─ filteredHistory: [all items] (no filter applied)
├─ selectedTimeFilter: 'all'
└─ selectedMealFilter: 'all'

↓ User selects time filter

After setTimeFilter('today'):
├─ history: [Item1, Item2, Item3, ...] (unchanged)
├─ filteredHistory: [Item1, Item3] (only today's items)
├─ selectedTimeFilter: 'today'
└─ selectedMealFilter: 'all'

↓ User selects meal filter

After setMealFilter('lunch'):
├─ history: [Item1, Item2, Item3, ...] (unchanged)
├─ filteredHistory: [Item1] (today's lunch items)
├─ selectedTimeFilter: 'today'
└─ selectedMealFilter: 'lunch'
```

---

## ✅ Testing Checklist

- [x] FAB appears in navigation bar
- [x] FAB is centered
- [x] FAB has correct styling
- [x] FAB navigation works
- [x] Glassmorphism effect visible
- [x] Time filters work individually
- [x] Meal filters work individually
- [x] Combined filters work correctly
- [x] Result counter updates
- [x] Empty state displays correctly
- [x] List rebuilds on filter change
- [x] No compilation errors

---

**Code Complete:** November 23, 2025 ✅
