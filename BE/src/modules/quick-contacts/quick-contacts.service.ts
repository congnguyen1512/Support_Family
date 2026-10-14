import { supabaseAdmin } from '../../config/supabase';
import { QuickContactRecord } from './quick-contacts.types';
import { SaveQuickContactInput } from './quick-contacts.validation';

export class QuickContactsService {
  async get(ownerUid: string): Promise<QuickContactRecord | null> {
    const { data, error } = await supabaseAdmin
      .from('quick_contacts')
      .select('*')
      .eq('owner_uid', ownerUid)
      .maybeSingle();

    if (error) {
      throw error;
    }

    return (data as QuickContactRecord) || null;
  }

  async save(
    ownerUid: string,
    input: SaveQuickContactInput,
  ): Promise<QuickContactRecord> {
    const payload = {
      owner_uid: ownerUid,
      name: input.name.trim(),
      phone: input.phone.trim(),
      avatar_url: input.avatar_url?.trim() || null,
      member_uid: input.member_uid?.trim() || null,
      updated_at: new Date().toISOString(),
    };

    const { data, error } = await supabaseAdmin
      .from('quick_contacts')
      .upsert(payload, { onConflict: 'owner_uid' })
      .select('*')
      .single();

    if (error) {
      throw error;
    }

    return data as QuickContactRecord;
  }

  async delete(ownerUid: string): Promise<void> {
    const { error } = await supabaseAdmin
      .from('quick_contacts')
      .delete()
      .eq('owner_uid', ownerUid);

    if (error) {
      throw error;
    }
  }
}
