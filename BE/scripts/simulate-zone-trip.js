/* eslint-disable no-console */
/**
 * Cong cu DEV: mo phong mot thanh vien di vao / ra khoi vung an toan
 * de test man hinh "Lich su hoat dong" ma khong can di chuyen that.
 *
 * Chay qua logic BE that (safeZonesService.checkLocationForUser):
 * ghi safe_zone_events + tao thong bao cho nguoi tao vung.
 * KHONG thay doi vi tri hien tai cua thanh vien tren ban do.
 *
 *   npm run simulate:zone                    -> liet ke cac vung dang bat
 *   npm run simulate:zone -- <zoneId>        -> mo phong 4 buoc vao/ra (moi buoc 3s)
 *   npm run simulate:zone -- <zoneId> --steps 6 --delay 5
 *   npm run simulate:zone -- <zoneId> --clean -> xoa cac su kien mo phong cua vung
 */
const path = require('path');
require('dotenv').config({ quiet: true });

const { supabaseAdmin } = require(path.join(__dirname, '../dist/config/supabase'));
const { safeZonesService } = require(
  path.join(__dirname, '../dist/modules/safe-zones/safe-zones.service'),
);

const SIM_TAG = '[Mo phong]';
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

function readArg(name, fallback) {
  const index = process.argv.indexOf(`--${name}`);
  if (index === -1) return fallback;
  const value = Number(process.argv[index + 1]);
  return Number.isFinite(value) ? value : fallback;
}

async function userNames(uids) {
  const { data } = await supabaseAdmin
    .from('user_info')
    .select('uid, name, email')
    .in('uid', uids);
  const map = new Map();
  for (const u of data ?? []) map.set(u.uid, u.name || u.email || u.uid);
  return (uid) => map.get(uid) || uid;
}

async function listZones() {
  const { data: zones, error } = await supabaseAdmin
    .from('safe_zones')
    .select('*')
    .eq('is_active', true)
    .order('id');
  if (error) throw error;

  if (!zones?.length) {
    console.log('Khong co vung an toan nao dang BAT. Hay bat 1 vung trong app truoc.');
    return;
  }

  const name = await userNames([...new Set(zones.flatMap((z) => [z.target_uid, z.owner_uid]))]);
  console.log('\nCac vung an toan dang bat:\n');
  for (const z of zones) {
    console.log(
      `  #${z.id}  "${z.name}"  -  thanh vien: ${name(z.target_uid)}  -  tao boi: ${name(z.owner_uid)}  -  ${z.radius_meters}m`,
    );
  }
  console.log('\nChay: npm run simulate:zone -- <zoneId>\n');
}

async function getZone(zoneId) {
  const { data: zone, error } = await supabaseAdmin
    .from('safe_zones')
    .select('*')
    .eq('id', zoneId)
    .maybeSingle();
  if (error) throw error;
  if (!zone) throw new Error(`Khong tim thay vung #${zoneId}`);
  return zone;
}

async function clean(zoneId) {
  const zone = await getZone(zoneId);
  const { data, error } = await supabaseAdmin
    .from('safe_zone_events')
    .delete()
    .eq('safe_zone_id', zone.id)
    .like('address', `${SIM_TAG}%`)
    .select('id');
  if (error) throw error;
  console.log(`Da xoa ${data?.length ?? 0} su kien mo phong cua vung "${zone.name}".`);
}

async function simulate(zoneId) {
  const steps = Math.max(1, Math.min(20, readArg('steps', 4)));
  const delaySec = Math.max(0, readArg('delay', 3));
  const zone = await getZone(zoneId);
  if (!zone.is_active) {
    throw new Error(`Vung "${zone.name}" dang TAT. Hay bat vung nay trong app roi chay lai.`);
  }

  const name = await userNames([zone.target_uid, zone.owner_uid]);
  const uid = zone.target_uid;

  // Luu trang thai that de khoi phuc sau khi mo phong (tranh sinh su kien sai
  // o lan cap nhat GPS that tiep theo).
  const { data: originalState } = await supabaseAdmin
    .from('safe_zone_states')
    .select('*')
    .eq('safe_zone_id', zone.id)
    .eq('uid', uid)
    .maybeSingle();

  const inside = { lat: zone.center_latitude, lng: zone.center_longitude };
  const outside = {
    lat: zone.center_latitude + (zone.radius_meters + 200) / 111320,
    lng: zone.center_longitude,
  };

  // Bat dau tu trang thai nguoc voi hien tai de buoc dau tien chac chan tao su kien.
  let goInside = !(originalState?.is_inside ?? false);

  console.log(
    `\nMo phong ${steps} buoc cho ${name(uid)} voi vung "${zone.name}" (${zone.radius_meters}m), moi buoc ${delaySec}s...\n`,
  );

  try {
    for (let i = 1; i <= steps; i++) {
      const point = goInside ? inside : outside;
      const label = goInside ? 'VAO vung' : 'ROI vung';
      await safeZonesService.checkLocationForUser(
        uid,
        point.lat,
        point.lng,
        `${SIM_TAG} ${goInside ? 'Trong' : 'Ngoai'} vung ${zone.name}`,
      );
      console.log(`  ${i}/${steps}  ${new Date().toLocaleTimeString()}  ${label}`);
      goInside = !goInside;
      if (i < steps && delaySec > 0) await sleep(delaySec * 1000);
    }
  } finally {
    await supabaseAdmin
      .from('safe_zone_states')
      .delete()
      .eq('safe_zone_id', zone.id)
      .eq('uid', uid);
    if (originalState) {
      const { id, ...rest } = originalState;
      await supabaseAdmin.from('safe_zone_states').insert(rest);
    }
  }

  console.log(
    `\nXong! Mo app (tai khoan cung gia dinh) -> Quan ly vung an toan -> Lich su di chuyen -> chon "${name(uid)}" -> keo xuong de lam moi.`,
  );
  console.log(`Xoa du lieu mo phong: npm run simulate:zone -- ${zone.id} --clean\n`);
}

(async () => {
  const zoneId = Number(process.argv[2]);
  if (!Number.isInteger(zoneId) || zoneId <= 0) {
    await listZones();
  } else if (process.argv.includes('--clean')) {
    await clean(zoneId);
  } else {
    await simulate(zoneId);
  }
  process.exit(0);
})().catch((error) => {
  console.error('Loi:', error?.message || error);
  process.exit(1);
});
