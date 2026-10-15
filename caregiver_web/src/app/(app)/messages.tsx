import React, { useEffect, useMemo, useRef, useState } from 'react';
import { Pressable, ScrollView, StyleSheet, TextInput, View } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useQueryClient } from '@tanstack/react-query';
import { useTheme } from '../../theme/ThemeProvider';
import { fontFamily } from '../../theme/tokens';
import { gradient, shadow, transition, web, type WebPressState } from '../../theme/web';
import { Avatar, Badge, Divider, EmptyState, Icon, IconButton, SearchInput, SkeletonList, T } from '../../components/ui';
import { presenceColor, presenceLabel } from '../../components/map/presence';
import { chatApi } from '../../api/endpoints';
import { qk, useFamilyMembers, useMessages, useThreads } from '../../api/hooks';
import { useAuthStore } from '../../store/auth';
import { toast } from '../../store/toast';
import { useBreakpoint } from '../../hooks/common';
import { formatDateLong, formatTime, isToday, normalizeSearch, relativeTime, toISODate } from '../../utils/format';
import type { ChatMessage } from '../../api/types';

const QUICK_REPLIES = ['Bạn đã uống thuốc chưa? 💊', 'Nhớ ăn uống đầy đủ nhé ❤️', 'Mình đang trên đường về', 'Gọi lại cho mình khi rảnh nhé 📞', 'Bạn đang ở đâu vậy?', 'Mình sẽ đến ngay!'];

interface ConvItem {
  peer: string;
  name: string;
  avatar: string | null;
  relation: string;
  latest: string;
  latestAt: string | null;
  unread: boolean;
}

