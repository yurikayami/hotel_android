# 🔧 Health Chatbot - Troubleshooting Guide

## ⚠️ Common Issues & Solutions

### 1. "API key is invalid"
**Problem:** 
```
Error message: "Gemini API key is invalid. Please check your API key."
```

**Causes:**
- API key not set in code
- API key format wrong
- API key expired or disabled
- Typo in API key

**Solutions:**
```dart
// ✅ Correct format
static const String _geminiApiKey = 'AIzaSy...'; // 39 characters

// ❌ Wrong
static const String _geminiApiKey = 'YOUR_API_KEY'; // Not valid
static const String _geminiApiKey = 'AIzaSy...extra'; // Too long
```

**Steps:**
1. Go to https://ai.google.dev/
2. Click "Get API Key"
3. Create new project
4. Copy full API key
5. Paste into `lib/services/gemini_health_service.dart` line 8
6. Save file
7. Run app again

---

### 2. "Request timeout"
**Problem:**
```
Error message: "Gemini API request timeout. Please check your connection."
```

**Causes:**
- No internet connection
- Slow internet (< 1 Mbps)
- API server down
- Network firewall blocking

**Solutions:**

**Check internet:**
```
- Open browser to google.com
- If loads, internet is working
- Try on different WiFi/mobile data
```

**Check API server:**
```
Visit: https://status.cloud.google.com/
Look for "Generative AI" or "API" status
```

**Increase timeout (if needed):**
```dart
// In gemini_health_service.dart
.timeout(const Duration(seconds: 60)) // Changed from 30
```

**Workaround:**
- Try again after few seconds
- Check internet speed
- Report if persistent

---

### 3. "Rate limit exceeded"
**Problem:**
```
Error message: "Gemini API rate limit exceeded. Please try again later."
```

**Causes:**
- Too many requests in short time
- Daily limit reached (1000/day free tier)
- Account limits exceeded

**Solutions:**

**Immediate:**
- Wait 1-5 minutes
- Try again later
- Use different API key (if you have another)

**Long term:**
- Upgrade to paid plan: https://ai.google.dev/pricing
- Implement request caching
- Add cooldown between messages
- Monitor usage in API console

**Check current usage:**
```
1. Go to https://console.cloud.google.com/
2. Select your project
3. Go to "APIs & Services" → "Quotas"
4. Search for "Generative Language API"
5. See daily usage
```

---

### 4. Chat doesn't appear / Blank screen
**Problem:**
```
HealthChatScreen opens but shows blank
No messages visible
Input field not showing
```

**Causes:**
- User data not loaded
- Provider not initialized
- Widget build error
- JSON serialization error

**Solutions:**

**Check user data is loaded:**
```dart
// In HealthChatScreen._initializeChat()
final userProvider = context.read<UserProvider>();
print('Basic: ${userProvider.basicProfile}');
print('Health: ${userProvider.healthProfile}');
// If null, data hasn't loaded yet
```

**Reload profile:**
```
1. Go back to Profile
2. Tap Tư vấn button again
3. Or tap refresh button in chat screen
```

**Check logs:**
```
Run: flutter logs
Look for errors with [GeminiHealthService] or [HealthChatProvider]
```

**Rebuild app:**
```
1. Stop running app (Ctrl+C)
2. flutter clean
3. dart run build_runner build --delete-conflicting-outputs
4. flutter run
```

---

### 5. Messages not sending
**Problem:**
```
Click send button, nothing happens
Button doesn't respond
No loading indicator
```

**Causes:**
- Button is disabled
- Message is empty
- API key not configured
- Provider not found in context

**Solutions:**

**Check button is enabled:**
```dart
// Button should only be disabled when isLoading=true
// If always disabled, check HealthChatProvider.isLoading
```

**Validate message:**
```
Message should be:
- Not empty
- Not just spaces ("   " won't send)
- Not too long (API has limits)
```

**Check provider exists:**
```dart
// In context
try {
  final provider = context.read<HealthChatProvider>();
  print('Provider found');
} catch (e) {
  print('Provider not found: $e');
}
```

**Check main.dart setup:**
```dart
// Verify HealthChatProvider is in MultiProvider list
ChangeNotifierProvider(create: (_) => HealthChatProvider()),
```

---

### 6. Loading spinner never stops
**Problem:**
```
Circle keeps spinning indefinitely
Message never appears
Can't send more messages
```

**Causes:**
- API request stuck
- No response from server
- JSON parsing error
- Provider state not updating

**Solutions:**

**Force refresh:**
```
1. Click refresh button in AppBar
2. Or navigate back and return
3. Or restart the app
```

**Check logs:**
```
flutter logs | grep -i "gemini\|chat"
Look for exceptions or stuck states
```

**Increase timeout and try again:**
```dart
// Modify timeout in gemini_health_service.dart
.timeout(const Duration(seconds: 60))
```

**Switch to different network:**
```
- Try mobile data instead of WiFi
- Try WiFi instead of mobile
- Some networks might block Gemini API
```

---

### 7. Error banner keeps showing
**Problem:**
```
Red error banner at top won't go away
Close button not working
Same error repeats
```

**Causes:**
- Close button not working
- Error state not clearing
- Persistent API error

**Solutions:**

**Dismiss error:**
```
1. Tap the [✕] button on error banner
2. If doesn't work, navigate away and back
3. Restart the app
```

**Try again:**
```
After fixing the underlying issue:
1. Wait 5 seconds
2. Type new message
3. Click send to try again
```

