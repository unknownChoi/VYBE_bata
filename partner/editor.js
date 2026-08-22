// 테이블 배치 편집기 — 편집 로직 단일 소스.
//
// 로컬 도구(scripts/table_editor.html)와 업주 웹(partner/index.html)이 이 파일을 **같이** 쓴다.
// 복붙으로 나눠 가지면 두 화면이 같은 배치도를 다르게 그리게 되고, 그 순간
// "웹과 앱의 데이터가 같아야 한다"는 요구가 조용히 깨진다.
//
// 전송 계층은 여기 없다 — 호출부가 api 를 넘긴다:
//   api.listClubs()                → [{ id, name, area }]
//   api.getLayout(clubId)          → 문서 객체 | null
//   api.saveLayout(clubId, layout) → 저장(문서 전체 교체). 실패하면 throw
//   api.deleteLayout(clubId)       → 삭제. 없으면 삭제 버튼을 숨긴다
//
// 앱 쪽 대응: lib/data/models/club_table_layout.dart (파서) ·
//             lib/presentation/clubs/widgets/table_floor_map.dart (렌더)

// ===========================================================================
// 팔레트 — 앱과 같은 값이어야 한다
// ===========================================================================

export const COLOR_KEYS = ['purple', 'blue', 'lime', 'pink', 'amber', 'gray'];

// lib/data/models/table_layout_palette.dart 와 같은 값.
// 여기가 어긋나면 업주가 보는 색과 앱이 보여주는 색이 달라진다.
const TIER_STYLE = {
  purple: { text: '#C8A8FF', dot: '#7731FE', fill: 'rgba(119,49,254,.16)', border: 'rgba(119,49,254,.5)' },
  blue:   { text: '#8FB5FF', dot: '#2B6BFF', fill: 'rgba(43,107,255,.14)', border: 'rgba(43,107,255,.5)' },
  lime:   { text: '#D3FFA0', dot: '#B5FF60', fill: 'rgba(181,255,96,.14)', border: 'rgba(181,255,96,.5)' },
  pink:   { text: '#FFA8C8', dot: '#FF4D8D', fill: 'rgba(255,77,141,.14)', border: 'rgba(255,77,141,.5)' },
  amber:  { text: '#FFD79A', dot: '#FFA726', fill: 'rgba(255,167,38,.14)', border: 'rgba(255,167,38,.5)' },
  gray:   { text: '#DBDBDC', dot: '#9F9FA1', fill: 'rgba(255,255,255,.05)', border: 'rgba(255,255,255,.2)' },
};

const FX_STYLE = {
  stage:      { fill: 'rgba(119,49,254,.15)', border: 'rgba(119,49,254,.5)', text: '#C8A8FF' },
  dj:         { fill: 'rgba(119,49,254,.15)', border: 'rgba(119,49,254,.5)', text: '#C8A8FF' },
  dancefloor: { fill: 'rgba(255,255,255,.015)', border: '#535355', text: '#9F9FA1' },
  wall:       { fill: 'rgba(255,255,255,.1)', border: 'rgba(255,255,255,.1)', text: 'transparent' },
  _default:   { fill: 'rgba(255,255,255,.04)', border: '#404042', text: '#CACACA' },
};

// FixtureType enum(club_table_layout.dart)과 키가 같아야 한다.
// 앱이 모르는 키는 조용히 버리므로, 여기서만 늘리면 화면에 안 나온다.
const FX_LABEL = {
  stage: 'STAGE', dancefloor: 'DANCE FLOOR', bar: 'BAR', dj: 'DJ BOOTH',
  entrance: 'ENTRANCE', restroom: 'RESTROOM', stairs: 'STAIRS', wall: '', etc: '',
};

const FX_OPTIONS = [
  ['stage', '무대 stage'], ['dj', 'DJ 부스 dj'], ['dancefloor', '댄스플로어 dancefloor'],
  ['bar', '바 bar'], ['entrance', '입구 entrance'], ['restroom', '화장실 restroom'],
  ['stairs', '계단 stairs'], ['wall', '벽 wall'], ['etc', '기타 etc'],
];

// club_table_layout.dart 의 kMinTableSpan · kMaxGridCols 와 같아야 한다.
// 열 상한 14 는 탭 타겟 44px 보장의 한쪽 축 — 늘리면 앱에서 못 누르는 테이블이 생긴다.
export const MIN_TABLE_SPAN = 2;
export const MAX_COLS = 14, MIN_COLS = 4, MAX_ROWS = 32, MIN_ROWS = 4;
const SCHEMA_VERSION = 1;

