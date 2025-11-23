import 'package:flutter/material.dart';
import 'dart:ui';
import '../posts/post_feed_screen.dart';
import '../food/mon_an_screen.dart';
import '../food/food_analysis_screen.dart';
import '../bai_thuoc/bai_thuoc_list_screen.dart';
import '../profile/my_profile_screen.dart';

/// Modern home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PostFeedScreen(),           // index 0: Trang chủ
    const BaiThuocListScreen(),       // index 1: Bài Thuốc
    const FoodAnalysisScreen(),       // index 2: Phân Tích (Camera - Center)
    const MonAnScreen(),              // index 3: Món Ăn
    const MyProfileScreen(),          // index 4: Cá nhân
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
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
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                navigationBarTheme: NavigationBarThemeData(
                  indicatorColor: _currentIndex == 2 ? Colors.transparent : null,
                ),
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  setState(() => _currentIndex = index);
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                destinations: [
                  NavigationDestination(
                    icon: Icon(_currentIndex == 0 ? Icons.home : Icons.home_outlined),
                    label: 'Trang chủ',
                  ),
                  NavigationDestination(
                    icon: Icon(_currentIndex == 1 ? Icons.local_hospital_rounded : Icons.local_hospital_outlined),
                    label: 'Bài Thuốc',
                  ),
                  // Center Camera Button - Prominent Style (index 2)
                  NavigationDestination(
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                    label: 'Phân Tích',
                  ),
                  NavigationDestination(
                    icon: Icon(_currentIndex == 3 ? Icons.restaurant_menu : Icons.restaurant_menu_outlined),
                    label: 'Món Ăn',
                  ),
                  NavigationDestination(
                    icon: Icon(_currentIndex == 4 ? Icons.person : Icons.person_outline),
                    label: 'Cá nhân',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

