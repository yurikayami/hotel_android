# **📘 Hướng Dẫn Refactor General Search Screen (React to Flutter)**

Tài liệu này hướng dẫn chi tiết cách chuyển đổi giao diện "General Search" từ bản thiết kế React (Dark Mode) sang Flutter cho dự án hotel\_android.

## **1\. Mục Tiêu**

Thiết kế lại lib/screens/search/general\_search\_screen.dart và cập nhật lib/providers/search\_provider.dart để đạt được giao diện và tính năng sau:

1. **Theme:** Dark Mode chủ đạo.  
2. **Layout:**  
   * **Users:** List dọc, style TikTok (Avatar tròn, nút Follow đỏ).  
   * **Posts:** List dọc, style "Tạp chí" (Text bên trái, Ảnh thumbnail bên phải, nền trong suốt).  
   * **Medicines & Dishes:** Grid 2 cột (Ảnh vuông, thông tin bên dưới).  
3. **Tính năng:**  
   * Tab "Tất cả": Sắp xếp theo thứ tự: **Users \-\> Posts \-\> Medicines \-\> Dishes**.  
   * Các Tab con (Bài viết, Món ăn...): Có thanh **Filter/Sort** (Giá, Lượt xem, Mới nhất) sticky bên dưới TabBar.

## **2\. Cập nhật Data Model & Provider**

### **A. Update SearchProvider (lib/providers/search\_provider.dart)**

Cần thêm state để quản lý Filter và Sort cục bộ (client-side sorting dựa trên kết quả tìm kiếm hiện có).

// Thêm vào SearchProvider  
String \_filterCategory \= 'Tất cả';  
String \_sortOption \= 'default'; // default, price\_asc, price\_desc, likes, views, newest

void setFilter(String category) {  
  \_filterCategory \= category;  
  notifyListeners();  
}

void setSort(String option) {  
  \_sortOption \= option;  
  notifyListeners();  
}

// Getter để lấy list đã lọc/sắp xếp  
List\<MonAn\> get filteredDishes {  
  List\<MonAn\> list \= List.from(\_results.dishes);  
  // Implement logic lọc theo \_filterCategory và sort theo \_sortOption (giá)  
  return list;  
}  
// Tương tự cho filteredPosts, filteredMedicines

## **3\. Mapping UI Components (React \-\> Flutter)**

### **A. Helper Functions**

* cleanContent: Sử dụng lib/widgets/html\_content\_viewer.dart hoặc thư viện html để parse, nhưng đơn giản nhất là dùng RegExp để strip tags cho phần preview text.  
* formatTimeAgo: Dùng logic tương tự React hoặc thư viện timeago.  
* formatCurrency: Dùng NumberFormat.currency(locale: 'vi\_VN', symbol: 'đ').

### **B. Widgets Tương Ứng**

#### **1\. UserItemTikTok (React) \-\> UserListItem (Flutter)**

* **Root:** Container (padding, decoration border bottom).  
* **Layout:** Row.  
* **Avatar:** CircleAvatar bọc Image.network (Dùng ImageUrlHelper.formatImageUrl).  
* **Info:** Column (Username: Bold white, Nickname: Grey, Stats: Grey small).  
* **Button:** ElevatedButton (style: backgroundColor: Color(0xFFFE2C55) cho trạng thái chưa follow).

#### **2\. PostItemMagazine (React) \-\> PostMagazineItem (Flutter)**

* **Root:** InkWell (onTap) \-\> Container (Màu nền: Colors.transparent).  
* **Header:** Row (Avatar nhỏ, Tên, Thời gian).  
* **Body:** Row (crossAxisAlignment: start).  
  * **Left (Expanded):** Column (Title: Style H3 bold, Excerpt: maxLines: 2, Actions: Row(Heart, Comment icon)).  
  * **Right:** SizedBox(width: 12\) \-\> ClipRRect (borderRadius: 12\) \-\> Image.network (size: 90x90, fit: cover).

#### **3\. GridItem (React) \-\> GridContentItem (Flutter)**

* **Root:** Card hoặc Container (decoration: borderRadius, color: Grey\[900\]).  
* **Image:** AspectRatio (ratio: 1.0 \- hình vuông) \-\> Stack:  
  * Image.network (fit: cover).  
  * Positioned (Top Right): Heart Button.  
  * Positioned (Bottom Left): Price Tag (cho Món ăn).  
