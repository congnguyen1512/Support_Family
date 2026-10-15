import React, { useRef, useState } from 'react';
import { Image, Pressable, ScrollView, StyleSheet, TextInput, View } from 'react-native';
import { Redirect, useRouter } from 'expo-router';
import { useTheme } from '../theme/ThemeProvider';
import { gradient, shadow, web } from '../theme/web';
import { Button, Field, Icon, T, TextField } from '../components/ui';
import { authApi } from '../api/endpoints';
import { ApiError, getApiBaseUrl } from '../api/client';
import { useAuthStore } from '../store/auth';
import { useUiStore } from '../store/ui';
import { useBreakpoint } from '../hooks/common';
import { queryClient } from '../api/hooks';

const FEATURES = [
  { icon: 'map', title: 'Bản đồ trực tiếp', text: 'Vị trí cả nhà, lộ trình & vùng an toàn trên một màn hình lớn.' },
  { icon: 'warning', title: 'Cảnh báo té ngã tức thì', text: 'Âm báo + thông báo desktop ngay khi có sự cố.' },
  { icon: 'flash', title: 'Thao tác siêu nhanh', text: 'Ctrl+K, phím tắt Alt+1…9, tạo nhắc nhở chỉ vài giây.' },
];

const LOGO = require('../../assets/images/logo.png');

