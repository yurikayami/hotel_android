# Hướng dẫn tự động cập nhật địa chỉ IP cho Flutter API

## Mục đích
Giúp bạn tự động cập nhật địa chỉ IP của máy tính vào file cấu hình `api_config.dart` mỗi khi đổi máy hoặc đổi mạng, không cần sửa tay từng lần.

## Bước 1: Chuẩn bị
- Đảm bảo bạn đã có file script `change_ip.ps1` trong thư mục gốc project Flutter (cùng cấp với pubspec.yaml).
- File này sẽ tự động lấy IPv4 của máy và cập nhật vào biến `ipComputer` trong `lib/services/api_config.dart`.

## Bước 2: Sử dụng script
1. **Mở PowerShell**
2. **Di chuyển đến thư mục project:**
   ```powershell
   cd "D:\Workspace\01 Project\Project Dev\Graduation project\Main Project\Hotel_Android\hotel_android"
   ```
3. **Chạy script:**
   ```powershell
   .\change_ip.ps1
   ```
   - Script sẽ tự động lấy IPv4 đầu tiên của máy (không phải localhost) và cập nhật vào file cấu hình.
   - Nếu thành công sẽ hiện thông báo: `Updated ipComputer to: <ip>`
   - Sau đó script sẽ tự động chạy `flutter run` để build và cài lại app lên thiết bị.

## Lưu ý
- Nếu bạn đổi máy hoặc đổi mạng, chỉ cần chạy lại script này.
- Nếu gặp lỗi không tìm thấy file hoặc không có IPv4, kiểm tra lại đường dẫn và kết nối mạng.
- Nếu Flutter báo lỗi môi trường, hãy kiểm tra lại biến môi trường PATH hoặc cài đặt lại Flutter.

## Tại sao phải chạy lại `flutter run`?
- Khi bạn cập nhật code (hoặc IP), app trên thiết bị chỉ nhận code mới khi bạn build lại bằng `flutter run`.
- Nếu chỉ mở lại app trên điện thoại mà không build lại, app sẽ chạy code cũ.

## Kết luận
Chỉ cần chạy `change_ip.ps1` mỗi khi đổi máy hoặc đổi mạng, bạn sẽ không cần sửa IP thủ công nữa và app luôn dùng đúng địa chỉ API mới nhất.
