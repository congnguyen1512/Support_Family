# Core Widgets Guide

## 1) Widget nào nên ở `core/widgets`

Đưa vào `core/widgets` khi widget:
- được dùng ở nhiều màn hình/feature,
- có cấu trúc và hành vi chung,
- chỉ khác nhau về dữ liệu hoặc style qua parameters.

Ví dụ phù hợp:
- button chung (`AppButton`, `AppPrimaryButton`)
- input/search chung (`AppTextInput`, `AppSearchField`)
- card container (`AppCardContainer`)
- avatar (`AppAvatar`)
- section title / field label (`AppSectionTitle`, `AppFieldLabel`)
- feedback chung (`AppLoading`, `AppEmptyState`, `AppStatusBadge`)

Giữ ở feature khi widget:
- chứa business logic riêng của màn hình,
- layout quá đặc thù chỉ dùng 1 nơi,
- phụ thuộc dữ liệu/domain cụ thể (map marker riêng, chart riêng, notification card riêng loại nghiệp vụ).

## 2) Cấu trúc đề xuất

```text
core/widgets/
  buttons/
    app_button.dart
  inputs/
    app_text_input.dart
    app_search_field.dart
  display/
    app_avatar.dart
    app_field_label.dart
    app_section_title.dart
  feedback/
    app_loading.dart
    app_empty_state.dart
    app_status_badge.dart
  layout/
    app_card_container.dart
  app_bottom_menu.dart
  app_primary_button.dart      # backward-compatible export
  app_text_input.dart          # backward-compatible export
  widgets.dart                 # barrel export
```

## 3) Ví dụ dùng ở các màn hình khác nhau

### Login screen

```dart
AppFieldLabel(text: 'Email'),
const SizedBox(height: 8),
AppTextInput(
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
  borderRadius: 8,
  fillColor: const Color(0xFFF5F8F8),
  enabledBorderColor: const Color(0xFF0F172A),
),
const SizedBox(height: 16),
AppPrimaryButton(
  label: 'Đăng nhập',
  onPressed: onLogin,
),
```

### Member / profile card

```dart
AppCardContainer(
  borderRadius: 18,
  padding: const EdgeInsets.all(14),
  child: Row(
    children: const [
      AppAvatar(initials: 'NA', size: 40),
      SizedBox(width: 12),
      Expanded(
        child: AppSectionTitle(
          title: 'Nguyễn An',
          subtitle: 'Đang hoạt động',
        ),
      ),
      AppStatusBadge(label: 'Online', type: AppStatusBadgeType.success),
    ],
  ),
)
```

### Search + empty state

```dart
AppSearchField(
  controller: searchController,
  hintText: 'Tìm thành viên',
  showClearButton: true,
),

AppEmptyState(
  title: 'Chưa có liên hệ ưu tiên',
  description: 'Thêm liên hệ để nhận hỗ trợ nhanh khi khẩn cấp.',
  action: AppButton(
    label: 'Thêm liên hệ',
    onPressed: onAdd,
  ),
)
```

### Loading state

```dart
const AppLoading(message: 'Đang tải dữ liệu...')
```

## 4) Lưu ý mở rộng

- Ưu tiên thêm `parameter` trước khi tạo widget mới.
- Không đưa logic nghiệp vụ (API, state domain) vào `core/widgets`.
- Nếu style dùng lặp nhiều, chuẩn hóa thêm ở `core/theme` hoặc `core/constants`.