// ===========================================================================
// 마크업
// ===========================================================================

const HTML = `
<header class="ed-header">
  <h1 data-el="title">테이블 배치</h1>
  <select data-el="clubSel"><option>불러오는 중…</option></select>
  <span data-el="status" class="ed-status muted">—</span>
  <span class="spacer"></span>
  <span data-el="headerExtra"></span>
  <button data-el="reloadBtn">되돌리기</button>
  <button data-el="deleteBtn" class="danger">배치도 삭제</button>
  <button data-el="saveBtn" class="primary">저장</button>
</header>

<main class="ed-main">
  <div>
    <div class="card">
      <div class="row" data-el="floorBar"></div>
      <div class="row" style="margin-top:10px">
        <label class="field">열 (cols)
          <input type="number" data-el="colsInp" min="${MIN_COLS}" max="${MAX_COLS}" />
        </label>
        <label class="field">행 (rows)
          <input type="number" data-el="rowsInp" min="${MIN_ROWS}" max="${MAX_ROWS}" />
        </label>
        <label class="field" style="flex:1">층 이름
          <input type="text" data-el="floorNameInp" />
        </label>
        <button data-el="addFloorBtn">＋ 층</button>
        <button data-el="delFloorBtn" class="danger">층 삭제</button>
      </div>
      <div class="hint">
        열은 최대 ${MAX_COLS} — 가장 좁은 기기(iPhone SE)에서도 셀 ≈23px, 테이블 최소 2칸 ≈46px 로
        탭 타겟 44px 하한이 격자 규칙만으로 보장된다. 셀은 정사각이라 캔버스 비율(cols/rows)이
        앱과 자동으로 같아진다.
      </div>
    </div>

    <div class="card">
      <div class="row">
        <button data-el="addTableBtn">＋ 테이블</button>
        <select data-el="fxTypeSel">
          ${FX_OPTIONS.map(([v, t]) => `<option value="${v}">${t}</option>`).join('')}
        </select>
        <button data-el="addFxBtn">＋ 구조물</button>
        <span class="muted">끌어서 이동 · 우하단 초록 손잡이로 크기 조절</span>
      </div>
      <div class="ed-canvas-wrap" data-el="canvasWrap" style="margin-top:12px">
        <div class="ed-canvas" data-el="canvas"><div class="ed-grid" data-el="grid"></div></div>
      </div>
      <div class="legend" data-el="legend"></div>
    </div>
  </div>

  <div>
    <div class="card">
      <h2>선택 항목</h2>
      <div data-el="inspector" class="muted">항목을 클릭하세요.</div>
    </div>

    <div class="card">
      <h2>등급</h2>
      <div class="list" data-el="tierList"></div>
      <div class="row" style="margin-top:8px">
        <button data-el="addTierBtn">＋ 등급</button>
      </div>
    </div>

    <div class="card">
      <h2>안내 문구</h2>
      <textarea data-el="noticeInp" rows="3" style="width:100%"></textarea>
    </div>
  </div>
</main>
`;

// ===========================================================================
// 편집기
// ===========================================================================

/**
 * @param {HTMLElement} root  마운트할 컨테이너
 * @param {object} api        전송 계층 (파일 상단 주석 참고)
 * @param {object} [opts]     { title, headerExtra: HTMLElement }
 */
