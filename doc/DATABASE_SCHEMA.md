# DATABASE SCHEMA DOCUMENTATION

## 📊 TỔNG QUAN DATABASE

**Database Name:** Hotel_Web  
**Database Server:** SQL Server  
**Connection String:** Xem trong `appsettings.json`

---

## 📋 TABLES STRUCTURE

### 1. AspNetUsers (ApplicationUser)

**Mô tả:** Bảng lưu thông tin người dùng (kế thừa từ Identity)

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| Id | nvarchar(450) | NO | Primary Key - User ID |
| UserName | nvarchar(256) | YES | Tên đăng nhập |
| Email | nvarchar(256) | YES | Email |
| EmailConfirmed | bit | NO | Email đã xác nhận |
| PasswordHash | nvarchar(MAX) | YES | Mật khẩu đã hash |
| PhoneNumber | nvarchar(MAX) | YES | Số điện thoại |
| gioi_tinh | nvarchar(MAX) | YES | Giới tính |
| tuoi | int | YES | Tuổi |
| ProfilePicture | nvarchar(MAX) | YES | Đường dẫn ảnh đại diện |
| displayName | nvarchar(MAX) | YES | Tên hiển thị |
| dang_online | bit | YES | Trạng thái online |
| trang_thai | int | YES | Trạng thái tài khoản (0=offline, 1=active) |
| lan_hoat_dong_cuoi | datetime2 | YES | Lần hoạt động cuối |
| isFacebookLinked | bit | YES | Đã liên kết Facebook |
| isGoogleLinked | bit | YES | Đã liên kết Google |
| googleProfilePicture | nvarchar(MAX) | YES | Ảnh từ Google |
| facebookProfilePicture | nvarchar(MAX) | YES | Ảnh từ Facebook |
| avatarUrl | nvarchar(MAX) | YES | URL avatar |
| kinh_nghiem | int | YES | Kinh nghiệm |
| chuyenKhoaId | uniqueidentifier | YES | ID chuyên khoa |

**Indexes:**
- Primary Key: `PK_AspNetUsers` on `Id`
- Index: `EmailIndex` on `NormalizedEmail`
- Index: `UserNameIndex` on `NormalizedUserName`

---

### 2. BaiDang (Posts)

**Mô tả:** Bảng lưu bài đăng mạng xã hội

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| Id | uniqueidentifier | NO | Primary Key |
| NguoiDungId | nvarchar(450) | YES | Foreign Key -> AspNetUsers(Id) |
| NoiDung | nvarchar(MAX) | YES | Nội dung bài viết |
| Loai | nvarchar(MAX) | YES | Loại bài viết (text, image, video) |
| DuongDanMedia | nvarchar(MAX) | YES | Đường dẫn file media |
| NgayDang | datetime2 | YES | Ngày đăng |
| LuotThich | int | YES | Số lượt thích |
| SoBinhLuan | int | YES | Số bình luận |
| so_chia_se | int | NO | Số lượt chia sẻ |
| Id_MonAn | uniqueidentifier | YES | ID món ăn liên quan |
| hashtags | nvarchar(MAX) | YES | Hashtags |
| DaDuyet | bit | YES | Đã duyệt (true/false) |
| NguoiDang | nvarchar(MAX) | YES | Tên người đăng |

**Relationships:**
- Foreign Key: `FK_BaiDang_AspNetUsers` -> `AspNetUsers(Id)` ON DELETE RESTRICT

---

### 3. BinhLuan (Comments)

**Mô tả:** Bảng lưu bình luận bài viết

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| Id | uniqueidentifier | NO | Primary Key |
| BaiDangId | uniqueidentifier | NO | Foreign Key -> BaiDang(Id) |
| NguoiDungId | nvarchar(450) | YES | Foreign Key -> AspNetUsers(Id) |
| NguoiBinhLuan | nvarchar(MAX) | YES | Tên người bình luận |
| NoiDung | nvarchar(MAX) | YES | Nội dung bình luận |
| NgayTao | datetime2 | NO | Ngày tạo |
| ParentCommentId | uniqueidentifier | YES | ID comment cha (cho reply) |

**Relationships:**
- Foreign Key: `FK_BinhLuan_BaiDang` -> `BaiDang(Id)` ON DELETE CASCADE
- Foreign Key: `FK_BinhLuan_AspNetUsers` -> `AspNetUsers(Id)` ON DELETE RESTRICT

---

### 4. BaiDang_LuotThich (Post Likes)

**Mô tả:** Bảng lưu lượt thích bài viết

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | uniqueidentifier | NO | Primary Key |
| baidang_id | uniqueidentifier | NO | Foreign Key -> BaiDang(Id) |
| nguoidung_id | nvarchar(450) | NO | Foreign Key -> AspNetUsers(Id) |
| ngay_thich | datetime2 | NO | Ngày thích |

**Relationships:**
- Foreign Key: `FK_BaiDang_LuotThich_BaiDang` -> `BaiDang(Id)` ON DELETE CASCADE
- Foreign Key: `FK_BaiDang_LuotThich_AspNetUsers` -> `AspNetUsers(Id)` ON DELETE RESTRICT

