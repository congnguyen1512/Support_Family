import { supabaseAdmin } from '../../config/supabase';
import { PushDeliveryService } from '../notifications/push-delivery.service';

export class RelationshipsService {
  private readonly pushDeliveryService = new PushDeliveryService();

  private normalizeRelationLabel(value?: string | null): string {
    const normalized = value?.toString().trim();
    return normalized && normalized.length > 0 ? normalized : 'Người thân';
  }

  private async getUserDisplayName(uid: string): Promise<string> {
    const { data: userProfile, error } = await supabaseAdmin
      .from('user_info')
      .select('name')
      .eq('uid', uid)
      .maybeSingle();

    if (error) {
      throw error;
    }

    const displayName = userProfile?.name?.toString().trim();
    return displayName && displayName.length > 0
      ? displayName
      : 'Một thành viên gia đình';
  }

  private async createRelationshipNotification(params: {
    recipientUid: string;
    relationshipId: number;
    title: string;
    content: string;
  }): Promise<void> {
    const { error } = await supabaseAdmin.from('notification').insert({
      uid: params.recipientUid,
      relationship_id: params.relationshipId,
      title: params.title,
      content: params.content,
      processing: 'done',
    });

    if (error) {
      throw error;
    }
  }

  async invite(
    uid: string,
    targetUid: string,
    relationType: string,
    reverseRelationType: string,
  ) {
    if (uid === targetUid) {
      throw new Error('Không thể tự thêm chính mình');
    }

    const { data: existed, error: existedError } = await supabaseAdmin
      .from('relationship')
      .select('id, processing')
      .or(
        `and(uid.eq.${uid},relation_id.eq.${targetUid}),and(uid.eq.${targetUid},relation_id.eq.${uid})`,
      )
      .not('processing', 'in', '(daxoa,huy)')
      .maybeSingle();

    if (existedError) throw existedError;

    if (existed) {
      throw new Error(
        'Hai người này đã có quan hệ hoặc đang chờ xác nhận',
      );
    }

    const { data: archivedRelationship, error: archivedRelationshipError } =
      await supabaseAdmin
        .from('relationship')
        .select('id, processing')
        .eq('uid', uid)
        .eq('relation_id', targetUid)
        .in('processing', ['daxoa', 'huy'])
        .maybeSingle();

    if (archivedRelationshipError) throw archivedRelationshipError;

    let relationship;
    let relationshipError;

    if (archivedRelationship) {
      const result = await supabaseAdmin
        .from('relationship')
        .update({
          uid,
          relation_id: targetUid,
          relation_type: relationType,
          reverse_relation_type: reverseRelationType,
          processing: 'chuachapnhan',
        })
        .eq('id', archivedRelationship.id)
        .select('*')
        .single();

      relationship = result.data;
      relationshipError = result.error;
    } else {
      const result = await supabaseAdmin
        .from('relationship')
        .insert({
          uid,
          relation_id: targetUid,
          relation_type: relationType,
          reverse_relation_type: reverseRelationType,
          processing: 'chuachapnhan',
        })
        .select('*')
        .single();

      relationship = result.data;
      relationshipError = result.error;
    }

    if (relationshipError) throw relationshipError;

    const inviterName = await this.getUserDisplayName(uid);
    const inviterRelation =
      reverseRelationType?.toString().trim() || 'Người thân';

    const { data: notification, error: notificationError } = await supabaseAdmin
      .from('notification')
      .insert({
        uid: targetUid,
        relationship_id: relationship.id,
        title: 'Xác nhận mối quan hệ',
        content: `Bạn có một lời mời xác nhận mối quan hệ từ ${inviterName}(${inviterRelation}). Xác nhận ngay?`,
        processing: 'dagui',
      })
      .select('*')
      .single();

    if (notificationError) throw notificationError;

    try {
      await this.pushDeliveryService.sendToUser({
        uid: targetUid,
        title: 'Xác nhận mối quan hệ',
        body: `Bạn có một lời mời xác nhận mối quan hệ từ ${inviterName}(${inviterRelation}).`,
        data: {
          type: 'relationship_invite',
          notification_id: String(notification.id),
          relationship_id: String(relationship.id),
        },
      });
    } catch (error) {
      console.error('Không thể gửi push lời mời quan hệ', error);
    }

    return {
      relationship,
      notification,
    };
  }

  async listMyRelationships(uid: string) {
    const { data, error } = await supabaseAdmin
      .from('relationship')
      .select(`
        id,
        uid,
        relation_id,
        relation_type,
        reverse_relation_type,
        processing,
        created_at,
        relation_user:user_info!relationship_relation_id_fkey(
          uid,
          name,
          email,
          phone,
          birthday,
          sex,
          address,
          role,
          avata,
          created_at
        )
      `)
      .eq('uid', uid)
      .neq('processing', 'daxoa')
      .order('created_at', { ascending: false });

    if (error) throw error;

    return data;
  }

