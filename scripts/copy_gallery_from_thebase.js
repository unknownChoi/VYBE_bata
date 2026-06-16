// 더 베이스(62VaHypRMWcCySNQZEaa)의 gallery/boards 이미지를
// 나머지 클럽 Storage로 서버사이드 복사. 클럽마다 gallery 순서는 셔플.
//
// - gallery: 소스 23장을 클럽별로 셔플 → clubs/{id}/gallery/{n}.{srcext}
// - boards : clubs/{id}/menus/boards/board_1~3.png (그대로)
// - thumbnail은 건드리지 않음 (이미 클럽별로 존재)
// - menu 아이템 이미지(menuId 명명)는 제외 — Firestore 메뉴 채울 때 처리
//
// 실행: gcloud 로그인 상태에서  node scripts/copy_gallery_from_thebase.js
//   --dry   : 복사 안 하고 계획만 출력
//   --force : 이미 gallery 있는 클럽도 덮어씀 (기본은 skip)

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const BUCKET = 'vybe-bata-c07aa.firebasestorage.app';
const BASE = '62VaHypRMWcCySNQZEaa';
const CONCURRENCY = 8;
const DRY = process.argv.includes('--dry');
const FORCE = process.argv.includes('--force');

function request(options) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (c) => (data += c));
      res.on('end', () => resolve({ status: res.statusCode, body: data }));
    });
    req.on('error', reject);
    req.end();
  });
}

function gcs(token, method, path) {
  return request({
    hostname: 'storage.googleapis.com',
    path,
    method,
    headers: { Authorization: `Bearer ${token}` },
  });
}

function fs_(token, method, path) {
  return request({
    hostname: 'firestore.googleapis.com',
    path,
    method,
    headers: { Authorization: `Bearer ${token}` },
  });
}

const enc = (s) => encodeURIComponent(s);

async function listObjects(token, prefix) {
  const items = [];
  let pageToken = '';
  do {
    const qs = `prefix=${enc(prefix)}&maxResults=1000&fields=items(name,contentType),nextPageToken${
      pageToken ? `&pageToken=${enc(pageToken)}` : ''
    }`;
    const res = await gcs(token, 'GET', `/storage/v1/b/${enc(BUCKET)}/o?${qs}`);
    const json = JSON.parse(res.body);
    (json.items || []).forEach((it) => items.push(it));
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return items;
}

async function listClubIds(token) {
  const ids = [];
  let pageToken = '';
  do {
    const qs = `pageSize=300&mask.fieldPaths=name${pageToken ? `&pageToken=${enc(pageToken)}` : ''}`;
    const res = await fs_(
      token,
      'GET',
      `/v1/projects/${PROJECT}/databases/(default)/documents/clubs?${qs}`
    );
    const json = JSON.parse(res.body);
    (json.documents || []).forEach((d) => ids.push(d.name.split('/').pop()));
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return ids;
}

async function copyObject(token, src, dst) {
  const res = await gcs(
    token,
    'POST',
    `/storage/v1/b/${enc(BUCKET)}/o/${enc(src)}/copyTo/b/${enc(BUCKET)}/o/${enc(dst)}`
  );
  if (res.status !== 200) throw new Error(`${res.status} ${res.body.slice(0, 120)}`);
}

function shuffle(arr) {
  const a = arr.slice();
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

const extOf = (name) => name.slice(name.lastIndexOf('.'));

// 동시성 제한 실행기
async function pool(tasks, n, onDone) {
  let idx = 0;
  let ok = 0;
  let fail = 0;
  async function worker() {
    while (idx < tasks.length) {
      const my = idx++;
      try {
        await tasks[my]();
        ok++;
      } catch (e) {
        fail++;
        console.error('  ✗', String(e.message).slice(0, 100));
      }
      if (onDone) onDone(ok + fail, tasks.length);
    }
  }
  await Promise.all(Array.from({ length: n }, worker));
  return { ok, fail };
}

async function run() {
  const token = execSync('gcloud auth print-access-token').toString().trim();

  const gallerySrc = (await listObjects(token, `clubs/${BASE}/gallery/`)).sort(
    (a, b) =>
      parseInt(a.name.split('/').pop()) - parseInt(b.name.split('/').pop())
  );
  const boardSrc = await listObjects(token, `clubs/${BASE}/menus/boards/`);
  console.log(`소스: gallery ${gallerySrc.length}장, boards ${boardSrc.length}장`);

  const allIds = await listClubIds(token);
  const targets = allIds.filter((id) => id !== BASE);
  console.log(`타깃 클럽 ${targets.length}개 (전체 ${allIds.length} - 더베이스)\n`);

  // 이미 gallery 있는 클럽 skip (force 아니면)
  let skip = [];
  const work = [];
  for (const id of targets) {
    if (!FORCE) {
      const existing = await listObjects(token, `clubs/${id}/gallery/`);
      if (existing.length > 0) {
        skip.push(id);
        continue;
      }
    }
    const shuffled = shuffle(gallerySrc);
    shuffled.forEach((src, i) => {
      const dst = `clubs/${id}/gallery/${i + 1}${extOf(src.name)}`;
      work.push(() => copyObject(token, src.name, dst));
    });
    boardSrc.forEach((src) => {
      const fname = src.name.split('/').pop();
      const dst = `clubs/${id}/menus/boards/${fname}`;
      work.push(() => copyObject(token, src.name, dst));
    });
  }

  const processed = targets.length - skip.length;
  console.log(
    `복사 대상 클럽 ${processed}개, skip ${skip.length}개, 총 복사 ${work.length}건` +
      (DRY ? '  (dry run)' : '')
  );
  if (DRY) return;

  let lastPct = -1;
  const { ok, fail } = await pool(work, CONCURRENCY, (done, total) => {
    const pct = Math.floor((done / total) * 100);
    if (pct !== lastPct && pct % 5 === 0) {
      lastPct = pct;
      console.log(`  ${pct}% (${done}/${total})`);
    }
  });
  console.log(`\n완료! 복사 성공 ${ok}, 실패 ${fail}, skip 클럽 ${skip.length}`);
}

run();
