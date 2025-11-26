# Quick Reference Guide - Hotel Android App

## 📱 Quick Commands

### Build & Run
```bash
# Build and run on device
flutter run

# Build APK release
flutter build apk --release

# Check code quality
flutter analyze

# Generate code (JSON models)
dart run build_runner build --delete-conflicting-outputs
```

### Project Navigation
```bash
# Go to project root
cd "d:\Workspace\01 Project\Project Dev\Graduation project\Main Project\Hotel_Android\hotel_android"

# View project structure
dir /s /b lib\
```

---

## 🏃 Quick Start for Developers

### First Time Setup
1. Navigate to project: `cd hotel_android`
2. Install dependencies: `flutter pub get`
3. Generate code: `dart run build_runner build --delete-conflicting-outputs`
4. Ensure backend running: `Hotel_API` on `https://localhost:7135`
5. Run app: `flutter run`

### Daily Development
1. Make code changes
2. Hot reload: Press `r` in terminal
3. Test changes in app
4. Push changes when complete

---

## 🧭 File Navigation Guide

### Core App Files
- `lib/main.dart` - App entry point, routing, theme
- `lib/utils/http_overrides.dart` - SSL bypass for development

### Models (JSON Serializable)
- `lib/models/user.dart` - User & AuthResponse
- `lib/models/post.dart` - Posts
- `lib/models/comment.dart` - Comments
- `lib/models/mon_an.dart` - Food items
- `lib/models/bai_thuoc.dart` - Medicine
- `lib/models/prediction_history.dart` - AI predictions

### Services (Business Logic)
- `lib/services/api_config.dart` - API endpoint constants
- `lib/services/api_service.dart` - Base HTTP client
- `lib/services/auth_service.dart` - Authentication operations

### State Management
- `lib/providers/auth_provider.dart` - User authentication state

### UI Screens
- `lib/screens/auth/login_screen.dart` - Login page
- `lib/screens/auth/register_screen.dart` - Registration page
- `lib/screens/home/home_screen.dart` - Post-login home
- `lib/screens/debug_screen.dart` - API debugging tool

---

## 🔗 API Endpoints Reference

### Current (Phase 0-3)
```
POST   /api/auth/register    - Create new user
POST   /api/auth/login       - Authenticate user
POST   /api/auth/logout      - Logout user
```

### Ready to Implement (Phase 4)
```
GET    /api/posts            - Get posts list (paginated)
GET    /api/posts/{id}       - Get single post
POST   /api/posts            - Create post
PUT    /api/posts/{id}       - Update post
DELETE /api/posts/{id}       - Delete post
POST   /api/posts/{id}/like  - Like post
DELETE /api/posts/{id}/like  - Unlike post
GET    /api/posts/{id}/comments - Get comments
POST   /api/posts/{id}/comments - Add comment
```

---

## 🎨 Common UI Patterns

### Show Loading Indicator
```dart
// In screen using AuthProvider:
if (context.read<AuthProvider>().isLoading) {
  return const CircularProgressIndicator();
}
```

### Show Error Message
```dart
// Error automatically shown in SnackBar
// But can access via:
final error = context.read<AuthProvider>().errorMessage;
if (error != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(error)),
  );
}
```

### Navigate to Screen
```dart
// Using named routes:
Navigator.pushNamed(context, '/home');

// Using context navigation:
Navigator.of(context).pushReplacementNamed('/login');
```

### Make API Call
```dart
// Through AuthProvider:
await context.read<AuthProvider>().login(email, password);

// Direct ApiService call:
final ApiService api = ApiService.instance;
final response = await api.get('/api/posts');
```

---

## 🧪 Testing Quick Reference

### Manual Test Cases

**Test 1: Register New User**
```
1. Tap "Register" on login screen
2. Fill form:
   - Username: testuser
   - Email: test@example.com
   - Password: Test@123456
   - Confirm: Test@123456
   - Age: 25
   - Gender: Nam
3. Tap "Register"
4. Expected: Success or specific error
```

**Test 2: Login With Valid Credentials**
```
1. On login screen enter:
   - Email: test@example.com
   - Password: Test@123456
2. Tap "Login"
3. Expected: Navigate to home screen
```

**Test 3: Login With Invalid Credentials**
```
1. On login screen enter:
   - Email: wrong@example.com
   - Password: wrongpass
2. Tap "Login"
3. Expected: Error message shown
```

**Test 4: Logout**
```
1. After successful login, tap "Logout" on home
2. Expected: Redirect to login screen
```

---

## 🐛 Debugging Tips

