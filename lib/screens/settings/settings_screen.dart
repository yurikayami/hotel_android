import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Theme Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Giao diện',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          
          // Light Mode Option
          ListTile(
            leading: Icon(
              Icons.light_mode_rounded,
              color: themeProvider.isLightMode 
                  ? colorScheme.primary 
                  : colorScheme.onSurfaceVariant,
            ),
            title: const Text('Sáng'),
            subtitle: const Text('Chế độ sáng'),
            trailing: Radio<ThemeMode>(
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                }
              },
            ),
            onTap: () {
              themeProvider.setThemeMode(ThemeMode.light);
            },
          ),
          
          // Dark Mode Option
          ListTile(
            leading: Icon(
              Icons.dark_mode_rounded,
              color: themeProvider.isDarkMode 
                  ? colorScheme.primary 
                  : colorScheme.onSurfaceVariant,
            ),
            title: const Text('Tối'),
            subtitle: const Text('Chế độ tối'),
            trailing: Radio<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                }
              },
            ),
            onTap: () {
              themeProvider.setThemeMode(ThemeMode.dark);
            },
          ),
          
          // System Mode Option
          ListTile(
            leading: Icon(
              Icons.brightness_auto_rounded,
              color: themeProvider.isSystemMode 
                  ? colorScheme.primary 
                  : colorScheme.onSurfaceVariant,
            ),
            title: const Text('Hệ thống'),
            subtitle: const Text('Tự động theo thiết bị'),
            trailing: Radio<ThemeMode>(
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                }
              },
            ),
            onTap: () {
              themeProvider.setThemeMode(ThemeMode.system);
            },
          ),
          
          const Divider(),
          
          // Pure Dark Mode Option
          ListTile(
            leading: Icon(
              Icons.dark_mode_rounded,
              color: themeProvider.pureDarkMode && themeProvider.isDarkMode
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            title: const Text('Pure Dark Mode'),
            subtitle: const Text('Nền đen hoàn toàn khi ở chế độ tối'),
            trailing: Switch(
              value: themeProvider.isDarkMode ? themeProvider.pureDarkMode : false,
              onChanged: themeProvider.isDarkMode
                  ? (value) {
                      themeProvider.setPureDarkMode(value);
                    }
                  : null, // Disabled if not in dark mode
            ),
          ),
          
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Thanh trạng thái',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),

          // Hide Status Bar Option
          ListTile(
            leading: Icon(
              Icons.remove_circle_outline_rounded,
              color: themeProvider.hideStatusBar 
                  ? colorScheme.primary 
                  : colorScheme.onSurfaceVariant,
            ),
            title: const Text('Ẩn thanh trạng thái'),
            subtitle: const Text('Ẩn thanh thông tin hệ thống'),
            trailing: Switch(
              value: themeProvider.hideStatusBar,
              onChanged: (value) {
                themeProvider.setHideStatusBar(value);
                // Apply immediately
                if (value) {
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
                } else {
                  SystemChrome.setEnabledSystemUIMode(
                    SystemUiMode.manual,
                    overlays: SystemUiOverlay.values,
                  );
                }
              },
            ),
          ),
          
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Thông tin ứng dụng',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),

          // App Info
          ListTile(
            leading: Icon(
              Icons.info_rounded,
              color: colorScheme.primary,
            ),
            title: const Text('Phiên bản ứng dụng'),
            subtitle: const Text('v1.0.0'),
          ),

          // Developer Info
          ListTile(
            leading: Icon(
              Icons.person_rounded,
              color: colorScheme.primary,
            ),
            title: const Text('Nhà phát triển'),
            subtitle: const Text('Nguyễn Ngọc Phúc'),
          ),

          // Support Info
          ListTile(
            leading: Icon(
              Icons.help_rounded,
              color: colorScheme.primary,
            ),
            title: const Text('Hỗ trợ'),
            subtitle: const Text('nguyenngocphuc@gmail.com'),
          ),

          // Privacy Policy
          ListTile(
            leading: Icon(
              Icons.privacy_tip_rounded,
              color: colorScheme.primary,
            ),
            title: const Text('Chính sách bảo mật'),
            subtitle: const Text('Tìm hiểu cách chúng tôi bảo vệ dữ liệu của bạn'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to privacy policy
            },
          ),

          // Terms of Service
          ListTile(
            leading: Icon(
              Icons.description_rounded,
              color: colorScheme.primary,
            ),
            title: const Text('Điều khoản dịch vụ'),
            subtitle: const Text('Các điều khoản sử dụng ứng dụng'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to terms of service
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

