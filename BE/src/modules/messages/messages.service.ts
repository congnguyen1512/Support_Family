import { supabaseAdmin } from '../../config/supabase';
import { PushDeliveryService } from '../notifications/push-delivery.service';

type LinkedMember = {
  id: number;
  relation_id: string;
  relation_type: string;
  reverse_relation_type?: string | null;
  relation_user?: {
    uid?: string;
    name?: string;
    role?: string;
    avata?: string;
  } | null;
};

export class MessagesService {
  private readonly pushDeliveryService = new PushDeliveryService();

  private async ensureLinked(uid: string, peerUid: string): Promise<LinkedMember> {
    const { data, error } = await supabaseAdmin
      .from('relationship')
      .select(
        `
        id,
        relation_id,
        relation_type,
        reverse_relation_type,
        relation_user:user_info!relationship_relation_id_fkey(
          uid,
          name,
          role,
          avata
        )
      `,
      )
      .eq('uid', uid)
      .eq('relation_id', peerUid)
      .eq('processing', 'xacnhan')
      .maybeSingle();

    if (error) throw error;
    if (!data) throw new Error('Hai tài khoản chưa liên kết thành viên');
    return data as LinkedMember;
  }

  async listThreads(uid: string) {
    const { data: relationships, error } = await supabaseAdmin
      .from('relationship')
      .select(
        `
        id,
        relation_id,
        relation_type,
        reverse_relation_type,
        relation_user:user_info!relationship_relation_id_fkey(
          uid,
          name,
          role,
          avata
        )
      `,
      )
      .eq('uid', uid)
      .eq('processing', 'xacnhan');

    if (error) throw error;

    const result: any[] = [];
    for (const relationship of (relationships ?? []) as LinkedMember[]) {
      const peerUid = relationship.relation_id;
      const { data: latestMessage } = await supabaseAdmin
        .from('chat_message')
        .select('id, sender_uid, receiver_uid, content, is_read, created_at')
        .or(
          `and(sender_uid.eq.${uid},receiver_uid.eq.${peerUid}),and(sender_uid.eq.${peerUid},receiver_uid.eq.${uid})`,
        )
        .order('created_at', { ascending: false })
        .limit(1)
        .maybeSingle();

      result.push({
        peer_uid: peerUid,
        relationship_id: relationship.id,
        peer_name: relationship.relation_user?.name ?? 'Thành viên gia đình',
        peer_role: relationship.relation_user?.role ?? 'adult',
        peer_avatar: relationship.relation_user?.avata ?? '',
        relation_type: relationship.relation_type,
        reverse_relation_type: relationship.reverse_relation_type ?? null,
        latest_message: latestMessage?.content ?? '',
        latest_at: latestMessage?.created_at ?? null,
        has_unread:
          latestMessage?.sender_uid === peerUid && latestMessage?.is_read === false,
      });
    }

    result.sort((a, b) => String(b.latest_at ?? '').localeCompare(String(a.latest_at ?? '')));
    return result;
  }

  async listMessages(uid: string, peerUid: string) {
    await this.ensureLinked(uid, peerUid);

    const { data, error } = await supabaseAdmin
      .from('chat_message')
      .select('id, sender_uid, receiver_uid, content, is_read, created_at')
      .or(
        `and(sender_uid.eq.${uid},receiver_uid.eq.${peerUid}),and(sender_uid.eq.${peerUid},receiver_uid.eq.${uid})`,
      )
      .order('created_at', { ascending: true });

    if (error) throw error;

    await supabaseAdmin
      .from('chat_message')
      .update({ is_read: true })
      .eq('sender_uid', peerUid)
      .eq('receiver_uid', uid)
      .eq('is_read', false);

    return data ?? [];
  }

  async updatePresence(uid: string, activePeerUid?: string | null) {
    const { data, error } = await supabaseAdmin
      .from('chat_presence')
      .upsert(
        {
          uid,
          active_peer_uid: activePeerUid?.trim() || null,
          updated_at: new Date().toISOString(),
        },
        { onConflict: 'uid' },
      )
      .select('uid, active_peer_uid, updated_at')
      .single();

    if (error) throw error;
    return data;
  }

  async sendMessage(uid: string, peerUid: string, content: string) {
    const relationship = await this.ensureLinked(uid, peerUid);
    const message = content.trim();
    if (!message) {
      throw new Error('Nội dung tin nhắn trống');
    }

    const { data, error } = await supabaseAdmin
      .from('chat_message')
      .insert({
        relationship_id: relationship.id,
        sender_uid: uid,
        receiver_uid: peerUid,
        content: message,
        is_read: false,
      })
      .select('id, sender_uid, receiver_uid, content, is_read, created_at')
      .single();

    if (error) throw error;

    const senderName = await this.getUserDisplayName(uid);

    await this.pushIncomingIfNeeded({
      senderUid: uid,
      receiverUid: peerUid,
      body: message,
      senderName,
    });

    return data;
  }

  private async pushIncomingIfNeeded(params: {
    senderUid: string;
    receiverUid: string;
    body: string;
    senderName: string;
  }) {
    const { data: presence, error } = await supabaseAdmin
      .from('chat_presence')
      .select('active_peer_uid, updated_at')
      .eq('uid', params.receiverUid)
      .maybeSingle();
    if (error) throw error;

    const updatedAt = presence?.updated_at
      ? new Date(presence.updated_at).getTime()
      : 0;
    const isPresenceFresh = Date.now() - updatedAt < 90 * 1000;
    const isViewingThisThread =
      isPresenceFresh && presence?.active_peer_uid === params.senderUid;

    if (isViewingThisThread) {
      return;
    }

    try {
      await this.pushDeliveryService.sendToUser({
        uid: params.receiverUid,
        title: params.senderName,
        body: params.body,
        data: {
          type: 'chat_message',
          sender_uid: params.senderUid,
        },
      });
    } catch (pushError) {
      console.error('Không gửi được push tin nhắn', pushError);
    }
  }

  private async getUserDisplayName(uid: string): Promise<string> {
    const { data, error } = await supabaseAdmin
      .from('user_info')
      .select('name')
      .eq('uid', uid)
      .maybeSingle();
    if (error) throw error;
    const value = data?.name?.toString().trim();
    return value && value.length > 0 ? value : 'Thành viên gia đình';
  }
}