  async updateRelationship(
    currentUid: string,
    relationshipId: number,
    relationType: string,
    reverseRelationType?: string,
  ) {
    const { data: relationship, error: findError } = await supabaseAdmin
      .from('relationship')
      .select('*')
      .eq('id', relationshipId)
      .single();

    if (findError || !relationship) {
      throw new Error('Không tìm thấy relationship');
    }

    if (relationship.uid !== currentUid) {
      throw new Error('Bạn không có quyền sửa relationship này');
    }

    if (relationship.processing === 'daxoa') {
      throw new Error('Relationship này đã bị xóa');
    }

    if (relationship.processing === 'huy') {
      throw new Error('Relationship này đã bị hủy');
    }

    const previousRelationType = relationship.relation_type
      ?.toString()
      .trim();
    const previousReverseRelationType = relationship.reverse_relation_type
      ?.toString()
      .trim();

    const updatePayload: Record<string, any> = {
      relation_type: relationType,
    };

    if (reverseRelationType) {
      updatePayload.reverse_relation_type = reverseRelationType;
    }

    const { data, error } = await supabaseAdmin
      .from('relationship')
      .update(updatePayload)
      .eq('id', relationshipId)
      .select('*')
      .single();

    if (error) throw error;

    if (relationship.processing === 'xacnhan') {
      const { error: reverseError } = await supabaseAdmin
        .from('relationship')
        .update({
          relation_type:
            reverseRelationType ?? relationship.reverse_relation_type,
          reverse_relation_type: relationType,
        })
        .eq('uid', relationship.relation_id)
        .eq('relation_id', relationship.uid)
        .neq('processing', 'daxoa');

      if (reverseError) throw reverseError;
    }

    try {
      const actorName = await this.getUserDisplayName(currentUid);

      let relationBefore = this.normalizeRelationLabel(
        previousReverseRelationType ?? previousRelationType,
      );
      let relationAfter = this.normalizeRelationLabel(
        reverseRelationType ?? previousReverseRelationType ?? relationType,
      );

      if (relationBefore === relationAfter) {
        relationBefore = this.normalizeRelationLabel(previousRelationType);
        relationAfter = this.normalizeRelationLabel(relationType);
      }

      const content =
        relationBefore === relationAfter
          ? `${actorName}(${relationAfter}) đã cập nhật thông tin quan hệ với bạn.`
          : `${actorName}(${relationAfter}) đã sửa quan hệ với bạn từ ${relationBefore} thành ${relationAfter}.`;

      await this.createRelationshipNotification({
        recipientUid: relationship.relation_id,
        relationshipId: relationship.id,
        title: 'Cập nhật mối quan hệ',
        content,
      });

      await this.pushDeliveryService.sendToUser({
        uid: relationship.relation_id,
        title: 'Cập nhật mối quan hệ',
        body: content,
        data: {
          type: 'relationship_updated',
          relationship_id: String(relationship.id),
        },
      });
    } catch (error) {
      console.error('Không thể tạo thông báo sửa quan hệ', error);
    }

    return data;
  }

  async deleteRelationship(currentUid: string, relationshipId: number) {
    const { data: relationship, error: findError } = await supabaseAdmin
      .from('relationship')
      .select('*')
      .eq('id', relationshipId)
      .single();

    if (findError || !relationship) {
      throw new Error('Không tìm thấy relationship');
    }

    if (relationship.uid !== currentUid) {
      throw new Error('Bạn không có quyền xóa relationship này');
    }

    if (relationship.processing === 'daxoa') {
      throw new Error('Relationship này đã bị xóa rồi');
    }

    const { data, error } = await supabaseAdmin
      .from('relationship')
      .update({
        processing: 'daxoa',
      })
      .eq('id', relationshipId)
      .select('*')
      .single();

    if (error) throw error;

    await supabaseAdmin
      .from('relationship')
      .update({
        processing: 'daxoa',
      })
      .eq('uid', relationship.relation_id)
      .eq('relation_id', relationship.uid)
      .neq('processing', 'daxoa');

    try {
      const actorName = await this.getUserDisplayName(currentUid);
      const actorRelation = this.normalizeRelationLabel(
        relationship.reverse_relation_type ?? relationship.relation_type,
      );

      await this.createRelationshipNotification({
        recipientUid: relationship.relation_id,
        relationshipId: relationship.id,
        title: 'Mối quan hệ đã bị xóa',
        content: `${actorName}(${actorRelation}) đã xóa quan hệ với bạn.`,
      });

      await this.pushDeliveryService.sendToUser({
        uid: relationship.relation_id,
        title: 'Mối quan hệ đã bị xóa',
        body: `${actorName}(${actorRelation}) đã xóa quan hệ với bạn.`,
        data: {
          type: 'relationship_deleted',
          relationship_id: String(relationship.id),
        },
      });
    } catch (error) {
      console.error('Không thể tạo thông báo xóa quan hệ', error);
    }

    return data;
  }
}