export default function MessagesScreen() {
  const c = useTheme();
  const router = useRouter();
  const client = useQueryClient();
  const params = useLocalSearchParams<{ peer?: string }>();
  const { isMobile } = useBreakpoint();
  const myUid = useAuthStore((s) => s.session?.userId);
  const { members } = useFamilyMembers();
  const threads = useThreads();
  const [peer, setPeer] = useState<string | null>(params.peer ?? null);
  const [query, setQuery] = useState('');
  const [text, setText] = useState('');
  const [sending, setSending] = useState(false);
  const scrollRef = useRef<ScrollView>(null);
  const inputRef = useRef<TextInput>(null);
  const messages = useMessages(peer ?? undefined);

  useEffect(() => {
    if (params.peer) setPeer(params.peer);
  }, [params.peer]);

  // Presence: báo cho BE biết đang mở cuộc trò chuyện nào (để không đẩy thông báo trùng)
  useEffect(() => {
    if (!peer) return;
    chatApi.presence(peer).catch(() => undefined);
    const t = setInterval(() => chatApi.presence(peer).catch(() => undefined), 30_000);
    return () => {
      clearInterval(t);
      chatApi.presence(null).catch(() => undefined);
    };
  }, [peer]);

  useEffect(() => {
    if (peer) {
      setTimeout(() => inputRef.current?.focus(), 80);
      client.invalidateQueries({ queryKey: qk.threads });
    }
  }, [peer, client]);

  const conversations = useMemo<ConvItem[]>(() => {
    const list: ConvItem[] = (threads.data ?? []).map((t) => {
      const m = members.find((x) => x.uid === t.peer_uid);
      return {
        peer: t.peer_uid,
        name: m?.name ?? t.peer_name,
        avatar: m?.avatar ?? t.peer_avatar ?? null,
        relation: m?.relation ?? t.relation_type ?? '',
        latest: t.latest_message,
        latestAt: t.latest_at,
        unread: t.has_unread,
      };
    });
    members.forEach((m) => {
      if (!list.some((x) => x.peer === m.uid)) list.push({ peer: m.uid, name: m.name, avatar: m.avatar, relation: m.relation, latest: '', latestAt: null, unread: false });
    });
    const q = normalizeSearch(query);
    return list
      .filter((x) => !q || normalizeSearch(`${x.name} ${x.relation}`).includes(q))
      .sort((a, b) => (b.latestAt ?? '').localeCompare(a.latestAt ?? ''));
  }, [threads.data, members, query]);

  const active = conversations.find((x) => x.peer === peer) ?? (peer ? { peer, name: members.find((m) => m.uid === peer)?.name ?? 'Người thân', avatar: null, relation: '', latest: '', latestAt: null, unread: false } : null);
  const activeMember = members.find((m) => m.uid === peer);

  const msgs = messages.data ?? [];
  useEffect(() => {
    setTimeout(() => scrollRef.current?.scrollToEnd({ animated: true }), 50);
  }, [msgs.length, peer]);

  const send = async (content?: string) => {
    const body = (content ?? text).trim();
    if (!body || !peer || sending) return;
    const temp: ChatMessage = { id: -Date.now(), sender_uid: myUid ?? '', receiver_uid: peer, content: body, is_read: false, created_at: new Date().toISOString(), pending: true };
    client.setQueryData<ChatMessage[]>(qk.messages(peer), (old) => [...(old ?? []), temp]);
    if (!content) setText('');
    setSending(true);
    try {
      await chatApi.send(peer, body);
      client.invalidateQueries({ queryKey: qk.messages(peer) });
      client.invalidateQueries({ queryKey: qk.threads });
    } catch (e: any) {
      client.setQueryData<ChatMessage[]>(qk.messages(peer), (old) => (old ?? []).filter((m) => m.id !== temp.id));
      if (!content) setText(body);
      toast.error('Không gửi được tin nhắn', e?.message);
    } finally {
      setSending(false);
      inputRef.current?.focus();
    }
  };

  const showList = !isMobile || !peer;
  const showChat = !isMobile || Boolean(peer);

  return (
    <View style={[styles.root, { padding: isMobile ? 12 : 20 }]}>
      <View style={[styles.frame, { backgroundColor: c.surface, borderColor: c.border }, shadow(2, c.shadow)]}>
        {showList ? (
          <View style={[styles.list, { borderRightColor: c.border, width: isMobile ? '100%' : 340 }]}>
            <View style={{ padding: 16, gap: 12 }}>
              <T variant="h2">Tin nhắn</T>
              <SearchInput nativeID="messages-search" value={query} onChangeText={setQuery} placeholder="Tìm người thân..." />
            </View>
            <Divider />
            <ScrollView style={{ flex: 1 }} contentContainerStyle={{ padding: 8, gap: 2 }}>
              {threads.isLoading ? (
                <SkeletonList rows={5} height={60} />
              ) : conversations.length === 0 ? (
                <EmptyState compact icon="chatbubbles-outline" title="Chưa có cuộc trò chuyện" />
              ) : (
                conversations.map((t) => {
                  const selected = t.peer === peer;
                  const m = members.find((x) => x.uid === t.peer);
                  return (
                    <Pressable
                      key={t.peer}
                      nativeID={`thread-${t.peer}`}
                      onPress={() => {
                        setPeer(t.peer);
                        router.setParams({ peer: t.peer } as any);
                      }}
                      style={(state) => {
                        const { hovered } = state as WebPressState;
                        return [
                          styles.thread,
                          { backgroundColor: selected ? c.primarySoft : hovered ? c.surfaceHover : 'transparent' },
                          transition('background-color', 120),
                          web({ cursor: 'pointer' }),
                        ];
                      }}
                    >
                      <Avatar name={t.name} uri={t.avatar} size={46} status={m ? presenceColor(m.location?.updated_at) : undefined} />
                      <View style={{ flex: 1, minWidth: 0 }}>
                        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                          <T variant="bodyStrong" numberOfLines={1} style={{ flex: 1 }}>
                            {t.name}
                          </T>
                          <T variant="caption" color={t.unread ? 'primary' : 'textMuted'}>
                            {t.latestAt ? (isToday(t.latestAt) ? formatTime(t.latestAt) : relativeTime(t.latestAt)) : ''}
                          </T>
                        </View>
                        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                          <T variant="small" color={t.unread ? 'text' : 'textMuted'} numberOfLines={1} style={{ flex: 1, fontWeight: t.unread ? '700' : '400' }}>
                            {t.latest || `Bắt đầu trò chuyện với ${t.relation || t.name}`}
                          </T>
                          {t.unread ? <View style={{ width: 9, height: 9, borderRadius: 5, backgroundColor: c.primary }} /> : null}
                        </View>
                      </View>
                    </Pressable>
                  );
                })
              )}
            </ScrollView>
          </View>
        ) : null}

        {showChat ? (
          <View style={styles.chat}>
            {!active ? (
              <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
                <EmptyState icon="chatbubbles-outline" title="Chọn một cuộc trò chuyện" description="Nhắn tin nhanh với người thân ngay trên máy tính. Nhấn Enter để gửi, Shift + Enter để xuống dòng." />
              </View>
            ) : (
              <>
                <View style={[styles.chatHeader, { borderBottomColor: c.border }]}>
                  {isMobile ? <IconButton icon="arrow-back" label="Quay lại" onPress={() => setPeer(null)} /> : null}
                  <Avatar name={active.name} uri={active.avatar} size={42} status={activeMember ? presenceColor(activeMember.location?.updated_at) : undefined} />
                  <View style={{ flex: 1, minWidth: 0 }}>
                    <T variant="h3" numberOfLines={1}>
                      {active.name}
                    </T>
                    <T variant="caption" color="textMuted">
                      {active.relation ? `${active.relation} · ` : ''}
                      {presenceLabel(activeMember?.location?.updated_at)}
                    </T>
                  </View>
                  {activeMember?.phone ? <IconButton icon="call-outline" label="Gọi điện" variant="secondary" onPress={() => window.open(`tel:${activeMember.phone}`)} /> : null}
                  <IconButton icon="location-outline" label="Xem trên bản đồ" variant="secondary" onPress={() => router.push(`/map?uid=${active.peer}` as any)} />
                  <IconButton icon="person-outline" label="Hồ sơ" variant="secondary" onPress={() => router.push(`/members?uid=${active.peer}` as any)} />
                </View>

                <ScrollView ref={scrollRef} style={{ flex: 1, backgroundColor: c.bg }} contentContainerStyle={{ padding: 20, gap: 4 }}>
                  {messages.isLoading ? (
                    <SkeletonList rows={6} height={40} />
                  ) : msgs.length === 0 ? (
                    <EmptyState icon="hand-right-outline" title={`Gửi lời chào đến ${active.name}`} description="Chọn một câu trả lời nhanh bên dưới hoặc nhập tin nhắn." />
                  ) : (
                    msgs.map((m, i) => {
                      const mine = m.sender_uid === myUid;
                      const prev = msgs[i - 1];
                      const newDay = !prev || toISODate(new Date(prev.created_at)) !== toISODate(new Date(m.created_at));
                      const grouped = prev && !newDay && prev.sender_uid === m.sender_uid && new Date(m.created_at).getTime() - new Date(prev.created_at).getTime() < 5 * 60_000;
                      return (
                        <React.Fragment key={m.id}>
                          {newDay ? (
                            <View style={{ alignItems: 'center', marginVertical: 12 }}>
                              <Badge label={isToday(m.created_at) ? 'Hôm nay' : formatDateLong(new Date(m.created_at))} color="textMuted" size="sm" />
                            </View>
                          ) : null}
                          <View style={{ flexDirection: 'row', justifyContent: mine ? 'flex-end' : 'flex-start', marginTop: grouped ? 0 : 8, gap: 8, alignItems: 'flex-end' }}>
                            {!mine ? <View style={{ width: 28 }}>{!grouped ? <Avatar name={active.name} uri={active.avatar} size={28} /> : null}</View> : null}
                            <View
                              dataSet={m.pending ? undefined : { anim: 'pop' }}
                              style={[
                                styles.bubble,
                                mine ? [gradient(c.primary, c.mode === 'dark' ? '#3C8CFF' : '#2E9BD6', 135), { borderBottomRightRadius: 6 }] : { backgroundColor: c.surface, borderWidth: 1, borderColor: c.border, borderBottomLeftRadius: 6 },
                                { opacity: m.pending ? 0.6 : 1 },
                              ]}
                            >
                              <T variant="body" style={{ color: mine ? '#fff' : c.text }}>
                                {m.content}
                              </T>
                              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 4, alignSelf: 'flex-end', marginTop: 2 }}>
                                <T variant="caption" style={{ color: mine ? 'rgba(255,255,255,0.75)' : c.textMuted, fontSize: 11.5 }}>
                                  {formatTime(m.created_at)}
                                </T>
                                {mine ? <Icon name={m.pending ? 'time-outline' : m.is_read ? 'checkmark-done' : 'checkmark'} size={13} color="rgba(255,255,255,0.85)" /> : null}
                              </View>
                            </View>
                          </View>
                        </React.Fragment>
                      );
                    })
                  )}
                </ScrollView>

                <View style={[styles.composer, { borderTopColor: c.border }]}>
                  <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={{ gap: 6, paddingBottom: 10 }}>
                    {QUICK_REPLIES.map((q) => (
                      <Pressable
                        key={q}
                        onPress={() => send(q)}
                        style={(state) => {
                          const { hovered } = state as WebPressState;
                          return [styles.quick, { borderColor: c.border, backgroundColor: hovered ? c.primarySoft : c.surfaceAlt }, transition('background-color', 120), web({ cursor: 'pointer' })];
                        }}
                      >
                        <T variant="small" color="textSoft">
                          {q}
                        </T>
                      </Pressable>
                    ))}
                  </ScrollView>
                  <View style={[styles.inputRow, { backgroundColor: c.inputBg, borderColor: c.border }]}>
                    <TextInput
                      ref={inputRef}
                      nativeID="message-input"
                      value={text}
                      onChangeText={setText}
                      placeholder={`Nhắn tin cho ${active.name}...`}
                      placeholderTextColor={c.textMuted}
                      multiline
                      style={[{ flex: 1, color: c.text, fontFamily: fontFamily.regular, fontSize: 15.5, maxHeight: 120, minHeight: 22, paddingVertical: 10 }, web({ outlineStyle: 'none', resize: 'none' })]}
                      {...({
                        onKeyPress: (e: any) => {
                          if (e.nativeEvent.key === 'Enter' && !e.nativeEvent.shiftKey) {
                            e.preventDefault();
                            send();
                          }
                        },
                      } as object)}
                    />
                    <Pressable
                      nativeID="message-send"
                      onPress={() => send()}
                      disabled={!text.trim()}
                      accessibilityLabel="Gửi"
                      style={[styles.sendBtn, text.trim() ? gradient(c.primary, '#4F7CFF', 135) : { backgroundColor: c.borderStrong }, web({ cursor: text.trim() ? 'pointer' : 'default' })]}
                    >
                      <Icon name="send" size={17} color="#fff" />
                    </Pressable>
                  </View>
                </View>
              </>
            )}
          </View>
        ) : null}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1 },
  frame: { flex: 1, flexDirection: 'row', borderRadius: 22, borderWidth: 1, overflow: 'hidden' },
  list: { borderRightWidth: 1 },
  thread: { flexDirection: 'row', alignItems: 'center', gap: 12, padding: 10, borderRadius: 14 },
  chat: { flex: 1, minWidth: 0 },
  chatHeader: { flexDirection: 'row', alignItems: 'center', gap: 10, paddingHorizontal: 18, paddingVertical: 12, borderBottomWidth: 1 },
  bubble: { maxWidth: '72%', paddingHorizontal: 14, paddingVertical: 9, borderRadius: 18 },
  composer: { paddingHorizontal: 16, paddingTop: 10, paddingBottom: 14, borderTopWidth: 1 },
  quick: { paddingHorizontal: 12, paddingVertical: 6, borderRadius: 999, borderWidth: 1 },
  inputRow: { flexDirection: 'row', alignItems: 'flex-end', gap: 8, borderWidth: 1, borderRadius: 18, paddingLeft: 14, paddingRight: 6, paddingVertical: 5 },
  sendBtn: { width: 38, height: 38, borderRadius: 19, alignItems: 'center', justifyContent: 'center' },
});
