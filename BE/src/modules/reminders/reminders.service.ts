import { supabaseAdmin } from '../../config/supabase';
import { CreateReminderInput, UpdateReminderInput } from './reminders.validation';
import { ReminderRecord } from './reminders.types';

export class RemindersService {
  private async ensureLinkedMember(
    requesterUid: string,
    memberUid: string,
  ): Promise<void> {
    if (requesterUid === memberUid) {
      return;
    }

    const { data, error } = await supabaseAdmin
      .from('relationship')
      .select('id')
      .or(
        `and(uid.eq.${requesterUid},relation_id.eq.${memberUid}),and(uid.eq.${memberUid},relation_id.eq.${requesterUid})`,
      )
      .eq('processing', 'xacnhan')
      .limit(1);

    if (error) {
      throw error;
    }

    if (!data || data.length === 0) {
      throw new Error('Bạn chưa có quyền kết nối với thành viên này');
    }
  }

  async list(requesterUid: string, memberUid?: string): Promise<ReminderRecord[]> {
    let query = supabaseAdmin
      .from('reminders')
      .select(`
        *,
        member_user:user_info!reminders_member_uid_fkey(
          uid,
          name,
          email,
          phone,
          avata,
          role
        )
      `);

    if (memberUid && memberUid.trim().length > 0) {
      const cleanMemberUid = memberUid.trim();
      await this.ensureLinkedMember(requesterUid, cleanMemberUid);
      query = query.eq('member_uid', cleanMemberUid);
    } else {
      query = query.or(
        `owner_uid.eq.${requesterUid},member_uid.eq.${requesterUid}`,
      );
    }

    const { data, error } = await query.order('reminder_time', { ascending: true });

    if (error) {
      throw error;
    }

    return (data || []) as ReminderRecord[];
  }

  async getById(requesterUid: string, id: number): Promise<ReminderRecord> {
    const { data, error } = await supabaseAdmin
      .from('reminders')
      .select(`
        *,
        member_user:user_info!reminders_member_uid_fkey(
          uid,
          name,
          email,
          phone,
          avata,
          role
        )
      `)
      .eq('id', id)
      .maybeSingle();

    if (error) {
      throw error;
    }

    if (!data) {
      throw new Error('Không tìm thấy lịch nhắc');
    }

    if (data.owner_uid !== requesterUid && data.member_uid !== requesterUid) {
      await this.ensureLinkedMember(requesterUid, data.member_uid);
    }

    return data as ReminderRecord;
  }

  async create(ownerUid: string, input: CreateReminderInput): Promise<ReminderRecord> {
    const targetMemberUid = input.member_uid?.trim() || ownerUid;
    await this.ensureLinkedMember(ownerUid, targetMemberUid);

    const { data, error } = await supabaseAdmin
      .from('reminders')
      .insert({
        owner_uid: ownerUid,
        member_uid: targetMemberUid,
        title: input.title,
        subtitle: input.subtitle ?? null,
        category: input.category ?? 'other',
        reminder_time: input.reminder_time,
        schedule_type: input.schedule_type ?? 'daily',
        schedule_date: input.schedule_type === 'once' ? input.schedule_date : null,
        weekdays: input.schedule_type === 'weekly' || input.schedule_type === 'custom'
          ? input.weekdays ?? []
          : [],
        is_active: input.is_active ?? true,
        voice_url: input.voice_url ?? null,
      })
      .select(`
        *,
        member_user:user_info!reminders_member_uid_fkey(
          uid,
          name,
          email,
          phone,
          avata,
          role
        )
      `)
      .single();

    if (error) {
      throw error;
    }

    return data as ReminderRecord;
  }

  async update(
    requesterUid: string,
    id: number,
    input: UpdateReminderInput,
  ): Promise<ReminderRecord> {
    const { data: existing, error: findError } = await supabaseAdmin
      .from('reminders')
      .select('owner_uid, member_uid')
      .eq('id', id)
      .maybeSingle();

    if (findError) {
      throw findError;
    }

    if (!existing) {
      throw new Error('Không tìm thấy lịch nhắc');
    }

    if (existing.owner_uid !== requesterUid && existing.member_uid !== requesterUid) {
      await this.ensureLinkedMember(requesterUid, existing.member_uid);
    }

    const updatePayload: Record<string, any> = {
      updated_at: new Date().toISOString(),
    };

    if (input.title !== undefined) updatePayload.title = input.title;
    if (input.subtitle !== undefined) updatePayload.subtitle = input.subtitle;
    if (input.category !== undefined) updatePayload.category = input.category;
    if (input.reminder_time !== undefined) updatePayload.reminder_time = input.reminder_time;
    if (input.schedule_type !== undefined) updatePayload.schedule_type = input.schedule_type;
    if (input.schedule_date !== undefined) updatePayload.schedule_date = input.schedule_date;
    if (input.weekdays !== undefined) updatePayload.weekdays = input.weekdays;
    if (input.is_active !== undefined) updatePayload.is_active = input.is_active;
    if (input.voice_url !== undefined) updatePayload.voice_url = input.voice_url;

    const { data, error } = await supabaseAdmin
      .from('reminders')
      .update(updatePayload)
      .eq('id', id)
      .select(`
        *,
        member_user:user_info!reminders_member_uid_fkey(
          uid,
          name,
          email,
          phone,
          avata,
          role
        )
      `)
      .single();

    if (error) {
      throw error;
    }

    return data as ReminderRecord;
  }

  async delete(requesterUid: string, id: number): Promise<{ success: boolean }> {
    const { data: existing, error: findError } = await supabaseAdmin
      .from('reminders')
      .select('owner_uid, member_uid')
      .eq('id', id)
      .maybeSingle();

    if (findError) {
      throw findError;
    }

    if (!existing) {
      throw new Error('Không tìm thấy lịch nhắc');
    }

    if (existing.owner_uid !== requesterUid && existing.member_uid !== requesterUid) {
      await this.ensureLinkedMember(requesterUid, existing.member_uid);
    }

    const { error } = await supabaseAdmin
      .from('reminders')
      .delete()
      .eq('id', id);

    if (error) {
      throw error;
    }

    return { success: true };
  }

  async bulkDelete(
    requesterUid: string,
    ids: number[],
  ): Promise<{ success: boolean; deletedCount: number }> {
    const { data, error } = await supabaseAdmin
      .from('reminders')
      .delete()
      .in('id', ids)
      .or(`owner_uid.eq.${requesterUid},member_uid.eq.${requesterUid}`)
      .select('id');

    if (error) {
      throw error;
    }

    return { success: true, deletedCount: data?.length || 0 };
  }
}
