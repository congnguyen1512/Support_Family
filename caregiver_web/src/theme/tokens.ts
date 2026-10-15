/**
 * Design tokens cho Support Family Caregiver Web.
 * Giữ nhận diện thương hiệu teal (#00ACB2) giống bản mobile,
 * mở rộng thêm bảng màu cho dashboard (light / dark).
 */

export type ThemeMode = 'light' | 'dark';

export interface Palette {
  mode: ThemeMode;
  bg: string;
  bgGradient: [string, string];
  surface: string;
  surfaceAlt: string;
  surfaceHover: string;
  elevated: string;
  border: string;
  borderStrong: string;
  text: string;
  textSoft: string;
  textMuted: string;
  textInverse: string;
  primary: string;
  primaryHover: string;
  primarySoft: string;
  primaryGlow: string;
  accent: string;
  accentSoft: string;
  success: string;
  successSoft: string;
  warning: string;
  warningSoft: string;
  danger: string;
  dangerSoft: string;
  info: string;
  infoSoft: string;
  pink: string;
  pinkSoft: string;
  overlay: string;
  inputBg: string;
  sidebarFrom: string;
  sidebarTo: string;
  sidebarText: string;
  sidebarMuted: string;
  sidebarActive: string;
  shadow: string;
  mapTiles: string;
}

const brand = {
  teal: '#00ACB2',
  tealBright: '#19C3C9',
  tealDeep: '#008A8F',
  violet: '#7C5CFF',
};

export const lightPalette: Palette = {
  mode: 'light',
  bg: '#F3F7F8',
  bgGradient: ['#EEF7F7', '#F6F8FB'],
  surface: '#FFFFFF',
  surfaceAlt: '#F7FAFB',
  surfaceHover: '#F1F6F7',
  elevated: '#FFFFFF',
  border: '#E3EBEE',
  borderStrong: '#CBD8DD',
  text: '#0C1D1A',
  textSoft: '#33454B',
  textMuted: '#6B7C83',
  textInverse: '#FFFFFF',
  primary: brand.teal,
  primaryHover: brand.tealDeep,
  primarySoft: 'rgba(0, 172, 178, 0.10)',
  primaryGlow: 'rgba(0, 172, 178, 0.35)',
  accent: brand.violet,
  accentSoft: 'rgba(124, 92, 255, 0.10)',
  success: '#12B76A',
  successSoft: 'rgba(18, 183, 106, 0.12)',
  warning: '#F59E0B',
  warningSoft: 'rgba(245, 158, 11, 0.14)',
  danger: '#EF4444',
  dangerSoft: 'rgba(239, 68, 68, 0.11)',
  info: '#3B82F6',
  infoSoft: 'rgba(59, 130, 246, 0.11)',
  pink: '#EC4899',
  pinkSoft: 'rgba(236, 72, 153, 0.11)',
  overlay: 'rgba(8, 20, 24, 0.45)',
  inputBg: '#F5F8F9',
  sidebarFrom: '#0A2227',
  sidebarTo: '#0D3036',
  sidebarText: '#E7F4F5',
  sidebarMuted: '#86A5AA',
  sidebarActive: 'rgba(25, 195, 201, 0.16)',
  shadow: 'rgba(15, 40, 45, 0.08)',
  // OpenStreetMap – không cần API key (giống bản mobile)
  mapTiles: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
};

export const darkPalette: Palette = {
  mode: 'dark',
  bg: '#0A1114',
  bgGradient: ['#0A1316', '#0C1218'],
  surface: '#111B20',
  surfaceAlt: '#152229',
  surfaceHover: '#1A2930',
  elevated: '#16242B',
  border: '#1F3038',
  borderStrong: '#2B414B',
  text: '#E8F3F4',
  textSoft: '#BFD0D4',
  textMuted: '#829AA2',
  textInverse: '#06181B',
  primary: brand.tealBright,
  primaryHover: '#3AD3D8',
  primarySoft: 'rgba(25, 195, 201, 0.14)',
  primaryGlow: 'rgba(25, 195, 201, 0.35)',
  accent: '#9B83FF',
  accentSoft: 'rgba(155, 131, 255, 0.14)',
  success: '#32D583',
  successSoft: 'rgba(50, 213, 131, 0.14)',
  warning: '#FDB022',
  warningSoft: 'rgba(253, 176, 34, 0.14)',
  danger: '#F97066',
  dangerSoft: 'rgba(249, 112, 102, 0.14)',
  info: '#60A5FA',
  infoSoft: 'rgba(96, 165, 250, 0.14)',
  pink: '#F472B6',
  pinkSoft: 'rgba(244, 114, 182, 0.14)',
  overlay: 'rgba(0, 0, 0, 0.6)',
  inputBg: '#0E181C',
  sidebarFrom: '#071417',
  sidebarTo: '#0A1D21',
  sidebarText: '#E7F4F5',
  sidebarMuted: '#7D979C',
  sidebarActive: 'rgba(25, 195, 201, 0.16)',
  shadow: 'rgba(0, 0, 0, 0.35)',
  // Cùng nguồn OSM, tông tối được xử lý bằng CSS filter (.fg-tiles trong global.css)
  mapTiles: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
};

export const radius = {
  xs: 6,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 28,
  pill: 999,
};

export const space = {
  xxs: 2,
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  xxxl: 32,
};

export const fontFamily = {
  regular: '"Be Vietnam Pro", "Inter", system-ui, -apple-system, "Segoe UI", Roboto, sans-serif',
  mono: '"JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, Consolas, monospace',
};

export const fontSize = {
  xs: 12.5,
  sm: 14,
  md: 15.5,
  lg: 17.5,
  xl: 20,
  xxl: 24,
  display: 30,
  hero: 36,
};

export const breakpoints = {
  mobile: 760,
  tablet: 1100,
  wide: 1440,
};
