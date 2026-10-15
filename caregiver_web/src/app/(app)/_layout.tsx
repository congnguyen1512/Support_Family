import React from 'react';
import { Redirect, Slot } from 'expo-router';
import { AppShell } from '../../components/layout/AppShell';
import { useAuthStore } from '../../store/auth';

export default function AppLayout() {
  const session = useAuthStore((s) => s.session);
  if (!session) return <Redirect href="/login" />;
  return (
    <AppShell>
      <Slot />
    </AppShell>
  );
}
