import React, { useEffect, useRef, useState } from 'react';
import { Pressable, View } from 'react-native';
import { useTheme } from '../../theme/ThemeProvider';
import { web } from '../../theme/web';
import { Avatar, Badge, Button, Card, CardHeader, DateField, Field, Icon, Kbd, Segmented, SelectField, Switch, T, TextField } from '../../components/ui';
import { confirm } from '../../components/ui/Overlay';
import { Col, Grid, Page } from '../../components/layout/Page';
import { authApi, profileApi, quickContactApi } from '../../api/endpoints';
import { qk, queryClient, useApiMutation, useFamilyMembers, useQuickContact } from '../../api/hooks';
import { getApiBaseUrl } from '../../api/client';
import { useAuthStore } from '../../store/auth';
import { useUiStore } from '../../store/ui';
import { toast } from '../../store/toast';
import { playAlarm } from '../../hooks/useAlertCenter';
import { useRouter } from 'expo-router';
import type { ThemeMode } from '../../theme/tokens';

const SHORTCUTS: [string, string][] = [
  ['Ctrl K', 'Bảng lệnh & tìm kiếm'],
  ['Alt 1…9, 0', 'Chuyển trang nhanh'],
  ['N', 'Tạo mới trên trang hiện tại'],
  ['/', 'Tìm trong trang'],
  ['Shift D', 'Đổi sáng / tối'],
  ['Ctrl B', 'Thu gọn thanh bên'],
  ['Esc', 'Đóng hộp thoại'],
];

