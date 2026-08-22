// 테이블 배치 편집기 — 로컬 테스트용 업주 페이지 서버.
//
// 실행:  node scripts/table_editor_server.js   →  http://127.0.0.1:5599
//   --port=NNNN 로 포트 변경
//
// 하는 일: scripts/table_editor.html 을 띄우고, 브라우저의 조회/저장 요청을
// Firestore REST 로 넘긴다. 인증은 다른 seed 스크립트와 같은 `gcloud auth
// print-access-token` — 브라우저에는 자격증명이 전혀 안 나간다.
//
// ⚠ 이건 **로컬 확인용 도구**다. gcloud 자격증명으로 붙으므로 Security Rules 를
//   거치지 않는다(파트너 클레임 검사도 안 탄다). 실제 업주용 웹은 같은 Firebase
//   프로젝트 Auth 로 로그인해 partner 클레임으로 Rules 를 통과해야 한다 —
//   firestore.rules 의 clubs/{clubId}/tableLayout 규칙 참고.
// ⚠ 127.0.0.1 에만 바인딩한다. 외부에 열지 말 것.
//
// 쓰기는 commit + updateMask 없는 update = **문서 전체 교체**(set 과 같다).
// 배치도가 한 문서라 저장이 원자적이고, 앱이 반쯤 옮겨진 배치도를 읽는 상태가 없다.

const { execSync } = require('child_process');
const fs = require('fs');
const http = require('http');
const https = require('https');
const path = require('path');

const PROJECT = 'vybe-bata-c07aa';
const PORT = Number(
  (process.argv.find((a) => a.startsWith('--port=')) || '').split('=')[1] || 5599
);
const HTML_PATH = path.join(__dirname, 'table_editor.html');
// 편집 로직·스타일은 업주 웹(partner/)과 공용이다 — 여기서 그대로 서빙한다.
const PARTNER_DIR = path.join(__dirname, '..', 'partner');
const DOC_ROOT = `projects/${PROJECT}/databases/(default)/documents`;

// ── 액세스 토큰 (만료 대비 5분 캐시) ──

let cachedToken = null;
let cachedAt = 0;

function accessToken() {
  const now = Date.now();
  if (cachedToken && now - cachedAt < 5 * 60 * 1000) return cachedToken;
  cachedToken = execSync('gcloud auth print-access-token').toString().trim();
  cachedAt = now;
  return cachedToken;
}

// ── Firestore REST ──