export default function LoginScreen() {
  const c = useTheme();
  const router = useRouter();
  const { isMobile, isDesktop } = useBreakpoint();
  const session = useAuthStore((s) => s.session);
  const setSession = useAuthStore((s) => s.setSession);
  const themeMode = useUiStore((s) => s.themeMode);
  const setThemeMode = useUiStore((s) => s.setThemeMode);
  const [identifier, setIdentifier] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const passwordRef = useRef<TextInput>(null);

  if (session) return <Redirect href="/" />;

  const submit = async () => {
    if (!identifier.trim() || !password) {
      setError('Vui lòng nhập email / số điện thoại và mật khẩu.');
      return;
    }
    setLoading(true);
    setError(null);
    try {
      const res = await authApi.login(identifier.trim(), password);
      if (res.profile?.role !== 'nguoichamsoc') {
        setError('Tài khoản này không phải vai trò Người chăm sóc. Bản web chỉ dành cho người chăm sóc — vui lòng dùng ứng dụng di động.');
        return;
      }
      queryClient.clear();
      setSession({
        accessToken: res.access_token,
        refreshToken: res.refresh_token,
        expiresAt: res.expires_at,
        userId: res.user.id,
        email: res.user.email,
        profile: { ...res.profile, age: res.age, home_type: res.home_type },
      });
      router.replace('/');
    } catch (e) {
      const msg = e instanceof ApiError || e instanceof Error ? e.message : 'Đăng nhập thất bại.';
      if (/invalid login credentials/i.test(msg)) setError('Sai email / số điện thoại hoặc mật khẩu.');
      else if (/email not confirmed/i.test(msg)) setError('Email chưa được xác thực. Vui lòng kiểm tra hộp thư.');
      else setError(msg);
    } finally {
      setLoading(false);
    }
  };

  const isDark = c.mode === 'dark';

  return (
    <View style={[styles.root, { backgroundColor: c.bg }]}>
      {isDesktop ? (
        <View style={[styles.hero, gradient('#062A2E', '#14245A', 145)]}>
          <View style={[styles.orb, { width: 520, height: 520, left: -160, top: -180, backgroundColor: 'rgba(25,195,201,0.25)' }]} />
          <View style={[styles.orb, { width: 420, height: 420, right: -140, bottom: -140, backgroundColor: 'rgba(124,92,255,0.25)' }]} />

          <View style={styles.brandRow}>
            <View style={[styles.logo, shadow(3, 'rgba(25,195,201,0.45)')]}>
              <Image source={LOGO} style={styles.logoImg} resizeMode="contain" accessibilityLabel="Logo Support Family" />
            </View>
            <View>
              <T variant="h2" style={{ color: '#fff' }}>
                Support Family
              </T>
              <T variant="caption" style={{ color: 'rgba(255,255,255,0.6)' }}>
                Caregiver Web · Bảng điều khiển người chăm sóc
              </T>
            </View>
          </View>

          <View style={{ flex: 1, justifyContent: 'center', gap: 28, maxWidth: 640 }}>
            <View dataSet={{ anim: 'rise' }} style={{ gap: 12 }}>
              <T variant="hero" style={{ color: '#fff', fontSize: 40, lineHeight: 50 }}>
                Chăm sóc người thân,{'\n'}
                <T variant="hero" style={{ color: '#5EE6EA', fontSize: 40, lineHeight: 50 }}>
                  ngay trên máy tính.
                </T>
              </T>
              <T variant="body" style={{ color: 'rgba(255,255,255,0.72)', fontSize: 17, lineHeight: 26, maxWidth: 540 }}>
                Theo dõi vị trí, nhận cảnh báo khẩn cấp và quản lý lịch chăm sóc của cả gia đình — nhanh gọn trong lúc bạn đang làm việc.
              </T>
            </View>

            <View dataSet={{ anim: 'float' }} style={[styles.heroImageWrap, shadow(4, 'rgba(0,0,0,0.45)')]}>
              <Image source={require('../../assets/images/login-hero.jpg')} style={styles.heroImage} resizeMode="cover" accessibilityLabel="Gia đình được chăm sóc an toàn" />
            </View>

            <View style={{ flexDirection: 'row', gap: 14, flexWrap: 'wrap' }}>
              {FEATURES.map((f, i) => (
                <View key={f.title} dataSet={{ anim: 'rise', delay: String(i + 2) }} style={[styles.feature, web({ backdropFilter: 'blur(10px)' })]}>
                  <View style={styles.featureIcon}>
                    <Icon name={f.icon} size={17} color="#5EE6EA" />
                  </View>
                  <T variant="bodyStrong" style={{ color: '#fff' }}>
                    {f.title}
                  </T>
                  <T variant="caption" style={{ color: 'rgba(255,255,255,0.62)', lineHeight: 19 }}>
                    {f.text}
                  </T>
                </View>
              ))}
            </View>
          </View>

          <T variant="caption" style={{ color: 'rgba(255,255,255,0.4)' }}>
            © {new Date().getFullYear()} Support Family · Đồng hành cùng gia đình bạn
          </T>
        </View>
      ) : null}

      <ScrollView style={{ flex: 1 }} contentContainerStyle={[styles.formWrap, { padding: isMobile ? 20 : 48 }]}>
        <View style={styles.topRight}>
          <Pressable
            nativeID="login-theme-toggle"
            onPress={() => setThemeMode(isDark ? 'light' : 'dark')}
            accessibilityLabel="Đổi giao diện"
            style={[styles.themeBtn, { borderColor: c.border, backgroundColor: c.surface }, web({ cursor: 'pointer' })]}
          >
            <Icon name={isDark ? 'sunny-outline' : 'moon-outline'} size={17} color="textSoft" />
            <T variant="small" color="textSoft">
              {themeMode === 'dark' ? 'Sáng' : 'Tối'}
            </T>
          </Pressable>
        </View>

        <View dataSet={{ anim: 'rise' }} style={[styles.card, { backgroundColor: c.surface, borderColor: c.border }, shadow(3, c.shadow)]}>
          {!isDesktop ? (
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12, marginBottom: 6 }}>
              <View style={[styles.logo, { borderWidth: 1, borderColor: c.border }]}>
                <Image source={LOGO} style={styles.logoImg} resizeMode="contain" accessibilityLabel="Logo Support Family" />
              </View>
              <T variant="h2">Support Family</T>
            </View>
          ) : null}
          <View style={{ gap: 6 }}>
            <T variant="display">Đăng nhập</T>
            <T variant="body" color="textMuted">
              Dành cho tài khoản <T variant="bodyStrong" color="primary">Người chăm sóc</T>. Dùng cùng tài khoản với ứng dụng di động.
            </T>
          </View>

          {error ? (
            <View dataSet={{ anim: 'shake' }} style={[styles.error, { backgroundColor: c.dangerSoft, borderColor: c.danger }]}>
              <Icon name="alert-circle" size={18} color="danger" />
              <T variant="small" color="danger" style={{ flex: 1 }}>
                {error}
              </T>
            </View>
          ) : null}

          <Field label="Email hoặc số điện thoại" required>
            <TextField
              nativeID="login-identifier"
              icon="person-outline"
              value={identifier}
              onChangeText={setIdentifier}
              placeholder="vd: an.nguyen@gmail.com"
              autoCapitalize="none"
              autoComplete="username"
              autoFocus
              returnKeyType="next"
              onSubmitEditing={() => passwordRef.current?.focus()}
              height={48}
            />
          </Field>

          <Field label="Mật khẩu" required>
            <TextField
              ref={passwordRef}
              nativeID="login-password"
              icon="lock-closed-outline"
              value={password}
              onChangeText={setPassword}
              placeholder="••••••••"
              secureTextEntry={!showPassword}
              autoComplete="current-password"
              returnKeyType="go"
              onSubmitEditing={submit}
              height={48}
              right={
                <Pressable
                  nativeID="login-toggle-password"
                  onPress={() => setShowPassword((v) => !v)}
                  accessibilityLabel={showPassword ? 'Ẩn mật khẩu' : 'Hiện mật khẩu'}
                  style={web({ cursor: 'pointer' })}
                >
                  <Icon name={showPassword ? 'eye-off-outline' : 'eye-outline'} size={18} color="textMuted" />
                </Pressable>
              }
            />
          </Field>

          <Button nativeID="login-submit" label="Đăng nhập" icon="log-in-outline" size="lg" full loading={loading} onPress={submit} hint="Enter" />

          <View style={[styles.serverRow, { backgroundColor: c.surfaceAlt, borderColor: c.border }]}>
            <Icon name="server-outline" size={15} color="textMuted" />
            <T variant="caption" color="textMuted" style={{ flex: 1 }} numberOfLines={1}>
              Máy chủ: {getApiBaseUrl()}
            </T>
          </View>
        </View>

        <View style={{ flexDirection: 'row', gap: 18, flexWrap: 'wrap', justifyContent: 'center', marginTop: 22 }}>
          {[
            ['lock-closed-outline', 'Kết nối bảo mật'],
            ['flash-outline', 'Cập nhật thời gian thực'],
            ['desktop-outline', 'Tối ưu cho máy tính'],
          ].map(([icon, label]) => (
            <View key={label} style={{ flexDirection: 'row', gap: 6, alignItems: 'center' }}>
              <Icon name={icon} size={14} color="textMuted" />
              <T variant="caption" color="textMuted">
                {label}
              </T>
            </View>
          ))}
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, flexDirection: 'row' },
  hero: { flex: 1.15, padding: 48, gap: 24, overflow: 'hidden' },
  orb: { position: 'absolute', borderRadius: 999, ...({ filter: 'blur(80px)' } as object) },
  brandRow: { flexDirection: 'row', alignItems: 'center', gap: 14 },
  logo: { width: 52, height: 52, borderRadius: 16, alignItems: 'center', justifyContent: 'center', backgroundColor: '#FFFFFF' },
  logoImg: { width: 38, height: 38 },
  heroImageWrap: { borderRadius: 26, overflow: 'hidden', borderWidth: 1, borderColor: 'rgba(255,255,255,0.12)', maxWidth: 560 },
  heroImage: { width: '100%', aspectRatio: 4 / 3, maxHeight: 340 },
  feature: {
    flex: 1,
    minWidth: 170,
    padding: 16,
    gap: 6,
    borderRadius: 18,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.1)',
  },
  featureIcon: { width: 34, height: 34, borderRadius: 10, backgroundColor: 'rgba(94,230,234,0.14)', alignItems: 'center', justifyContent: 'center', marginBottom: 4 },
  formWrap: { flexGrow: 1, alignItems: 'center', justifyContent: 'center' },
  topRight: { position: 'absolute', top: 20, right: 20 },
  themeBtn: { flexDirection: 'row', alignItems: 'center', gap: 6, borderWidth: 1, borderRadius: 999, paddingHorizontal: 12, height: 34 },
  card: { width: '100%', maxWidth: 440, padding: 32, borderRadius: 28, borderWidth: 1, gap: 18 },
  error: { flexDirection: 'row', gap: 10, alignItems: 'flex-start', padding: 12, borderRadius: 12, borderWidth: 1 },
  serverRow: { flexDirection: 'row', gap: 8, alignItems: 'center', paddingHorizontal: 12, paddingVertical: 8, borderRadius: 10, borderWidth: 1 },
});
