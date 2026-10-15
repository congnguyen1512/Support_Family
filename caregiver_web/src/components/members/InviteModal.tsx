import React, { useEffect, useState } from 'react';
import { Pressable, View } from 'react-native';
import { useTheme } from '../../theme/ThemeProvider';
import { transition, web, type WebPressState } from '../../theme/web';
import { Avatar, Badge, Button, EmptyState, Field, Icon, Loader, Modal, SearchInput, SelectField, T, TextField } from '../ui';
import { profileApi, relationshipApi } from '../../api/endpoints';
import { qk, useApiMutation } from '../../api/hooks';
import { useDebounce } from '../../hooks/common';
import { RELATION_OPTIONS, resolveReverseRelation } from '../../utils/constants';
import type { SearchUser } from '../../api/types';

/** Mời người thân: tìm theo email / SĐT → chọn quan hệ → gửi lời mời. */
export function InviteModal({ visible, onClose, existingUids }: { visible: boolean; onClose: () => void; existingUids: string[] }) {
  const c = useTheme();
  const [query, setQuery] = useState('');
  const q = useDebounce(query.trim(), 350);
  const [results, setResults] = useState<SearchUser[]>([]);
  const [searching, setSearching] = useState(false);
  const [searchError, setSearchError] = useState<string | null>(null);
  const [picked, setPicked] = useState<SearchUser | null>(null);
  const [relation, setRelation] = useState('');
  const [reverse, setReverse] = useState('');

  useEffect(() => {
    if (!visible) {
      setQuery('');
      setResults([]);
      setPicked(null);
      setRelation('');
      setReverse('');
    }
  }, [visible]);

  useEffect(() => {
    if (q.length < 2) {
      setResults([]);
      setSearchError(null);
      return;
    }
    let cancelled = false;
    setSearching(true);
    profileApi
      .searchUsers(q)
      .then((r) => !cancelled && (setResults(r ?? []), setSearchError(null)))
      .catch((e) => !cancelled && setSearchError(e.message))
      .finally(() => !cancelled && setSearching(false));
    return () => {
      cancelled = true;
    };
  }, [q]);

  const invite = useApiMutation(relationshipApi.invite, {
    invalidate: [qk.relationships],
    success: 'Đã gửi lời mời. Người thân cần xác nhận trên ứng dụng.',
    errorTitle: 'Không gửi được lời mời',
    onSuccess: onClose,
  });

  const submit = () => {
    if (!picked || !relation) return;
    invite.mutate({ target_uid: picked.uid, relation_type: relation, reverse_relation_type: reverse || resolveReverseRelation(relation) });
  };

  return (
    <Modal
      visible={visible}
      onClose={onClose}
      title="Mời thành viên"
      subtitle="Tìm tài khoản Support Family của người thân qua email hoặc số điện thoại"
      icon="person-add"
      width={600}
      footer={
        <>
          <Button label="Hủy" variant="secondary" onPress={onClose} />
          <Button nativeID="invite-submit" label="Gửi lời mời" icon="paper-plane" disabled={!picked || !relation} loading={invite.isPending} onPress={submit} />
        </>
      }
    >
      {!picked ? (
        <>
          <SearchInput nativeID="invite-search" value={query} onChangeText={setQuery} placeholder="Nhập email hoặc số điện thoại (≥ 2 ký tự)" autoFocus />
          <View style={{ minHeight: 200, gap: 6 }}>
            {searching ? (
              <Loader label="Đang tìm..." />
            ) : searchError ? (
              <EmptyState compact icon="alert-circle-outline" title="Lỗi tìm kiếm" description={searchError} />
            ) : q.length < 2 ? (
              <EmptyState compact icon="search-outline" title="Tìm người thân" description="Người được mời sẽ nhận thông báo và cần xác nhận trên ứng dụng di động." />
            ) : results.length === 0 ? (
              <EmptyState compact icon="person-outline" title="Không tìm thấy tài khoản" description="Hãy chắc chắn người thân đã đăng ký Support Family." />
            ) : (
              results.map((u) => {
                const existed = existingUids.includes(u.uid);
                return (
                  <Pressable
                    key={u.uid}
                    nativeID={`invite-user-${u.uid}`}
                    disabled={existed}
                    onPress={() => setPicked(u)}
                    style={(state) => {
                      const { hovered } = state as WebPressState;
                      return [
                        { flexDirection: 'row', alignItems: 'center', gap: 12, padding: 10, borderRadius: 14, borderWidth: 1, borderColor: c.border, opacity: existed ? 0.5 : 1 },
                        { backgroundColor: hovered && !existed ? c.surfaceHover : c.surface },
                        transition('background-color', 120),
                        web({ cursor: existed ? 'not-allowed' : 'pointer' }),
                      ];
                    }}
                  >
                    <Avatar name={u.name} uri={u.avata} size={40} />
                    <View style={{ flex: 1 }}>
                      <T variant="bodyStrong">{u.name || 'Chưa đặt tên'}</T>
                      <T variant="caption" color="textMuted">
                        {[u.email, u.phone].filter(Boolean).join(' · ')}
                      </T>
                    </View>
                    {existed ? (
                      <Badge label="Đã kết nối" color="success" size="sm" />
                    ) : (
                      <Badge label={u.role === 'nguoichamsoc' ? 'Người chăm sóc' : 'Được chăm sóc'} color={u.role === 'nguoichamsoc' ? 'accent' : 'primary'} size="sm" />
                    )}
                  </Pressable>
                );
              })
            )}
          </View>
        </>
      ) : (
        <>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12, padding: 12, borderRadius: 16, backgroundColor: c.primarySoft }}>
            <Avatar name={picked.name} uri={picked.avata} size={46} />
            <View style={{ flex: 1 }}>
              <T variant="bodyStrong">{picked.name}</T>
              <T variant="caption" color="textMuted">
                {[picked.email, picked.phone].filter(Boolean).join(' · ')}
              </T>
            </View>
            <Button label="Đổi" size="sm" variant="ghost" icon="swap-horizontal" onPress={() => setPicked(null)} />
          </View>
          <Field label={`${picked.name} là gì của bạn?`} required>
            <SelectField
              id="invite-relation"
              value={relation}
              placeholder="Chọn quan hệ"
              options={RELATION_OPTIONS.map((r) => ({ value: r, label: r }))}
              onChange={(v) => {
                setRelation(v);
                setReverse(resolveReverseRelation(v));
              }}
            />
          </Field>
          <Field label={`Bạn là gì của ${picked.name}?`} hint="Tự động gợi ý theo quan hệ đã chọn, có thể sửa.">
            <TextField nativeID="invite-reverse" value={reverse} onChangeText={setReverse} placeholder="vd: Con" icon="git-compare-outline" />
          </Field>
          <View style={{ flexDirection: 'row', gap: 8, alignItems: 'center' }}>
            <Icon name="information-circle-outline" size={16} color="info" />
            <T variant="caption" color="textMuted" style={{ flex: 1 }}>
              Sau khi người thân xác nhận, bạn có thể xem vị trí, tạo nhắc nhở và nhận cảnh báo té ngã.
            </T>
          </View>
        </>
      )}
    </Modal>
  );
}
