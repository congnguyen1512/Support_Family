export interface QuickContactRecord {
  id: number;
  owner_uid: string;
  name: string;
  phone: string;
  avatar_url: string | null;
  member_uid: string | null;
  created_at: string;
  updated_at: string;
}