---

### 5. MonAn (Dishes)

**Mô tả:** Bảng lưu thông tin món ăn

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| Id | uniqueidentifier | NO | Primary Key |
| Ten | nvarchar(MAX) | YES | Tên món ăn |
| MoTa | nvarchar(MAX) | YES | Mô tả |
| CachCheBien | nvarchar(MAX) | YES | Cách chế biến |
| Loai | nvarchar(MAX) | YES | Loại món ăn |
| NgayTao | datetime2 | YES | Ngày tạo |
| Image | nvarchar(MAX) | YES | Đường dẫn ảnh |
| Gia | decimal(18,2) | YES | Giá tiền |
| SoNguoi | int | YES | Số người ăn |
| LuotXem | int | YES | Lượt xem |

---

### 6. BaiThuoc (Medicine Articles)

**Mô tả:** Bảng lưu bài thuốc

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| Id | uniqueidentifier | NO | Primary Key |
| Ten | nvarchar(MAX) | NO | Tên bài thuốc |
| MoTa | nvarchar(MAX) | YES | Mô tả |
| HuongDanSuDung | nvarchar(MAX) | YES | Hướng dẫn sử dụng |
| NguoiDungId | nvarchar(450) | YES | Foreign Key -> AspNetUsers(Id) |
| NgayTao | datetime2 | NO | Ngày tạo |
| Image | nvarchar(MAX) | YES | Đường dẫn ảnh |
| SoLuotThich | int | YES | Số lượt thích |
| SoLuotXem | int | YES | Số lượt xem |
| TrangThai | int | NO | Trạng thái (0=draft, 1=published) |

**Relationships:**
- Foreign Key: `FK_BaiThuoc_AspNetUsers` -> `AspNetUsers(Id)` ON DELETE RESTRICT

---

### 7. NuocUong (Drinks)

**Mô tả:** Bảng lưu thông tin nước uống

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| Id | uniqueidentifier | NO | Primary Key |
| Ten | nvarchar(MAX) | YES | Tên nước uống |
| MoTa | nvarchar(MAX) | YES | Mô tả |
| CongThuc | nvarchar(MAX) | YES | Công thức pha chế |
| Loai | nvarchar(MAX) | YES | Loại nước uống |
| NgayTao | datetime2 | YES | Ngày tạo |
| Image | nvarchar(MAX) | YES | Đường dẫn ảnh |
| Gia | decimal(18,2) | YES | Giá tiền |
| LuotXem | int | YES | Lượt xem |

---

### 8. HealthPlans (Phác đồ sức khỏe)

**Mô tả:** Bảng lưu phác đồ sức khỏe người dùng

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| Id | int | NO | Primary Key (Identity) |
| UserId | nvarchar(450) | NO | Foreign Key -> AspNetUsers(Id) |
| ChieuCao | float | NO | Chiều cao (cm) |
| CanNang | float | NO | Cân nặng (kg) |
| BMI | float | NO | Chỉ số BMI |
| MucTieuCalo | float | NO | Mục tiêu calories/ngày |
| MucTieuProtein | float | NO | Mục tiêu protein/ngày |
| MucTieuCarbs | float | NO | Mục tiêu carbs/ngày |
| MucTieuFat | float | NO | Mục tiêu fat/ngày |
| MucDoHoatDong | nvarchar(MAX) | YES | Mức độ hoạt động |
| MucTieu | nvarchar(MAX) | YES | Mục tiêu (giảm/tăng/duy trì cân) |
| NgayTao | datetime2 | NO | Ngày tạo |

**Relationships:**
- Foreign Key: `FK_HealthPlans_AspNetUsers` -> `AspNetUsers(Id)` ON DELETE RESTRICT

---

### 9. PredictionHistory (Lịch sử phân tích món ăn)

**Mô tả:** Bảng lưu lịch sử phân tích món ăn bằng AI

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| Id | int | NO | Primary Key (Identity) |
| UserId | nvarchar(450) | NO | Foreign Key -> AspNetUsers(Id) |
| ImagePath | nvarchar(MAX) | NO | Đường dẫn ảnh |
| FoodName | nvarchar(MAX) | NO | Tên món ăn |
| Confidence | float | NO | Độ tin cậy (0-1) |
| Calories | float | NO | Calories |
| Protein | float | NO | Protein (g) |
| Fat | float | NO | Fat (g) |
| Carbs | float | NO | Carbs (g) |
| MealType | nvarchar(MAX) | YES | Loại bữa ăn |
| Advice | nvarchar(MAX) | YES | Lời khuyên từ AI |
| CreatedAt | datetime2 | NO | Ngày tạo |

**Relationships:**
- Foreign Key: `FK_PredictionHistory_AspNetUsers` -> `AspNetUsers(Id)` ON DELETE RESTRICT

---

### 10. PredictionDetail (Chi tiết phân tích)

