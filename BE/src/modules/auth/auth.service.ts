import { supabase, supabaseAdmin } from '../../config/supabase';
import { RegisterInput } from './auth.validation';

type HomeType = 'adult' | 'child' | 'elderly';

function calculateAge(birthday?: string | null): number | null {
  if (!birthday) return null;

  const birthDate = new Date(birthday);
  if (Number.isNaN(birthDate.getTime())) return null;

  const today = new Date();

  let age = today.getFullYear() - birthDate.getFullYear();
  const monthDiff = today.getMonth() - birthDate.getMonth();

  if (
    monthDiff < 0 ||
    (monthDiff === 0 && today.getDate() < birthDate.getDate())
  ) {
    age--;
  }

  return age;
}

function normalizeBirthday(raw?: string | null): string | null {
  if (!raw || !raw.trim()) return null;
  const trimmed = raw.trim();

  // Format dd/MM/yyyy
  if (/^\d{1,2}\/\d{1,2}\/\d{4}$/.test(trimmed)) {
    const parts = trimmed.split('/');
    const d = parts[0].padStart(2, '0');
    const m = parts[1].padStart(2, '0');
    const y = parts[2];
    return `${y}-${m}-${d}`;
  }

  // Format yyyy-MM-dd
  if (/^\d{4}-\d{2}-\d{2}/.test(trimmed)) {
    return trimmed.substring(0, 10);
  }

  const date = new Date(trimmed);
  if (!Number.isNaN(date.getTime())) {
    return date.toISOString().split('T')[0];
  }

  return null;
}

function resolveHomeType(
  role?: string | null,
  birthday?: string | null,
): { age: number | null; home_type: HomeType } {
  const age = calculateAge(birthday);

  if (role === 'nguoichamsoc') {
    return {
      age,
      home_type: 'adult',
    };
  }

  if (role === 'nguoiduocchamsoc') {
    if (age !== null && age < 16) {
      return {
        age,
        home_type: 'child',
      };
    }

    if (age !== null && age >= 60) {
      return {
        age,
        home_type: 'elderly',
      };
    }

    return {
      age,
      home_type: 'adult',
    };
  }

  return {
    age,
    home_type: 'adult',
  };
}

export class AuthService {
  async register(input: RegisterInput) {
    const rawEmail = input.email?.trim() || '';
    const phone = input.phone?.trim() || null;
    const name = input.fullName.trim();
    const password = input.password;
    const birthday = normalizeBirthday(input.birthday);
    const sex = input.gender?.trim() || null;
    const address = input.address?.trim() || null;

    // Supabase auth requires an email format string
    const authEmail =
      rawEmail.length > 0
        ? rawEmail
        : `${phone ? phone.replace(/\D/g, '') : Date.now()}@familyguard.test`;

    const age = calculateAge(birthday);
    let resolvedRole: 'nguoichamsoc' | 'nguoiduocchamsoc' =
      input.role || 'nguoichamsoc';
    if (!input.role) {
      if (age !== null && (age < 16 || age >= 60)) {
        resolvedRole = 'nguoiduocchamsoc';
      } else {
        resolvedRole = 'nguoichamsoc';
      }
    }

    // 1. Create auth user in Supabase
    const { data: authData, error: authError } =
      await supabaseAdmin.auth.admin.createUser({
        email: authEmail,
        password,
        email_confirm: true,
        user_metadata: {
          name,
          phone,
          role: resolvedRole,
        },
      });

    if (authError || !authData.user) {
      const msg = authError?.message || '';
      if (
        msg.toLowerCase().includes('already') ||
        msg.toLowerCase().includes('exists')
      ) {
        throw new Error('Email hoặc số điện thoại này đã được đăng ký');
      }
      throw new Error(msg || 'Đăng ký tài khoản thất bại');
    }

    const uid = authData.user.id;

    // 2. Upsert user_info
    const { data: profile, error: profileError } = await supabaseAdmin
      .from('user_info')
      .upsert({
        uid,
        name,
        email: rawEmail.length > 0 ? rawEmail : authEmail,
        phone,
        birthday,
        sex,
        address,
        role: resolvedRole,
      })
      .select('*')
      .single();

    if (profileError) {
      await supabaseAdmin.auth.admin.deleteUser(uid);
      throw profileError;
    }

    // 3. Sign in immediately to generate access/refresh tokens
    const { data: sessionData, error: loginError } =
      await supabase.auth.signInWithPassword({
        email: authEmail,
        password,
      });

    if (loginError || !sessionData.session) {
      throw new Error(
        loginError?.message || 'Đăng ký thành công nhưng đăng nhập thất bại',
      );
    }

    const extra = resolveHomeType(profile.role, profile.birthday);

    return {
      access_token: sessionData.session.access_token,
      refresh_token: sessionData.session.refresh_token,
      expires_at: sessionData.session.expires_at,
      user: {
        id: authData.user.id,
        email: authData.user.email,
      },
      profile,
      ...extra,
    };
  }

  async login(identifier: string, password: string) {
    let emailToAuth = identifier.trim();

    // Support login with phone number
    if (!emailToAuth.includes('@')) {
      const { data: userByPhone } = await supabaseAdmin
        .from('user_info')
        .select('email')
        .eq('phone', emailToAuth)
        .maybeSingle();

      if (userByPhone?.email) {
        emailToAuth = userByPhone.email;
      } else {
        emailToAuth = `${emailToAuth}@familyguard.test`;
      }
    }

    const { data, error } = await supabase.auth.signInWithPassword({
      email: emailToAuth,
      password,
    });

    if (error || !data.user || !data.session) {
      throw new Error(error?.message || 'Đăng nhập thất bại');
    }

    const uid = data.user.id;

    let { data: profile, error: profileError } = await supabaseAdmin
      .from('user_info')
      .select('*')
      .eq('uid', uid)
      .maybeSingle();

    if (profileError) {
      throw profileError;
    }

    if (!profile) {
      const { data: newProfile, error: insertError } = await supabaseAdmin
        .from('user_info')
        .insert({
          uid,
          email: data.user.email,
          name: '',
          phone: null,
          birthday: null,
          sex: null,
          address: null,
          role: 'nguoiduocchamsoc',
          avata: null,
        })
        .select('*')
        .single();

      if (insertError) {
        throw insertError;
      }

      profile = newProfile;
    }

    const extra = resolveHomeType(profile.role, profile.birthday);

    return {
      access_token: data.session.access_token,
      refresh_token: data.session.refresh_token,
      expires_at: data.session.expires_at,
      user: {
        id: data.user.id,
        email: data.user.email,
      },
      profile,
      ...extra,
    };
  }

  async logout(accessToken: string) {
    if (!accessToken) {
      throw new Error('Thiếu access token');
    }

    const { error } = await supabase.auth.admin.signOut(accessToken);

    if (error) {
      throw new Error(error.message || 'Đăng xuất thất bại');
    }

    return { success: true };
  }

  async me(uid: string) {
    const { data, error } = await supabaseAdmin
      .from('user_info')
      .select('*')
      .eq('uid', uid)
      .single();

    if (error || !data) {
      throw new Error(error?.message || 'Không lấy được thông tin người dùng');
    }

    const extra = resolveHomeType(data.role, data.birthday);

    return {
      ...data,
      ...extra,
    };
  }
}