# Tính năng Chatbot Tư vấn Sức khỏe (Health Chat Bot)

## 📋 Tổng quan

Tính năng này cung cấp một chatbot AI tư vấn sức khỏe sử dụng Google Gemini API, giúp người dùng nhận được lời khuyên về sức khỏe dựa trên dữ liệu cá nhân của họ.

## 🏗️ Kiến trúc

### 1. **Models** (`lib/models/`)
- `chat_message.dart` - Mô hình tin nhắn chat
  - `isUser` - Phân biệt tin nhắn từ người dùng hay AI
  - `isLoading` - Trạng thái đang chờ phản hồi
  - Factory methods: `userMessage()`, `aiResponse()`, `aiLoading()`

### 2. **Service** (`lib/services/`)
- `gemini_health_service.dart` - Giao tiếp với Gemini API
  - Hàm chính: `sendMessage(userMessage, user, health)`
  - Tự động tạo **System Instruction** từ dữ liệu người dùng
  - Xử lý lỗi: timeout, rate limit, invalid key

**System Instruction Template:**
```
Bạn là bác sĩ AI chuyên tư vấn sức khỏe.

Thông tin bệnh nhân:
- Tên: [userName]
- Tuổi: [age]
- Giới tính: [gender]

Chỉ số sức khỏe:
- Chiều cao: [height] cm
- Cân nặng: [weight] kg
- BMI: [bmi]
- Nhóm máu: [bloodType]

Tiền sử bệnh:
- Bệnh tiểu đường: [hasDiabetes]
- Tăng huyết áp: [hasHypertension]
- ...

Hướng dẫn:
1. Tư vấn dựa trên thông tin sức khỏe
2. Luôn lưu ý bệnh nền và dị ứng
3. Nếu bệnh lạ, khuyên gặp bác sĩ
4. Trả lời bằng tiếng Việt
5. Không chẩn đoán bệnh, chỉ tư vấn chung
```

### 3. **Provider** (`lib/providers/`)
- `health_chat_provider.dart` - State management
  - `messages: List<ChatMessage>` - Danh sách tin nhắn
  - `isLoading: bool` - Đang chờ API
  - `errorMessage: String?` - Thông báo lỗi
  - Methods:
    - `sendMessage(message, user, health)` - Gửi tin nhắn
    - `clearChat()` - Xóa hết cuộc trò chuyện
    - `clearError()` - Xóa thông báo lỗi
    - `loadGreeting(user)` - Tải tin nhắn chào mừng

### 4. **UI** (`lib/screens/profile/`)
- `health_chat_screen.dart` - Giao diện chat
  - Giống Messenger: bong bóng chat trái phải
  - Input field dưới cùng với nút gửi
  - Tự động cuộn xuống tin nhắn mới
  - Loading indicator khi chờ API
  - Error banner có nút đóng

## 🔧 Setup

### 1. **Cấu hình API Key**

Sửa file `lib/services/gemini_health_service.dart`:

```dart
static const String _geminiApiKey = 'YOUR_ACTUAL_API_KEY_HERE';
```

**Lấy API Key:**
1. Truy cập https://ai.google.dev/
2. Click "Get API Key"
3. Create new project hoặc chọn project hiện tại
4. Copy API Key

### 2. **Thêm Provider vào main.dart**

Đã được thêm tự động:

```dart
import 'providers/health_chat_provider.dart';

// ...

ChangeNotifierProvider(create: (_) => HealthChatProvider()),
```

### 3. **Thêm nút vào Profile Screen**

Đã được thêm vào `lib/screens/profile/my_profile_screen.dart`:

```dart
floatingActionButton: FloatingActionButton.extended(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HealthChatScreen()),
    );
  },
  icon: const Icon(Icons.health_and_safety_outlined),
  label: const Text('Tư vấn'),
),
```

## 📱 Sử dụng

### Từ Profile Screen:
1. Nhấn nút FAB "Tư vấn" ở góc dưới phải
2. Chatbot sẽ tải greeting message
3. Nhập câu hỏi sức khỏe
4. Nhấn nút gửi (➤)
5. Chờ AI xử lý (1-3 giây)
6. Nhận phản hồi tù AI

### Ví dụ câu hỏi:
- "Tôi nên ăn gì cho bữa trưa?"
- "Cách giảm cân an toàn là gì?"
- "Có nên tập thể dục hôm nay không?"
- "Tôi bị đau đầu thường xuyên, phải làm sao?"

## 🔐 Bảo mật

**Dữ liệu cá nhân:**
- ✅ Chỉ gửi đến Gemini API
- ✅ Không lưu trữ trên server cục bộ
- ✅ HTTPS encryption
- ✅ API key nên giữ trong config file (không hardcode)

