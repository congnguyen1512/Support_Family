import React from 'react';
import { View } from 'react-native';
import { useRouter } from 'expo-router';
import { useTheme } from '../theme/ThemeProvider';
import { Button, EmptyState } from '../components/ui';

export default function NotFound() {
  const c = useTheme();
  const router = useRouter();
  return (
    <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: c.bg }}>
      <EmptyState
        icon="compass-outline"
        title="Không tìm thấy trang"
        description="Đường dẫn không tồn tại hoặc đã bị thay đổi."
        action={<Button label="Về trang tổng quan" icon="home-outline" onPress={() => router.replace('/')} />}
      />
    </View>
  );
}
