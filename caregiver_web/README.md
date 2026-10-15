# Support Family · Caregiver Web 🛡️

Bản **web dành riêng cho vai trò Người chăm sóc** của Support Family, viết bằng **React Native (Expo + React Native Web)**.
Tối ưu cho máy tính: màn hình lớn, phím tắt, thao tác nhanh — dùng chung tài khoản & Backend với ứng dụng di động.

---

## 🚀 Chạy nhanh (Windows)

Nhấp đúp file **`run_web.bat`** ở thư mục gốc dự án → tự mở Backend (cổng 3000) + Web (cổng 8081) và trình duyệt.

## 🧑‍💻 Chạy thủ công

```bash
# 1) Backend
cd BE
npm install
npm run dev            # http://localhost:3000

# 2) Web người chăm sóc (cửa sổ terminal khác)
cd caregiver_web
npm install
npm run dev            # http://localhost:8081
```

Đăng nhập bằng tài khoản **Người chăm sóc** (`nguoichamsoc`). Tài khoản người được chăm sóc sẽ bị chặn trên bản web.

### Biến môi trường (`caregiver_web/.env`)

| Biến | Mặc định | Ý nghĩa |
| --- | --- | --- |
| `EXPO_PUBLIC_API_BASE_URL` | `http://localhost:3000/api` | Địa chỉ Backend |
| `EXPO_PUBLIC_SUPABASE_URL` | (như app mobile) | Realtime thông báo |
| `EXPO_PUBLIC_SUPABASE_ANON_KEY` | (như app mobile) | Realtime + làm mới phiên |

> Có thể đổi địa chỉ API ngay trong **Cài đặt → Kết nối máy chủ** mà không cần build lại.

### Build production

```bash
npm run build      # xuất ra thư mục dist/
npm run preview    # chạy thử bản build tại http://localhost:4173
```

---

## ✨ Tính năng

| Trang | Nội dung |
| --- | --- |
| **Tổng quan** | Lời chào, thao tác nhanh, thống kê, bản đồ trực tiếp, trạng thái thành viên, lịch nhắc hôm nay, lịch khám, hoạt động gần đây |
| **Bản đồ trực tiếp** | Vị trí cả nhà (tự làm mới 15s), vùng an toàn, **xem lại lộ trình theo ngày** có phát lại (1x/2x/4x), quãng đường |
| **Thông báo** | Lọc theo loại, đánh dấu đã đọc, chấp nhận/từ chối lời mời, xem vị trí té ngã |
| **Thành viên** | Thẻ thành viên, lọc cao tuổi/trẻ em, mời qua email/SĐT, sửa quan hệ, xóa, ngăn kéo chi tiết, **nhắc việc cho trẻ em** |
| **Tin nhắn** | Hai khung, gửi tức thì (optimistic), trả lời nhanh, Enter để gửi |
| **Nhắc nhở** | Bảng nhắc nhở, mẫu nhanh, bật/tắt, **chọn nhiều & xóa hàng loạt** |
| **Lịch khám** | Nhóm theo ngày, đánh dấu đã khám/hủy, nhắc trước 1 ngày/2 giờ |
| **Vận động** | Vòng tiến độ bước chân/calo/phút, cập nhật mục tiêu, lịch tập |
| **Báo cáo sức khỏe** | Tỷ lệ tuân thủ, phân loại, biểu đồ 7 ngày, nhật ký sức khỏe |
| **Vùng an toàn** | Nhấn bản đồ để đặt tâm, kéo bán kính, tìm địa chỉ, trạng thái trong/ngoài vùng |
| **Cài đặt** | Hồ sơ + ảnh đại diện, sáng/tối, âm báo, thông báo desktop, liên hệ khẩn cấp, địa chỉ API |

**Cảnh báo té ngã**: popup khẩn cấp toàn màn hình + âm báo + thông báo desktop + bản đồ vị trí, nút gọi / chỉ đường / nhắn tin.
Thông báo được đẩy theo thời gian thực qua **Supabase Realtime** (kèm polling dự phòng).

## ⌨️ Phím tắt

| Phím | Chức năng |
| --- | --- |
| `Ctrl + K` / `?` | Bảng lệnh: tìm thành viên, trang, thao tác |
| `Alt + 1…9`, `Alt + 0` | Chuyển trang (1 Tổng quan · 2 Bản đồ · 3 Thành viên · 4 Vùng an toàn · 5 Nhắc nhở · 6 Lịch khám · 7 Vận động · 8 Sức khỏe · 9 Tin nhắn · 0 Thông báo) |
| `N` | Tạo mới trên trang hiện tại |
| `/` | Tìm kiếm trong trang |
| `Shift + D` | Đổi giao diện sáng / tối |
| `Ctrl + B` | Thu gọn thanh bên |
| `Esc` | Đóng hộp thoại |

## 🗂️ Cấu trúc

```
caregiver_web/
├─ src/app/            # Expo Router: login, (app)/index, map, members, ...
├─ src/components/     # ui/ (design system), layout/, map/ (Leaflet), members/
├─ src/api/            # client (tự làm mới token), endpoints, React Query hooks
├─ src/store/          # Zustand: auth, ui, toast (lưu localStorage)
├─ src/hooks/          # phím tắt, trung tâm cảnh báo realtime
├─ src/theme/          # design tokens sáng/tối
└─ src/utils/          # định dạng, hằng số, lịch
```

## ⚡ Tối ưu

- Bản đồ Leaflet được **tải lười** (code-splitting) → trang đầu mở nhanh.
- React Query cache + làm mới nền theo từng loại dữ liệu; tự làm mới access token khi hết hạn.
- Không cần thư viện UI nặng — design system tự xây trên React Native Web.