* **Content:** Padding \-\> Column:  
  * Title: maxLines: 2\.  
  * Description: Text Grey, maxLines: 2 (Yêu cầu mới).  
  * Footer: Row (View count / Category).

#### **4\. FilterBar (React) \-\> FilterChoiceBar (Flutter)**

* **Widget:** SliverToBoxAdapter hoặc PreferredSizeWidget (nếu đặt trong AppBar).  
* **Content:** SingleChildScrollView (horizontal).  
* **Items:** ChoiceChip hoặc OutlinedButton với style bo tròn (RoundedStadiumBorder).

## **4\. Cấu trúc màn hình GeneralSearchScreen**

Sử dụng DefaultTabController kết hợp NestedScrollView để có hiệu ứng cuộn mượt mà.

Scaffold(  
  backgroundColor: Colors.black, // Dark Theme  
  body: DefaultTabController(  
    length: 5,  
    child: NestedScrollView(  
      headerSliverBuilder: (context, innerBoxIsScrolled) \=\> \[  
        // 1\. Search Bar (Pinned)  
        SliverAppBar(  
          backgroundColor: Colors.black,  
          title: SearchBarWidget(...), // Input search  
          floating: true,  
          pinned: true,  
          bottom: TabBar(  
            isScrollable: true,  
            tabs: \[  
              Tab(text: 'Tất cả'),  
              Tab(text: 'Người dùng'),  
              Tab(text: 'Bài viết'),  
              Tab(text: 'Bài thuốc'),  
              Tab(text: 'Món ăn'),  
            \],  
            // Styles indicator màu xanh Emerald  
          ),  
        ),  
          
        // 2\. Filter Bar (Chỉ hiện ở các tab con, dùng logic hiển thị có điều kiện)  
        // Lưu ý: Khó đưa FilterBar vào đây nếu muốn nó thay đổi theo từng Tab.  
        // Cách tốt hơn: Đưa FilterBar vào bên trong body của từng TabView con.  
      \],  
      body: TabBarView(  
        children: \[  
          \_buildAllTab(),      // Tab Tất cả  
          \_buildUsersTab(),    // Tab Người dùng  
          \_buildPostsTab(),    // Tab Bài viết (có FilterBar đầu list)  
          \_buildMedicinesTab(),// Tab Bài thuốc (có FilterBar đầu list)  
          \_buildDishesTab(),   // Tab Món ăn (có FilterBar đầu list)  
        \],  
      ),  
    ),  
  ),  
);

### **Logic Tab "Tất cả" (\_buildAllTab)**

Sử dụng CustomScrollView hoặc ListView:

1. **Section Users:** Header "Người dùng" \-\> List Users (limit 3-5) \-\> Button "Xem thêm".  
2. **Section Posts:** Header "Bài viết nổi bật" \-\> List Posts.  
3. **Section Medicines:** Header "Bài thuốc dân gian" \-\> Grid Medicines (physics: NeverScrollableScrollPhysics, shrinkWrap: true).  
4. **Section Dishes:** Header "Món ngon mỗi ngày" \-\> Grid Dishes.

## **5\. Yêu cầu Style chi tiết (Tailwind \-\> Flutter)**

* **Colors:**  
  * Background: Colors.black or Color(0xFF121212).  
  * Card/Item Background: Color(0xFF1E1E1E).  
  * Primary/Accent: Colors.emerald (Flutter: Colors.greenAccent hoặc define màu \#34D399).  
  * Text Primary: Colors.white hoặc Colors.grey\[100\].  
  * Text Secondary: Colors.grey\[400\].  
  * TikTok Follow Button: Color(0xFFFE2C55).  
* **Typography:** Sử dụng Theme.of(context).textTheme nhưng override màu sắc sang trắng/xám.

## **6\. Implementation Checklist**

1. \[ \] Tạo các Widget con: UserListItem, PostMagazineItem, GridContentItem, FilterChoiceBar.  
2. \[ \] Update SearchProvider thêm logic filter/sort.  
3. \[ \] Viết lại GeneralSearchScreen sử dụng NestedScrollView.  
4. \[ \] Tích hợp API:  
   * Map dữ liệu từ SearchResults model vào các widget.  
   * Xử lý loading state và empty state.  
5. \[ \] Kiểm tra hiển thị ảnh bằng ImageUrlHelper.