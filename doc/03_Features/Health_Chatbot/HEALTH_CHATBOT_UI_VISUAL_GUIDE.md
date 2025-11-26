# 🎨 Health Chatbot - UI/UX Visual Guide

## 📱 Screen Flows

### Flow 1: Navigate to Chat
```
┌─────────────────────┐
│  My Profile Screen  │
│                     │
│                     │
│                     │
│     (content)       │
│                     │
│                     │
│           ╔════════╗│
│           ║ Tư vấn ║│  ← Tap here
│           ╚════════╝│
└─────────────────────┘
         ↓
┌─────────────────────┐
│ Health Chat Screen  │ ← Opens with greeting
└─────────────────────┘
```

---

## 📸 Health Chat Screen Layout

### Header
```
┌─────────────────────────────────────────────────┐
│ ◄  Tư vấn Sức khỏe                      🔄   ⚙️  │
│     AI Health Advisor                          │
└─────────────────────────────────────────────────┘
```

### Message List
```
┌─────────────────────────────────────────────────┐
│                                                 │
│ 🏥 │ Xin chào Nguyễn Văn A! 👋                 │
│    │ Tôi là trợ lý y tế AI...                 │
│    │ Hãy đặt câu hỏi của bạn                  │
│                                                 │
│                   Tôi nên ăn gì? │ 👤           │
│                                 │              │
│ 🏥 │ Dựa trên thông tin của    │              │
│    │ bạn (BMI 22.5 - Bình    │              │
│    │ thường), bạn nên ăn:     │              │
│    │ - Rau xanh                │              │
│    │ - Cá hồi                  │              │
│    │ - Rau họ đậu              │              │
│                                                 │
│              Cảm ơn anh! │ 👤                 │
│                       │                       │
│ 🏥 │ Không sao! .... │                       │
│    │ ...                                      │
│                                                 │
└─────────────────────────────────────────────────┘
     (Auto-scrolls to newest message)
```

### Loading State
```
┌─────────────────────────────────────────────────┐
│                                                 │
│ 🏥 │ ⟳ Đang suy nghĩ...                      │
│    │ (circular progress indicator spinning)    │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Error State
```
┌─────────────────────────────────────────────────┐
│ ⚠ Lỗi: Gemini API key is invalid. [✕]          │
└─────────────────────────────────────────────────┘
     ↓ Click [✕] to dismiss
```

### Input Area
```
┌─────────────────────────────────────────────────┐
│ ┌─────────────────────────────────────┐ ╔════╗ │
│ │ Nhập câu hỏi...                   │ ║ ➤  ║ │
│ │ (multi-line supported)            │ ╚════╝ │
│ └─────────────────────────────────────┘       │
└─────────────────────────────────────────────────┘
```

---

## 🎨 Color Scheme

### Light Mode
```
Component          Color           Usage
─────────────────────────────────────────
Primary            #2E7D32 (Green)  Send button, tabs
User bubble        #2E7D32 (Green)  Message background
AI bubble          #E8E8E8 (Gray)   Message background
User text          White            Text on green
AI text            #212121 (Black)  Text on gray
Loading spinner    #2E7D32 (Green)  Progress indicator
Error banner       #B3261E (Red)    Error background
Background         #FFFFFF (White)  Screen background
```

### Dark Mode
```
Component          Color           Usage
─────────────────────────────────────────
Primary            #4CAF50 (Lt.Grn) Send button, tabs
User bubble        #4CAF50 (Lt.Grn) Message background
AI bubble          #424242 (D.Gray) Message background
User text          White            Text on green
AI text            #E8E8E8 (Light)  Text on gray
Loading spinner    #4CAF50 (Lt.Grn) Progress indicator
Error banner       #F2B8B5 (Lt.Red) Error background
Background         #121212 (Black)  Screen background
```

---

## 💬 Message Bubble Examples

### User Message (Right-aligned)
```
┌───────────────────────────┐
│   Tôi bị tăng huyết áp   │  ← Primary color (green)
│   có thể tập thể dục?    │     Rounded corners
└───────────────────────────┘     White text
      👤 (User avatar)
```

### AI Message (Left-aligned)
```
        🏥 (AI avatar)
┌──────────────────────────────┐
│ Dựa trên thông tin của bạn  │  ← Surface variant (gray)
│ có tăng huyết áp, bạn nên:  │     Rounded corners
│ - Tập thể dục nhẹ nhàng    │     Dark text
│ - Kéo dài từ 30-60 phút    │
│ - Tránh tập bạo lực        │
└──────────────────────────────┘
```

### Loading Message
```
        🏥 (AI avatar)
┌────────────────────────────┐
│ ⟳ Đang suy nghĩ...       │  ← Gray background
│ (circular spinner visible)│     Loading text
└────────────────────────────┘
```

---

## 🎯 Interactive Elements

### Send Button
```
Normal State:        Pressed State:       Disabled State:
┌────────┐          ┌────────┐           ┌────────┐
│ ➤ SEND │ (green)  │ ➤ SEND │ (darker) │ ➤      │ (gray)
└────────┘          └────────┘           └────────┘
```

### Input Field
```
Focused:                Normal:
┌──────────────────┐   ┌──────────────────┐
│ Type here...     │   │ Type here...     │
└──────────────────┘   └──────────────────┘
(Border green)        (Border light gray)
```

### Error Banner
```
Before dismiss:        After dismiss:
┌────────────────┐     (banner gone)
│ ⚠ Lỗi [✕]      │
└────────────────┘
(Click ✕ to close)
```

---

## 🔄 User Interactions Timeline

### Perfect Flow
```
[1] User opens app
    ↓
