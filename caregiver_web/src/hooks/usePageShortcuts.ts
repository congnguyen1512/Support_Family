import { useEffect } from 'react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useHotkeys } from './common';

/**
 * Chuẩn hóa thao tác "tạo mới" trên mỗi trang:
 *  - phím N mở form tạo mới, phím / focus ô tìm kiếm
 *  - URL ?new=1&member=uid (từ Tạo nhanh / bảng lệnh) tự mở form
 */
export function usePageShortcuts({ onNew, searchId }: { onNew?: (memberUid?: string) => void; searchId?: string }) {
  const params = useLocalSearchParams<{ new?: string; member?: string }>();
  const router = useRouter();

  useEffect(() => {
    if (params.new === '1' && onNew) {
      onNew(params.member);
      router.setParams({ new: undefined, member: undefined } as any);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [params.new, params.member]);

  useHotkeys({
    ...(onNew ? { n: () => onNew() } : {}),
    ...(searchId ? { '/': () => (document.getElementById(searchId) as HTMLInputElement | null)?.focus() } : {}),
  });

  return { memberParam: params.member };
}