**Clear chat:**
```
1. Click refresh button in AppBar
2. All messages + errors cleared
3. Start fresh conversation
```

---

### 8. "Cannot get UserProvider" error
**Problem:**
```
Error: "No UserProvider in context"
Chat won't open
Black screen with error
```

**Causes:**
- UserProvider not loaded
- User not logged in
- Provider hierarchy issue

**Solutions:**

**Check user is logged in:**
```dart
// In HealthChatScreen
final authProvider = context.read<AuthProvider>();
if (authProvider.user == null) {
  // User not logged in, show error
}
```

**Load user data first:**
```
1. Go to Profile screen
2. Wait for profile to load
3. Then tap Tư vấn button
```

**Restart app:**
```bash
flutter run --no-fast-start
```

---

### 9. Build_runner errors
**Problem:**
```
Error: "Target of URI hasn't been generated: 'chat_message.g.dart'"
Can't compile app
Multiple .g.dart errors
```

**Causes:**
- Build_runner not executed
- JSON serializable generator failed
- Pubspec.yaml missing dependencies

**Solutions:**

**Run build_runner:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

**If still fails:**
```bash
# Clean and rebuild
flutter clean
dart run build_runner build --delete-conflicting-outputs
flutter pub get
flutter run
```

**Verify dependencies:**
```yaml
# In pubspec.yaml should have:
dev_dependencies:
  build_runner: ^2.4.7
  json_serializable: ^6.7.1

dependencies:
  json_annotation: ^4.8.1
```

---

### 10. AI response is gibberish
**Problem:**
```
AI returns nonsensical response
Response has garbled text
Response not in Vietnamese
```

**Causes:**
- System instruction not working
- Model misunderstanding
- Encoding issue
- Prompt quality

**Solutions:**

**Check system instruction:**
```dart
// Verify in GeminiHealthService._buildSystemInstruction()
// Should include health data:
// - Age
// - Gender  
// - BMI
// - Diseases
// - Allergies
```

**Try simpler question:**
```
Instead of: "Tôi bị đau đầu, chóng mặt, tay run, ngủ không sâu, 
            sạch lạnh, nước tiểu vàng nhạt, sau bữa ăn đau bụng"

Try: "Tôi có bị tiểu đường không?"
```

**Check model is correct:**
```dart
static const String _geminiModel = 'gemini-2.5-flash'; // ✅ Correct
```

**Report issue:**
- Screenshot the gibberish response
- Note what question you asked
- Include your health profile
- Contact support

---

### 11. Message history not saving
**Problem:**
```
Refresh app, all messages gone
Need to keep chat history
```

**Causes:**
- Messages only in RAM (by design)
- No persistent storage implemented
- App restarted

**Current behavior:**
```
✅ Messages saved during session
❌ Messages lost on app restart
❌ No export feature yet
```

**Workaround:**
```
1. Take screenshots
2. Copy-paste important responses
3. Screenshot full conversation
```

**Future feature:**
```
(Not implemented yet)
- Save to local database
- Export as PDF
- Share to doctor
```

---

### 12. Keyboard issues
**Problem:**
```
Keyboard doesn't show
Keyboard won't dismiss
Message input field unresponsive
```

**Causes:**
- FocusNode not managed
- Keyboard dismissed before message sent
- Focus lost

**Solutions:**

**Manual keyboard:**
```
Tap in message input field
Keyboard should appear
If not, restart app
```

**Force keyboard close:**
```dart
// After sending message, code closes keyboard
FocusManager.instance.primaryFocus?.unfocus();
// This happens automatically
```

**If stuck:**
```
1. Minimize app (home button)
2. Reopen app
3. Keyboard state reset
```

---

## 🔍 Debugging Techniques

### Enable logging
```dart
// Add to services/gemini_health_service.dart
print('[GeminiHealthService] Starting request...');
print('[GeminiHealthService] API Key: $_geminiApiKey');
print('[GeminiHealthService] Request body: $requestBody');
print('[GeminiHealthService] Response: $response');
```

### Check console output
```bash
flutter logs
# Grep for specific messages
flutter logs | grep -i "chat\|gemini\|error"
```

### Verify API manually
```bash
# Test API with curl (replace KEY with your key)
curl -X POST \
  https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=YOUR_KEY \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [{"text": "Hello"}]
    }]
  }'
```

### Use DevTools
```bash
# Open Flutter DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Or in VS Code: Debug > Open DevTools
# Check:
# - Memory usage
# - Performance
# - Provider state
```

---

## 📞 Getting Help

### Before contacting support, gather:
1. Error message screenshot
2. What were you doing when error occurred
3. User's health profile data (sanitized)
4. Question that caused issue
5. Console logs (flutter logs output)
6. Device/OS information

### Where to get help:
- **Flutter community:** https://stackoverflow.com/questions/tagged/flutter
- **Gemini API docs:** https://ai.google.dev/
- **Provider docs:** https://pub.dev/packages/provider
- **GitHub issues:** File an issue with reproduction steps

---

## ✅ Debugging Checklist

Before concluding it's a bug:

- [ ] Restarted the app
- [ ] Checked internet connection
- [ ] Verified API key is set
- [ ] Ran `flutter clean` and `flutter run`
- [ ] Checked console logs for errors
- [ ] Verified user is logged in
- [ ] Tried on different network
- [ ] Tried with simple test message
- [ ] Checked if rate limited (wait 5 min)
- [ ] Reviewed error message carefully

---

**Last Updated:** November 26, 2025  
**Version:** 1.0  
**Status:** ✅ Ready for troubleshooting
