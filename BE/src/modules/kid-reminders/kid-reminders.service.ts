import { supabaseAdmin } from '../../config/supabase';
import { CreateKidReminderInput, UpdateKidReminderInput } from './kid-reminders.validation';
import { KidReminderRecord } from './kid-reminders.types';

export class KidRemindersService {
  private async ensureLinkedMember(
    ownerUid: string,
    memberUid: string,
  ): Promise<void> {
    const { data, error } = await supabaseAdmin
      .from('relationship')
      .select('id')
      .eq('uid', ownerUid)
      .eq('relation_id', memberUid)
      .eq('processing', 'xacnhan')
      .maybeSingle();

    if (error) {
      throw error;
    }

    if (!data) {
      throw new Error('Không có quyền truy cập thành viên này');
    }
  }

  async listByMember(requesterUid: string, memberUid: string) {
    if (requesterUid === memberUid) {
      const vietnamNow = new Date(Date.now() + 7 * 60 * 60 * 1000);
      const todayIso = vietnamNow.toISOString().slice(0, 10);
      const weekday = vietnamNow.getUTCDay() === 0 ? 7 : vietnamNow.getUTCDay();

      const { data, error } = await supabaseAdmin
        .from('kid_reminder')
        .select('*')
        .eq('member_uid', memberUid)
        .eq('is_active', true)
        .or(
          `schedule_type.eq.daily,and(schedule_type.eq.once,schedule_date.eq.${todayIso}),and(schedule_type.eq.weekly,weekdays.cs.{${weekday}})`,
        )
        .order('reminder_time', { ascending: true });

      if (error) {
        throw error;
      }

      return data as KidReminderRecord[];
    }

    await this.ensureLinkedMember(requesterUid, memberUid);

    const { data, error } = await supabaseAdmin
      .from('kid_reminder')
      .select('*')
      .eq('owner_uid', requesterUid)
      .eq('member_uid', memberUid)
      .order('reminder_time', { ascending: true });

    if (error) {
      throw error;
    }

    return data as KidReminderRecord[];
  }

  async create(ownerUid: string, input: CreateKidReminderInput) {
    await this.ensureLinkedMember(ownerUid, input.member_uid);

    const { data, error } = await supabaseAdmin
      .from('kid_reminder')
      .insert({
        owner_uid: ownerUid,
        member_uid: input.member_uid,
        title: input.title,
        reminder_time: input.reminder_time,
        schedule_type: input.schedule_type,
        schedule_date:
          input.schedule_type === 'once' ? input.schedule_date : null,
        weekdays: input.schedule_type === 'weekly' ? input.weekdays : [],
        is_active: true,
      })
      .select('*')
      .single();

    if (error) {
      throw error;
    }

    return data as KidReminderRecord;
  }

  async update(ownerUid: string, id: number, input: UpdateKidReminderInput) {
    const { data: existing, error: findError } = await supabaseAdmin
      .from('kid_reminder')
      .select('*')
      .eq('id', id)
      .single();

    if (findError || !existing) {
      throw new Error('Không tìm thấy nhắc nhỏ');
    }

    if (existing.owner_uid !== ownerUid) {
      throw new Error('Bạn không có quyền sửa nhắc nhỏ này');
    }

    const { data, error } = await supabaseAdmin
      .from('kid_reminder')
      .update({
        ...input,
        updated_at: new Date().toISOString(),
      })
      .eq('id', id)
      .select('*')
      .single();

    if (error) {
      throw error;
    }

    return data as KidReminderRecord;
  }

  async delete(ownerUid: string, id: number) {
    const { data: existing, error: findError } = await supabaseAdmin
      .from('kid_reminder')
      .select('*')
      .eq('id', id)
      .single();

    if (findError || !existing) {
      throw new Error('Không tìm thấy nhắc nhỏ');
    }

    if (existing.owner_uid !== ownerUid) {
      throw new Error('Bạn không có quyền xóa nhắc nhỏ này');
    }

    const { error } = await supabaseAdmin
      .from('kid_reminder')
      .delete()
      .eq('id', id);

    if (error) {
      throw error;
    }

    return { success: true };
  }
}