export function mountEditor(root, api, opts = {}) {
  root.innerHTML = HTML;
  const $ = (name) => root.querySelector(`[data-el="${name}"]`);

  if (opts.title) $('title').textContent = opts.title;
  if (opts.headerExtra) $('headerExtra').appendChild(opts.headerExtra);
  if (!api.deleteLayout) $('deleteBtn').remove();

  let clubs = [];
  let clubId = '';
  let layout = null;   // { schemaVersion, tiers, floors, notice }
  let fi = 0;          // 현재 층 index
  let sel = null;      // { kind: 'table'|'fixture', id }
  let dirty = false;

  // ── 기본값 ──

  const blankFloor = (i) => ({
    floorId: 'f' + (i + 1) + '_' + Math.random().toString(36).slice(2, 7),
    name: (i + 1) + 'F',
    order: i,
    cols: 12,
    rows: 16,
    fixtures: [],
    tables: [],
  });

  const blankLayout = () => ({
    schemaVersion: SCHEMA_VERSION,
    tiers: [
      { key: 'vvip', name: 'VVIP', short: 'VVIP', colorKey: 'purple', order: 0 },
      { key: 'vip', name: 'VIP', short: 'VIP', colorKey: 'blue', order: 1 },
      { key: 'std', name: 'STANDARD', short: 'STD', colorKey: 'gray', order: 2 },
    ],
    floors: [blankFloor(0)],
    notice: '가격 및 예약 조건은 요일·이벤트에 따라 변동될 수 있습니다.',
  });

  // ── 유틸 ──

  const floor = () => layout.floors[fi];
  const clamp = (v, lo, hi) => Math.max(lo, Math.min(hi, v));

  function priceShort(won) {
    won = Number(won) || 0;
    if (won <= 0) return '문의';
    if (won < 10000) return won.toLocaleString('ko-KR');
    const man = won / 10000;
    return (won % 10000 === 0 ? man : man.toFixed(1)) + '만';
  }

  const tierOf = (key) =>
    layout.tiers.find((t) => t.key === key)
    || { key: '', name: 'TABLE', short: 'TBL', colorKey: 'gray', order: 999 };

  const overlaps = (a, b) =>
    a.col < b.col + b.colSpan && b.col < a.col + a.colSpan
    && a.row < b.row + b.rowSpan && b.row < a.row + a.rowSpan;

  // 테이블끼리만 겹침을 막는다. 구조물은 벽·바닥처럼 겹쳐 쓰는 경우가 있어 허용한다
  // (앱은 구조물을 먼저 그리고 테이블을 그 위에 얹는다).
  const collides = (rect, exceptId) =>
    floor().tables.some((t) => t.id !== exceptId && overlaps(rect, t));

  function uid(prefix) {
    let n = 1;
    const all = [...floor().tables, ...floor().fixtures].map((x) => x.id);
    while (all.includes(prefix + n)) n++;
    return prefix + n;
  }

  function setStatus(msg, cls) {
    $('status').textContent = msg;
    $('status').className = 'ed-status ' + (cls || 'muted');
  }

  function markDirty() {
    dirty = true;
    setStatus('저장 안 됨', 'warn');
  }

  const esc = (s) => String(s == null ? '' : s)
    .replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

  function field(label, type, value, key, options) {
    const head = '<label class="field">' + esc(label);
    if (type === 'select') {
      return head + '<select data-key="' + key + '">'
        + options.map(([v, t]) =>
            '<option value="' + esc(v) + '"' + (String(v) === String(value) ? ' selected' : '') + '>'
            + esc(t) + '</option>').join('')
        + '</select></label>';
    }
    return head + '<input type="' + type + '" data-key="' + key + '" value="' + esc(value) + '" /></label>';
  }

  // ── 렌더 ──

  function renderAll() {
    renderFloorBar();
    renderCanvas();
    renderLegend();
    renderInspector();
    renderTiers();
    $('noticeInp').value = layout.notice || '';
    $('colsInp').value = floor().cols;
    $('rowsInp').value = floor().rows;
    $('floorNameInp').value = floor().name;
  }

  function renderFloorBar() {
    const bar = $('floorBar');
    bar.innerHTML = '';
    layout.floors.forEach((f, i) => {
      const b = document.createElement('button');
      b.textContent = f.name + ' (' + f.tables.length + ')';
      if (i === fi) b.className = 'on';
      b.onclick = () => { fi = i; sel = null; renderAll(); };
      bar.appendChild(b);
    });
  }

  const cellSize = () => ($('canvasWrap').clientWidth || 420) / floor().cols;

  function renderCanvas() {
    const f = floor();
    const canvas = $('canvas');

    // 셀은 정사각 — 폭에서만 구한다. 높이로 따로 구하면 두 값이 어긋나 앱과 그림이 달라진다.
    const cell = cellSize();
    canvas.style.height = (cell * f.rows) + 'px';

    $('grid').style.background =
      'repeating-linear-gradient(to right, rgba(255,255,255,.05) 0 1px, transparent 1px ' + cell + 'px),'
      + 'repeating-linear-gradient(to bottom, rgba(255,255,255,.05) 0 1px, transparent 1px ' + cell + 'px)';

    [...canvas.querySelectorAll('.item')].forEach((el) => el.remove());
    f.fixtures.forEach((x) => canvas.appendChild(itemEl(x, 'fixture', cell)));
    f.tables.forEach((x) => canvas.appendChild(itemEl(x, 'table', cell)));
  }

  function itemEl(item, kind, cell) {
    const el = document.createElement('div');
    el.className = 'item';
    el.style.left = (item.col * cell) + 'px';
    el.style.top = (item.row * cell) + 'px';
    el.style.width = (item.colSpan * cell) + 'px';
    el.style.height = (item.rowSpan * cell) + 'px';

    if (kind === 'table') {
      const st = TIER_STYLE[tierOf(item.tierKey).colorKey] || TIER_STYLE.gray;
      el.style.background = st.fill;
      el.style.border = '1px solid ' + st.border;
      el.style.borderRadius = item.shape === 'circle' ? '999px' : '9px';
      el.innerHTML =
        '<div class="tier" style="color:' + st.text + '">' + esc(tierOf(item.tierKey).short) + '</div>'
        + '<div class="price">' + priceShort(item.price) + '</div>';
    } else {
      const st = FX_STYLE[item.type] || FX_STYLE._default;
      el.style.background = st.fill;
      el.style.border = '1px solid ' + st.border;
      el.style.borderRadius = '10px';
      const label = item.label || FX_LABEL[item.type] || '';
      el.innerHTML = '<div class="fx" style="color:' + st.text + '">' + esc(label) + '</div>';
    }

    if (sel && sel.kind === kind && sel.id === item.id) {
      el.classList.add('sel');
      const h = document.createElement('div');
      h.className = 'handle';
      h.onmousedown = (e) => startResize(e, item, kind);
      el.appendChild(h);
    }

    el.onmousedown = (e) => {
      if (e.target.classList.contains('handle')) return;
      sel = { kind, id: item.id };
      renderCanvas();
      renderInspector();
      startDrag(e, item, kind);
    };
    return el;
  }

  function renderLegend() {
    const used = new Set(layout.floors.flatMap((f) => f.tables.map((t) => t.tierKey)));
    $('legend').innerHTML = layout.tiers
      .filter((t) => used.has(t.key))
      .map((t) => {
        const st = TIER_STYLE[t.colorKey] || TIER_STYLE.gray;
        return '<span><i class="dot" style="background:' + st.dot + '"></i>' + esc(t.name) + '</span>';
      })
      .join('');
  }

  // ── 드래그 / 리사이즈 ──

  function startDrag(e, item, kind) {
    e.preventDefault();
    const cell = cellSize();
    const sx = e.clientX, sy = e.clientY;
    const c0 = item.col, r0 = item.row;
    const f = floor();

    function move(ev) {
      const col = clamp(c0 + Math.round((ev.clientX - sx) / cell), 0, f.cols - item.colSpan);
      const row = clamp(r0 + Math.round((ev.clientY - sy) / cell), 0, f.rows - item.rowSpan);
      if (col === item.col && row === item.row) return;

      const next = { col, row, colSpan: item.colSpan, rowSpan: item.rowSpan };
      if (kind === 'table' && collides(next, item.id)) return; // 겹치면 그 자리엔 안 놓는다
      item.col = col; item.row = row;
      renderCanvas(); renderInspector();
    }
    function up() {
      document.removeEventListener('mousemove', move);
      document.removeEventListener('mouseup', up);
      if (item.col !== c0 || item.row !== r0) markDirty();
    }
    document.addEventListener('mousemove', move);
    document.addEventListener('mouseup', up);
  }

  function startResize(e, item, kind) {
    e.preventDefault();
    e.stopPropagation();
    const cell = cellSize();
    const sx = e.clientX, sy = e.clientY;
    const w0 = item.colSpan, h0 = item.rowSpan;
    const minSpan = kind === 'table' ? MIN_TABLE_SPAN : 1;
    const f = floor();

    function move(ev) {
      const colSpan = clamp(w0 + Math.round((ev.clientX - sx) / cell), minSpan, f.cols - item.col);
      const rowSpan = clamp(h0 + Math.round((ev.clientY - sy) / cell), minSpan, f.rows - item.row);
      if (colSpan === item.colSpan && rowSpan === item.rowSpan) return;

      const next = { col: item.col, row: item.row, colSpan, rowSpan };
      if (kind === 'table' && collides(next, item.id)) return;
      item.colSpan = colSpan; item.rowSpan = rowSpan;
      renderCanvas(); renderInspector();
    }
    function up() {
      document.removeEventListener('mousemove', move);
      document.removeEventListener('mouseup', up);
      if (item.colSpan !== w0 || item.rowSpan !== h0) markDirty();
    }
    document.addEventListener('mousemove', move);
    document.addEventListener('mouseup', up);
  }

  // ── 추가 / 삭제 ──

  /** 빈 자리를 왼쪽 위부터 훑어 찾는다. 없으면 null. */
  function findSpot(colSpan, rowSpan) {
    const f = floor();
    for (let r = 0; r + rowSpan <= f.rows; r++) {
      for (let c = 0; c + colSpan <= f.cols; c++) {
        const rect = { col: c, row: r, colSpan, rowSpan };
        if (!collides(rect, null)) return rect;
      }
    }
    return null;
  }

  function addTable() {
    const spot = findSpot(MIN_TABLE_SPAN, MIN_TABLE_SPAN);
    if (!spot) return alert('빈 자리가 없습니다. 격자를 넓히거나 테이블을 지우세요.');
    const id = uid('T');
    floor().tables.push({
      id,
      tierKey: (layout.tiers[0] || {}).key || '',
      name: '테이블 ' + id,
      desc: '',
      ...spot,
      shape: 'rect',
      price: 0, minPeople: 0, minBottles: 0, minSpend: 0,
      note: '', isActive: true,
    });
    sel = { kind: 'table', id };
    markDirty(); renderAll();
  }

  function addFixture() {
    const id = uid('FX');
    floor().fixtures.push({
      id,
      type: $('fxTypeSel').value,
      label: '',
      col: 0, row: 0,
      colSpan: Math.min(4, floor().cols), rowSpan: 2,
    });
    sel = { kind: 'fixture', id };
    markDirty(); renderAll();
  }

  function deleteSelected() {
    if (!sel) return;
    const f = floor();
    if (sel.kind === 'table') f.tables = f.tables.filter((t) => t.id !== sel.id);
    else f.fixtures = f.fixtures.filter((x) => x.id !== sel.id);
    sel = null;
    markDirty(); renderAll();
  }

  // ── 인스펙터 ──

  function selectedItem() {
    if (!sel) return null;
    const list = sel.kind === 'table' ? floor().tables : floor().fixtures;
    return list.find((x) => x.id === sel.id) || null;
  }

  function renderInspector() {
    const box = $('inspector');
    const item = selectedItem();
    if (!item) { box.className = 'muted'; box.textContent = '항목을 클릭하세요.'; return; }
    box.className = '';
    box.innerHTML = '';

    const add = (html) => {
      const d = document.createElement('div');
      d.className = 'row';
      d.innerHTML = html;
      box.appendChild(d);
    };

    if (sel.kind === 'table') {
      add(field('id', 'text', item.id, 'tid')
        + field('등급', 'select', item.tierKey, 'ttier', layout.tiers.map((t) => [t.key, t.name])));
      add(field('이름', 'text', item.name, 'tname'));
      add(field('설명', 'text', item.desc, 'tdesc'));
      add(field('가격(원)', 'number', item.price, 'tprice')
        + field('최소 주문(원)', 'number', item.minSpend, 'tspend'));
      add(field('최소 인원', 'number', item.minPeople, 'tpeople')
        + field('최소 보틀', 'number', item.minBottles, 'tbottle'));
      add(field('모양', 'select', item.shape, 'tshape', [['rect', '사각'], ['circle', '원형']])
        + field('노출', 'select', String(item.isActive !== false), 'tactive', [['true', '노출'], ['false', '숨김']]));
      add(field('비고', 'text', item.note || '', 'tnote'));
    } else {
      add(field('id', 'text', item.id, 'tid')
        + field('타입', 'select', item.type, 'ftype', FX_OPTIONS));
      add(field('라벨(비우면 기본)', 'text', item.label || '', 'flabel'));
    }

    add(field('col', 'number', item.col, 'pcol')
      + field('row', 'number', item.row, 'prow')
      + field('colSpan', 'number', item.colSpan, 'pcw')
      + field('rowSpan', 'number', item.rowSpan, 'pch'));

    const btns = document.createElement('div');
    btns.className = 'row';
    const del = document.createElement('button');
    del.className = 'danger';
    del.textContent = '삭제';
    del.onclick = deleteSelected;
    btns.appendChild(del);
    box.appendChild(btns);

    box.querySelectorAll('input,select').forEach((el) => {
      el.onchange = () => applyInspector(item);
    });
  }

  function applyInspector(item) {
    const box = $('inspector');
    const get = (k) => {
      const el = box.querySelector('[data-key="' + k + '"]');
      return el ? el.value : null;
    };
    const f = floor();
    const minSpan = sel.kind === 'table' ? MIN_TABLE_SPAN : 1;

    const colSpan = clamp(parseInt(get('pcw'), 10) || minSpan, minSpan, f.cols);
    const rowSpan = clamp(parseInt(get('pch'), 10) || minSpan, minSpan, f.rows);
    const col = clamp(parseInt(get('pcol'), 10) || 0, 0, f.cols - colSpan);
    const row = clamp(parseInt(get('prow'), 10) || 0, 0, f.rows - rowSpan);
    const rect = { col, row, colSpan, rowSpan };

    if (sel.kind === 'table' && collides(rect, item.id)) {
      setStatus('다른 테이블과 겹칩니다 — 위치를 되돌렸습니다', 'err');
    } else {
      Object.assign(item, rect);
    }

    const newId = (get('tid') || '').trim();
    if (newId && newId !== item.id) {
      const taken = [...f.tables, ...f.fixtures].some((x) => x !== item && x.id === newId);
      if (taken) setStatus('id 가 이미 있습니다 — 변경하지 않았습니다', 'err');
      else { item.id = newId; sel.id = newId; }
    }

    if (sel.kind === 'table') {
      item.tierKey = get('ttier');
      item.name = get('tname');
      item.desc = get('tdesc');
      item.price = Math.max(0, parseInt(get('tprice'), 10) || 0);
      item.minSpend = Math.max(0, parseInt(get('tspend'), 10) || 0);
      item.minPeople = Math.max(0, parseInt(get('tpeople'), 10) || 0);
      item.minBottles = Math.max(0, parseInt(get('tbottle'), 10) || 0);
      item.shape = get('tshape');
      item.isActive = get('tactive') === 'true';
      item.note = get('tnote') || '';
    } else {
      item.type = get('ftype');
      item.label = get('flabel') || '';
    }

    markDirty();
    renderCanvas(); renderLegend(); renderInspector();
  }

  // ── 등급 편집 ──

  function renderTiers() {
    const box = $('tierList');
    box.innerHTML = '';
    layout.tiers.forEach((t, i) => {
      const row = document.createElement('div');
      row.className = 'row';
      row.innerHTML =
        field('key', 'text', t.key, 'k' + i)
        + field('이름', 'text', t.name, 'n' + i)
        + field('짧게', 'text', t.short || '', 's' + i)
        + field('색', 'select', t.colorKey, 'c' + i, COLOR_KEYS.map((k) => [k, k]))
        + '<button class="danger" data-del="' + i + '">✕</button>';
      box.appendChild(row);
    });

    box.querySelectorAll('input,select').forEach((el) => {
      el.onchange = () => {
        layout.tiers.forEach((t, i) => {
          const g = (p) => box.querySelector('[data-key="' + p + i + '"]').value;
          t.key = g('k').trim();
          t.name = g('n');
          t.short = g('s');
          t.colorKey = g('c');
          t.order = i;
        });
        markDirty(); renderCanvas(); renderLegend(); renderInspector();
      };
    });
    box.querySelectorAll('[data-del]').forEach((b) => {
      b.onclick = () => {
        const i = Number(b.dataset.del);
        const key = layout.tiers[i].key;
        if (layout.floors.some((f) => f.tables.some((t) => t.tierKey === key))) {
          return alert('이 등급을 쓰는 테이블이 있습니다. 먼저 등급을 바꾸세요.');
        }
        layout.tiers.splice(i, 1);
        markDirty(); renderTiers(); renderLegend();
      };
    });
  }

  // ── 검증 / 저장 ──

  function validate() {
    const errs = [];
    if (!layout.tiers.length) errs.push('등급이 하나도 없습니다.');
    const tierKeys = new Set(layout.tiers.map((t) => t.key));
    if (tierKeys.size !== layout.tiers.length) errs.push('등급 key 가 중복됩니다.');
    if (layout.tiers.some((t) => !t.key)) errs.push('등급 key 가 비어 있습니다.');

    if (!layout.floors.some((f) => f.tables.length > 0)) {
      errs.push('테이블이 한 자리도 없습니다 — 앱이 섹션을 그리지 않습니다.');
    }

    layout.floors.forEach((f) => {
      const ids = new Set();
      [...f.tables, ...f.fixtures].forEach((x) => {
        if (!x.id) errs.push(f.name + ': id 가 빈 항목이 있습니다.');
        if (ids.has(x.id)) errs.push(f.name + ': id 중복 — ' + x.id);
        ids.add(x.id);
      });
      f.tables.forEach((t) => {
        if (t.colSpan < MIN_TABLE_SPAN || t.rowSpan < MIN_TABLE_SPAN) {
          errs.push(f.name + '/' + t.id + ': 테이블은 최소 '
            + MIN_TABLE_SPAN + '×' + MIN_TABLE_SPAN + ' 여야 합니다(탭 타겟).');
        }
        if (t.col + t.colSpan > f.cols || t.row + t.rowSpan > f.rows) {
          errs.push(f.name + '/' + t.id + ': 격자 밖으로 나갔습니다.');
        }
        if (!tierKeys.has(t.tierKey)) {
          errs.push(f.name + '/' + t.id + ': 없는 등급 — ' + t.tierKey);
        }
      });
      for (let i = 0; i < f.tables.length; i++) {
        for (let j = i + 1; j < f.tables.length; j++) {
          if (overlaps(f.tables[i], f.tables[j])) {
            errs.push(f.name + ': ' + f.tables[i].id + ' 와 ' + f.tables[j].id + ' 가 겹칩니다.');
          }
        }
      }
    });
    return errs;
  }

  async function save() {
    const errs = validate();
    if (errs.length) {
      alert('저장 못 함:\n\n' + errs.join('\n'));
      setStatus('검증 실패', 'err');
      return;
    }
    // 테이블 없는 층은 저장할 이유가 없다 — 앱도 목록에서 뺀다.
    const payload = {
      schemaVersion: SCHEMA_VERSION,
      tiers: layout.tiers.map((t, i) => ({ ...t, order: i })),
      floors: layout.floors.filter((f) => f.tables.length > 0).map((f, i) => ({ ...f, order: i })),
      notice: $('noticeInp').value,
    };

    setStatus('저장 중…');
    try {
      await api.saveLayout(clubId, payload);
      dirty = false;
      setStatus('저장됨 · ' + new Date().toLocaleTimeString('ko-KR'), 'ok');
    } catch (e) {
      setStatus('저장 실패: ' + (e.message || e), 'err');
    }
  }

  // ── 로드 ──

  /** 서버에서 온 문서를 편집기가 기대하는 모양으로 채운다(누락 필드 보정). */
  function normalize(doc) {
    const out = {
      schemaVersion: SCHEMA_VERSION,
      tiers: (doc.tiers || []).map((t, i) => ({
        key: t.key || '',
        name: t.name || '',
        short: t.short || t.name || '',
        colorKey: COLOR_KEYS.includes(t.colorKey) ? t.colorKey : 'gray',
        order: t.order ?? i,
      })),
      floors: (doc.floors || []).map((f, i) => ({
        floorId: f.floorId || 'f' + (i + 1),
        name: f.name || (i + 1) + 'F',
        order: f.order ?? i,
        cols: clamp(f.cols || 12, MIN_COLS, MAX_COLS),
        rows: clamp(f.rows || 16, MIN_ROWS, MAX_ROWS),
        fixtures: (f.fixtures || []).map((x) => ({
          id: x.id || '', type: x.type || 'etc', label: x.label || '',
          col: x.col || 0, row: x.row || 0,
          colSpan: x.colSpan || 1, rowSpan: x.rowSpan || 1,
        })),
        tables: (f.tables || []).map((t) => ({
          id: t.id || '', tierKey: t.tierKey || '', name: t.name || '', desc: t.desc || '',
          col: t.col || 0, row: t.row || 0,
          colSpan: t.colSpan || MIN_TABLE_SPAN, rowSpan: t.rowSpan || MIN_TABLE_SPAN,
          shape: t.shape === 'circle' ? 'circle' : 'rect',
          price: t.price || 0, minPeople: t.minPeople || 0,
          minBottles: t.minBottles || 0, minSpend: t.minSpend || 0,
          note: t.note || '', isActive: t.isActive !== false,
        })),
      })),
      notice: doc.notice || '',
    };
    if (!out.tiers.length) out.tiers = blankLayout().tiers;
    if (!out.floors.length) out.floors = [blankFloor(0)];
    out.floors.sort((a, b) => a.order - b.order);
    return out;
  }

  async function loadLayout(id) {
    if (dirty && !confirm('저장하지 않은 변경이 있습니다. 버리고 이동할까요?')) {
      $('clubSel').value = clubId;
      return;
    }
    clubId = id;
    setStatus('불러오는 중…');
    try {
      const doc = await api.getLayout(id);
      layout = doc ? normalize(doc) : blankLayout();
      fi = 0; sel = null; dirty = false;
      setStatus(doc ? '불러옴' : '새 배치도 (아직 저장 안 됨)', doc ? 'ok' : 'warn');
      renderAll();
    } catch (e) {
      setStatus('불러오기 실패: ' + (e.message || e), 'err');
    }
  }

  async function loadClubs() {
    try {
      clubs = await api.listClubs();
    } catch (e) {
      setStatus('클럽 목록 실패: ' + (e.message || e), 'err');
      return;
    }
    if (!clubs.length) {
      setStatus('관리 중인 클럽이 없습니다', 'err');
      $('clubSel').innerHTML = '<option>없음</option>';
      return;
    }
    const selEl = $('clubSel');
    selEl.innerHTML = clubs
      .map((c) => '<option value="' + esc(c.id) + '">' + esc(c.name)
        + (c.area ? ' · ' + esc(c.area) : '') + '</option>')
      .join('');
    selEl.onchange = () => loadLayout(selEl.value);

    // ?clubId=xxx 로 바로 열 수 있다.
    const want = new URLSearchParams(location.search).get('clubId');
    const first = (want && clubs.some((c) => c.id === want)) ? want : clubs[0].id;
    selEl.value = first;
    loadLayout(first);
  }

  // ── 이벤트 ──

  $('addTableBtn').onclick = addTable;
  $('addFxBtn').onclick = addFixture;
  $('saveBtn').onclick = save;
  $('reloadBtn').onclick = () => { dirty = false; loadLayout(clubId); };

  $('addTierBtn').onclick = () => {
    const n = layout.tiers.length;
    layout.tiers.push({
      key: 'tier' + (n + 1), name: 'TIER ' + (n + 1), short: 'T' + (n + 1),
      colorKey: COLOR_KEYS[n % COLOR_KEYS.length], order: n,
    });
    markDirty(); renderTiers(); renderLegend();
  };

  if (api.deleteLayout) {
    $('deleteBtn').onclick = async () => {
      if (!confirm('이 클럽의 배치도 문서를 삭제합니다. 앱에서 테이블 섹션이 사라집니다. 계속할까요?')) return;
      try {
        await api.deleteLayout(clubId);
      } catch (e) {
        return setStatus('삭제 실패: ' + (e.message || e), 'err');
      }
      layout = blankLayout(); fi = 0; sel = null; dirty = false;
      setStatus('삭제됨', 'ok'); renderAll();
    };
  }

  $('addFloorBtn').onclick = () => {
    layout.floors.push(blankFloor(layout.floors.length));
    fi = layout.floors.length - 1; sel = null;
    markDirty(); renderAll();
  };

  $('delFloorBtn').onclick = () => {
    if (layout.floors.length <= 1) return alert('층이 하나뿐입니다.');
    if (!confirm(floor().name + ' 층을 삭제할까요?')) return;
    layout.floors.splice(fi, 1);
    fi = 0; sel = null;
    markDirty(); renderAll();
  };

  $('floorNameInp').onchange = (e) => { floor().name = e.target.value; markDirty(); renderFloorBar(); };
  $('noticeInp').onchange = () => markDirty();

  function resizeGrid(key, min, max) {
    return (e) => {
      const v = clamp(parseInt(e.target.value, 10) || min, min, max);
      const f = floor();
      // 줄이면 밖으로 밀려나는 항목이 생긴다. 앱은 clamp 하지만 그 결과는 업주가
      // 의도한 배치가 아니므로 여기서 막는다.
      const out = [...f.tables, ...f.fixtures].filter((x) =>
        key === 'cols' ? x.col + x.colSpan > v : x.row + x.rowSpan > v);
      if (out.length) {
        alert('격자를 줄이면 밖으로 나가는 항목이 있습니다: ' + out.map((x) => x.id).join(', '));
        e.target.value = f[key];
        return;
      }
      f[key] = v;
      markDirty(); renderCanvas();
    };
  }
  $('colsInp').onchange = resizeGrid('cols', MIN_COLS, MAX_COLS);
  $('rowsInp').onchange = resizeGrid('rows', MIN_ROWS, MAX_ROWS);

  document.addEventListener('keydown', (e) => {
    if ((e.key === 'Delete' || e.key === 'Backspace') && sel
        && !['INPUT', 'TEXTAREA', 'SELECT'].includes(document.activeElement.tagName)) {
      e.preventDefault();
      deleteSelected();
    }
  });

  window.addEventListener('resize', () => { if (layout) renderCanvas(); });
  window.addEventListener('beforeunload', (e) => { if (dirty) e.preventDefault(); });

  loadClubs();

  return { reload: () => loadLayout(clubId) };
}
