# ⚡ Health Chatbot Setup - Quick Start

## Files Created

### 1. Models
```
lib/models/chat_message.dart
lib/models/chat_message.g.dart (auto-generated)
```

### 2. Services  
```
lib/services/gemini_health_service.dart
```

### 3. Providers
```
lib/providers/health_chat_provider.dart
```

### 4. Screens
```
lib/screens/profile/health_chat_screen.dart
```

### 5. Updated Files
```
lib/main.dart (added HealthChatProvider)
lib/screens/profile/my_profile_screen.dart (added FAB button)
```

## 🔴 CRITICAL SETUP STEP

### Get Gemini API Key
1. Go to https://ai.google.dev/
2. Click "Get API Key" button
3. Create new project or select existing
4. Copy your API key
5. Open `lib/services/gemini_health_service.dart`
6. Replace this line:
   ```dart
   static const String _geminiApiKey = 'AIzaSyB1234567890abcdefghijklmnopqrstuvwxyz';
   ```
   With your actual API key:
   ```dart
   static const String _geminiApiKey = 'YOUR_ACTUAL_API_KEY';
   ```

## 📦 Dependencies

All dependencies already in pubspec.yaml:
- `provider: ^6.1.1` - State management
- `http: ^1.1.0` - HTTP requests
- `json_annotation: ^4.8.1` - JSON serialization

## ✅ Verification

### Run code generation:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Check for errors:
```bash
flutter analyze
```

### Run the app:
```bash
flutter run
```

## 🎯 Testing the Feature

1. **Open the app** and navigate to Profile
2. **Click the "Tư vấn" FAB button** (bottom right)
3. **Wait for greeting message** to load
4. **Type a question** like:
   - "Tôi nên ăn gì?"
   - "Cách giảm cân?"
   - "Tôi bị đau đầu phải làm sao?"
5. **Click send button** (➤)
6. **Wait 1-3 seconds** for AI response
7. **See the answer** in chat

## 🔗 User Data Flow

```
MyProfileScreen
    ↓ (User clicks "Tư vấn" button)
HealthChatScreen
    ↓ (Shows greeting + input field)
User types message
    ↓ (Click send)
HealthChatProvider.sendMessage()
    ↓ (Gets user data from UserProvider)
GeminiHealthService
    ↓ (Builds system instruction from user/health data)
Google Gemini API
    ↓ (Processes request)
HealthChatProvider receives response
    ↓ (Updates messages list)
HealthChatScreen rebuilds
    ↓ (Shows AI response in chat)
```

## 🎨 UI Structure

```
HealthChatScreen
├── AppBar
│   ├── Title "Tư vấn Sức khỏe"
│   ├── Refresh button
│   └── Settings
├── Messages List
│   ├── User messages (Primary color, right)
│   ├── AI messages (Surface variant, left)
│   └── Loading state
├── Error Banner (if error)
└── Message Input
    ├── TextField
    └── Send button
```

## 🧪 Example Test Cases

### ✅ Success Case
- Input: "Tôi bị tăng huyết áp, có thể tập thể dục không?"
- Output: AI responds with relevant health advice

### ✅ Empty Input
- Input: (empty)
- Output: "Vui lòng nhập tin nhắn"

### ✅ Network Error
- API key wrong → "Gemini API key is invalid"
- No internet → "Request timeout"
- Rate limit → "Rate limit exceeded"

### ✅ Data Context
- AI uses user's health profile in response
- Considers BMI, diseases, allergies
- Speaks Vietnamese

## 📝 Notes

- API Key has daily rate limit (1000 requests/day on free tier)
- Responses take 1-3 seconds typically
- AI is advisory only, not diagnostic
- Always recommend user see real doctor for serious issues

## 🆘 Troubleshooting

### "Target of URI hasn't been generated"
```bash
dart run build_runner build --delete-conflicting-outputs
```

### "Unused import" warnings
These are just warnings, code still runs. Can ignore.

### Chat not loading messages
- Check API key is correct
- Check internet connection
- Check Gemini API quota

### Long response time
- First request might be slower (1-3s)
- Check internet speed
- Gemini API might be rate limiting

## 📞 Support

For issues:
1. Check error message in app
2. Look at console logs (search for [GeminiHealthService])
3. Verify API key is set correctly
4. Check https://ai.google.dev/ console for API quota

---

**Ready to use! Just add your API key and start chatting.** 🚀
