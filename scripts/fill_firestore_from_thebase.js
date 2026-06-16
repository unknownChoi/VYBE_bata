// 더 베이스(62VaHypRMWcCySNQZEaa) Firestore 데이터를 나머지 클럽에 복제.
// CLAUDE.md 구조 기준. Storage는 이미 복사돼 있다고 가정(gallery/boards/menu이미지).
//
// 클럽별 작업:
//   1) clubs/{id} 문서: imageUrls(23) / heroImageUrls(5) / menuBoardUrls(3) +
//      operatingHours / ratingSum / reviewCount / rating  (없는 필드 채움)
//   2) clubs/{id}/info/{id}        : 더 베이스 info 복제
//   3) clubs/{id}/menus/{menuId}   : 더 베이스 17개 메뉴 복제(imageUrl clubId 치환)
//   4) clubs/{id}/reviews/{auto}   : 더 베이스 5개 리뷰 복제(clubId 치환, imageUrls 비움)
//   * photos 서브컬렉션은 별도 scripts/seed_photos.js 로 처리(imageUrls→photos)
//
// 실행: gcloud 로그인 상태에서  node scripts/fill_firestore_from_thebase.js
//   --dry   : 쓰지 않고 계획만
//   --force : 이미 채워진 클럽도 덮어씀(기본은 menus 있으면 skip)

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const BUCKET = 'vybe-bata-c07aa.firebasestorage.app';
const BASE = '62VaHypRMWcCySNQZEaa';
const CONCURRENCY = 6;
const DRY = process.argv.includes('--dry');
const FORCE = process.argv.includes('--force');
const enc = encodeURIComponent;

function request(options, body) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (c) => (data += c));
      res.on('end', () => resolve({ status: res.statusCode, body: data }));
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}
const gcs = (t, m, p) =>
  request({ hostname: 'storage.googleapis.com', path: p, method: m, headers: { Authorization: `Bearer ${t}` } });
const fsReq = (t, m, p, b) =>
  request(
    {
      hostname: 'firestore.googleapis.com',
      path: p,
      method: m,
      headers: { Authorization: `Bearer ${t}`, 'Content-Type': 'application/json', ...(b ? { 'Content-Length': Buffer.byteLength(b) } : {}) },
    },
    b
  );

const DOCROOT = `/v1/projects/${PROJECT}/databases/(default)/documents`;

