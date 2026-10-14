# Tổng hợp chức năng hiện có - Family Guard

Tài liệu này tổng hợp các chức năng đã được khai báo và đang có sẵn trong ứng dụng (dựa trên module trong `lib/features` và danh sách route trong `lib/core/constants/app_routes.dart` + `lib/core/routes/app_router.dart`).

## 1. Xác thực và tài khoản
- Đăng nhập (`/login`)
- Quên mật khẩu (`/forgot-password`)
- Đăng ký thông tin cá nhân (`/signup`)
- Đăng ký thông tin tài khoản (`/signup-account`)
- Đăng ký bảo mật (`/signup-security`)
- Splash/khởi động (`/splash`)

## 2. Trang chính và điều hướng tổng quan
- Trang chủ (`/home`)
- Cài đặt (`/settings`)
- Thông báo (`/notifications`)
- Hồ sơ cá nhân (`/profile`)
- Bảo mật mật khẩu (`/password-security`)

## 3. Quản lý thành viên gia đình
- Màn hình quản lý thành viên (`/member-management`)
- Danh sách thành viên (`/member-list`)
- Chi tiết thành viên (`/member-details`)
- Thêm thành viên (`/add-member`)
- Chọn thành viên (`/member-selection`)
- Quản lý trẻ em (`/kid-management`)
- Chi tiết thành viên người lớn (`/adult-member-detail`)
- Chi tiết thành viên cao tuổi (`/senior-member-detail`)

## 4. Theo dõi vị trí và lịch sử di chuyển
- Bản đồ gia đình/theo dõi (`/tracking`)
- Lịch sử hoạt động (`/activity-history`)
- Báo cáo hoạt động (`/activity-report`)
- Thống kê lịch sử (`/history-statistics`)
- Xem lại lộ trình (`/route-playback`)

## 5. Vùng an toàn (Safe Zone)
- Tổng quan vùng an toàn (`/safe-zone`)
- Cảnh báo vùng an toàn (`/safe-zone-alert`)
- Chọn thành viên cho vùng an toàn (`/safe-zone-select-member`)
- Trạng thái trống vùng an toàn (`/safe-zone-empty`)
- Thêm vùng an toàn (`/safe-zone-add`)
- Chi tiết vùng an toàn (`/safe-zone-detail`)
- Quy tắc thời gian (`/safe-zone-time-rules`)
- Chỉnh sửa vùng an toàn (`/safe-zone-edit`)
- Xác nhận xóa vùng an toàn (`/safe-zone-delete-confirm`)
- Cài đặt cảnh báo vùng an toàn (`/safe-zone-alert-settings`)
- Thông tin vùng an toàn (`/safe-zone-info`)
- Cấu hình vùng an toàn (`/safe-zone-config`)
- Vùng an toàn đang kích hoạt (`/safe-zone-active`)
- Chỉnh sửa vùng an toàn đang kích hoạt (`/safe-zone-edit-active`)

## 6. Nhắc nhở và check-in
- Nhắc nhở check-in (`/checkin-reminder`)
- Nhắc nhở check-in đã chọn (`/checkin-reminder-selected`)
- Quản lý nhắc nhở (`/reminder-management`)
- Danh sách nhắc nhở (`/reminder-list`)
- Danh sách nhắc nhở (chế độ sửa) (`/reminder-list-editable`)
- Danh sách nhắc nhở (chế độ xóa) (`/reminder-list-delete`)
- Chi tiết nhắc nhở (`/reminder-detail`)
- Xem chi tiết nhắc nhở (`/reminder-details-view`)
- Xem trước thông báo nhắc nhở (`/notification-preview`)
- Tạo nhắc nhở (`/create-reminder`)
- Tần suất lặp lại (`/repeat-frequency`)
- Ghi âm giọng nói (`/voice-recording`)

## 7. Liên lạc khẩn cấp và giao tiếp
- Danh bạ ưu tiên (`/priority-contacts`)
- Thêm liên hệ ưu tiên (`/add-priority-contact`)
- Gọi trong ứng dụng (`/in-app-call`)
- Danh sách đoạn chat (`/chat-list`)
- Cuộc trò chuyện (`/chat-conversation`)
- SOS (route đã khai báo: `/sos` - cần kiểm tra màn hình gán route)

## 8. Sức khỏe và cảm xúc
- Lịch hẹn y tế (`/medical-appointment`)
- Vận động thể chất (`/physical-activity`)
- Nhịp cảm xúc (`/emotion-pulse`)
- Nhật ký cảm xúc (`/emotion-journal`)

## 9. Các route đã khai báo nhưng chưa thấy mapping trong AppRouter
- `/sos`
- `/about`

## 10. Ghi chú kỹ thuật
- Ứng dụng khởi tạo với `initialRoute = /login` trong `lib/main.dart`.
- Toàn bộ route hiện được quản lý tập trung qua `AppRoutes` và `AppRouter`.
- Thư mục feature hiện có: `alerts`, `calling`, `chat`, `checkin_reminder`, `emotion`, `family_guard`, `home`, `kid_management`, `login`, `medical`, `member`, `member_management`, `notification`, `physical`, `priority_contacts`, `profile_security`, `reminder`, `safe_zone`, `settings`, `signup`, `splash`, `tracking`.

---
Cập nhật lần cuối: 2026-04-06