**Mô tả:** Bảng lưu chi tiết các món ăn trong ảnh

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| Id | int | NO | Primary Key (Identity) |
| PredictionHistoryId | int | NO | Foreign Key -> PredictionHistory(Id) |
| Label | nvarchar(MAX) | NO | Tên món ăn |
| Weight | float | NO | Khối lượng (g) |
| Confidence | float | NO | Độ tin cậy |
| Calories | float | NO | Calories |
| Protein | float | NO | Protein (g) |
| Fat | float | NO | Fat (g) |
| Carbs | float | NO | Carbs (g) |

**Relationships:**
- Foreign Key: `FK_PredictionDetail_PredictionHistory` -> `PredictionHistory(Id)` ON DELETE CASCADE

---

## 🔄 ENTITY RELATIONSHIPS DIAGRAM

```
AspNetUsers (1) ----< (N) BaiDang
AspNetUsers (1) ----< (N) BinhLuan
AspNetUsers (1) ----< (N) BaiDang_LuotThich
AspNetUsers (1) ----< (N) BaiThuoc
AspNetUsers (1) ----< (N) HealthPlans
AspNetUsers (1) ----< (N) PredictionHistory

BaiDang (1) ----< (N) BinhLuan
BaiDang (1) ----< (N) BaiDang_LuotThich

BinhLuan (1) ----< (N) BinhLuan (Self-reference for replies)

PredictionHistory (1) ----< (N) PredictionDetail
```

---

## 📝 SQL QUERIES VÍ DỤ

### Lấy tất cả bài viết của user
```sql
SELECT b.*, u.UserName, u.ProfilePicture
FROM BaiDang b
INNER JOIN AspNetUsers u ON b.NguoiDungId = u.Id
WHERE b.NguoiDungId = 'user-id'
ORDER BY b.NgayDang DESC
```

### Lấy số lượt thích của bài viết
```sql
SELECT COUNT(*) as TotalLikes
FROM BaiDang_LuotThich
WHERE baidang_id = 'post-id'
```

### Lấy comments có replies
```sql
SELECT c1.*, c2.* as Reply
FROM BinhLuan c1
LEFT JOIN BinhLuan c2 ON c2.ParentCommentId = c1.Id
WHERE c1.BaiDangId = 'post-id' AND c1.ParentCommentId IS NULL
ORDER BY c1.NgayTao DESC
```

### Lấy lịch sử phân tích của user
```sql
SELECT ph.*, pd.*
FROM PredictionHistory ph
LEFT JOIN PredictionDetail pd ON pd.PredictionHistoryId = ph.Id
WHERE ph.UserId = 'user-id'
ORDER BY ph.CreatedAt DESC
```

### Thống kê calories theo ngày
```sql
SELECT 
    CAST(CreatedAt AS DATE) as NgayPhanTich,
    SUM(Calories) as TongCalories,
    COUNT(*) as SoBuaAn
FROM PredictionHistory
WHERE UserId = 'user-id'
GROUP BY CAST(CreatedAt AS DATE)
ORDER BY NgayPhanTich DESC
```

---

## 🔐 IDENTITY TABLES

ASP.NET Identity tự động tạo các bảng:

- **AspNetUsers** - User accounts
- **AspNetRoles** - User roles (Admin, User, etc.)
- **AspNetUserRoles** - User-Role mapping
- **AspNetUserClaims** - User claims
- **AspNetUserLogins** - External login info (Google, Facebook)
- **AspNetUserTokens** - Authentication tokens
- **AspNetRoleClaims** - Role claims

---

## 💾 DATABASE BACKUP & RESTORE

### Backup
```sql
BACKUP DATABASE [Hotel_Web] 
TO DISK = 'C:\Backup\Hotel_Web.bak'
WITH FORMAT, MEDIANAME = 'SQLServerBackups',
NAME = 'Full Backup of Hotel_Web';
```

### Restore
```sql
RESTORE DATABASE [Hotel_Web]
FROM DISK = 'C:\Backup\Hotel_Web.bak'
WITH REPLACE;
```

---

## 🔧 MIGRATIONS

API sử dụng Entity Framework Core Migrations.

### Tạo migration mới
```bash
dotnet ef migrations add MigrationName
```

### Apply migration
```bash
dotnet ef database update
```

### Remove migration
```bash
dotnet ef migrations remove
```

---

## 📊 INDEXES RECOMMENDATIONS

Để tối ưu performance:

```sql
-- Index cho tìm kiếm bài viết theo NgayDang
CREATE INDEX IX_BaiDang_NgayDang ON BaiDang(NgayDang DESC)

-- Index cho tìm kiếm comment theo BaiDangId
CREATE INDEX IX_BinhLuan_BaiDangId ON BinhLuan(BaiDangId)

-- Index cho tìm kiếm PredictionHistory theo UserId
CREATE INDEX IX_PredictionHistory_UserId ON PredictionHistory(UserId)

-- Index cho tìm kiếm MonAn theo Loai
CREATE INDEX IX_MonAn_Loai ON MonAn(Loai)
```

---

**Last Updated:** November 9, 2025