### Check API Configuration
1. Launch app
2. On login screen, tap "Debug" button
3. Verify URL shows: `https://localhost:7135/api`
4. If wrong, check `lib/services/api_config.dart`

### View Console Logs
```bash
# Start flutter run first, then:
flutter logs
```

### Check Network Traffic
```bash
# Use Fiddler or Charles Proxy to intercept HTTPS traffic
# Useful for verifying request/response format
```

### Verify Backend Running
```bash
# In PowerShell:
curl https://localhost:7135/api/health
# Should return 200 if backend is running
```

---

## 📋 Common Tasks

### Add New API Endpoint
1. Add endpoint constant in `lib/services/api_config.dart`
2. Add method in `lib/services/api_service.dart`
3. Create service class (e.g., `lib/services/post_service.dart`)
4. Test with debug screen or manual HTTP request

### Add New Screen
1. Create file in `lib/screens/` with appropriate subfolder
2. Extend `StatelessWidget` (preferred) or `StatefulWidget`
3. Add route in `lib/main.dart` routes map
4. Navigate to it using `Navigator.pushNamed(context, '/route')`

### Add New Model
1. Create file in `lib/models/` following naming convention
2. Add `@JsonSerializable()` annotation
3. Run `dart run build_runner build --delete-conflicting-outputs`
4. Verify `.g.dart` file was generated
5. Use `model.toJson()` and `Model.fromJson(json)`

### Update Dependencies
```bash
# Check for updates
flutter pub outdated

# Update one package
flutter pub add package_name@version

# Update all packages
flutter pub upgrade

# Remove package
flutter pub remove package_name
```

---

## ⚙️ Configuration Files

### pubspec.yaml
- Location: Root of project
- Purpose: Dependencies, assets, metadata
- Key sections:
  - `dependencies:` - Runtime packages
  - `dev_dependencies:` - Development-only packages
  - `flutter:` - Flutter-specific config (assets, plugins)

### analysis_options.yaml
- Location: Root of project
- Purpose: Lint rules and analyzer configuration
- Key: Ensures code quality standards

### android/build.gradle.kts
- Location: `android/build.gradle.kts`
- Purpose: Android build configuration
- May need updates for new Android API levels

### ios/Podfile
- Location: `ios/Podfile`
- Purpose: iOS dependencies
- May need CocoaPods updates

---

## 🔐 Security Checklist

Before Production:
- [ ] Remove SSL bypass code from production build
- [ ] Add certificate pinning for API communication
- [ ] Enable ProGuard/R8 obfuscation for Android
- [ ] Use release build type only
- [ ] Review all API responses for sensitive data
- [ ] Add additional input validation
- [ ] Implement refresh token rotation
- [ ] Add rate limiting on client side
- [ ] Test logout clears all sensitive data
- [ ] Implement certificate validity checking

---

## 📚 Key Concepts Used

### State Management (Provider)
```dart
// Read value
final user = context.read<AuthProvider>().user;

// Listen to changes
final user = context.watch<AuthProvider>().user;

// Call method
await context.read<AuthProvider>().login(email, password);
```

### JSON Serialization
```dart
// To JSON
final json = user.toJson();

// From JSON
final user = User.fromJson(json);
```

### Async/Await Pattern
```dart
Future<void> doSomethingAsync() async {
  try {
    final result = await someAsyncOperation();
    // Handle result
  } catch (e) {
    // Handle error
  }
}
```

### Navigation with Routes
```dart
// Define in main.dart
routes: {
  '/login': (context) => const LoginScreen(),
  '/home': (context) => const HomeScreen(),
}

// Navigate
Navigator.pushNamed(context, '/home');
```

---

## 🎯 Phase 4 Preparation Checklist

Before starting Phase 4 (Posts API):
- [ ] Backend connectivity verified with successful login
- [ ] JWT token successfully stored and retrieved
- [ ] API error handling working properly
- [ ] All Phase 0-3 tests passing
- [ ] Code quality (flutter analyze) passing
- [ ] App builds without errors

---

## 📞 Useful Links

### Documentation
- Dart: https://dart.dev/guides
- Flutter: https://flutter.dev/docs
- Material 3: https://m3.material.io/
- Provider: https://pub.dev/packages/provider

### Tools
- Pub.dev packages: https://pub.dev
- Flutter DevTools: Run `flutter pub global activate devtools` then `devtools`
- Android Studio: For Android debugging
- Xcode: For iOS debugging

### API Testing
- Postman: https://www.postman.com/
- Insomnia: https://insomnia.rest/
- curl: Command-line tool (pre-installed)

---

**Last Updated**: Today
**Version**: 0.3.0
**Quick Ref Version**: 1.0
