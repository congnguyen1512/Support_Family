# Hướng dẫn cài lại FamilyGuard với Supabase mới

## Bước 0 — Cài sẵn công cụ
- **Node.js** ≥ 18 (máy bạn đang có v24 ✅)
- **Flutter SDK** + Android Studio (để có emulator / adb)
- Tài khoản **Supabase** (miễn phí): https://supabase.com

---

## Bước 1 — Tạo project Supabase mới
1. Vào https://supabase.com/dashboard → **New project**.
2. Đặt tên (vd `family-guard`), đặt mật khẩu DB, chọn region **Southeast Asia (Singapore)**.
3. Chờ ~2 phút cho project khởi tạo xong.

## Bước 2 — Tạo database
1. Trong project → menu trái **SQL Editor** → **New query**.
2. Mở file [`family_guard_database.sql`](family_guard_database.sql), copy **toàn bộ** nội dung, dán vào.
3. Bấm **Run**. Thấy `Success. No rows returned` là xong.
4. Kiểm tra: **Table Editor** phải có 11 bảng (`user_info`, `relationship`, `notification`, ...)
   và **Storage** có bucket `avatars`.

## Bước 3 — Tắt xác nhận email (cho dễ test)
**Authentication → Sign In / Providers → Email** → tắt **Confirm email** → Save.

## Bước 4 — Lấy API keys
**Project Settings → API** (hoặc **API Keys**), copy:
| Giá trị | Dán vào |
|---|---|
| Project URL | `SUPABASE_URL` |
| `anon` `public` key | `SUPABASE_ANON_KEY` |
| `service_role` key (bấm Reveal) | `SUPABASE_SERVICE_ROLE_KEY` |

> ⚠️ `service_role` key có toàn quyền DB — **không** đưa vào app Flutter, không push lên Git.

## Bước 5 — Cấu hình
### 5.1 Backend: sửa `BE/.env`
```env
PORT=3000
SUPABASE_URL=https://xxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...
GOOGLE_APPLICATION_CREDENTIALS=
```
### 5.2 App Flutter: sửa `lib/core/realtime/supabase_realtime_config.dart`
```dart
static const String url = 'https://xxxxxxxx.supabase.co';   // Project URL mới
static const String anonKey = 'eyJ...';                       // anon key mới
```

## Bước 6 — Chạy Backend
```powershell
cd BE
npm install
npm run dev
```
Thấy `Server is running at http://0.0.0.0:3000` là OK.
(Dòng cảnh báo `[firebase] ... Push notifications are DISABLED` là bình thường nếu chưa có key Firebase.)

## Bước 7 — Chạy App Flutter (terminal thứ 2, ở thư mục gốc)
```powershell
flutter pub get
flutter devices                 # xem id thiết bị
flutter run -d emulator-5554    # Android emulator
```
Máy thật qua USB:
```powershell
adb reverse tcp:3000 tcp:3000
flutter run -d <device-id>
```
Máy thật qua Wi-Fi (thay IP máy tính, xem bằng `ipconfig`):
```powershell
flutter run -d <device-id> --dart-define=FAMILY_GUARD_API_BASE_URL=http://192.168.x.x:3000/api
```

## Bước 8 — Tạo tài khoản để đăng nhập
Backend **không có API đăng ký**, nên tạo user trên Supabase:
1. **Authentication → Users → Add user → Create new user**
2. Nhập email + mật khẩu, tick **Auto Confirm User** → Create.
3. Đăng nhập trên app bằng email/mật khẩu đó → bảng `user_info` tự tạo profile.

**Phân vai trò** (Table Editor → `user_info`, sửa cột):
| `role` | `birthday` | Giao diện |
|---|---|---|
| `nguoichamsoc` | bất kỳ | Người chăm sóc (adult) |
| `nguoiduocchamsoc` | tuổi < 16 | Trẻ em (child) |
| `nguoiduocchamsoc` | tuổi ≥ 60 | Người già (elderly) |
| `nguoiduocchamsoc` | còn lại | adult |

Tạo ít nhất 2 tài khoản (vd 1 người chăm sóc + 1 trẻ em) rồi mời kết nối gia đình trong app để test.

---

## (Tuỳ chọn) Bật Push Notification
App đang dùng Firebase project của bạn bạn (`android/app/google-services.json`).
Để push hoạt động, backend cần **service account key của cùng Firebase project đó**:
1. Xin bạn bạn file `familyguard-...-firebase-adminsdk-....json`
   (Firebase Console → Project settings → Service accounts → Generate new private key).
2. Đặt vào `BE/keys/` và sửa `.env`:
   `GOOGLE_APPLICATION_CREDENTIALS=D:\University\FamilyGuard\Family_Guard\BE\keys\<ten-file>.json`

Nếu dùng Firebase project riêng của bạn thì phải thay luôn `google-services.json` trong app.

---

## Lỗi thường gặp
| Lỗi | Cách xử lý |
|---|---|
| `Invalid login credentials` | User chưa tạo / chưa Auto Confirm |
| `Could not find a relationship between 'relationship' and 'user_info'` | Chạy lại SQL, rồi chạy `notify pgrst, 'reload schema';` |
| `Bucket not found` khi đổi avatar | Kiểm tra Storage có bucket `avatars` (public) |
| App không gọi được backend | Backend chưa chạy / thiếu `adb reverse` / Firewall chặn port 3000 |
| Realtime không cập nhật | Chưa sửa `supabase_realtime_config.dart` sang project mới |
