Đã rõ. Vì bạn đã có logic (backend/function) để gọi hệ thống, phần mô tả UI cần điều chỉnh để AI hiểu rằng **nút Thư viện chỉ là một trigger (nút bấm)** chứ không dẫn sang một màn hình UI mới trong app.

Dưới đây là bản **Prompt UI đã được cập nhật**, loại bỏ màn hình Gallery ảo và thay thế bằng hành vi gọi Native Picker.

---

### **UPDATED PROMPT (Dành cho AI Agent)**

**Context:**
Tôi đã có logic xử lý dữ liệu và logic gọi **Native System Image Picker** (chọn ảnh từ thư viện máy). Hãy giúp tôi viết code Flutter UI (Widget tree) dựa trên mô tả dưới đây.

**1. Design System & Theme:** (Giữ nguyên như cũ)
*   **Style:** Dark Mode, Modern, Minimalism.
*   **Màu chủ đạo:** `#121212` (Bg), `#B6F2BA` (Accent), `#0A3812` (Text on Accent).
*   **Font:** San-serif (Inter/Roboto).

---

**2. Chi tiết các màn hình:**

#### **Màn hình 1: Camera Screen (Màn hình chính)**
*   **Layout:** Stack.
*   **Layer 1 & 2 (Camera Viewfinder & Overlay):**
    *   Full màn hình.
    *   Khung quét (Scanner frame) ở giữa với animation gradient xanh `#B6F2BA` chạy dọc.
    *   Chip cảnh báo: "Giữ camera ổn định" (Blur background).
*   **Layer 3 (Top Bar):** Nút Back, Title Badge "AI Camera", Nút Settings.
*   **Layer 4 (Bottom Controls) - CẬP NHẬT:**
    *   Panel bo góc trên, nền đen `#121212`.
    *   **Meal Selector:** List ngang chọn bữa (Sáng/Trưa/Tối/Phụ). Active: màu xanh `#B6F2BA`.
    *   **Action Area (3 nút chính):**
        *   **Nút Trái (Thư viện):**
            *   Icon: Image/Photo Icon.
            *   Visual: Hình vuông bo góc (`RoundedRectangle`), viền mỏng, nền xám tối.
            *   **Hành vi UI:** Khi nhấn vào, hiệu ứng `InkWell` ripple. **Lưu ý:** Nút này sẽ nhận một callback `onOpenGallery` từ bên ngoài để kích hoạt System Picker (không điều hướng sang màn hình mới).
        *   **Nút Giữa (Chụp):** Nút tròn lớn, viền ngoài trắng mờ, lõi trong màu `#B6F2BA`.
        *   **Nút Phải (Lịch sử):** Icon History, tương tự nút trái, điều hướng sang màn hình Lịch sử.

#### **Màn hình 2: Gallery Screen**
*   **❌ LOẠI BỎ (REMOVE):** Không code UI cho màn hình này. App sẽ sử dụng System UI native của điện thoại.

#### **Màn hình 3: Result Screen (Kết quả phân tích)**
*   Màn hình này sẽ hiển thị sau khi user chụp ảnh HOẶC chọn ảnh thành công từ System Picker.
*   **Header Image:** Hiển thị ảnh vừa chụp/chọn (Full width, height ~40% màn hình).
*   **Sheet Nội dung:**
    *   Bo góc tròn trùm lên ảnh.
    *   **Info:** Tag bữa ăn (Lunch/Dinner...), Ngày giờ, Tên món ăn (Lớn).
    *   **Nutrient Grid:** 3 thẻ vuông hiển thị Calories (Cam), Protein (Đỏ), Carbs (Vàng).
    *   **AI Insight:** Card viền xanh lá chứa nhận xét của AI.

#### **Màn hình 4: History Screen (Lịch sử)**
*   Danh sách món ăn cũ (List View).
*   Mỗi item hiển thị: Thumbnail ảnh, Tên, Calo, Ngày tháng.
*   Có bộ lọc (Chips) theo Thời gian và Bữa ăn.

#### **Loading Overlay (Quan trọng)**
*   Vì việc load ảnh từ System Gallery và phân tích cần thời gian, hãy thiết kế một Widget `LoadingOverlay`.
*   Nền đen mờ phủ toàn màn hình.
*   Hiển thị Spinner và text: "Đang tải ảnh..." hoặc "Đang phân tích...".

---

**Yêu cầu kỹ thuật cho Flutter UI:**
1.  Tại `CameraScreen`, Widget nút Thư viện phải có tham số `final VoidCallback onOpenGallery;` để tôi có thể truyền hàm gọi `image_picker` của tôi vào đó.
2.  Tại `ResultScreen`, constructor phải nhận vào một tham số `final File imageFile;` (hoặc `String imagePath`) để hiển thị ảnh được trả về từ thư viện.
3.  Sử dụng `SafeArea` và các icon từ `lucide_icons` hoặc `cupertino_icons`.

--- END OF PROMPT ---