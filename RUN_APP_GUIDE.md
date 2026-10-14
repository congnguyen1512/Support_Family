# FamilyGuard Run Guide

## 1. Chạy Backend

Mở terminal tại thư mục `BE`:

```powershell
cd BE
npm run dev
```

Backend hiện chạy ở:

```text
http://0.0.0.0:3000
```

API app dùng:

```text
http://<host>:3000/api
```

## 2. Chạy Trên Android Emulator

Không cần `adb reverse`.

```powershell
flutter run -d emulator-5554
```

App sẽ tự dùng:

```text
http://10.0.2.2:3000/api
```

## 3. Chạy Trên Điện Thoại Android Thật Qua USB

Bật:

- `Developer options`
- `USB debugging`

Kiểm tra thiết bị:

```powershell
adb devices
```

Thiết bị hiện tại của bạn:

```text
f16106a3
```

Mở reverse cổng:

```powershell
adb -s f16106a3 reverse tcp:3000 tcp:3000
```

Chạy app:

```powershell
flutter run -d f16106a3
```

App sẽ tự dùng:

```text
http://127.0.0.1:3000/api
```

`adb reverse` sẽ map `127.0.0.1:3000` trên điện thoại về máy tính của bạn.

## 4. Chạy Trên Điện Thoại Android Thật Qua Wi-Fi

Điện thoại và laptop phải cùng mạng Wi-Fi.

IP Wi-Fi hiện tại của máy bạn:

```text
192.168.1.14
```

Chạy app với `dart-define`:

```powershell
flutter run --dart-define=FAMILY_GUARD_API_BASE_URL=http://192.168.1.14:3000/api
```

Nếu chọn đúng thiết bị thật:

```powershell
flutter run -d f16106a3 --dart-define=FAMILY_GUARD_API_BASE_URL=http://192.168.1.14:3000/api
```

## 5. Khi Có Nhiều Thiết Bị Cùng Kết Nối

Xem danh sách:

```powershell
adb devices
flutter devices
```

Chạy đúng thiết bị bằng `-d <device-id>`.

Ví dụ:

```powershell
flutter run -d emulator-5554
flutter run -d f16106a3
```

## 6. Lệnh Nhanh Nhất

### Emulator

Terminal 1:

```powershell
cd BE
npm run dev
```

Terminal 2:

```powershell
flutter run -d emulator-5554
```

### Điện thoại thật qua USB

Terminal 1:

```powershell
cd BE
npm run dev
```

Terminal 2:

```powershell
adb -s f16106a3 reverse tcp:3000 tcp:3000
flutter run -d f16106a3
```

### Điện thoại thật qua Wi-Fi

Terminal 1:

```powershell
cd BE
npm run dev
```

Terminal 2:

```powershell
flutter run -d f16106a3 --dart-define=FAMILY_GUARD_API_BASE_URL=http://192.168.1.14:3000/api
```

## 7. Lỗi Thường Gặp

### `adb.exe: more than one device/emulator`

Thêm `-s <serial>`:

```powershell
adb -s f16106a3 reverse tcp:3000 tcp:3000
```

### Điện thoại thật không gọi được backend

Kiểm tra:

- backend đang chạy chưa
- đã chạy `adb reverse` chưa
- hoặc nếu chạy Wi-Fi thì IP LAN có đúng không
- Windows Firewall có chặn Node/port `3000` không

### `127.0.0.1` không chạy trên máy thật qua Wi-Fi

Đúng, `127.0.0.1` chỉ dùng được khi có `adb reverse`.

Qua Wi-Fi bắt buộc dùng IP LAN, ví dụ:

```text
http://192.168.1.14:3000/api
```