export default function SettingsScreen() {
  const c = useTheme();
  const router = useRouter();
  const session = useAuthStore((s) => s.session);
  const updateProfile = useAuthStore((s) => s.updateProfile);
  const logout = useAuthStore((s) => s.logout);
  const ui = useUiStore();
  const { members } = useFamilyMembers();
  const quick = useQuickContact();
  const profile = session?.profile;
  const fileRef = useRef<HTMLInputElement | null>(null);

  const [name, setName] = useState(profile?.name ?? '');
  const [email, setEmail] = useState(profile?.email ?? '');
  const [phone, setPhone] = useState(profile?.phone ?? '');
  const [birthday, setBirthday] = useState(profile?.birthday?.slice(0, 10) ?? '');
  const [sex, setSex] = useState(profile?.sex ?? '');
  const [address, setAddress] = useState(profile?.address ?? '');
  const [uploading, setUploading] = useState(false);
  const [apiUrl, setApiUrl] = useState(ui.apiBaseUrlOverride);
  const [testing, setTesting] = useState(false);
  const [qcName, setQcName] = useState('');
  const [qcPhone, setQcPhone] = useState('');
  const [qcMember, setQcMember] = useState('');
  const [perm, setPerm] = useState<string>(typeof Notification !== 'undefined' ? Notification.permission : 'unsupported');

  useEffect(() => {
    profileApi
      .get()
      .then((p) => {
        updateProfile(p);
        setName(p.name ?? '');
        setEmail(p.email ?? '');
        setPhone(p.phone ?? '');
        setBirthday(p.birthday?.slice(0, 10) ?? '');
        setSex(p.sex ?? '');
        setAddress(p.address ?? '');
      })
      .catch(() => undefined);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    setQcName(quick.data?.name ?? '');
    setQcPhone(quick.data?.phone ?? '');
    setQcMember(quick.data?.member_uid ?? '');
  }, [quick.data]);

  const saveProfile = useApiMutation(profileApi.update, {
    invalidate: [qk.profile],
    success: 'Đã lưu hồ sơ',
    onSuccess: (p) => updateProfile(p),
  });
  const saveQc = useApiMutation(quickContactApi.save, { invalidate: [qk.quickContact], success: 'Đã lưu liên hệ khẩn cấp' });
  const removeQc = useApiMutation(() => quickContactApi.remove(), { invalidate: [qk.quickContact], success: 'Đã xóa liên hệ khẩn cấp' });

  const onPickFile = async (file?: File | null) => {
    if (!file) return;
    if (file.size > 5 * 1024 * 1024) return toast.error('Ảnh quá lớn', 'Vui lòng chọn ảnh nhỏ hơn 5MB.');
    setUploading(true);
    try {
      const base64 = await new Promise<string>((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(String(reader.result).split(',')[1] ?? '');
        reader.onerror = reject;
        reader.readAsDataURL(file);
      });
      const p = await profileApi.uploadAvatar({ fileName: file.name, mimeType: file.type, base64Data: base64 });
      updateProfile(p);
      toast.success('Đã cập nhật ảnh đại diện');
    } catch (e: any) {
      toast.error('Tải ảnh thất bại', e?.message);
    } finally {
      setUploading(false);
      if (fileRef.current) fileRef.current.value = '';
    }
  };

  const testConnection = async () => {
    ui.setApiBaseUrlOverride(apiUrl.trim());
    setTesting(true);
    try {
      await authApi.me();
      toast.success('Kết nối thành công', getApiBaseUrl());
      queryClient.invalidateQueries();
    } catch (e: any) {
      toast.error('Không kết nối được', e?.message);
    } finally {
      setTesting(false);
    }
  };

  const doLogout = async () => {
    if (!(await confirm({ title: 'Đăng xuất?', confirmLabel: 'Đăng xuất', icon: 'log-out-outline' }))) return;
    authApi.logout().catch(() => undefined);
    queryClient.clear();
    logout();
    router.replace('/login');
  };

  return (
    <Page title="Cài đặt" subtitle="Hồ sơ cá nhân, giao diện, cảnh báo và liên hệ khẩn cấp" maxWidth={1200}>
      <Grid>
        <Col flex={1.5} minWidth={420}>
          <Card anim="rise" delay={1}>
            <CardHeader title="Hồ sơ cá nhân" icon="person-circle" />
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 18, marginBottom: 18, flexWrap: 'wrap' }}>
              <Pressable onPress={() => fileRef.current?.click()} style={web({ cursor: 'pointer' })} accessibilityLabel="Đổi ảnh đại diện">
                <Avatar name={profile?.name} uri={profile?.avata} size={84} ring={c.primary} />
                <View style={{ position: 'absolute', right: -2, bottom: -2, width: 30, height: 30, borderRadius: 15, backgroundColor: c.primary, alignItems: 'center', justifyContent: 'center', borderWidth: 3, borderColor: c.surface }}>
                  <Icon name="camera" size={14} color="#fff" />
                </View>
              </Pressable>
              <View style={{ flex: 1, gap: 4 }}>
                <T variant="h2">{profile?.name || 'Người chăm sóc'}</T>
                <View style={{ flexDirection: 'row', gap: 6 }}>
                  <Badge label="Người chăm sóc" color="primary" icon="shield-checkmark" size="sm" />
                  <Badge label={`${members.length} thành viên`} color="accent" size="sm" />
                </View>
                <Button nativeID="settings-avatar" label={uploading ? 'Đang tải...' : 'Đổi ảnh đại diện'} icon="image-outline" size="sm" variant="ghost" loading={uploading} onPress={() => fileRef.current?.click()} />
              </View>
              <input ref={fileRef} type="file" accept="image/*" style={{ display: 'none' }} onChange={(e) => onPickFile(e.target.files?.[0])} />
            </View>
            <View style={{ gap: 14 }}>
              <View style={{ flexDirection: 'row', gap: 12, flexWrap: 'wrap' }}>
                <Field label="Họ và tên" style={{ flex: 1, minWidth: 220 }}>
                  <TextField nativeID="settings-name" value={name} onChangeText={setName} icon="person-outline" />
                </Field>
                <Field label="Số điện thoại" style={{ flex: 1, minWidth: 200 }}>
                  <TextField nativeID="settings-phone" value={phone} onChangeText={setPhone} icon="call-outline" keyboardType="phone-pad" />
                </Field>
              </View>
              <View style={{ flexDirection: 'row', gap: 12, flexWrap: 'wrap' }}>
                <Field label="Email" style={{ flex: 1, minWidth: 220 }}>
                  <TextField nativeID="settings-email" value={email} onChangeText={setEmail} icon="mail-outline" autoCapitalize="none" />
                </Field>
                <Field label="Ngày sinh" style={{ width: 200 }}>
                  <DateField id="settings-birthday" value={birthday} onChange={setBirthday} />
                </Field>
                <Field label="Giới tính" style={{ width: 150 }}>
                  <SelectField id="settings-sex" value={sex} onChange={setSex} placeholder="Chọn" options={[{ value: 'Nam', label: 'Nam' }, { value: 'Nữ', label: 'Nữ' }, { value: 'Khác', label: 'Khác' }]} />
                </Field>
              </View>
              <Field label="Địa chỉ">
                <TextField nativeID="settings-address" value={address} onChangeText={setAddress} icon="home-outline" />
              </Field>
              <View style={{ flexDirection: 'row', justifyContent: 'flex-end' }}>
                <Button
                  nativeID="settings-save-profile"
                  label="Lưu hồ sơ"
                  icon="checkmark"
                  loading={saveProfile.isPending}
                  onPress={() =>
                    saveProfile.mutate({
                      name: name.trim() || undefined,
                      email: email.trim() || undefined,
                      phone: phone.trim() || undefined,
                      birthday: birthday || undefined,
                      sex: sex || undefined,
                      address: address.trim() || undefined,
                    })
                  }
                />
              </View>
            </View>
          </Card>

          <Card anim="rise" delay={3}>
            <CardHeader title="Liên hệ khẩn cấp" subtitle="Hiển thị nút gọi nhanh trên ứng dụng của người thân" icon="call" iconColor="danger" />
            <View style={{ gap: 14 }}>
              <View style={{ flexDirection: 'row', gap: 12, flexWrap: 'wrap' }}>
                <Field label="Tên liên hệ" style={{ flex: 1, minWidth: 200 }}>
                  <TextField nativeID="qc-name" value={qcName} onChangeText={setQcName} placeholder="vd: Con trai - Minh" icon="person-outline" />
                </Field>
                <Field label="Số điện thoại" style={{ flex: 1, minWidth: 180 }}>
                  <TextField nativeID="qc-phone" value={qcPhone} onChangeText={setQcPhone} placeholder="09xx xxx xxx" icon="call-outline" keyboardType="phone-pad" />
                </Field>
              </View>
              <Field label="Liên kết với thành viên" hint="Không bắt buộc">
                <SelectField id="qc-member" value={qcMember} onChange={setQcMember} placeholder="Không liên kết" options={members.map((m) => ({ value: m.uid, label: `${m.name} (${m.relation})` }))} />
              </Field>
              <View style={{ flexDirection: 'row', justifyContent: 'flex-end', gap: 8 }}>
                {quick.data ? (
                  <Button label="Xóa" icon="trash-outline" variant="dangerSoft" loading={removeQc.isPending} onPress={async () => { if (await confirm({ title: 'Xóa liên hệ khẩn cấp?', confirmLabel: 'Xóa' })) removeQc.mutate(); }} />
                ) : null}
                <Button
                  nativeID="qc-save"
                  label="Lưu liên hệ"
                  icon="checkmark"
                  disabled={!qcName.trim() || qcPhone.trim().length < 8}
                  loading={saveQc.isPending}
                  onPress={() => saveQc.mutate({ name: qcName.trim(), phone: qcPhone.trim(), member_uid: qcMember || null })}
                />
              </View>
            </View>
          </Card>
        </Col>

        <Col minWidth={340}>
          <Card anim="rise" delay={2}>
            <CardHeader title="Giao diện" icon="color-palette" iconColor="accent" />
            <View style={{ gap: 14 }}>
              <Segmented<ThemeMode | 'system'>
                value={ui.themeMode}
                onChange={ui.setThemeMode}
                options={[
                  { value: 'light', label: 'Sáng', icon: 'sunny-outline' },
                  { value: 'dark', label: 'Tối', icon: 'moon-outline' },
                  { value: 'system', label: 'Theo hệ thống', icon: 'desktop-outline' },
                ]}
              />
              <SettingRow title="Thu gọn thanh bên" desc="Dành thêm không gian cho nội dung" value={ui.sidebarCollapsed} onChange={() => ui.toggleSidebar()} />
            </View>
          </Card>

          <Card anim="rise" delay={3}>
            <CardHeader title="Cảnh báo" icon="notifications" iconColor="warning" />
            <View style={{ gap: 14 }}>
              <SettingRow title="Âm thanh cảnh báo" desc="Phát âm báo khi có thông báo mới / té ngã" value={ui.soundEnabled} onChange={ui.setSoundEnabled} />
              <SettingRow
                title="Thông báo trên desktop"
                desc={perm === 'granted' ? 'Trình duyệt đã cho phép' : perm === 'denied' ? 'Bị chặn — hãy bật trong cài đặt trình duyệt' : 'Cần cấp quyền cho trình duyệt'}
                value={ui.desktopNotify}
                onChange={(v) => {
                  ui.setDesktopNotify(v);
                  if (v && typeof Notification !== 'undefined' && Notification.permission === 'default') Notification.requestPermission().then(setPerm);
                }}
              />
              <View style={{ flexDirection: 'row', gap: 8, flexWrap: 'wrap' }}>
                <Button label="Thử âm báo té ngã" icon="volume-high-outline" size="sm" variant="secondary" onPress={() => playAlarm('fall')} />
                <Button
                  label="Thử thông báo"
                  icon="desktop-outline"
                  size="sm"
                  variant="secondary"
                  onPress={async () => {
                    if (typeof Notification === 'undefined') return toast.error('Trình duyệt không hỗ trợ thông báo');
                    const p = Notification.permission === 'default' ? await Notification.requestPermission() : Notification.permission;
                    setPerm(p);
                    if (p === 'granted') new Notification('Support Family', { body: 'Thông báo desktop đang hoạt động ✅' });
                    else toast.warning('Chưa được cấp quyền thông báo');
                  }}
                />
              </View>
            </View>
          </Card>

          <Card anim="rise" delay={4}>
            <CardHeader title="Kết nối máy chủ" icon="server" iconColor="info" />
            <View style={{ gap: 12 }}>
              <Field label="Địa chỉ API" hint={`Để trống để dùng mặc định: ${process.env.EXPO_PUBLIC_API_BASE_URL || 'http://localhost:3000/api'}`}>
                <TextField nativeID="settings-api-url" value={apiUrl} onChangeText={setApiUrl} placeholder="http://192.168.1.10:3000/api" icon="link-outline" autoCapitalize="none" />
              </Field>
              <Button nativeID="settings-test-api" label="Lưu & kiểm tra kết nối" icon="pulse-outline" variant="soft" loading={testing} onPress={testConnection} />
            </View>
          </Card>

          <Card anim="rise" delay={5}>
            <CardHeader title="Phím tắt" icon="keypad" />
            <View style={{ gap: 10 }}>
              {SHORTCUTS.map(([k, d]) => (
                <View key={k} style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
                  <T variant="small" color="textSoft">
                    {d}
                  </T>
                  <Kbd>{k}</Kbd>
                </View>
              ))}
            </View>
          </Card>

          <Button nativeID="settings-logout" label="Đăng xuất" icon="log-out-outline" variant="dangerSoft" full onPress={doLogout} />
        </Col>
      </Grid>
    </Page>
  );
}

function SettingRow({ title, desc, value, onChange }: { title: string; desc: string; value: boolean; onChange: (v: boolean) => void }) {
  return (
    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
      <View style={{ flex: 1 }}>
        <T variant="bodyStrong">{title}</T>
        <T variant="caption" color="textMuted">
          {desc}
        </T>
      </View>
      <Switch value={value} onChange={onChange} label={title} />
    </View>
  );
}
