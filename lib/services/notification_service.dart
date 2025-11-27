import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

/// Manages meal reminder notifications and scheduling.
/// Uses robust zoned scheduling for reliable daily notifications.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  bool _isInitialized = false;

  /// Default meal times
  static const int defaultBreakfastHour = 7;
  static const int defaultLunchHour = 12;
  static const int defaultDinnerHour = 18;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Initialize Timezone Database
    tz.initializeTimeZones();
    try {
      final dynamic result = await FlutterTimezone.getLocalTimezone();
      // Handle both String (older versions) and TimezoneInfo (newer versions)
      final String timeZoneName = result is String ? result : result.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      developer.log('Could not get local timezone: $e', name: 'notification_service');
      // Fallback to UTC or default if needed, but usually local is fine
      tz.setLocalLocation(tz.local); 
    }

    // Initialize Android settings
    final AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('app_icon');
    final DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        developer.log('Notification clicked: ${details.payload}', name: 'notification_service');
      },
    );

    // Create notification channel for Android 8.0+
    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      'meal_reminders',
      'Nhắc nhở bữa ăn',
      description: 'Thông báo nhắc nhở giờ ăn',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
      showBadge: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _isInitialized = true;

    // Initial setup - don't request permission immediately to avoid annoying user
    // Just schedule if permissions are already granted or will be requested by UI
    await _initializeDefaultSettings();
    await _rescheduleAllReminders();
  }

  /// Request notification permission explicitly
  Future<bool> requestNotificationPermissionExplicit() async {
    try {
      final status = await Permission.notification.request();
      debugPrint('Explicit notification permission status: $status');
      
      if (status.isGranted) {
        // If granted, ensure reminders are scheduled
        await _rescheduleAllReminders();
      }
      
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Initialize default meal reminder times if not set
  Future<void> _initializeDefaultSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('breakfast_reminder_hour')) {
      await prefs.setInt('breakfast_reminder_hour', defaultBreakfastHour);
      await prefs.setInt('breakfast_reminder_minute', 0);
    }

    if (!prefs.containsKey('lunch_reminder_hour')) {
      await prefs.setInt('lunch_reminder_hour', defaultLunchHour);
      await prefs.setInt('lunch_reminder_minute', 0);
    }

    if (!prefs.containsKey('dinner_reminder_hour')) {
      await prefs.setInt('dinner_reminder_hour', defaultDinnerHour);
      await prefs.setInt('dinner_reminder_minute', 0);
    }

    // Default to enabled if not set
    if (!prefs.containsKey('meal_reminders_enabled')) {
      await prefs.setBool('meal_reminders_enabled', true);
    }
  }

  /// Reschedule all meal reminders based on current settings
  Future<void> _rescheduleAllReminders() async {
    // Cancel all existing notifications first to avoid duplicates
    await _flutterLocalNotificationsPlugin.cancelAll();

    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('meal_reminders_enabled') ?? true;

    if (!isEnabled) {
      developer.log('Reminders disabled, skipping schedule', name: 'notification_service');
      return;
    }

    // Schedule Breakfast
    await _scheduleDailyNotification(
      id: 1,
      title: '🌅 Giờ bữa sáng',
      body: 'Hãy bắt đầu ngày mới với một bữa sáng lành mạnh!',
      hour: prefs.getInt('breakfast_reminder_hour') ?? defaultBreakfastHour,
      minute: prefs.getInt('breakfast_reminder_minute') ?? 0,
    );

    // Schedule Lunch
    await _scheduleDailyNotification(
      id: 2,
      title: '☀️ Giờ bữa trưa',
      body: 'Cơm trưa lành mạnh giúp bạn có năng lượng cho buổi chiều!',
      hour: prefs.getInt('lunch_reminder_hour') ?? defaultLunchHour,
      minute: prefs.getInt('lunch_reminder_minute') ?? 0,
    );

    // Schedule Dinner
    await _scheduleDailyNotification(
      id: 3,
      title: '🌙 Giờ bữa tối',
      body: 'Hãy chuẩn bị cho một bữa tối nhẹ nhàng và lành mạnh!',
      hour: prefs.getInt('dinner_reminder_hour') ?? defaultDinnerHour,
      minute: prefs.getInt('dinner_reminder_minute') ?? 0,
    );
    
    developer.log('All reminders rescheduled', name: 'notification_service');
  }

  /// Schedule a daily notification at specific time
  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'meal_reminders',
            'Nhắc nhở bữa ăn',
            channelDescription: 'Thông báo nhắc nhở giờ ăn',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'app_icon', // Ensure this drawable exists
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at time
      );
      
      developer.log('Scheduled notification $id at $hour:$minute', name: 'notification_service');
    } catch (e) {
      developer.log('Error scheduling notification: $e', name: 'notification_service');
    }
  }

  /// Update meal reminder time and reschedule
  Future<void> updateMealReminderTime({
    required String mealType,
    required int hour,
    required int minute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${mealType}_reminder_hour', hour);
    await prefs.setInt('${mealType}_reminder_minute', minute);
    
    // Reschedule everything to be safe
    await _rescheduleAllReminders();
  }

  /// Enable/disable meal reminders
  Future<void> setRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('meal_reminders_enabled', enabled);
    
    if (enabled) {
      await _rescheduleAllReminders();
    } else {
      await _flutterLocalNotificationsPlugin.cancelAll();
    }
  }

  /// Get meal reminder time
  Future<({int hour, int minute})> getMealReminderTime(String mealType) async {
    final prefs = await SharedPreferences.getInstance();
    int hour, minute;
    
    if (mealType == 'breakfast') {
      hour = prefs.getInt('breakfast_reminder_hour') ?? defaultBreakfastHour;
      minute = prefs.getInt('breakfast_reminder_minute') ?? 0;
    } else if (mealType == 'lunch') {
      hour = prefs.getInt('lunch_reminder_hour') ?? defaultLunchHour;
      minute = prefs.getInt('lunch_reminder_minute') ?? 0;
    } else if (mealType == 'dinner') {
      hour = prefs.getInt('dinner_reminder_hour') ?? defaultDinnerHour;
      minute = prefs.getInt('dinner_reminder_minute') ?? 0;
    } else {
      hour = defaultBreakfastHour;
      minute = 0;
    }
    return (hour: hour, minute: minute);
  }

  /// Dispose service
  void dispose() {
    // Nothing to dispose with zonedSchedule
  }
}