**Khuyến nghị:**
1. Sử dụng environment variables cho API key:

```dart
// lib/config/env.dart
const String GEMINI_API_KEY = String.fromEnvironment('GEMINI_API_KEY');
```

2. Hoặc Firebase Secrets Management

3. Giáo dục người dùng:
   - Không lưu thông tin nhạy cảm trong chat
   - Luôn xác nhận với bác sĩ thật

## 🎨 Styling

- Theme: Động theo app theme (light/dark mode)
- Color Scheme: Xanh lá cây (health theme)
- Message bubbles: 
  - Người dùng: Primary color, phải
  - AI: Surface variant, trái
- Avatar: Icons khác nhau cho user/AI

## ⚠️ Xử lý lỗi

### API Errors:

1. **Timeout (30s)**
   ```
   "Gemini API request timeout. Please check your connection."
   ```

2. **Rate Limit (429)**
   ```
   "Gemini API rate limit exceeded. Please try again later."
   ```

3. **Invalid Key (401)**
   ```
   "Gemini API key is invalid. Please check your API key."
   ```

4. **Network Error**
   ```
   "Lỗi: [error message]"
   ```

### User Errors:
- Tin nhắn trống: Không gửi, hiển thị thông báo
- Không có dữ liệu user: Hiển thị snackbar

## 🚀 Tính năng mở rộng (Future)

1. **Chat History**
   - Lưu lịch sử chat vào local DB
   - Load chat cũ khi mở lại

2. **Voice Input**
   - Ghi âm câu hỏi
   - STT để chuyển thành text

3. **Appointment**
   - Nút "Đặt lịch khám"
   - Tích hợp lịch bác sĩ

4. **Export Report**
   - Xuất chat history thành PDF
   - Chia sẻ với bác sĩ

5. **Multi-language**
   - Hỗ trợ tiếng Anh, tiếng Trung

## 📊 Model dữ liệu tham khảo

### UserBasicModel
```dart
{
  "id": "user123",
  "userName": "Nguyễn Văn A",
  "phoneNumber": "0901234567",
  "gender": "Nam",
  "profilePicture": "..."
}
```

### HealthProfileModel
```dart
{
  "id": "health123",
  "dateOfBirth": "1990-01-15T00:00:00Z",
  "bloodType": "O+",
  "height": 170,
  "weight": 65,
  "age": 34,
  "hasDiabetes": false,
  "hasHypertension": true,
  "hasAsthma": false,
  "hasHeartDisease": false,
  "foodAllergies": "Lạc, tôm",
  "otherDiseases": "Dạ dày yếu"
}
```

## 🐛 Debugging

### Enable Logs:
Tất cả service có print statements:

```dart
[GeminiHealthService] Response received: ...
[HealthChatProvider] Sending message to Gemini...
[HealthChatProvider] Error: ...
```

### Monitor API Calls:
- Xem requests trong Gemini API console
- Check quota hàng ngày (1000 requests/day free tier)

## 📚 Tài liệu tham khảo

- [Google Gemini API Docs](https://ai.google.dev/tutorials/rest_quickstart)
- [Gemini 2.5 Flash Model](https://ai.google.dev/models/gemini-2-5-flash)
- [Flutter Provider Pattern](https://pub.dev/packages/provider)
- [JSON Serialization](https://flutter.dev/docs/development/data-and-backend/json)

## 🤝 Contributes

Để cải thiện chatbot:

1. **Cập nhật System Instruction** (GeminiHealthService._buildSystemInstruction)
2. **Thêm xử lý use case mới** (HealthChatProvider.sendMessage)
3. **Tối ưu UI** (HealthChatScreen widgets)
4. **Thêm validation** (User input checks)

## ✅ Checklist triển khai

- [x] Tạo ChatMessage model với JSON serialization
- [x] Tạo GeminiHealthService với system instruction
- [x] Tạo HealthChatProvider với state management
- [x] Tạo HealthChatScreen UI
- [x] Thêm HealthChatProvider vào MultiProvider
- [x] Thêm FAB button vào MyProfileScreen
- [ ] **BƯỚC QUAN TRỌNG: Cấu hình Gemini API Key** ⚠️
- [ ] Test trên Android emulator
- [ ] Test trên iOS simulator
- [ ] Test với các scenario khác nhau
- [ ] Handle edge cases
- [ ] Production deployment

## ⚡ Performance

- **Message load:** O(n) - linear time
- **API response:** ~1-3 giây
- **Memory:** Nhẹ, messages giữ trong RAM
- **Network:** HTTPS, encrypted

---

**Tác giả:** AI Health Advisor System  
**Phiên bản:** 1.0  
**Ngày cập nhật:** 26/11/2025
