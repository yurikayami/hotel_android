import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../providers/theme_provider.dart';
import '../../providers/meal_reminder_provider.dart';
import 'privacy_terms_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final mealReminderProvider = context.watch<MealReminderProvider>();
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
          
          // Theme Mode Options using RadioGroup
          RadioGroup<ThemeMode>(
            groupValue: themeProvider.themeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                themeProvider.setThemeMode(value);
              }
            },
            child: Column(
              children: [
                // Light Mode Option
                RadioListTile<ThemeMode>(
                  secondary: Icon(
                    Icons.light_mode_rounded,
                    color: themeProvider.isLightMode 
                        ? colorScheme.primary 
                        : colorScheme.onSurfaceVariant,
                  ),
                  title: const Text('Sáng'),
                  subtitle: const Text('Chế độ sáng'),
                  value: ThemeMode.light,
                ),
                
                // Dark Mode Option
                RadioListTile<ThemeMode>(
                  secondary: Icon(
                    Icons.dark_mode_rounded,
                    color: themeProvider.isDarkMode 
                        ? colorScheme.primary 
                        : colorScheme.onSurfaceVariant,
                  ),
                  title: const Text('Tối'),
                  subtitle: const Text('Chế độ tối'),
                  value: ThemeMode.dark,
                ),
                
                // System Mode Option
                RadioListTile<ThemeMode>(
                  secondary: Icon(
                    Icons.brightness_auto_rounded,
                    color: themeProvider.isSystemMode 
                        ? colorScheme.primary 
                        : colorScheme.onSurfaceVariant,
                  ),
                  title: const Text('Hệ thống'),
                  subtitle: const Text('Tự động theo thiết bị'),
                  value: ThemeMode.system,
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Meal Reminders Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Nhắc nhở bữa ăn',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),

          // Enable/Disable Reminders
          ListTile(
            leading: Icon(
              Icons.notifications_active_rounded,
              color: mealReminderProvider.remindersEnabled
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            title: const Text('Bật nhắc nhở'),
            subtitle: const Text('Nhận thông báo nhắc nhở giờ ăn'),
            trailing: Switch(
              value: mealReminderProvider.remindersEnabled,
              onChanged: (value) async {
                if (value) {
                  // Request permission when enabling
                  final granted =
                      await mealReminderProvider.requestNotificationPermission();
                  if (granted) {
                    mealReminderProvider.setRemindersEnabled(true);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Cần cấp quyền thông báo để bật nhắc nhở',
                          ),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                } else {
                  mealReminderProvider.setRemindersEnabled(false);
                }
              },
            ),
          ),

          // Permission Request Button
          if (mealReminderProvider.remindersEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final granted =
                      await mealReminderProvider.requestNotificationPermission();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          granted
                              ? '✓ Đã cấp quyền thông báo'
                              : '✗ Chưa cấp quyền thông báo',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.shield_outlined),
                label: const Text('Cấp quyền thông báo'),
              ),
            ),

          if (mealReminderProvider.remindersEnabled) ...[
            // Breakfast Time
            ListTile(
              leading: Icon(
                Icons.wb_sunny_outlined,
                color: colorScheme.primary,
              ),
              title: const Text('Bữa sáng'),
              subtitle: Text(mealReminderProvider.breakfastTimeString),
              trailing: const Icon(Icons.edit_outlined, size: 18),
              onTap: () {
                _showTimePickerDialog(
                  context,
                  'Chọn giờ bữa sáng',
                  mealReminderProvider.breakfastHour,
                  mealReminderProvider.breakfastMinute,
                  (hour, minute) {
                    mealReminderProvider.setBreakfastTime(hour, minute);
                  },
                );
              },
            ),

            // Lunch Time
            ListTile(
              leading: Icon(
                Icons.light_mode_outlined,
                color: colorScheme.primary,
              ),
              title: const Text('Bữa trưa'),
              subtitle: Text(mealReminderProvider.lunchTimeString),
              trailing: const Icon(Icons.edit_outlined, size: 18),
              onTap: () {
                _showTimePickerDialog(
                  context,
                  'Chọn giờ bữa trưa',
                  mealReminderProvider.lunchHour,
                  mealReminderProvider.lunchMinute,
                  (hour, minute) {
                    mealReminderProvider.setLunchTime(hour, minute);
                  },
                );
              },
            ),

            // Dinner Time
            ListTile(
              leading: Icon(
                Icons.nightlight_outlined,
                color: colorScheme.primary,
              ),
              title: const Text('Bữa tối'),
              subtitle: Text(mealReminderProvider.dinnerTimeString),
              trailing: const Icon(Icons.edit_outlined, size: 18),
              onTap: () {
                _showTimePickerDialog(
                  context,
                  'Chọn giờ bữa tối',
                  mealReminderProvider.dinnerHour,
                  mealReminderProvider.dinnerMinute,
                  (hour, minute) {
                    mealReminderProvider.setDinnerTime(hour, minute);
                  },
                );
              },
            ),

            // Reset to defaults
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Đặt lại mặc định'),
                      content: const Text(
                          'Bạn có muốn đặt lại giờ bữa ăn về mặc định không?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () {
                            mealReminderProvider.resetToDefaults();
                            Navigator.pop(context);
                          },
                          child: const Text('Đặt lại'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Đặt lại mặc định'),
              ),
            ),
          ],

          const Divider(),
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

          // Privacy & Terms - Combined with tabs
          ListTile(
            leading: Icon(
              Icons.security_rounded,
              color: colorScheme.primary,
            ),
            title: const Text('Bảo mật & Điều khoản'),
            subtitle: const Text('Chính sách bảo mật và điều khoản dịch vụ'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyTermsScreen(
                    initialTab: 'privacy',
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Show time picker dialog using Material 3 circular clock
  Future<void> _showTimePickerDialog(
    BuildContext context,
    String title,
    int initialHour,
    int initialMinute,
    Function(int, int) onTimeSelected,
  ) async {
    final TimeOfDay initialTime = TimeOfDay(hour: initialHour, minute: initialMinute);

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              dayPeriodBorderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
              dayPeriodColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.primaryContainer;
                }
                return Theme.of(context).colorScheme.surfaceContainer;
              }),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.onPrimaryContainer;
                }
                return Theme.of(context).colorScheme.onSurface;
              }),
              dialBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              dialHandColor: Theme.of(context).colorScheme.primary,
              dialTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.onPrimary;
                }
                return Theme.of(context).colorScheme.onSurface;
              }),
              entryModeIconColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      onTimeSelected(pickedTime.hour, pickedTime.minute);
    }
  }
}


