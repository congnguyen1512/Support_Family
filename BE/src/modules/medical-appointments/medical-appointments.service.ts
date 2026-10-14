import { supabaseAdmin } from '../../config/supabase';
import {
  CreateMedicalAppointmentInput,
  UpdateMedicalAppointmentInput,
} from './medical-appointments.validation';
import { MedicalAppointmentRecord } from './medical-appointments.types';

export class MedicalAppointmentsService {
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
    status?: string,
  ): Promise<MedicalAppointmentRecord[]> {
    let query = supabaseAdmin
      .from('medical_appointments')
      .select(`
        *,
        member_user:user_info!medical_appointments_member_uid_fkey(
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

    if (status && ['upcoming', 'done', 'cancelled'].includes(status)) {
      query = query.eq('status', status);
    }

    const { data, error } = await query
      .order('appointment_date', { ascending: true })
      .order('appointment_time', { ascending: true });

    if (error) {
      throw error;
    }

    return (data || []) as MedicalAppointmentRecord[];
  }

  async getById(
    requesterUid: string,
    id: number,
  ): Promise<MedicalAppointmentRecord> {
    const { data, error } = await supabaseAdmin
      .from('medical_appointments')
      .select(`
        *,
        member_user:user_info!medical_appointments_member_uid_fkey(
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
      throw new Error('Không tìm thấy lịch hẹn khám');
    }

    if (data.owner_uid !== requesterUid && data.member_uid !== requesterUid) {
      await this.ensureLinkedMember(requesterUid, data.member_uid);
    }

    return data as MedicalAppointmentRecord;
  }

  async create(
    ownerUid: string,
    input: CreateMedicalAppointmentInput,
  ): Promise<MedicalAppointmentRecord> {
    const targetMemberUid = input.member_uid?.trim() || ownerUid;
    await this.ensureLinkedMember(ownerUid, targetMemberUid);

    const payload = {
      owner_uid: ownerUid,
      member_uid: targetMemberUid,
      clinic: input.clinic.trim(),
      doctor: input.doctor.trim(),
      appointment_date: input.appointment_date.trim(),
      appointment_time: input.appointment_time.trim(),
      notes: input.notes?.trim() || '',
      status: input.status || 'upcoming',
      remind_before_1_day: input.remind_before_1_day ?? true,
      remind_before_2_hours: input.remind_before_2_hours ?? true,
      updated_at: new Date().toISOString(),
    };

    const { data, error } = await supabaseAdmin
      .from('medical_appointments')
      .insert(payload)
      .select(`
        *,
        member_user:user_info!medical_appointments_member_uid_fkey(
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

    return data as MedicalAppointmentRecord;
  }

  async update(
    requesterUid: string,
    id: number,
    input: UpdateMedicalAppointmentInput,
  ): Promise<MedicalAppointmentRecord> {
    const current = await this.getById(requesterUid, id);

    const updatePayload: Record<string, any> = {
      updated_at: new Date().toISOString(),
    };

    if (input.clinic !== undefined) updatePayload.clinic = input.clinic.trim();
    if (input.doctor !== undefined) updatePayload.doctor = input.doctor.trim();
    if (input.appointment_date !== undefined) updatePayload.appointment_date = input.appointment_date.trim();
    if (input.appointment_time !== undefined) updatePayload.appointment_time = input.appointment_time.trim();
    if (input.notes !== undefined) updatePayload.notes = input.notes.trim();
    if (input.status !== undefined) updatePayload.status = input.status;
    if (input.remind_before_1_day !== undefined) updatePayload.remind_before_1_day = input.remind_before_1_day;
    if (input.remind_before_2_hours !== undefined) updatePayload.remind_before_2_hours = input.remind_before_2_hours;
    if (input.member_uid !== undefined) {
      const nextMemberUid = input.member_uid.trim();
      await this.ensureLinkedMember(requesterUid, nextMemberUid);
      updatePayload.member_uid = nextMemberUid;
    }

    const { data, error } = await supabaseAdmin
      .from('medical_appointments')
      .update(updatePayload)
      .eq('id', current.id)
      .select(`
        *,
        member_user:user_info!medical_appointments_member_uid_fkey(
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

    return data as MedicalAppointmentRecord;
  }

  async delete(requesterUid: string, id: number): Promise<void> {
    const current = await this.getById(requesterUid, id);

    const { error } = await supabaseAdmin
      .from('medical_appointments')
      .delete()
      .eq('id', current.id);

    if (error) {
      throw error;
    }
  }
}
