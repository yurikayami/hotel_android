import 'package:flutter/material.dart';
import '../posts/post_feed_screen.dart';
import '../food/mon_an_screen.dart';
import '../food/food_analysis_screen.dart';
import '../bai_thuoc/bai_thuoc_list_screen.dart';
import '../profile/my_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PostFeedScreen(),       // 0
    const BaiThuocListScreen(),   // 1
    const FoodAnalysisScreen(),   // 2 (Camera)
    const MonAnScreen(),          // 3
    const MyProfileScreen(),      // 4
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // Nếu bấm vào vị trí giữa (Camera) thì mở màn hình chụp
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FoodAnalysisScreen(),
        ),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // Dùng Stack ở bottomNavigationBar để nút Camera có thể "lòi ra" đè lên trên
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none, // Quan trọng: Cho phép nút lòi ra ngoài khung
        children: [
          // 1. THANH NAVIGATION BAR CHUẨN (Đã hạ chiều cao)
          Container(
            // Tạo bóng mờ phía sau thanh bar cho đẹp
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                height: 70, // HẠ CHIỀU CAO XUỐNG (Mặc định là 80)
                indicatorColor: colorScheme.primaryContainer,
                labelTextStyle: WidgetStateProperty.all(
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: _onItemTapped,
                backgroundColor: colorScheme.surface.withValues(alpha: 0.95),
                elevation: 0,
                destinations: [
                  const NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Trang chủ',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.local_hospital_outlined),
                    selectedIcon: Icon(Icons.local_hospital_rounded),
                    label: 'Bài thuốc',
                  ),
                  
                  // ITEM Ở GIỮA: Giữ chỗ (Sẽ bị nút tròn đè lên)
                  const NavigationDestination(
                    icon: SizedBox.shrink(), // Icon rỗng để không bị trùng
                    label: '', // Không hiện chữ
                    enabled: false, // Không cho bấm vào item chìm này (đã xử lý ở nút nổi)
                  ),

                  const NavigationDestination(
                    icon: Icon(Icons.restaurant_menu_outlined),
                    selectedIcon: Icon(Icons.restaurant_menu),
                    label: 'Món Ăn',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Cá nhân',
                  ),
                ],
              ),
            ),
          ),

          // 2. NÚT CAMERA LỒI RA (Nằm đè lên trên NavigationBar)
          Positioned(
            bottom: 20, // Đẩy nút lên cao để tạo hiệu ứng "lòi ra"
            child: GestureDetector(
              onTap: () => _onItemTapped(2),
              child: Container(
                height: 64, // Kích thước nút to hơn thanh bar một chút
                width: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: colorScheme.onPrimary,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}