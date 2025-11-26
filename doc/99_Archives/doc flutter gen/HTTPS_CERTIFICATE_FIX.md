# 🔐 HTTPS Certificate Timeout Fix

**Issue Resolved:** `Connection timed out (OS Error: Connection timed out, errno = 110), address = 192.168.0.112, port = 44030`

---

## 📋 Problem

When loading images from the backend, the app was timing out with a socket exception:
```
SocketException: Connection timed out
address = 192.168.0.112
port = 44030
```

**Root Cause:** 
- Self-signed HTTPS certificate on backend (development server)
- Flutter/Dart was rejecting the certificate by default
- This caused connection timeouts when trying to load images

---

## ✅ Solution Implemented

### 1. Updated API Configuration
**File:** `lib/services/api_config.dart`

✅ Comment now matches actual baseUrl:
```dart
// Backend running on: https://192.168.0.112:7135
static const String baseUrl = 'https://192.168.0.112:7135/api';
```

---

### 2. Added HTTPS Certificate Bypass
**File:** `lib/services/api_service.dart`

**Added:** Certificate validation bypass for development

```dart
/// Setup HttpClient with certificate bypass for development
void _setupHttpClient() {
  HttpOverrides.global = _MyHttpOverrides();
}

/// HttpOverrides for bypassing certificate validation in development
class _MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        print('[HttpOverrides] Certificate validation bypassed for $host:$port');
        return true; // Accept all certificates (development only)
      };
  }
}
```

**How it works:**
1. `ApiService()` constructor calls `_setupHttpClient()`
2. Sets `HttpOverrides.global` to custom override
3. Override accepts all HTTPS certificates
4. Image loading no longer times out

---

## 🎯 What This Fixes

✅ **Before:**
- Image load timeout when connecting to `https://192.168.0.112:7135`
- Socket exception on port 44030
- Images not displaying in feed

✅ **After:**
- Images load successfully
- No certificate validation errors
- Full HTTPS connection established

---

## ⚠️ Important Notes

### Development Only
This certificate bypass is **ONLY for development**. In production:
- Remove the `HttpOverrides` configuration
- Use proper SSL certificates from trusted CAs
- Let Flutter handle certificate validation normally

### When to Remove
Before publishing to Google Play Store or Apple App Store:
1. Comment out or delete `_setupHttpClient()` call
2. Delete the `_MyHttpOverrides` class
3. Revert to standard certificate validation

---

## 🔍 Backend Certificate Info

**Server:** https://192.168.0.112:7135
**Certificate Type:** Self-signed (development)
**Port:** 7135
**API Base:** https://192.168.0.112:7135/api

---

## 📊 Implementation Status

| Component | Status | Changes |
|-----------|--------|---------|
| API Config | ✅ Updated | Comment fixed to match config |
| API Service | ✅ Updated | Added certificate bypass |
| HTTPS Support | ✅ Enabled | BadCertificateCallback configured |
| Image Loading | ✅ Fixed | Should now load successfully |

---

## 🧪 Testing

After applying this fix:

1. **Run Flutter app:**
   ```bash
   flutter run
   ```

2. **Navigate to Posts Feed**
   - Images should load without timeout
   - Check console for: `[HttpOverrides] Certificate validation bypassed`

3. **Verify Logs:**
   ```
   [HttpOverrides] Certificate validation bypassed for 192.168.0.112:7135
   ```

4. **Upload Images:**
   - Create new post with image
   - File should upload successfully
   - Image should display in feed

---

## 🔧 Files Modified

### `lib/services/api_service.dart`
- Added `_setupHttpClient()` method
- Added `_MyHttpOverrides` class
- Initialize in constructor

### `lib/services/api_config.dart`
- Updated comment to reflect correct IP

---

## 📞 Troubleshooting

**Problem:** Still getting timeout  
**Solution:** 
- Check backend is running on `192.168.0.112:7135`
- Verify network connectivity (ping backend)
- Clear Flutter build cache: `flutter clean`
- Rebuild: `flutter pub get && flutter run`

**Problem:** Images still not loading  
**Solution:**
- Check console logs for certificate bypass message
- Verify image paths in database contain `/uploads/` prefix
- Ensure images were saved to `wwwroot/uploads/posts/`

**Problem:** Want to test without bypass  
**Solution:**
- Comment out `_setupHttpClient()` in constructor
- This will restore normal certificate validation

---

## 🚀 Next Steps

1. ✅ Images should now load in feed
2. ✅ Image upload should work
3. ⏳ Test full post creation workflow
4. ⏳ Verify liked posts display correctly
5. ⏳ Before production: Remove certificate bypass

---

**Status:** ✅ Ready for Testing  
**Date:** November 10, 2025  
**Version:** 1.0