function fsReq(method, urlPath, body) {
  const payload = body ? JSON.stringify(body) : null;
  return new Promise((resolve, reject) => {
    const req = https.request(
      {
        hostname: 'firestore.googleapis.com',
        path: urlPath,
        method,
        headers: {
          Authorization: `Bearer ${accessToken()}`,
          'Content-Type': 'application/json',
          ...(payload ? { 'Content-Length': Buffer.byteLength(payload) } : {}),
        },
      },
      (res) => {
        let data = '';
        res.on('data', (c) => (data += c));
        res.on('end', () => resolve({ status: res.statusCode, body: data }));
      }
    );
    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

function toValue(v) {
  if (v === null || v === undefined) return { nullValue: null };
  if (typeof v === 'boolean') return { booleanValue: v };
  if (typeof v === 'number') {
    return Number.isInteger(v)
      ? { integerValue: String(v) }
      : { doubleValue: v };
  }
  if (typeof v === 'string') return { stringValue: v };
  if (v instanceof Date) return { timestampValue: v.toISOString() };
  if (Array.isArray(v)) return { arrayValue: { values: v.map(toValue) } };
  return { mapValue: { fields: toFields(v) } };
}

function toFields(obj) {
  const out = {};
  for (const [k, v] of Object.entries(obj)) out[k] = toValue(v);
  return out;
}

function fromValue(v) {
  if (!v || typeof v !== 'object') return null;
  if ('nullValue' in v) return null;
  if ('booleanValue' in v) return v.booleanValue;
  if ('integerValue' in v) return Number(v.integerValue);
  if ('doubleValue' in v) return Number(v.doubleValue);
  if ('stringValue' in v) return v.stringValue;
  if ('timestampValue' in v) return v.timestampValue;
  if ('arrayValue' in v) return (v.arrayValue.values || []).map(fromValue);
  if ('mapValue' in v) return fromFields(v.mapValue.fields || {});
  return null;
}

function fromFields(fields) {
  const out = {};
  for (const [k, v] of Object.entries(fields)) out[k] = fromValue(v);
  return out;
}

// ── API ──

async function listClubs() {
  const clubs = [];
  let pageToken = '';
  do {
    const qs = `pageSize=300&mask.fieldPaths=name&mask.fieldPaths=area${
      pageToken ? `&pageToken=${encodeURIComponent(pageToken)}` : ''
    }`;
    const res = await fsReq('GET', `/v1/${DOC_ROOT}/clubs?${qs}`);
    if (res.status !== 200) throw new Error(`list clubs ${res.status}: ${res.body}`);
    const json = JSON.parse(res.body);
    for (const doc of json.documents || []) {
      clubs.push({
        id: doc.name.split('/').pop(),
        name: doc.fields?.name?.stringValue || '(이름 없음)',
        area: doc.fields?.area?.stringValue || '',
      });
    }
    pageToken = json.nextPageToken || '';
  } while (pageToken);

  clubs.sort((a, b) => a.name.localeCompare(b.name, 'ko'));
  return clubs;
}

async function getLayout(clubId) {
  const res = await fsReq(
    'GET',
    `/v1/${DOC_ROOT}/clubs/${clubId}/tableLayout/${clubId}`
  );
  if (res.status === 404) return null;
  if (res.status !== 200) throw new Error(`get layout ${res.status}: ${res.body}`);
  return fromFields(JSON.parse(res.body).fields || {});
}

async function saveLayout(clubId, layout) {
  const doc = {
    ...layout,
    clubId,
    updatedAt: new Date(),
    updatedBy: 'table_editor',
  };
  const res = await fsReq('POST', `/v1/${DOC_ROOT}:commit`, {
    writes: [
      {
        update: {
          name: `${DOC_ROOT}/clubs/${clubId}/tableLayout/${clubId}`,
          fields: toFields(doc),
        },
      },
    ],
  });
  if (res.status !== 200) throw new Error(`commit ${res.status}: ${res.body}`);
}

async function deleteLayout(clubId) {
  const res = await fsReq(
    'DELETE',
    `/v1/${DOC_ROOT}/clubs/${clubId}/tableLayout/${clubId}`
  );
  if (res.status !== 200) throw new Error(`delete ${res.status}: ${res.body}`);
}

// ── HTTP ──

function json(res, status, obj) {
  const body = JSON.stringify(obj);
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Content-Length': Buffer.byteLength(body),
  });
  res.end(body);
}

function sendFile(res, filePath, type) {
  const body = fs.readFileSync(filePath);
  res.writeHead(200, {
    'Content-Type': type,
    'Content-Length': body.length,
    // 편집기를 고치는 중에 브라우저가 예전 파일을 붙들고 있으면 안 된다.
    'Cache-Control': 'no-store',
  });
  res.end(body);
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', (c) => {
      data += c;
      // 배치도 한 장이 1MB 를 넘을 일이 없다 — 넘으면 잘못된 요청이다.
      if (data.length > 2 * 1024 * 1024) reject(new Error('body too large'));
    });
    req.on('end', () => {
      try {
        resolve(data ? JSON.parse(data) : {});
      } catch (e) {
        reject(e);
      }
    });
  });
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://127.0.0.1:${PORT}`);
  const clubId = url.searchParams.get('clubId');

  try {
    if (url.pathname === '/' || url.pathname === '/index.html') {
      return sendFile(res, HTML_PATH, 'text/html; charset=utf-8');
    }
    if (url.pathname === '/editor.js') {
      return sendFile(res, path.join(PARTNER_DIR, 'editor.js'), 'text/javascript; charset=utf-8');
    }
    if (url.pathname === '/editor.css') {
      return sendFile(res, path.join(PARTNER_DIR, 'editor.css'), 'text/css; charset=utf-8');
    }

    if (url.pathname === '/api/clubs' && req.method === 'GET') {
      return json(res, 200, { clubs: await listClubs() });
    }

    if (url.pathname === '/api/layout') {
      if (!clubId) return json(res, 400, { error: 'clubId 가 필요하다' });

      if (req.method === 'GET') {
        return json(res, 200, { layout: await getLayout(clubId) });
      }
      if (req.method === 'PUT') {
        const layout = await readBody(req);
        await saveLayout(clubId, layout);
        return json(res, 200, { ok: true });
      }
      if (req.method === 'DELETE') {
        await deleteLayout(clubId);
        return json(res, 200, { ok: true });
      }
    }

    json(res, 404, { error: 'not found' });
  } catch (e) {
    console.error(e);
    json(res, 500, { error: String(e.message || e) });
  }
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`테이블 배치 편집기  →  http://127.0.0.1:${PORT}`);
  console.log(`프로젝트: ${PROJECT} (gcloud 자격증명 사용 — Rules 우회)`);
});
