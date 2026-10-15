export interface NavItem {
  key: string;
  label: string;
  href: string;
  icon: string;
  iconActive: string;
  shortcut?: string;
  description: string;
}

export interface NavGroup {
  title: string;
  items: NavItem[];
}

export const NAV_GROUPS: NavGroup[] = [
  {
    title: 'Giám sát',
    items: [
      { key: 'dashboard', label: 'Tổng quan', href: '/', icon: 'grid-outline', iconActive: 'grid', shortcut: '1', description: 'Tình hình gia đình hôm nay' },
      { key: 'map', label: 'Bản đồ trực tiếp', href: '/map', icon: 'map-outline', iconActive: 'map', shortcut: '2', description: 'Vị trí & lộ trình di chuyển' },
      { key: 'notifications', label: 'Thông báo', href: '/notifications', icon: 'notifications-outline', iconActive: 'notifications', shortcut: '0', description: 'Cảnh báo, lời mời, vùng an toàn' },
    ],
  },
  {
    title: 'Gia đình',
    items: [
      { key: 'members', label: 'Thành viên', href: '/members', icon: 'people-outline', iconActive: 'people', shortcut: '3', description: 'Hồ sơ & mời người thân' },
      { key: 'messages', label: 'Tin nhắn', href: '/messages', icon: 'chatbubbles-outline', iconActive: 'chatbubbles', shortcut: '9', description: 'Trò chuyện với người thân' },
    ],
  },
  {
    title: 'Chăm sóc',
    items: [
      { key: 'reminders', label: 'Nhắc nhở', href: '/reminders', icon: 'alarm-outline', iconActive: 'alarm', shortcut: '5', description: 'Lịch uống thuốc, ăn uống, sinh hoạt' },
      { key: 'appointments', label: 'Lịch khám', href: '/appointments', icon: 'medkit-outline', iconActive: 'medkit', shortcut: '6', description: 'Lịch hẹn tái khám, bác sĩ' },
      { key: 'activities', label: 'Vận động', href: '/activities', icon: 'walk-outline', iconActive: 'walk', shortcut: '7', description: 'Bước chân, calo, bài tập' },
      { key: 'health', label: 'Báo cáo sức khỏe', href: '/health', icon: 'pulse-outline', iconActive: 'pulse', shortcut: '8', description: 'Tỷ lệ tuân thủ & nhật ký' },
      { key: 'safe-zones', label: 'Vùng an toàn', href: '/safe-zones', icon: 'shield-checkmark-outline', iconActive: 'shield-checkmark', shortcut: '4', description: 'Geofence & cảnh báo ra/vào' },
    ],
  },
];

export const SETTINGS_NAV: NavItem = {
  key: 'settings',
  label: 'Cài đặt',
  href: '/settings',
  icon: 'settings-outline',
  iconActive: 'settings',
  description: 'Hồ sơ, giao diện, liên hệ khẩn cấp',
};

export const ALL_NAV: NavItem[] = [...NAV_GROUPS.flatMap((g) => g.items), SETTINGS_NAV];

export function isActive(pathname: string, href: string) {
  if (href === '/') return pathname === '/' || pathname === '';
  return pathname === href || pathname.startsWith(`${href}/`);
}
