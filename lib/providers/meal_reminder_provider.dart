import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

/// Provider for managing meal reminder settings and state.
class MealReminderProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool _remindersEnabled = true;
  int _breakfastHour = NotificationService.defaultBreakfastHour;
  int _breakfastMinute = 0;
  int _lunchHour = NotificationService.defaultLunchHour;
  int _lunchMinute = 0;
  int _dinnerHour = NotificationService.defaultDinnerHour;
  int _dinnerMinute = 0;

  // Getters
  bool get remindersEnabled => _remindersEnabled;
  int get breakfastHour => _breakfastHour;
  int get breakfastMinute => _breakfastMinute;
  int get lunchHour => _lunchHour;
  int get lunchMinute => _lunchMinute;
  int get dinnerHour => _dinnerHour;
  int get dinnerMinute => _dinnerMinute;

  // Get formatted time strings
  String get breakfastTimeString =>
      '${_breakfastHour.toString().padLeft(2, '0')}:${_breakfastMinute.toString().padLeft(2, '0')}';
  String get lunchTimeString =>
      '${_lunchHour.toString().padLeft(2, '0')}:${_lunchMinute.toString().padLeft(2, '0')}';
  String get dinnerTimeString =>
      '${_dinnerHour.toString().padLeft(2, '0')}:${_dinnerMinute.toString().padLeft(2, '0')}';

  /// Constructor initializes the service
  MealReminderProvider() {
    initialize();
  }

  /// Initialize provider by loading saved settings
  Future<void> initialize() async {
    await _notificationService.initialize();
    await loadSettings();
  }

  /// Load settings from SharedPreferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _remindersEnabled = prefs.getBool('meal_reminders_enabled') ?? true;
    _breakfastHour = prefs.getInt('breakfast_reminder_hour') ??
        NotificationService.defaultBreakfastHour;
    _breakfastMinute = prefs.getInt('breakfast_reminder_minute') ?? 0;
    _lunchHour = prefs.getInt('lunch_reminder_hour') ??
        NotificationService.defaultLunchHour;
    _lunchMinute = prefs.getInt('lunch_reminder_minute') ?? 0;
    _dinnerHour = prefs.getInt('dinner_reminder_hour') ??
        NotificationService.defaultDinnerHour;
    _dinnerMinute = prefs.getInt('dinner_reminder_minute') ?? 0;

    notifyListeners();
  }

  /// Toggle reminders on/off
  Future<void> setRemindersEnabled(bool enabled) async {
    _remindersEnabled = enabled;
    await _notificationService.setRemindersEnabled(enabled);
    notifyListeners();
  }

  /// Update breakfast time
  Future<void> setBreakfastTime(int hour, int minute) async {
    _breakfastHour = hour;
    _breakfastMinute = minute;
    await _notificationService.updateMealReminderTime(
      mealType: 'breakfast',
      hour: hour,
      minute: minute,
    );
    notifyListeners();
  }

  /// Update lunch time
  Future<void> setLunchTime(int hour, int minute) async {
    _lunchHour = hour;
    _lunchMinute = minute;
    await _notificationService.updateMealReminderTime(
      mealType: 'lunch',
      hour: hour,
      minute: minute,
    );
    notifyListeners();
  }

  /// Update dinner time
  Future<void> setDinnerTime(int hour, int minute) async {
    _dinnerHour = hour;
    _dinnerMinute = minute;
    await _notificationService.updateMealReminderTime(
      mealType: 'dinner',
      hour: hour,
      minute: minute,
    );
    notifyListeners();
  }

  /// Reset to default times
  Future<void> resetToDefaults() async {
    await setBreakfastTime(NotificationService.defaultBreakfastHour, 0);
    await setLunchTime(NotificationService.defaultLunchHour, 0);
    await setDinnerTime(NotificationService.defaultDinnerHour, 0);
  }

  /// Get all meal times as a map
  Map<String, ({int hour, int minute})> getAllMealTimes() {
    return {
      'breakfast': (hour: _breakfastHour, minute: _breakfastMinute),
      'lunch': (hour: _lunchHour, minute: _lunchMinute),
      'dinner': (hour: _dinnerHour, minute: _dinnerMinute),
    };
  }

  /// Get specific meal time
  ({int hour, int minute}) getMealTime(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return (hour: _breakfastHour, minute: _breakfastMinute);
      case 'lunch':
        return (hour: _lunchHour, minute: _lunchMinute);
      case 'dinner':
        return (hour: _dinnerHour, minute: _dinnerMinute);
      default:
        return (hour: 7, minute: 0);
    }
  }

  /// Request notification permission explicitly
  Future<bool> requestNotificationPermission() async {
    return await _notificationService.requestNotificationPermissionExplicit();
  }

  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }
}