async function listObjects(token, prefix) {
  const items = [];
  let pageToken = '';
  do {
    const qs = `prefix=${enc(prefix)}&maxResults=1000&fields=items(name),nextPageToken${pageToken ? `&pageToken=${enc(pageToken)}` : ''}`;
    const res = await gcs(token, 'GET', `/storage/v1/b/${enc(BUCKET)}/o?${qs}`);
    const json = JSON.parse(res.body);
    (json.items || []).forEach((it) => items.push(it.name));
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return items;
}
const mediaUrl = (path) => `https://firebasestorage.googleapis.com/v0/b/${BUCKET}/o/${enc(path)}?alt=media`;
const arrVal = (urls) => ({ arrayValue: { values: urls.map((u) => ({ stringValue: u })) } });

async function listClubIds(token) {
  const ids = [];
  let pageToken = '';
  do {
    const qs = `pageSize=300&mask.fieldPaths=name${pageToken ? `&pageToken=${enc(pageToken)}` : ''}`;
    const res = await fsReq(token, 'GET', `${DOCROOT}/clubs?${qs}`);
    const json = JSON.parse(res.body);
    (json.documents || []).forEach((d) => ids.push(d.name.split('/').pop()));
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return ids;
}

async function getDoc(token, path) {
  const res = await fsReq(token, 'GET', `${DOCROOT}/${path}`);
  if (res.status !== 200) throw new Error(`get ${path}: ${res.status}`);
  return JSON.parse(res.body).fields;
}
async function listDocs(token, coll) {
  const out = [];
  let pageToken = '';
  do {
    const qs = `pageSize=300${pageToken ? `&pageToken=${enc(pageToken)}` : ''}`;
    const res = await fsReq(token, 'GET', `${DOCROOT}/${coll}?${qs}`);
    const json = JSON.parse(res.body);
    (json.documents || []).forEach((d) => out.push({ id: d.name.split('/').pop(), fields: d.fields }));
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return out;
}

// 특정 필드만 PATCH (기존 필드 보존)
async function patchFields(token, path, fields) {
  const mask = Object.keys(fields).map((k) => `updateMask.fieldPaths=${enc(k)}`).join('&');
  const body = JSON.stringify({ fields });
  const res = await fsReq(token, 'PATCH', `${DOCROOT}/${path}?${mask}`, body);
  if (res.status !== 200) throw new Error(`patch ${path}: ${res.status} ${res.body.slice(0, 120)}`);
}
// 문서 전체 생성/교체
async function putDoc(token, path, fields) {
  const body = JSON.stringify({ fields });
  const res = await fsReq(token, 'PATCH', `${DOCROOT}/${path}`, body);
  if (res.status !== 200) throw new Error(`put ${path}: ${res.status} ${res.body.slice(0, 120)}`);
}
async function addDoc(token, coll, fields) {
  const body = JSON.stringify({ fields });
  const res = await fsReq(token, 'POST', `${DOCROOT}/${coll}`, body);
  if (res.status !== 200) throw new Error(`add ${coll}: ${res.status} ${res.body.slice(0, 120)}`);
}

// imageUrl 안의 BASE clubId → target 으로 치환
function swapClubIdInImageUrl(field, targetId) {
  if (!field || !field.stringValue) return field;
  return { stringValue: field.stringValue.split(BASE).join(targetId) };
}

function galleryUrls(objs, id) {
  return objs
    .filter((n) => n.includes(`/${id}/gallery/`))
    .sort((a, b) => parseInt(a.split('/').pop()) - parseInt(b.split('/').pop()))
    .map(mediaUrl);
}
function boardUrls(objs, id) {
  return objs
    .filter((n) => n.includes(`/${id}/menus/boards/`))
    .sort()
    .map(mediaUrl);
}

async function hasMenus(token, id) {
  const res = await fsReq(token, 'GET', `${DOCROOT}/clubs/${id}/menus?pageSize=1&fields=documents(name)`);
  return (JSON.parse(res.body).documents || []).length > 0;
}

async function pool(tasks, n, onDone) {
  let idx = 0, ok = 0, fail = 0;
  async function w() {
    while (idx < tasks.length) {
      const my = idx++;
      try { await tasks[my](); ok++; } catch (e) { fail++; console.error('  ✗', String(e.message).slice(0, 120)); }
      if (onDone) onDone(ok + fail, tasks.length);
    }
  }
  await Promise.all(Array.from({ length: n }, w));
  return { ok, fail };
}

async function run() {
  const token = execSync('gcloud auth print-access-token').toString().trim();

  // 베이스 템플릿 로드
  const baseClub = await getDoc(token, `clubs/${BASE}`);
  const baseInfo = await getDoc(token, `clubs/${BASE}/info/${BASE}`);
  const baseMenus = await listDocs(token, `clubs/${BASE}/menus`);
  const baseReviews = await listDocs(token, `clubs/${BASE}/reviews`);
  console.log(`베이스: menus ${baseMenus.length}, reviews ${baseReviews.length}, info 1`);

  const tmpl = {
    operatingHours: baseClub.operatingHours,
    ratingSum: baseClub.ratingSum,
    reviewCount: baseClub.reviewCount,
    rating: baseClub.rating,
  };

  const allObjs = await listObjects(token, 'clubs/');
  const ids = (await listClubIds(token)).filter((id) => id !== BASE);
  console.log(`타깃 ${ids.length}개 클럽\n`);

  const tasks = [];
  let skip = 0;
  for (const id of ids) {
    if (!FORCE && (await hasMenus(token, id))) { skip++; continue; }

    const gal = galleryUrls(allObjs, id);
    const boards = boardUrls(allObjs, id);
    const hero = gal.slice(0, 5);

    tasks.push(async () => {
      // 1) 클럽 문서 필드 채우기
      await patchFields(token, `clubs/${id}`, {
        imageUrls: arrVal(gal),
        heroImageUrls: arrVal(hero),
        menuBoardUrls: arrVal(boards),
        operatingHours: tmpl.operatingHours,
        ratingSum: tmpl.ratingSum,
        reviewCount: tmpl.reviewCount,
        rating: tmpl.rating,
        updatedAt: { timestampValue: new Date().toISOString() },
      });
      // 2) info
      await putDoc(token, `clubs/${id}/info/${id}`, baseInfo);
      // 3) menus (같은 menuId, imageUrl clubId 치환, clubId 필드 세팅)
      for (const m of baseMenus) {
        const f = { ...m.fields };
        f.clubId = { stringValue: id };
        if (f.imageUrl) f.imageUrl = swapClubIdInImageUrl(f.imageUrl, id);
        await putDoc(token, `clubs/${id}/menus/${m.id}`, f);
      }
      // 4) reviews (auto id, clubId 치환, imageUrls 비움)
      for (const r of baseReviews) {
        const f = { ...r.fields };
        f.clubId = { stringValue: id };
        f.imageUrls = { arrayValue: { values: [] } };
        await addDoc(token, `clubs/${id}/reviews`, f);
      }
    });
  }

  console.log(`처리 ${tasks.length} 클럽, skip ${skip}` + (DRY ? '  (dry run)' : ''));
  if (DRY) return;

  let last = -1;
  const { ok, fail } = await pool(tasks, CONCURRENCY, (d, t) => {
    const pct = Math.floor((d / t) * 100);
    if (pct !== last && pct % 10 === 0) { last = pct; console.log(`  ${pct}% (${d}/${t} 클럽)`); }
  });
  console.log(`\n완료! 성공 ${ok} 클럽, 실패 ${fail}, skip ${skip}`);
}

run();