[2] Navigates to Profile
    ↓
[3] Sees FAB "Tư vấn" button
    ↓
[4] Taps button
    ↓
[5] HealthChatScreen opens
    ↓
[6] Greeting message appears
    ↓
[7] User types message
    ↓
[8] User taps send button
    ↓
[9] Loading indicator shows
    ↓
[10] AI response appears
    ↓
[11] User can continue chatting
```

### Error Flow
```
[1] User taps send
    ↓
[2] API error occurs (timeout/rate limit)
    ↓
[3] Error banner appears at top
    ↓
[4] User can dismiss error (click ✕)
    ↓
[5] Or try sending again
    ↓
[6] Works on retry
```

---

## 📐 Spacing & Sizing

### AppBar
```
Height: 56dp (default Material)
Title: 16sp
Subtitle: 12sp

Icons: 24dp
Padding: 12dp (horizontal)
```

### Messages
```
Horizontal padding: 16dp
Vertical padding (list): 12dp
Bubble padding: 16dp (horizontal), 12dp (vertical)
Border radius: 16dp
```

### Input Area
```
Container height: ~60dp (with padding)
TextField height: ~48dp (multi-line)
Button size: FAB.small (40dp diameter)
Gap between field & button: 12dp
```

### Avatar
```
User & AI avatar radius: 16dp
Position: After/before message bubble
Gap to bubble: 8dp
```

---

## 🎬 Animations

### Message Appearing
```
Fade-in effect: 200ms
Slide effect: none (appears at bottom)
```

### Auto-scroll
```
Duration: 300ms
Curve: easeOut
When: After new message added
```

### Loading Spinner
```
Duration: continuous
Type: CircularProgressIndicator
Size: 16dp
```

### Error Banner
```
Slide down: 200ms
```

---

## 📱 Responsive Design

### Phone (Portrait)
```
Width: 360dp - 480dp
Message bubble max width: 85%
Input area: Full width with padding
```

### Tablet (Landscape)
```
Width: 600dp+
Message bubble max width: 70%
Input area: Constrained width
```

### Layout Adjustments
```
- Single column on phone
- Message bubbles scale with screen
- Input grows/shrinks with screen
- Font sizes adjust for readability
```

---

## ♿ Accessibility

### Text
```
Minimum contrast: 4.5:1 (WCAG AA)
Default font size: 14sp (body), 16sp (app bar)
Line height: 1.5x font size
```

### Touch Targets
```
Minimum: 48dp x 48dp
Send button: 40dp (FAB.small, acceptable)
Message taps: Full bubble area
```

### Semantic Labels
```
AppBar title: "Health Consultation Chat"
Send button: "Send message"
Loading indicator: "Loading response from AI"
Avatar: "AI assistant" / "You"
```

### Screen Reader Support
```
Message type announced: "User message" / "AI message"
Timestamps: Announced when asked
Emojis: Alternative text provided
```

---

## 🌈 Theme Integration

### Material 3 Design
```
- Uses ColorScheme.fromSeed()
- Respects system theme
- Smooth transitions on theme change
- Proper contrast ratios
```

### Light Theme
- Bright backgrounds
- Dark text
- Primary green
- Soft shadows

### Dark Theme
- Dark backgrounds
- Light text
- Lighter green
- Reduced shadows

---

## 📊 Message Bubble Variants

### User Messages
```
Short: "Xin chào"
Medium: "Tôi nên ăn gì?"
Long: Multi-line with proper wrapping
Very long: Scrollable message bubble
```

### AI Messages
```
Bullet points: "- Item 1\n- Item 2"
Paragraphs: Multiple paragraphs handled
Links: Text-only, no clickable links
Bold/Italic: Plain text (AI response)
```

---

## 🎓 Empty States

### First Load (Greeting)
```
┌─────────────────────────┐
│                         │
│   🏥 GREETING MESSAGE  │
│   (shows on first open) │
│                         │
└─────────────────────────┘
```

### After Clear
```
┌─────────────────────────┐
│      Conversation       │
│      cleared 🧹         │
│                         │
│   (can start fresh)     │
└─────────────────────────┘
```

---

## ✨ Polish Details

- ✅ Smooth scrolling with physics
- ✅ Material ink ripple on buttons
- ✅ Keyboard automatically shows on open
- ✅ Keyboard dismisses on message send
- ✅ Haptic feedback on send (optional)
- ✅ Status bar color matches theme
- ✅ Back button exits properly
- ✅ Messages persist while scrolling
- ✅ Loading spinner centered
- ✅ Error messages user-friendly

---

**Design Language:** Material Design 3  
**Color Palette:** Green (health) + Orange (accent)  
**Typography:** Roboto (default Material)  
**Animation Style:** Smooth, purposeful  
**Target Platforms:** Android, iOS, Web (supported)  

