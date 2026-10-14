import { supabaseAdmin } from '../../config/supabase';
import {
  CreatePhysicalActivityInput,
  UpdatePhysicalActivityInput,
  UpdatePhysicalMetricsInput,
} from './physical-activities.validation';
import {
  PhysicalActivityRecord,
  PhysicalMetricsRecord,
} from './physical-activities.types';

export class PhysicalActivitiesService {
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

  async list(
    requesterUid: string,
    memberUid?: string,
  ): Promise<PhysicalActivityRecord[]> {
    let query = supabaseAdmin
      .from('physical_activities')
      .select(`
        *,
        member_user:user_info!physical_activities_member_uid_fkey(
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

    const { data, error } = await query
      .order('activity_time', { ascending: true });

    if (error) {
      throw error;
    }

    return (data || []) as PhysicalActivityRecord[];
  }

  async getById(
    requesterUid: string,
    id: number,
  ): Promise<PhysicalActivityRecord> {
    const { data, error } = await supabaseAdmin
      .from('physical_activities')
      .select(`
        *,
        member_user:user_info!physical_activities_member_uid_fkey(
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
      throw new Error('Không tìm thấy hoạt động');
    }

    if (data.owner_uid !== requesterUid && data.member_uid !== requesterUid) {
      await this.ensureLinkedMember(requesterUid, data.member_uid);
    }

    return data as PhysicalActivityRecord;
  }

  async create(
    ownerUid: string,
    input: CreatePhysicalActivityInput,
  ): Promise<PhysicalActivityRecord> {
    const targetMemberUid = input.member_uid?.trim() || ownerUid;
    await this.ensureLinkedMember(ownerUid, targetMemberUid);

    const payload = {
      owner_uid: ownerUid,
      member_uid: targetMemberUid,
      name: input.name.trim(),
      activity_type: input.activity_type || 'walking',
      duration_min: input.duration_min ?? 30,
      activity_time: input.activity_time.trim(),
      repeat_days: input.repeat_days || [1, 2, 3, 4, 5],
      enabled: input.enabled ?? true,
      updated_at: new Date().toISOString(),
    };

    const { data, error } = await supabaseAdmin
      .from('physical_activities')
      .insert(payload)
      .select(`
        *,
        member_user:user_info!physical_activities_member_uid_fkey(
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

    return data as PhysicalActivityRecord;
  }

  async update(
    requesterUid: string,
    id: number,
    input: UpdatePhysicalActivityInput,
  ): Promise<PhysicalActivityRecord> {
    const current = await this.getById(requesterUid, id);

    const updatePayload: Record<string, any> = {
      updated_at: new Date().toISOString(),
    };

    if (input.name !== undefined) updatePayload.name = input.name.trim();
    if (input.activity_type !== undefined) updatePayload.activity_type = input.activity_type;
    if (input.duration_min !== undefined) updatePayload.duration_min = input.duration_min;
    if (input.activity_time !== undefined) updatePayload.activity_time = input.activity_time.trim();
    if (input.repeat_days !== undefined) updatePayload.repeat_days = input.repeat_days;
    if (input.enabled !== undefined) updatePayload.enabled = input.enabled;
    if (input.member_uid !== undefined) {
      const nextMemberUid = input.member_uid.trim();
      await this.ensureLinkedMember(requesterUid, nextMemberUid);
      updatePayload.member_uid = nextMemberUid;
    }

    const { data, error } = await supabaseAdmin
      .from('physical_activities')
      .update(updatePayload)
      .eq('id', current.id)
      .select(`
        *,
        member_user:user_info!physical_activities_member_uid_fkey(
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

    return data as PhysicalActivityRecord;
  }

  async toggle(
    requesterUid: string,
    id: number,
    enabled: boolean,
  ): Promise<PhysicalActivityRecord> {
    return this.update(requesterUid, id, { enabled });
  }

  async delete(requesterUid: string, id: number): Promise<void> {
    const current = await this.getById(requesterUid, id);

    const { error } = await supabaseAdmin
      .from('physical_activities')
      .delete()
      .eq('id', current.id);

    if (error) {
      throw error;
    }
  }

  // ── Metrics ────────────────────────────────────────────────────────
  async getMetrics(
    requesterUid: string,
    memberUid?: string,
    date?: string,
  ): Promise<PhysicalMetricsRecord> {
    const targetMemberUid = memberUid?.trim() || requesterUid;
    await this.ensureLinkedMember(requesterUid, targetMemberUid);

    const todayStr = date?.trim() || new Date().toISOString().split('T')[0];

    const { data, error } = await supabaseAdmin
      .from('physical_metrics')
      .select('*')
      .eq('member_uid', targetMemberUid)
      .eq('metric_date', todayStr)
      .maybeSingle();

    if (error) {
      throw error;
    }

    if (data) {
      return data as PhysicalMetricsRecord;
    }

    // Default if not yet recorded
    return {
      id: 0,
      member_uid: targetMemberUid,
      metric_date: todayStr,
      steps: 0,
      steps_goal: 10000,
      calories: 0,
      calories_goal: 500,
      active_minutes: 0,
      minutes_goal: 60,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };
  }

  async upsertMetrics(
    requesterUid: string,
    input: UpdatePhysicalMetricsInput,
  ): Promise<PhysicalMetricsRecord> {
    const targetMemberUid = input.member_uid?.trim() || requesterUid;
    await this.ensureLinkedMember(requesterUid, targetMemberUid);

    const targetDate = input.metric_date?.trim() || new Date().toISOString().split('T')[0];

    // Read current
    const current = await this.getMetrics(requesterUid, targetMemberUid, targetDate);

    const payload = {
      member_uid: targetMemberUid,
      metric_date: targetDate,
      steps: input.steps !== undefined ? input.steps : current.steps,
      steps_goal: input.steps_goal !== undefined ? input.steps_goal : current.steps_goal,
      calories: input.calories !== undefined ? input.calories : current.calories,
      calories_goal: input.calories_goal !== undefined ? input.calories_goal : current.calories_goal,
      active_minutes: input.active_minutes !== undefined ? input.active_minutes : current.active_minutes,
      minutes_goal: input.minutes_goal !== undefined ? input.minutes_goal : current.minutes_goal,
      updated_at: new Date().toISOString(),
    };

    const { data, error } = await supabaseAdmin
      .from('physical_metrics')
      .upsert(payload, { onConflict: 'member_uid,metric_date' })
      .select('*')
      .single();

    if (error) {
      throw error;
    }

    return data as PhysicalMetricsRecord;
  }
}
