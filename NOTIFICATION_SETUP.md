# Cấu hình Thông báo Nhắc nhở Bữa ăn

## 📋 Yêu cầu

Tính năng thông báo nhắc nhở giờ ăn đã được cấu hình đầy đủ cho Android và iOS. Dưới đây là các bước để đảm bảo hoạt động đúng.

## 🔧 Cấu hình Android

### 1. Quyền được thêm vào `AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

### 2. Core Library Desugaring

Đã bật trong `android/app/build.gradle.kts`:
```kotlin
compileOptions {
    isCoreLibraryDesugaringEnabled = true
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```

### 3. Permission Handler

Package `permission_handler: ^12.0.1` được thêm vào `pubspec.yaml`.

## 📱 Cấu hình iOS

Thêm vào `ios/Runner/Info.plist`:

```xml
<key>NSUserNotificationAlertOption</key>
<string>alert</string>
<key>UIUserNotificationAlertStyle</key>
<string>Alert</string>
```

## 🚀 Sử dụng

### Tự động khởi tạo

NotificationService được khởi tạo tự động khi ứng dụng khởi động thông qua `MealReminderProvider` với `lazy: false` trong `main.dart`.

### Yêu cầu quyền

Ứng dụng sẽ tự động yêu cầu quyền `POST_NOTIFICATIONS` khi khởi động trên Android 13+.

### Cài đặt giờ nhắc nhở

1. Mở **Cài đặt** (Settings)
2. Chọn **Nhắc nhở bữa ăn**
3. Bật/tắt nhắc nhở bằng switch
4. Nhấp vào biểu tượng chỉnh sửa (edit icon) để thay đổi thời gian
5. Chọn thời gian mong muốn từ Time Picker
6. Lưu cài đặt (tự động lưu vào SharedPreferences)

### Kiểm tra hoạt động

1. Cài đặt thời gian nhắc nhở sắp tới (ví dụ: 1 phút kể từ giờ hiện tại)
2. Chờ cho đến khi đến thời gian
3. Kiểm tra xem thông báo có xuất hiện không
4. Xem Logcat để xem debug messages:
   ```
   📢 Notification: 🌅 Giờ bữa sáng - Hãy bắt đầu ngày mới với một bữa sáng lành mạnh!
   ```

## 🔍 Debugger

### Logcat Messages

Khi thông báo được gửi:
```
I/flutter: 📢 Notification: 🌅 Giờ bữa sáng - ...
I/flutter: Notification permission status: PermissionStatus.granted
```

### SharedPreferences Keys

Các key được lưu trữ:
- `meal_reminders_enabled`: Boolean (bật/tắt)
- `breakfast_reminder_hour`: Integer (giờ)
- `breakfast_reminder_minute`: Integer (phút)
- `lunch_reminder_hour`: Integer
- `lunch_reminder_minute`: Integer
- `dinner_reminder_hour`: Integer
- `dinner_reminder_minute`: Integer
- `last_notification_breakfast`: String (ngày)
- `last_notification_lunch`: String (ngày)
- `last_notification_dinner`: String (ngày)

## 📊 Các thành phần

### NotificationService (`lib/services/notification_service.dart`)
- Singleton pattern
- Khởi tạo FlutterLocalNotificationsPlugin
- Tạo notification channel cho Android 8.0+
- Yêu cầu quyền thông báo
- Timer kiểm tra mỗi 1 phút
- Gửi thông báo khi đến thời gian
- Ngăn chặn thông báo trùng lặp cùng ngày

### MealReminderProvider (`lib/providers/meal_reminder_provider.dart`)
- Quản lý trạng thái nhắc nhở
- Lưu/tải cài đặt từ NotificationService
- Cung cấp getters cho UI

### Settings Screen (`lib/screens/settings/settings_screen.dart`)
- UI cho cài đặt nhắc nhở
- Time Picker Material 3 cho lựa chọn thời gian
- Toggle bật/tắt
- Nút reset về mặc định

## ⚠️ Lưu ý

- **Android 13+**: Ứng dụng sẽ yêu cầu quyền thông báo khi khởi động lần đầu tiên. Người dùng phải cấp quyền để thông báo hoạt động.
- **Android 12 trở xuống**: Quyền được cấp tự động (không cần yêu cầu).
- **iOS**: Ứng dụng sẽ yêu cầu quyền thông báo khi gửi thông báo đầu tiên.
- **Thời gian nhắc nhở**: Kiểm tra được thực hiện mỗi 1 phút, vì vậy có thể có độ trễ nhỏ.
- **Trùng lặp**: Mỗi loại bữa ăn chỉ gửi 1 thông báo mỗi ngày.

## 🔧 Tùy chỉnh

### Thay đổi thời gian kiểm tra

Trong `notification_service.dart`, hàm `_scheduleDailyNotificationCheck()`:
```dart
_dailyTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
  // Thay đổi Duration(minutes: 1) sang giá trị khác
});
```

### Thay đổi các thông báo

Trong `_checkAndSendNotifications()`, sửa nội dung thông báo:
```dart
_triggerNotification(
  'breakfast',
  '🌅 Giờ bữa sáng',
  'Hãy bắt đầu ngày mới với một bữa sáng lành mạnh!',
);
```

### Thay đổi giờ mặc định

Trong `NotificationService`, hãy sửa các hằng số:
```dart
static const int defaultBreakfastHour = 7;
static const int defaultLunchHour = 12;
static const int defaultDinnerHour = 18;
```

## 📚 Tài liệu tham khảo

- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [permission_handler](https://pub.dev/packages/permission_handler)
- [Android Notification Channels](https://developer.android.com/training/notify-user/channels)
- [Android 13+ Notification Runtime Permission](https://developer.android.com/about/versions/13/changes/notification-permission)
