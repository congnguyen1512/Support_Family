import React, { useEffect, useMemo, useState } from 'react';
import { View } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTheme } from '../../theme/ThemeProvider';
import { Avatar, Badge, Button, Card, EmptyState, Icon, SearchInput, Segmented, Skeleton, StatusDot, T } from '../../components/ui';
import { confirm } from '../../components/ui/Overlay';
import { Grid, Page } from '../../components/layout/Page';
import { InviteModal } from '../../components/members/InviteModal';
import { MemberDetail } from '../../components/members/MemberDetail';
import { presenceColor, presenceLabel } from '../../components/map/presence';
import { qk, useApiMutation, useFamilyMembers } from '../../api/hooks';
import { relationshipApi } from '../../api/endpoints';
import { useHotkeys } from '../../hooks/common';
import { normalizeSearch, relativeTime } from '../../utils/format';
import { MEMBER_KIND_META } from '../../utils/constants';
import type { MemberKind } from '../../api/types';

type Filter = 'all' | MemberKind | 'pending';

export default function MembersScreen() {
  const c = useTheme();
  const router = useRouter();
  const params = useLocalSearchParams<{ uid?: string; invite?: string }>();
  const { members, pending, isLoading, refetch, isFetching } = useFamilyMembers();
  const [query, setQuery] = useState('');
  const [filter, setFilter] = useState<Filter>('all');
  const [detailUid, setDetailUid] = useState<string | null>(params.uid ?? null);
  const [inviteOpen, setInviteOpen] = useState(params.invite === '1');

  useEffect(() => {
    if (params.uid) setDetailUid(params.uid);
    if (params.invite === '1') setInviteOpen(true);
  }, [params.uid, params.invite]);

  useHotkeys({ n: () => setInviteOpen(true) });

  const cancelInvite = useApiMutation((id: number) => relationshipApi.remove(id), { invalidate: [qk.relationships], success: 'Đã hủy lời mời' });

  const list = useMemo(() => {
    const q = normalizeSearch(query);
    return members.filter(
      (m) => (filter === 'all' || filter === m.kind) && (!q || normalizeSearch(`${m.name} ${m.relation} ${m.phone ?? ''} ${m.email ?? ''}`).includes(q)),
    );
  }, [members, query, filter]);

  const counts = {
    child: members.filter((m) => m.kind === 'child').length,
    senior: members.filter((m) => m.kind === 'senior').length,
    adult: members.filter((m) => m.kind === 'adult').length,
  };

  const closeDetail = () => {
    setDetailUid(null);
    if (params.uid) router.setParams({ uid: undefined } as any);
  };
  const closeInvite = () => {
    setInviteOpen(false);
    if (params.invite) router.setParams({ invite: undefined } as any);
  };

  return (
    <Page
      title="Thành viên gia đình"
      subtitle={`${members.length} người thân đã kết nối${pending.length ? ` · ${pending.length} lời mời đang chờ` : ''}`}
      onRefresh={refetch}
      refreshing={isFetching && !isLoading}
      actions={<Button nativeID="members-invite" label="Mời thành viên" icon="person-add" hint="N" onPress={() => setInviteOpen(true)} />}
    >
      <View style={{ flexDirection: 'row', gap: 12, flexWrap: 'wrap', alignItems: 'center' }}>
        <SearchInput nativeID="members-search" value={query} onChangeText={setQuery} placeholder="Tìm theo tên, quan hệ, SĐT..." style={{ flex: 1, minWidth: 240, maxWidth: 420 }} />
        <Segmented<Filter>
          value={filter}
          onChange={setFilter}
          options={[
            { value: 'all', label: 'Tất cả', count: members.length },
            { value: 'senior', label: 'Cao tuổi', icon: 'heart-outline', count: counts.senior },
            { value: 'child', label: 'Trẻ em', icon: 'happy-outline', count: counts.child },
            { value: 'adult', label: 'Người lớn', icon: 'person-outline', count: counts.adult },
            { value: 'pending', label: 'Đang chờ', icon: 'hourglass-outline', count: pending.length },
          ]}
        />
      </View>

      {filter === 'pending' ? (
        pending.length === 0 ? (
          <Card>
            <EmptyState icon="mail-open-outline" title="Không có lời mời đang chờ" description="Lời mời đã gửi sẽ hiển thị tại đây cho đến khi người thân xác nhận." />
          </Card>
        ) : (
          <Grid gap={16}>
            {pending.map((p, i) => (
              <Card key={p.id} anim="rise" delay={Math.min(6, i + 1)} style={{ flexBasis: 320, flexGrow: 1, maxWidth: 520 }}>
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
                  <Avatar name={p.relation_user?.name} uri={p.relation_user?.avata} size={48} />
                  <View style={{ flex: 1 }}>
                    <T variant="bodyStrong">{p.relation_user?.name ?? 'Người dùng'}</T>
                    <T variant="caption" color="textMuted">
                      {p.relation_user?.email || p.relation_user?.phone} · {p.relation_type}
                    </T>
                    <View style={{ flexDirection: 'row', gap: 6, marginTop: 6 }}>
                      <Badge label="Chờ xác nhận" color="warning" icon="hourglass-outline" size="sm" />
                      <T variant="caption" color="textMuted">
                        Gửi {relativeTime(p.created_at)}
                      </T>
                    </View>
                  </View>
                  <Button
                    label="Hủy"
                    variant="dangerSoft"
                    size="sm"
                    onPress={async () => {
                      if (await confirm({ title: 'Hủy lời mời?', confirmLabel: 'Hủy lời mời' })) cancelInvite.mutate(p.id);
                    }}
                  />
                </View>
              </Card>
            ))}
          </Grid>
        )
      ) : isLoading ? (
        <Grid gap={16}>
          {Array.from({ length: 6 }).map((_, i) => (
            <View key={i} style={{ flexBasis: 300, flexGrow: 1 }}>
              <Skeleton height={190} radius={20} />
            </View>
          ))}
        </Grid>
      ) : list.length === 0 ? (
        <Card>
          <EmptyState
            icon="people-outline"
            title={members.length ? 'Không có thành viên phù hợp' : 'Chưa có thành viên nào'}
            description={members.length ? 'Thử đổi từ khóa hoặc bộ lọc.' : 'Mời người thân để bắt đầu theo dõi và chăm sóc.'}
            action={!members.length ? <Button label="Mời thành viên" icon="person-add" onPress={() => setInviteOpen(true)} /> : undefined}
          />
        </Card>
      ) : (
        <Grid gap={16}>
          {list.map((m, i) => {
            const kind = MEMBER_KIND_META[m.kind];
            const status = presenceColor(m.location?.updated_at);
            return (
              <Card key={m.uid} anim="rise" delay={Math.min(6, i + 1)} onPress={() => setDetailUid(m.uid)} style={{ flexBasis: 300, flexGrow: 1, maxWidth: 480, overflow: 'hidden' }} padding={0}>
                <View style={{ height: 6, backgroundColor: c[kind.color] as string }} />
                <View style={{ padding: 18, gap: 14 }}>
                  <View style={{ flexDirection: 'row', gap: 12, alignItems: 'center' }}>
                    <Avatar name={m.name} uri={m.avatar} size={56} status={status} />
                    <View style={{ flex: 1, minWidth: 0 }}>
                      <T variant="h3" numberOfLines={1}>
                        {m.name}
                      </T>
                      <View style={{ flexDirection: 'row', gap: 6, marginTop: 4, flexWrap: 'wrap' }}>
                        <Badge label={m.relation} color="primary" size="sm" />
                        <Badge label={kind.label} color={kind.color} icon={kind.icon} size="sm" />
                        {m.age != null ? <Badge label={`${m.age} tuổi`} color="textMuted" size="sm" /> : null}
                      </View>
                    </View>
                  </View>
                  <View style={{ gap: 6 }}>
                    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
                      <StatusDot color={status} size={8} pulse={status === '#12B76A'} />
                      <T variant="small" color="textSoft">
                        {presenceLabel(m.location?.updated_at)}
                        {m.location?.updated_at ? ` · ${relativeTime(m.location.updated_at)}` : ''}
                      </T>
                    </View>
                    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
                      <Icon name="location-outline" size={14} color="textMuted" />
                      <T variant="small" color="textMuted" numberOfLines={1} style={{ flex: 1 }}>
                        {m.location?.address || m.location?.place_name || 'Chưa có vị trí'}
                      </T>
                    </View>
                    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
                      <Icon name="call-outline" size={14} color="textMuted" />
                      <T variant="small" color="textMuted" numberOfLines={1}>
                        {m.phone || m.email || '—'}
                      </T>
                    </View>
                  </View>
                  <View style={{ flexDirection: 'row', gap: 8 }}>
                    <Button label="Nhắn tin" icon="chatbubble-outline" size="sm" variant="secondary" style={{ flex: 1 }} full onPress={() => router.push(`/messages?peer=${m.uid}` as any)} />
                    <Button label="Bản đồ" icon="map-outline" size="sm" variant="secondary" style={{ flex: 1 }} full onPress={() => router.push(`/map?uid=${m.uid}` as any)} />
                    <Button label="Chi tiết" icon="chevron-forward" size="sm" variant="soft" onPress={() => setDetailUid(m.uid)} />
                  </View>
                </View>
              </Card>
            );
          })}
        </Grid>
      )}

      <InviteModal visible={inviteOpen} onClose={closeInvite} existingUids={[...members.map((m) => m.uid), ...pending.map((p) => p.relation_id)]} />
      <MemberDetail member={members.find((m) => m.uid === detailUid) ?? null} onClose={closeDetail} />
    </Page>
  );
}
