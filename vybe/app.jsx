/* global React, ReactDOM, IOSDevice, COLORS, TYPO, GRAY, PURPLE, LIME */
const { useState, useRef, useEffect } = React;

// ============ DESIGN TOKENS (디자인 시스템 매핑) ============
const C = {
  bg: COLORS.bg,
  surface: '#17171B',
  divider: '#2A2A2F',
  divider2: '#1F1F23',
  text: COLORS.white,
  text2: GRAY[200],
  text3: GRAY[400],
  text4: GRAY[500],
  text5: GRAY[600],
  text6: GRAY[700],
  purple: PURPLE[500],
  purpleDeep: PURPLE[700],
  purpleSoft: 'rgba(119, 49, 254, 0.14)',
  lime: LIME[500],
  blue: '#2B6BFF',
  line9: '#BD941C',
};

// ============ ICONS (lucide-ish, stroke=1.6) ============
const Icon = ({ d, size = 18, stroke = C.text3, fill = 'none', sw = 1.6 }) =>
<svg width={size} height={size} viewBox="0 0 24 24" fill={fill} stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round">
    {d}
  </svg>;

const IconBack = (p) => <Icon {...p} d={<polyline points="15 18 9 12 15 6" />} />;
const IconShare = (p) => <Icon {...p} d={<><circle cx="18" cy="5" r="3" /><circle cx="6" cy="12" r="3" /><circle cx="18" cy="19" r="3" /><line x1="8.59" y1="13.51" x2="15.42" y2="17.49" /><line x1="15.41" y1="6.51" x2="8.59" y2="10.49" /></>} />;
const IconHeart = ({ active, ...p }) => <Icon {...p} fill={active ? C.purple : 'none'} stroke={active ? C.purple : C.text2} sw={2} d={<path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />} />;
const IconPin = (p) => <Icon {...p} d={<><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" /><circle cx="12" cy="10" r="3" /></>} />;
const IconClock = (p) => <Icon {...p} d={<><circle cx="12" cy="12" r="10" /><polyline points="12 6 12 12 16 14" /></>} />;
const IconTicket = (p) => <Icon {...p} d={<><path d="M2 9a3 3 0 0 1 0 6v2a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-2a3 3 0 0 1 0-6V7a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2z" /><path d="M13 5v2" /><path d="M13 17v2" /><path d="M13 11v2" /></>} />;
const IconLink = (p) => <Icon {...p} d={<><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71" /><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71" /></>} />;
const IconChevDown = (p) => <Icon {...p} sw={2} d={<polyline points="6 9 12 15 18 9" />} />;
const IconChevRight = (p) => <Icon {...p} sw={2} d={<polyline points="9 18 15 12 9 6" />} />;
const IconStar = (p) => <Icon {...p} fill={C.lime} stroke={C.lime} d={<polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />} />;
const IconPhone = (p) => <Icon {...p} d={<path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.13.96.37 1.9.72 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.91.35 1.85.59 2.81.72A2 2 0 0 1 22 16.92z" />} />;
const IconChevLeft = (p) => <Icon {...p} sw={2} d={<polyline points="15 18 9 12 15 6" />} />;

// ============ SECTION DIVIDER ============
const SectionDivider = () => <div style={{ height: 8, background: '#000', borderTop: `1px solid ${C.divider2}`, borderBottom: `1px solid ${C.divider2}` }} />;

// ============ HERO ============
function Hero({ onSaved, saved }) {
  const [idx, setIdx] = useState(0);
  const total = 5;
  const trackRef = useRef(null);
  const dragRef = useRef({ startX: 0, dragging: false });

  const goTo = (i) => {
    const el = trackRef.current;
    if (!el) return;
    el.scrollTo({ left: i * el.clientWidth, behavior: 'smooth' });
    setIdx(i);
  };

  const handleScroll = () => {
    if (!trackRef.current) return;
    const w = trackRef.current.clientWidth;
    const i = Math.round(trackRef.current.scrollLeft / w);
    setIdx(i);
  };

  const onPointerDown = (e) => {
    dragRef.current = { startX: e.clientX, dragging: true };
    e.currentTarget.setPointerCapture(e.pointerId);
  };

  const onPointerMove = (e) => {
    if (!dragRef.current.dragging) return;
    const el = trackRef.current;
    if (!el) return;
    const dx = dragRef.current.startX - e.clientX;
    el.scrollLeft = idx * el.clientWidth + dx;
  };

  const onPointerUp = (e) => {
    if (!dragRef.current.dragging) return;
    dragRef.current.dragging = false;
    const dx = dragRef.current.startX - e.clientX;
    const threshold = 40;
    if (dx > threshold) goTo(Math.min(idx + 1, total - 1));
    else if (dx < -threshold) goTo(Math.max(idx - 1, 0));
    else goTo(idx);
  };

  // 3초마다 자동 스크롤
  useEffect(() => {
    const timer = setInterval(() => {
      setIdx(prev => {
        const next = (prev + 1) % total;
        const el = trackRef.current;
        if (el) el.scrollTo({ left: next * el.clientWidth, behavior: 'smooth' });
        return next;
      });
    }, 3000);
    return () => clearInterval(timer);
  }, [total]);

  const slides = [
    { bg: 'linear-gradient(135deg, #2b1655 0%, #7731FE 60%, #ff4d8d 100%)', label: '메인 플로어', icon: '🪩' },
    { bg: 'linear-gradient(135deg, #0f0f23 0%, #4a2580 50%, #7731FE 100%)', label: 'DJ 부스',    icon: '🎧' },
    { bg: 'linear-gradient(135deg, #1a0b3d 0%, #6622cc 70%, #B5FF60 110%)', label: '바',         icon: '🍸' },
    { bg: 'linear-gradient(135deg, #2a0d4a 0%, #ff4d8d 50%, #7731FE 100%)', label: 'VIP 테이블', icon: '✨' },
    { bg: 'linear-gradient(135deg, #0a0a1f 0%, #2B6BFF 60%, #7731FE 100%)', label: '입구',       icon: '🚪' },
  ];


  return (
    <div style={{ position: 'relative', background: '#000', height: "270px" }}>
      <div
        ref={trackRef}
        onScroll={handleScroll}
        onPointerDown={onPointerDown}
        onPointerMove={onPointerMove}
        onPointerUp={onPointerUp}
        onPointerCancel={onPointerUp}
        style={{ display: 'flex', overflowX: 'auto', scrollSnapType: 'x mandatory', scrollbarWidth: 'none', height: "270px", cursor: 'grab', userSelect: 'none' }}>
        
        {slides.map((s, i) =>
        <div
          key={i}
          style={{
            flex: '0 0 100%',

            background: s.bg,
            scrollSnapAlign: 'start',
            position: 'relative',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            height: 270
          }}>
          
            {/* film-grain overlay */}
            <div style={{
            position: 'absolute', inset: 0,
            background: 'radial-gradient(120% 80% at 50% 30%, rgba(0,0,0,0) 0%, rgba(0,0,0,0.55) 100%)'
          }} />
            {/* light spots — different per slide */}
            <div style={{
              position: 'absolute',
              left: `${20 + i * 14}%`, top: `${15 + (i % 3) * 18}%`,
              width: 140, height: 140, borderRadius: '50%',
              background: 'radial-gradient(circle, rgba(255,255,255,0.18), transparent 60%)',
              filter: 'blur(8px)',
            }} />
            <div style={{
              position: 'absolute',
              right: `${10 + i * 8}%`, bottom: `${20 + (i % 2) * 24}%`,
              width: 100, height: 100, borderRadius: '50%',
              background: i % 2 === 0 ? 'radial-gradient(circle, rgba(181,255,96,0.22), transparent 60%)' : 'radial-gradient(circle, rgba(255,77,141,0.25), transparent 60%)',
              filter: 'blur(10px)',
            }} />
            {/* label */}
            <div style={{
              position: 'absolute', left: 24, bottom: 56,
              display: 'flex', alignItems: 'center', gap: 8,
              padding: '6px 12px', borderRadius: 999,
              background: 'rgba(0,0,0,0.55)', backdropFilter: 'blur(8px)',
              color: '#fff', ...TYPO.caption, lineHeight: '14px', fontWeight: 600,
            }}>
              <span style={{ fontSize: 13 }}>{s.icon}</span>
              {s.label}
            </div>
          </div>
        )}
      </div>

      {/* top scrim */}
      <div style={{ position: 'absolute', top: 0, left: 0, right: 0, height: 130, background: 'linear-gradient(180deg, rgba(0,0,0,0.6), transparent)', pointerEvents: 'none' }} />
      {/* bottom scrim */}
      <div style={{ position: 'absolute', bottom: 0, left: 0, right: 0, height: 120, background: 'linear-gradient(0deg, rgba(14,14,17,1), transparent)', pointerEvents: 'none' }} />

      {/* nav bar overlay */}
      <div style={{ position: 'absolute', top: 54, left: 0, right: 0, padding: '8px 16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <button style={iconBtn}><IconChevLeft size={22} stroke="#fff" /></button>
        <div style={{ display: 'flex', gap: 10 }}>
          <button style={iconBtn}><IconShare size={18} stroke="#fff" /></button>
          <button style={iconBtn} onClick={onSaved}>
          <div style={{
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            transition: 'transform .2s cubic-bezier(0.34, 1.56, 0.64, 1)',
            transform: saved ? 'scale(1.15)' : 'scale(1)',
          }}>
            <IconHeart size={18} active={saved} />
          </div>
        </button>
        </div>
      </div>

      {/* counter */}
      <div style={{ position: 'absolute', right: 16, bottom: 40, padding: '6px 12px', borderRadius: 999, background: 'rgba(0,0,0,0.55)', backdropFilter: 'blur(8px)', fontSize: 12, color: '#fff', fontWeight: 500 }}>
        {idx + 1} / {total}
      </div>

      {/* dot indicator */}
      <div style={{ position: 'absolute', left: 0, right: 0, bottom: 18, display: 'flex', justifyContent: 'center', gap: 5 }}>
        {Array.from({ length: total }).map((_, i) =>
        <div key={i} style={{
          width: i === idx ? 16 : 5, height: 5, borderRadius: 999,
          background: i === idx ? '#fff' : 'rgba(255,255,255,0.4)',
          transition: 'all .25s'
        }} />
        )}
      </div>
    </div>);

}

const iconBtn = {
  width: 36, height: 36, borderRadius: '50%',
  background: 'rgba(0,0,0,0.4)', backdropFilter: 'blur(10px)',
  border: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center',
  cursor: 'pointer', padding: 0
};

// ============ TITLE BLOCK ============
function TitleBlock() {
  return (
    <div style={{ padding: '20px 20px 24px', display: 'flex', flexDirection: 'column', gap: 14 }}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 12, color: C.text4 }}>
          <span>홍대</span>
          <span style={{ width: 1, height: 10, background: C.text6 }} />
          <span>힙합 클럽</span>
        </div>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 12 }}>
          <h1 style={{ ...TYPO.h2, color: '#fff', margin: 0 }}>
            어썸 레드
          </h1>
          <button style={{
            display: 'flex', alignItems: 'center', gap: 5,
            padding: '7px 12px', borderRadius: 999,
            border: `1px solid ${C.divider}`, background: 'transparent',
            color: C.text3, ...TYPO.button2,
            cursor: 'pointer'
          }}>
            <IconPhone size={13} stroke={C.text3} />
            전화
          </button>
        </div>
      </div>

      {/* rating row */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
          <IconStar size={15} />
          <span style={{ fontSize: 15, color: '#fff', fontWeight: 600 }}>4.76</span>
        </div>
        <span style={{ width: 2, height: 2, borderRadius: 99, background: C.text6 }} />
        <span style={{ fontSize: 14, color: C.text3 }}>리뷰 13</span>
      </div>

      <p style={{ fontSize: 15, color: C.text3, lineHeight: 1.5, margin: 0 }}>
        홍대역 인근 입문자에게 좋은 힙합 클럽
      </p>

      {/* tags - fixed */}
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
        {['#힙합', '#대중적', '#무료입장', '#홍대'].map((t) =>
        <span key={t} style={{
          padding: '5px 10px', borderRadius: 99,
          background: C.purpleSoft, color: '#C8A8FF',
          ...TYPO.body4, fontWeight: 500
        }}>{t}</span>
        )}
      </div>
    </div>);

}

// ============ TABS ============
function Tabs({ active, onChange }) {
  const tabs = ['홈', '메뉴', '사진', '리뷰', '매장 정보'];
  return (
    <div style={{
      display: 'flex', borderBottom: `1px solid ${C.divider2}`,
      position: 'sticky', top: 0, background: C.bg, zIndex: 10
    }}>
      {tabs.map((t) => {
        const sel = t === active;
        return (
          <button key={t} onClick={() => onChange(t)} style={{
            flex: 1, padding: '12px 0', textAlign: 'center', cursor: 'pointer',
            background: 'transparent', border: 'none',
            color: sel ? '#fff' : C.text4,
            ...TYPO.button2, fontWeight: sel ? 700 : 500,
            borderBottom: sel ? `2px solid ${C.purple}` : '2px solid transparent',
            transition: 'all .2s'
          }}>{t}</button>);

      })}
    </div>);

}

// ============ INFO SECTION ============
function InfoRow({ icon, children }) {
  return (
    <div style={{ display: 'flex', gap: 12, alignItems: 'flex-start' }}>
      <div style={{ width: 20, marginTop: 1, flexShrink: 0, display: 'flex', justifyContent: 'center' }}>{icon}</div>
      <div style={{ flex: 1, fontSize: 14, color: C.text2, lineHeight: 1.5 }}>{children}</div>
    </div>);

}

function InfoSection() {
  const [open, setOpen] = useState(false);
  const [addrOpen, setAddrOpen] = useState(false);
  const days = [
  ['월', '11:00 - 02:00', true],
  ['화', '11:00 - 02:00'],
  ['수', '11:00 - 02:00'],
  ['목', '11:00 - 02:00'],
  ['금', '11:00 - 02:00'],
  ['토', '11:00 - 02:00'],
  ['일', '정기휴무']];

  return (
    <div style={{ padding: '24px 20px', display: 'flex', flexDirection: 'column', gap: 16 }}>
      <InfoRow icon={<IconPin size={17} stroke={C.text4} />}>
        <button onClick={() => setAddrOpen(!addrOpen)} style={{
          all: 'unset', cursor: 'pointer', width: '100%',
          display: 'flex', alignItems: 'center', justifyContent: 'space-between'
        }}>
          <div>서울 마포구 잔다리로 12 지하 1층</div>
          <div style={{ transform: addrOpen ? 'rotate(180deg)' : 'rotate(0)', transition: 'transform .2s' }}>
            <IconChevDown size={16} stroke={C.text4} />
          </div>
        </button>
        <div style={{
          maxHeight: addrOpen ? 80 : 0, overflow: 'hidden',
          transition: 'max-height .3s ease'
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 10 }}>
            <span style={{
              width: 17, height: 17, borderRadius: 99, background: C.line9,
              color: '#fff', fontSize: 11, fontWeight: 700,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              flexShrink: 0
            }}>9</span>
            <span style={{ fontSize: 13, color: C.text3 }}>상수역 1번 출구에서 422m</span>
          </div>
        </div>
      </InfoRow>

      <InfoRow icon={<IconClock size={17} stroke={C.text4} />}>
        <button onClick={() => setOpen(!open)} style={{
          all: 'unset', cursor: 'pointer', width: '100%',
          display: 'flex', alignItems: 'center', justifyContent: 'space-between'
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <span style={{ color: C.lime, fontWeight: 600, fontSize: 14 }}>영업중</span>
            <span style={{ width: 2, height: 2, borderRadius: 99, background: C.text6 }} />
            <span style={{ fontSize: 14, color: C.text3 }}>02:00에 영업 종료</span>
          </div>
          <div style={{ transform: open ? 'rotate(180deg)' : 'rotate(0)', transition: 'transform .2s' }}>
            <IconChevDown size={16} stroke={C.text4} />
          </div>
        </button>
        <div style={{
          maxHeight: open ? 250 : 0, overflow: 'hidden',
          transition: 'max-height .3s ease'
        }}>
          <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 6 }}>
            {days.map(([d, h, today]) =>
            <div key={d} style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                <span style={{
                width: 18, fontSize: 13,
                color: today ? '#fff' : C.text4,
                fontWeight: today ? 700 : 400
              }}>{d}</span>
                <span style={{
                fontSize: 13,
                color: today ? '#fff' : C.text4,
                fontWeight: today ? 600 : 400
              }}>{h}</span>
                {today && <span style={{
                fontSize: 10, color: C.purple, fontWeight: 700,
                padding: '1px 6px', borderRadius: 4,
                background: C.purpleSoft
              }}>오늘</span>}
              </div>
            )}
          </div>
        </div>
      </InfoRow>

      <InfoRow icon={<IconTicket size={17} stroke={C.text4} />}>
        <span>입장료 <span style={{ color: '#fff', fontWeight: 600 }}>0 ~ 10,000원</span></span>
      </InfoRow>

      <InfoRow icon={<IconLink size={17} stroke={C.text4} />}>
        <a href="#" onClick={(e) => e.preventDefault()} style={{
          color: '#8FB5FF', fontSize: 14, textDecoration: 'none'
        }}>
          @awesomered_omg
        </a>
      </InfoRow>
    </div>);

}

// ============ MENU ============
function MenuItem({ tag, name, desc, price, color }) {
  return (
    <div style={{ display: 'flex', gap: 14, padding: '14px 0', borderBottom: `1px solid ${C.divider2}`, alignItems: 'center' }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 6 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          {tag && <span style={{
            padding: '2px 7px', borderRadius: 4,
            background: C.purple, color: '#fff',
            fontSize: 10, fontWeight: 700, letterSpacing: '0.02em'
          }}>{tag}</span>}
          <span style={{ ...TYPO.body4, color: C.text2, fontWeight: 500 }}>{name}</span>
        </div>
        {desc && <p style={{ fontSize: 12, color: C.text4, margin: 0, lineHeight: 1.4 }}>{desc}</p>}
        <div style={{ fontSize: 16, color: '#fff', fontWeight: 700, marginTop: 2 }}>{price}</div>
      </div>
      <div style={{
        width: 88, height: 88, borderRadius: 10, flexShrink: 0,
        background: color, position: 'relative', overflow: 'hidden'
      }}>
        <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(circle at 30% 30%, rgba(255,255,255,0.25), transparent 60%)' }} />
      </div>
    </div>);

}

function MenuSection() {
  return (
    <div style={{ padding: '24px 20px' }}>
      <SectionHeader title="메뉴" />
      <div style={{ marginTop: 4 }}>
        <MenuItem tag="대표" name="LEMON DROP" desc="레몬 보드카 베이스 · 새콤달콤" price="15,000원"
        color="linear-gradient(135deg, #f7d046, #e8a020)" />
        <MenuItem tag="대표" name="PURPLE HAZE" desc="블루베리 진 토닉" price="16,000원"
        color="linear-gradient(135deg, #7731FE, #2a0d4a)" />
        <MenuItem name="NEGRONI" desc="진 · 캄파리 · 베르무트" price="14,000원"
        color="linear-gradient(135deg, #c0392b, #6e1818)" />
        <MenuItem name="VIP TABLE 패키지" desc="2시간 · 4인 기준 · 보틀 1병" price="120,000원"
        color="linear-gradient(135deg, #2c3e50, #0a0a1f)" />
      </div>
      <p style={{ fontSize: 11, color: C.text5, marginTop: 12, marginBottom: 0 }}>
        메뉴 항목과 가격은 매장 사정에 따라 다를 수 있습니다.
      </p>
    </div>);

}

// ============ MENU TAB (full) ============
const MENU_CATEGORIES = [
  { key: 'signature', label: '대표메뉴' },
  { key: 'set',       label: 'SET' },
  { key: 'hard',      label: 'HARD' },
  { key: 'champagne', label: 'CHAMPAGNE' },
  { key: 'beer',      label: 'BEER' },
  { key: 'cocktail',  label: 'COCKTAIL' },
];

const MENU_GROUPS = {
  signature: {
    label: '대표 메뉴',
    items: [
      { tag: '대표', name: 'LEMON DROP', desc: '레몬 보드카 베이스 · 새콤달콤', price: '15,000원',
        color: 'linear-gradient(135deg, #f7d046, #e8a020)' },
      { tag: '대표', name: 'PURPLE HAZE', desc: '블루베리 진 토닉', price: '16,000원',
        color: 'linear-gradient(135deg, #7731FE, #2a0d4a)' },
    ],
  },
  set: {
    label: 'SET',
    items: [
      { tag: '대표', name: 'HARD SET A',   desc: 'CHOICE A · OPERA BRUIT', price: '220,000원' },
      {            name: 'HARD SET A·B', desc: 'CHOICE A·B · OPERA BRUIT', price: '420,000원' },
      {            name: 'HARD SET B',   desc: 'CHOICE B · HENKELL',       price: '320,000원' },
    ],
  },
  hard: {
    label: 'HARD',
    items: [
      { name: 'JACK DANIEL\'S',   desc: '버번 위스키 · 750ml', price: '180,000원',
        color: 'linear-gradient(135deg, #6e3a1f, #2a160a)' },
      { name: 'CHIVAS REGAL 12',  desc: '스카치 위스키 · 750ml', price: '220,000원',
        color: 'linear-gradient(135deg, #c0392b, #6e1818)' },
      { name: 'GREY GOOSE',       desc: '프렌치 보드카 · 750ml', price: '260,000원',
        color: 'linear-gradient(135deg, #2c3e50, #0a0a1f)' },
    ],
  },
  champagne: {
    label: 'CHAMPAGNE',
    items: [
      { name: 'MOËT & CHANDON',  desc: '브뤼 · 750ml', price: '280,000원' },
      { name: 'VEUVE CLICQUOT',  desc: '옐로우 라벨 · 750ml', price: '320,000원' },
      { name: 'DOM PÉRIGNON',    desc: '빈티지 · 750ml', price: '780,000원' },
    ],
  },
  beer: {
    label: 'BEER',
    items: [
      { name: 'HEINEKEN',  desc: '하이네켄 · 330ml', price: '12,000원' },
      { name: 'CORONA',    desc: '코로나 엑스트라 · 355ml', price: '14,000원' },
      { name: 'STELLA',    desc: '스텔라 아르투아 · 330ml', price: '13,000원' },
    ],
  },
  cocktail: {
    label: 'COCKTAIL',
    items: [
      { name: 'NEGRONI',         desc: '진 · 캄파리 · 베르무트', price: '14,000원',
        color: 'linear-gradient(135deg, #c0392b, #6e1818)' },
      { name: 'OLD FASHIONED',   desc: '버번 · 비터스 · 슈가', price: '15,000원' },
      { name: 'ESPRESSO MARTINI',desc: '보드카 · 에스프레소 · 칼루아', price: '16,000원' },
    ],
  },
};

function MenuRow({ item }) {
  return (
    <div style={{
      display: 'flex', gap: 16, padding: '16px 0',
      borderTop: `1px solid ${C.divider}`,
      alignItems: 'center', minHeight: 100,
    }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 10, minWidth: 0 }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            {item.tag && (
              <span style={{
                padding: '2px 7px', borderRadius: 999,
                background: C.purple, color: GRAY[200],
                ...TYPO.caption, lineHeight: '14px', fontWeight: 500,
              }}>{item.tag}</span>
            )}
            <span style={{ ...TYPO.body3, color: GRAY[200] }}>{item.name}</span>
          </div>
          {item.desc && (
            <span style={{ ...TYPO.caption, color: GRAY[500], lineHeight: '14px' }}>{item.desc}</span>
          )}
        </div>
        <div style={{ ...TYPO.body2, color: '#fff', fontWeight: 600 }}>{item.price}</div>
      </div>
      {item.color && (
        <div style={{
          width: 100, height: 100, borderRadius: 6, flexShrink: 0,
          background: item.color, position: 'relative', overflow: 'hidden',
        }}>
          <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(circle at 30% 30%, rgba(255,255,255,0.25), transparent 60%)' }} />
        </div>
      )}
    </div>
  );
}

function MenuTab({ scrollRef }) {
  const [active, setActive] = useState('signature');
  const sectionRefs = useRef({});

  const goTo = (key) => {
    setActive(key);
    const el = sectionRefs.current[key];
    if (el && scrollRef?.current) {
      const top = el.offsetTop - 90; // tabs(42) + chips(~48)
      scrollRef.current.scrollTo({ top, behavior: 'smooth' });
    }
  };

  // menu image gallery (top)
  const galleryColors = [
    'linear-gradient(135deg, #f7d046, #e8a020)',
    'linear-gradient(135deg, #7731FE, #2a0d4a)',
    'linear-gradient(135deg, #c0392b, #6e1818)',
    'linear-gradient(135deg, #2c3e50, #0a0a1f)',
  ];

  return (
    <div>
      {/* 메뉴 이미지 */}
      <div style={{ padding: '24px 0 28px', borderBottom: `2px solid ${GRAY[900]}` }}>
        <h3 style={{ ...TYPO.h4, color: '#fff', margin: 0, padding: '0 20px 16px' }}>메뉴 이미지</h3>
        <div style={{ display: 'flex', gap: 8, padding: '0 20px', overflowX: 'auto', scrollbarWidth: 'none' }}>
          {galleryColors.map((bg, i) => (
            <div key={i} style={{
              width: 121, height: 121, borderRadius: 8, flexShrink: 0,
              background: bg, position: 'relative', overflow: 'hidden',
            }}>
              <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(circle at 30% 30%, rgba(255,255,255,0.25), transparent 60%)' }} />
            </div>
          ))}
        </div>
      </div>

      {/* sticky category chips */}
      <div style={{
        position: 'sticky', top: 42, zIndex: 9,
        background: C.bg,
        padding: '16px 20px 12px',
        borderBottom: `1px solid ${GRAY[900]}`,
        display: 'flex', gap: 8, overflowX: 'auto', scrollbarWidth: 'none',
      }}>
        {MENU_CATEGORIES.map(c => {
          const sel = c.key === active;
          return (
            <button key={c.key} onClick={() => goTo(c.key)} style={{
              all: 'unset', cursor: 'pointer', flexShrink: 0,
              padding: '7px 14px', borderRadius: 999,
              background: sel ? PURPLE[700] : GRAY[800],
              color: sel ? '#fff' : GRAY[400],
              ...TYPO.button2, fontWeight: sel ? 600 : 500,
            }}>{c.label}</button>
          );
        })}
      </div>

      {/* sections */}
      <div style={{ padding: '8px 20px 24px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        {MENU_CATEGORIES.map(c => {
          const g = MENU_GROUPS[c.key];
          return (
            <div
              key={c.key}
              ref={el => { sectionRefs.current[c.key] = el; }}
              style={{ paddingTop: 16 }}
            >
              <h3 style={{ ...TYPO.h4, color: '#fff', margin: 0, marginBottom: 4 }}>{g.label}</h3>
              <div>
                {g.items.map((it, i) => <MenuRow key={i} item={it} />)}
                <div style={{ borderTop: `1px solid ${C.divider}` }} />
              </div>
            </div>
          );
        })}

        <p style={{
          ...TYPO.caption, color: GRAY[500], lineHeight: '16px',
          margin: '4px 0 0',
        }}>
          메뉴 항목과 가격은 각 매장 사정에 따라 기재된 내용과 다를 수 있습니다.
        </p>
      </div>
    </div>
  );
}

// ============ PHOTOS TAB (full) ============
const PHOTO_FILTERS = [
  { key: 'all',      label: '전체', count: 32 },
  { key: 'venue',    label: '업체', count: 8 },
  { key: 'food',     label: '음식', count: 14 },
  { key: 'interior', label: '내부', count: 10 },
];

const PHOTO_DATA = [
  { h: 262, bg: 'linear-gradient(135deg, #2b1655, #7731FE)',  cat: 'interior' },
  { h: 180, bg: 'linear-gradient(135deg, #ff4d8d, #6622cc)',  cat: 'venue' },
  { h: 180, bg: 'linear-gradient(135deg, #f7d046, #e8a020)',  cat: 'food' },
  { h: 180, bg: 'linear-gradient(135deg, #B5FF60, #2B6BFF)',  cat: 'interior' },
  { h: 220, bg: 'linear-gradient(135deg, #c0392b, #6e1818)',  cat: 'food' },
  { h: 180, bg: 'linear-gradient(135deg, #2c3e50, #0a0a1f)',  cat: 'venue' },
  { h: 270, bg: 'linear-gradient(135deg, #7731FE, #ff4d8d)',  cat: 'interior' },
  { h: 180, bg: 'linear-gradient(135deg, #2B6BFF, #7731FE)',  cat: 'venue' },
  { h: 200, bg: 'linear-gradient(135deg, #fb5607, #ffbe0b)',  cat: 'food' },
  { h: 220, bg: 'linear-gradient(135deg, #06ffa5, #3a86ff)',  cat: 'interior' },
  { h: 180, bg: 'linear-gradient(135deg, #8338ec, #ff006e)',  cat: 'food' },
  { h: 200, bg: 'linear-gradient(135deg, #2a2d34, #6c757d)',  cat: 'interior' },
  { h: 240, bg: 'linear-gradient(135deg, #ff006e, #fb5607)',  cat: 'food' },
  { h: 180, bg: 'linear-gradient(135deg, #4a2580, #B5FF60)',  cat: 'interior' },
  { h: 200, bg: 'linear-gradient(135deg, #2659D0, #B5FF60)',  cat: 'venue' },
  { h: 260, bg: 'linear-gradient(135deg, #94CF51, #2659D0)',  cat: 'food' },
  { h: 180, bg: 'linear-gradient(135deg, #FF5C5F, #4E24A0)',  cat: 'interior' },
  { h: 220, bg: 'linear-gradient(135deg, #ffbe0b, #ff4d8d)',  cat: 'food' },
  { h: 200, bg: 'linear-gradient(135deg, #0f0f23, #6622cc)',  cat: 'venue' },
  { h: 180, bg: 'linear-gradient(135deg, #f7d046, #ff006e)',  cat: 'food' },
  { h: 240, bg: 'linear-gradient(135deg, #7731FE, #94CF51)',  cat: 'interior' },
  { h: 200, bg: 'linear-gradient(135deg, #3a86ff, #8338ec)',  cat: 'food' },
  { h: 280, bg: 'linear-gradient(135deg, #1a0b3d, #ff4d8d)',  cat: 'interior' },
  { h: 180, bg: 'linear-gradient(135deg, #06ffa5, #7731FE)',  cat: 'venue' },
  { h: 220, bg: 'linear-gradient(135deg, #2a2d34, #c0392b)',  cat: 'food' },
  { h: 200, bg: 'linear-gradient(135deg, #739F41, #2F1A5A)',  cat: 'interior' },
  { h: 180, bg: 'linear-gradient(135deg, #ff4d8d, #B5FF60)',  cat: 'food' },
  { h: 240, bg: 'linear-gradient(135deg, #CF4D50, #2047A1)',  cat: 'interior' },
  { h: 200, bg: 'linear-gradient(135deg, #ffbe0b, #2659D0)',  cat: 'venue' },
  { h: 220, bg: 'linear-gradient(135deg, #4E24A0, #B5FF60)',  cat: 'food' },
  { h: 180, bg: 'linear-gradient(135deg, #6e3a1f, #f7d046)',  cat: 'interior' },
  { h: 200, bg: 'linear-gradient(135deg, #9F3E40, #2B6BFF)',  cat: 'food' },
];

function PhotosTab() {
  const [filter, setFilter] = useState('all');
  const [shown, setShown] = useState(12);
  const [loading, setLoading] = useState(false);
  const filteredAll = filter === 'all' ? PHOTO_DATA : PHOTO_DATA.filter(p => p.cat === filter);
  const filtered = filteredAll.slice(0, shown);
  const hasMore = shown < filteredAll.length;
  const sentinelRef = useRef(null);

  // 필터 바뀌면 기본 12장으로 리셋 + 로딩 잠깐
  const setFilterReset = (k) => {
    setFilter(k);
    setShown(12);
    setLoading(true);
    setTimeout(() => setLoading(false), 600);
  };

  // 무한 스크롤 — 센티넬이 뷰포트에 가까워지면 12장씩 로드
  useEffect(() => {
    if (!hasMore) return;
    const el = sentinelRef.current;
    if (!el) return;
    const obs = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting) {
          setShown((s) => Math.min(s + 12, filteredAll.length));
        }
      },
      { rootMargin: '0px 0px 200px 0px', threshold: 0 }
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, [hasMore, shown, filteredAll.length]);

  // 다음에 로드될 사진들 (피크 미리보기, 2장)
  const peekItems = hasMore ? filteredAll.slice(shown, shown + 2) : [];

  // 메인 컬럼 분배 (현재 보여지는 사진)
  const colA = [];
  const colB = [];
  let hA = 0, hB = 0;
  filtered.forEach(p => {
    if (hA <= hB) { colA.push(p); hA += p.h + 8; }
    else          { colB.push(p); hB += p.h + 8; }
  });

  const renderCol = (col) => (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 8 }}>
      {col.map((p, i) => (
        <div key={i} style={{
          width: '100%', height: p.h, borderRadius: 6,
          background: p.bg, position: 'relative', overflow: 'hidden',
          border: `1px solid ${GRAY[800]}`,
        }}>
          <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(circle at 30% 30%, rgba(255,255,255,0.22), transparent 60%)' }} />
        </div>
      ))}
    </div>
  );

  return (
    <div>
      {/* sticky filter chips */}
      <div style={{
        position: 'sticky', top: 42, zIndex: 9,
        background: C.bg,
        padding: '16px 20px 12px',
        borderBottom: `1px solid ${GRAY[900]}`,
        display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12,
      }}>
        <div style={{ display: 'flex', gap: 8, overflowX: 'auto', scrollbarWidth: 'none', flex: 1 }}>
          {PHOTO_FILTERS.map(f => {
            const sel = f.key === filter;
            const count = f.key === 'all' ? PHOTO_DATA.length : PHOTO_DATA.filter(p => p.cat === f.key).length;
            return (
              <button key={f.key} onClick={() => setFilterReset(f.key)} style={{
                all: 'unset', cursor: 'pointer', flexShrink: 0,
                padding: '7px 14px', borderRadius: 999,
                background: sel ? PURPLE[700] : GRAY[800],
                color: sel ? '#fff' : GRAY[400],
                ...TYPO.button2, fontWeight: sel ? 600 : 500,
              }}>
                {f.label} {count}
              </button>
            );
          })}
        </div>
      </div>

      {/* masonry grid OR skeleton */}
      {loading ? (
        <div style={{ padding: '16px 20px 0', display: 'flex', gap: 8 }}>
          {[
            [262, 180, 220, 270],
            [180, 220, 180, 200],
          ].map((heights, ci) => (
            <div key={ci} style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 8 }}>
              {heights.map((h, i) => (
                <Skel key={i} w="100%" h={h} r={6} />
              ))}
            </div>
          ))}
        </div>
      ) : (
        <div style={{
          padding: '16px 20px 0',
          display: 'flex', gap: 8,
        }}>
          {renderCol(colA)}
          {renderCol(colB)}
        </div>
      )}

      {/* 무한 스크롤 — 다음 사진 피크 + 텍스트 안내 */}
      {hasMore && (
        <div ref={sentinelRef} style={{
          position: 'relative',
          padding: '8px 20px 32px',
          marginTop: 8,
        }}>
          <div style={{
            display: 'flex', gap: 8, height: 110, overflow: 'hidden',
            WebkitMask: 'linear-gradient(180deg, #000 0%, transparent 90%)',
            mask: 'linear-gradient(180deg, #000 0%, transparent 90%)',
            opacity: 0.55,
          }}>
            {peekItems.map((p, i) => (
              <div key={i} style={{
                flex: 1, height: '100%', borderRadius: 6,
                background: p.bg, position: 'relative', overflow: 'hidden',
                border: `1px solid ${GRAY[800]}`,
              }}>
                <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(circle at 30% 30%, rgba(255,255,255,0.22), transparent 60%)' }} />
              </div>
            ))}
          </div>

          {/* 하단 텍스트 안내 */}
          <div style={{
            position: 'absolute', left: 0, right: 0, bottom: 28,
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
            pointerEvents: 'none',
          }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={GRAY[400]} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
              style={{ animation: 'scrollHint 1.6s ease-in-out infinite' }}>
              <polyline points="6 9 12 15 18 9" />
            </svg>
            <span style={{ ...TYPO.caption, color: GRAY[400], lineHeight: '14px' }}>
              아래로 스크롤하여 사진 더 보기
            </span>
            <span style={{ ...TYPO.caption, color: GRAY[600], lineHeight: '14px' }}>
              {shown} / {filteredAll.length}
            </span>
          </div>
        </div>
      )}
      {!hasMore && filtered.length > 12 && (
        <div style={{
          padding: '24px 20px 32px',
          textAlign: 'center', ...TYPO.caption,
          color: GRAY[600], lineHeight: '16px',
        }}>
          모든 사진을 봤어요
        </div>
      )}
    </div>
  );
}

// ============ REVIEWS TAB (full) ============
const REVIEWS = [
  {
    id: 1, name: '익명의 사자', rating: 5.0, date: '2025.06.08',
    text: '외관이 깔끔해서 들어가보니 내부도 너무 깨끗하고 음악도 너무 좋네요. 술 종류도 다양해서 잘 놀다왔어요. 재방문 의사 100%고 친구들한테도 추천하고 싶은 곳이에요. DJ 셀렉이 진짜 좋았고 사장님도 친절하셨어요.',
    photos: ['linear-gradient(135deg, #2b1655, #7731FE)', 'linear-gradient(135deg, #ff4d8d, #6622cc)', 'linear-gradient(135deg, #B5FF60, #2B6BFF)', 'linear-gradient(135deg, #c0392b, #6e1818)', 'linear-gradient(135deg, #f7d046, #e8a020)'],
    avatarColor: 'linear-gradient(135deg, #7731FE, #ff4d8d)',
  },
  {
    id: 2, name: '이시안', rating: 5.0, date: '2025.06.08',
    text: '음악이 너무 제스타일이었어요~',
    photos: ['linear-gradient(135deg, #2c3e50, #0a0a1f)'],
    avatarColor: 'linear-gradient(135deg, #B5FF60, #2B6BFF)',
  },
  {
    id: 3, name: '익명의 토끼', rating: 4.5, date: '2025.06.05',
    text: '외관이 깔끔해서 들어가보니 내부도 너무 깨끗하고 음악도 너무 좋네요',
    photos: [],
    avatarColor: 'linear-gradient(135deg, #ff006e, #8338ec)',
  },
  {
    id: 4, name: '송강', rating: 5.0, date: '2025.06.03',
    text: '외관이 깔끔해서 들어가보니 내부도 너무 깨끗하고 음악도 너무 좋네요. 술 종류도 다양해서 잘 놀다왔어요. 재방문 의사 100%입니다.',
    photos: [],
    avatarColor: 'linear-gradient(135deg, #fb5607, #ffbe0b)',
  },
  {
    id: 5, name: '익명의 라쿤', rating: 4.5, date: '2025.05.28',
    text: '입장료가 무료여서 부담없이 갈 수 있었고, 분위기도 좋고 음악도 좋았어요. 다만 주말엔 좀 붐벼서 자리잡기 어려웠어요.',
    photos: ['linear-gradient(135deg, #06ffa5, #3a86ff)', 'linear-gradient(135deg, #2a2d34, #6c757d)'],
    avatarColor: 'linear-gradient(135deg, #94CF51, #2659D0)',
  },
  {
    id: 6, name: '댄싱퀸', rating: 5.0, date: '2025.05.24',
    text: 'DJ 라인업이 진짜 좋아요. 매주 다른 게스트가 오는데 한 번도 실망한 적이 없어요. 분위기 좋고 음향도 훌륭합니다.',
    photos: ['linear-gradient(135deg, #fb5607, #ffbe0b)', 'linear-gradient(135deg, #ff006e, #fb5607)', 'linear-gradient(135deg, #2659D0, #B5FF60)'],
    avatarColor: 'linear-gradient(135deg, #ff006e, #fb5607)',
  },
  {
    id: 7, name: '익명의 곰', rating: 4.0, date: '2025.05.18',
    text: '음악은 좋은데 사람이 너무 많아서 답답했어요. 평일에 가는 게 좋을 듯.',
    photos: [],
    avatarColor: 'linear-gradient(135deg, #6e3a1f, #2a160a)',
  },
  {
    id: 8, name: '한결', rating: 5.0, date: '2025.05.12',
    text: '친구들과 처음 가봤는데 정말 좋았어요! 입장도 빨랐고 자리도 충분했어요.',
    photos: ['linear-gradient(135deg, #7731FE, #94CF51)'],
    avatarColor: 'linear-gradient(135deg, #2B6BFF, #7731FE)',
  },
  {
    id: 9, name: '익명의 여우', rating: 4.5, date: '2025.05.08',
    text: '칵테일이 맛있어요. 특히 퍼플 헤이즈 추천! 직원분들도 친절해서 기분 좋게 놀다왔어요.',
    photos: ['linear-gradient(135deg, #7731FE, #2a0d4a)', 'linear-gradient(135deg, #f7d046, #e8a020)'],
    avatarColor: 'linear-gradient(135deg, #ffbe0b, #ff4d8d)',
  },
  {
    id: 10, name: '주말장인', rating: 5.0, date: '2025.05.03',
    text: '홍대에서 제일 좋아하는 클럽 중 하나예요. 무료입장에 음악도 좋고, 분위기도 너무 마음에 들어요. 매주 옵니다.',
    photos: [],
    avatarColor: 'linear-gradient(135deg, #4E24A0, #B5FF60)',
  },
  {
    id: 11, name: '익명의 너구리', rating: 4.0, date: '2025.04.27',
    text: '음악 좋고 가격도 적당해요. 다만 화장실이 좀 작은 게 아쉬워요.',
    photos: [],
    avatarColor: 'linear-gradient(135deg, #739F41, #2F1A5A)',
  },
  {
    id: 12, name: '하늘하늘', rating: 5.0, date: '2025.04.20',
    text: '생일파티로 왔는데 분위기 띄우기 딱 좋았어요. VIP 테이블도 잘 봐주시고 만족합니다.',
    photos: ['linear-gradient(135deg, #ff4d8d, #B5FF60)', 'linear-gradient(135deg, #c0392b, #6e1818)'],
    avatarColor: 'linear-gradient(135deg, #ff006e, #B5FF60)',
  },
  {
    id: 13, name: '익명의 펭귄', rating: 4.5, date: '2025.04.15',
    text: '오랜만에 클럽 와봤는데 너무 재밌었어요. 음향이 정말 빵빵하고 좋네요. 다음에 또 올게요!',
    photos: ['linear-gradient(135deg, #2B6BFF, #7731FE)'],
    avatarColor: 'linear-gradient(135deg, #06ffa5, #2B6BFF)',
  },
];

const BLOG_REVIEWS = [
  { id: 'b1', blogger: '클럽 탐험가', subtitle: 'NAVER 블로그', date: '2025.06.10', title: '홍대에서 입문자가 가기 좋은 클럽 TOP 5', preview: '어썸 레드는 입장료가 무료라서 처음 클럽에 가는 사람도 부담 없이 즐길 수 있는 곳이다...', cover: 'linear-gradient(135deg, #7731FE, #ff4d8d)' },
  { id: 'b2', blogger: '주말의기록', subtitle: 'Tistory', date: '2025.06.02', title: '어썸 레드 방문 후기 - 힙합 좋아하는 사람 모여라', preview: '드디어 다녀온 어썸 레드! 디제이 셀렉이 정말 취향 저격이었다. 입장하자마자...', cover: 'linear-gradient(135deg, #2B6BFF, #B5FF60)' },
  { id: 'b3', blogger: 'night_seoul', subtitle: 'Instagram', date: '2025.05.20', title: '홍대 클럽 어썸 레드 솔직 후기 ✨', preview: '오늘은 홍대에 새로 생긴 클럽 어썸 레드에 다녀왔어요. 분위기 짱이고 음악이...', cover: 'linear-gradient(135deg, #ff006e, #ffbe0b)' },
  { id: 'b4', blogger: '서울나잇라이프', subtitle: 'NAVER 블로그', date: '2025.05.15', title: '입장료 없는 홍대 클럽 추천 BEST 3', preview: '주말 밤 놀거리 찾으시는 분들께 추천드리는 무료 입장 클럽들. 어썸 레드는 분위기가...', cover: 'linear-gradient(135deg, #94CF51, #2659D0)' },
  { id: 'b5', blogger: '디제이러버', subtitle: 'Tistory', date: '2025.05.10', title: '어썸 레드 라인업 분석 - 6월의 DJ들', preview: '이번 달 어썸 레드 라인업이 빵빵합니다. 매주 다른 게스트가 오는데...', cover: 'linear-gradient(135deg, #4E24A0, #B5FF60)' },
  { id: 'b6', blogger: 'club_review_kr', subtitle: 'Instagram', date: '2025.05.05', title: '홍대 어썸 레드 ❤️ 분위기 미쳤어요', preview: '진짜 오랜만에 너무 좋은 클럽 다녀왔어요! 입장도 빨랐고 분위기는 말할 것도 없고...', cover: 'linear-gradient(135deg, #ff4d8d, #B5FF60)' },
  { id: 'b7', blogger: '주말도서관', subtitle: 'NAVER 블로그', date: '2025.04.28', title: '홍대 클럽 어썸 레드 이용 후기 + 메뉴', preview: '주말에 친구들과 다녀왔어요. 메뉴는 칵테일, 위스키 등 다양했고 가격도 합리적이었습니다...', cover: 'linear-gradient(135deg, #c0392b, #6e1818)' },
];

// Star icon (small/large)
const Star = ({ size = 14, color = LIME[500] }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={color} stroke={color} strokeWidth="1" strokeLinecap="round" strokeLinejoin="round">
    <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
  </svg>
);

// Avatar circle
function Avatar({ name, color }) {
  return (
    <div style={{
      width: 32, height: 32, borderRadius: '50%',
      background: color, flexShrink: 0,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      color: '#fff', ...TYPO.button2, fontWeight: 700,
    }}>{name.slice(0, 1)}</div>
  );
}

// Rating distribution bar
function RatingSummary() {
  const dist = [
    { star: 5, count: 9 },
    { star: 4, count: 3 },
    { star: 3, count: 1 },
    { star: 2, count: 0 },
    { star: 1, count: 0 },
  ];
  const total = dist.reduce((a, b) => a + b.count, 0);
  return (
    <div style={{
      padding: '20px 16px', borderRadius: 12,
      background: GRAY[900], border: `1px solid ${GRAY[800]}`,
      display: 'flex', gap: 18, alignItems: 'center',
    }}>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, minWidth: 80 }}>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 2 }}>
          <span style={{ ...TYPO.h2, color: '#fff' }}>4.76</span>
          <span style={{ ...TYPO.body4, color: GRAY[500] }}>/5</span>
        </div>
        <div style={{ display: 'flex', gap: 1 }}>
          {[1,2,3,4,5].map(i => <Star key={i} size={12} color={i <= 4.76 ? LIME[500] : GRAY[700]} />)}
        </div>
        <span style={{ ...TYPO.caption, color: GRAY[500], lineHeight: '14px' }}>방문자 {total}명</span>
      </div>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 4 }}>
        {dist.map(d => {
          const pct = total > 0 ? (d.count / total) * 100 : 0;
          return (
            <div key={d.star} style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <span style={{ ...TYPO.caption, color: GRAY[400], lineHeight: '14px', width: 12 }}>{d.star}</span>
              <div style={{ flex: 1, height: 4, borderRadius: 99, background: GRAY[800], overflow: 'hidden' }}>
                <div style={{ width: `${pct}%`, height: '100%', background: LIME[500], transition: 'width .3s' }} />
              </div>
              <span style={{ ...TYPO.caption, color: GRAY[500], lineHeight: '14px', minWidth: 18, textAlign: 'right' }}>{d.count}</span>
            </div>
          );
        })}
      </div>
    </div>
  );
}

// Single review card
function ReviewCard({ r }) {
  const [expanded, setExpanded] = useState(false);
  const isLong = r.text.length > 60;
  const showExpand = isLong && !expanded;
  const display = showExpand ? r.text.slice(0, 60) + '...' : r.text;
  const firstPhoto = r.photos[0];
  const morePhotos = r.photos.length - 1;

  return (
    <div style={{
      padding: '16px 0',
      borderBottom: `1px solid ${GRAY[900]}`,
      display: 'flex', flexDirection: 'column', gap: 10,
    }}>
      {/* header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <Avatar name={r.name} color={r.avatarColor} />
          <div style={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
            <span style={{ ...TYPO.button2, color: '#fff', fontWeight: 700 }}>{r.name}</span>
            <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
              <Star size={12} />
              <span style={{ ...TYPO.caption, color: GRAY[300], lineHeight: '14px', fontWeight: 600 }}>{r.rating.toFixed(1)}</span>
            </div>
          </div>
        </div>
        <span style={{ ...TYPO.caption, color: GRAY[500], lineHeight: '14px' }}>{r.date}</span>
      </div>

      {/* body */}
      <div style={{ display: 'flex', gap: 14, alignItems: 'flex-start' }}>
        <div style={{ flex: 1, minWidth: 0 }}>
          <p style={{
            ...TYPO.body3, color: GRAY[200],
            margin: 0, lineHeight: '22px',
            whiteSpace: 'pre-wrap',
          }}>{display}</p>
          {showExpand && (
            <button onClick={() => setExpanded(true)} style={{
              all: 'unset', cursor: 'pointer',
              ...TYPO.caption, color: GRAY[500], lineHeight: '14px',
              marginTop: 6, display: 'inline-flex', alignItems: 'center', gap: 2,
            }}>
              자세히 보기
              <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke={GRAY[500]} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="6 9 12 15 18 9" />
              </svg>
            </button>
          )}
        </div>
        {firstPhoto && (
          <div style={{ position: 'relative', width: 90, height: 90, flexShrink: 0 }}>
            <div style={{
              width: '100%', height: '100%', borderRadius: 6,
              background: firstPhoto, position: 'relative', overflow: 'hidden',
            }}>
              <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(circle at 30% 30%, rgba(255,255,255,0.22), transparent 60%)' }} />
            </div>
            {morePhotos > 0 && (
              <div style={{
                position: 'absolute', right: 6, bottom: 6,
                padding: '3px 8px', borderRadius: 999,
                background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(6px)',
                ...TYPO.caption, color: '#fff', lineHeight: '14px', fontWeight: 600,
              }}>+{morePhotos}</div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

// Blog review card
function BlogReviewCard({ b }) {
  return (
    <div style={{
      padding: '16px 0',
      borderBottom: `1px solid ${GRAY[900]}`,
      display: 'flex', gap: 14, alignItems: 'flex-start',
    }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 8, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <span style={{ ...TYPO.caption, color: LIME[500], lineHeight: '14px', fontWeight: 600 }}>{b.subtitle}</span>
          <span style={{ width: 2, height: 2, borderRadius: 99, background: GRAY[600] }} />
          <span style={{ ...TYPO.caption, color: GRAY[500], lineHeight: '14px' }}>{b.blogger}</span>
        </div>
        <h4 style={{
          ...TYPO.body3, color: '#fff', fontWeight: 600, margin: 0,
          display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical',
          overflow: 'hidden',
        }}>{b.title}</h4>
        <p style={{
          ...TYPO.caption, color: GRAY[400], lineHeight: '16px',
          margin: 0,
          display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical',
          overflow: 'hidden',
        }}>{b.preview}</p>
        <span style={{ ...TYPO.caption, color: GRAY[600], lineHeight: '14px' }}>{b.date}</span>
      </div>
      <div style={{
        width: 80, height: 80, flexShrink: 0, borderRadius: 8,
        background: b.cover, position: 'relative', overflow: 'hidden',
      }}>
        <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(circle at 30% 30%, rgba(255,255,255,0.22), transparent 60%)' }} />
      </div>
    </div>
  );
}

function ReviewsTab() {
  const [tab, setTab] = useState('visitor');
  const [sort, setSort] = useState('latest');
  const [shownVisitor, setShownVisitor] = useState(5);
  const [shownBlog, setShownBlog] = useState(3);
  const sentinelVisitor = useRef(null);
  const sentinelBlog = useRef(null);

  const sortedVisitor = sort === 'photo' ? REVIEWS.filter(r => r.photos.length > 0) : REVIEWS;
  const visitorShownList = sortedVisitor.slice(0, shownVisitor);
  const hasMoreVisitor = shownVisitor < sortedVisitor.length;
  const peekVisitor = hasMoreVisitor ? sortedVisitor.slice(shownVisitor, shownVisitor + 1)[0] : null;

  const blogShownList = BLOG_REVIEWS.slice(0, shownBlog);
  const hasMoreBlog = shownBlog < BLOG_REVIEWS.length;
  const peekBlog = hasMoreBlog ? BLOG_REVIEWS.slice(shownBlog, shownBlog + 1)[0] : null;

  // 무한 스크롤 — 방문자 리뷰
  useEffect(() => {
    if (!hasMoreVisitor || tab !== 'visitor') return;
    const el = sentinelVisitor.current;
    if (!el) return;
    const obs = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting) {
          setShownVisitor(s => Math.min(s + 5, sortedVisitor.length));
        }
      },
      { rootMargin: '0px 0px 200px 0px', threshold: 0 }
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, [hasMoreVisitor, shownVisitor, tab, sortedVisitor.length]);

  // 무한 스크롤 — 블로그 리뷰
  useEffect(() => {
    if (!hasMoreBlog || tab !== 'blog') return;
    const el = sentinelBlog.current;
    if (!el) return;
    const obs = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting) {
          setShownBlog(s => Math.min(s + 3, BLOG_REVIEWS.length));
        }
      },
      { rootMargin: '0px 0px 200px 0px', threshold: 0 }
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, [hasMoreBlog, shownBlog, tab]);

  // 정렬 바뀌면 리셋
  const setSortReset = (k) => { setSort(k); setShownVisitor(5); };

  return (
    <div style={{ padding: '20px 20px 32px', display: 'flex', flexDirection: 'column', gap: 20 }}>
      {/* segmented toggle */}
      <div style={{
        display: 'flex', background: GRAY[900],
        borderRadius: 999, padding: 4, position: 'relative',
      }}>
        <div style={{
          position: 'absolute', top: 4, bottom: 4,
          left: tab === 'visitor' ? 4 : '50%',
          width: 'calc(50% - 4px)',
          background: GRAY[700], borderRadius: 999,
          transition: 'left .25s ease',
        }} />
        {[{ k: 'visitor', l: '방문자 리뷰' }, { k: 'blog', l: '블로그 리뷰' }].map(o => (
          <button key={o.k} onClick={() => setTab(o.k)} style={{
            all: 'unset', cursor: 'pointer', flex: 1, textAlign: 'center',
            padding: '8px 0', position: 'relative', zIndex: 1,
            ...TYPO.button2, color: tab === o.k ? '#fff' : GRAY[400],
            fontWeight: 600,
          }}>{o.l}</button>
        ))}
      </div>

      {tab === 'visitor' && (
        <>
          <RatingSummary />

          {/* sort + filter chips */}
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <span style={{ ...TYPO.body4, color: '#fff', fontWeight: 600 }}>리뷰 {sortedVisitor.length}</span>
            <div style={{ display: 'flex', gap: 4 }}>
              {[{ k: 'latest', l: '최신순' }, { k: 'rating', l: '평점순' }, { k: 'photo', l: '사진' }].map(s => {
                const sel = sort === s.k;
                return (
                  <button key={s.k} onClick={() => setSortReset(s.k)} style={{
                    all: 'unset', cursor: 'pointer',
                    padding: '4px 10px', borderRadius: 999,
                    ...TYPO.caption, lineHeight: '14px', fontWeight: 500,
                    color: sel ? '#fff' : GRAY[500],
                    background: sel ? GRAY[800] : 'transparent',
                  }}>{s.l}</button>
                );
              })}
            </div>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column' }}>
            {visitorShownList.map(r => <ReviewCard key={r.id} r={r} />)}
          </div>

          {/* 무한 스크롤 피크 */}
          {hasMoreVisitor && (
            <ScrollPeek
              sentinelRef={sentinelVisitor}
              current={shownVisitor}
              total={sortedVisitor.length}
              preview={<ReviewCard r={peekVisitor} />}
            />
          )}
          {!hasMoreVisitor && sortedVisitor.length > 5 && (
            <div style={{
              textAlign: 'center', ...TYPO.caption,
              color: GRAY[600], lineHeight: '16px', padding: '8px 0',
            }}>
              모든 리뷰를 봤어요
            </div>
          )}
        </>
      )}

      {tab === 'blog' && (
        <>
          <div style={{ display: 'flex', flexDirection: 'column' }}>
            {blogShownList.map(b => <BlogReviewCard key={b.id} b={b} />)}
          </div>

          {hasMoreBlog && (
            <ScrollPeek
              sentinelRef={sentinelBlog}
              current={shownBlog}
              total={BLOG_REVIEWS.length}
              preview={<BlogReviewCard b={peekBlog} />}
            />
          )}
          {!hasMoreBlog && BLOG_REVIEWS.length > 3 && (
            <div style={{
              textAlign: 'center', ...TYPO.caption,
              color: GRAY[600], lineHeight: '16px', padding: '8px 0',
            }}>
              모든 블로그 리뷰를 봤어요
            </div>
          )}
        </>
      )}
    </div>
  );
}

// 무한 스크롤용 피크 컴포넌트 — 사진 탭과 동일 패턴
function ScrollPeek({ sentinelRef, current, total, preview }) {
  return (
    <div ref={sentinelRef} style={{ position: 'relative', marginTop: 4 }}>
      <div style={{
        maxHeight: 160, overflow: 'hidden',
        WebkitMask: 'linear-gradient(180deg, #000 0%, transparent 85%)',
        mask: 'linear-gradient(180deg, #000 0%, transparent 85%)',
        opacity: 0.55,
        pointerEvents: 'none',
      }}>
        {preview}
      </div>
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 4,
        display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
        pointerEvents: 'none',
      }}>
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={GRAY[400]} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
          style={{ animation: 'scrollHint 1.6s ease-in-out infinite' }}>
          <polyline points="6 9 12 15 18 9" />
        </svg>
        <span style={{ ...TYPO.caption, color: GRAY[400], lineHeight: '14px' }}>
          아래로 스크롤하여 더 보기
        </span>
        <span style={{ ...TYPO.caption, color: GRAY[600], lineHeight: '14px' }}>
          {current} / {total}
        </span>
      </div>
    </div>
  );
}

// ============ INFO TAB (full) ============

// Map placeholder — stylized streets + pulsing pin + nearby labels
function MapCard() {
  return (
    <div style={{
      position: 'relative', width: '100%', height: 200,
      borderRadius: 12, overflow: 'hidden',
      background: 'linear-gradient(135deg, #1a1a1f 0%, #2a2a30 100%)',
      border: `1px solid ${GRAY[800]}`,
    }}>
      {/* simulated streets */}
      <svg width="100%" height="100%" viewBox="0 0 345 200" preserveAspectRatio="none" style={{ position: 'absolute', inset: 0 }}>
        <defs>
          <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
            <path d="M 40 0 L 0 0 0 40" fill="none" stroke="rgba(255,255,255,0.04)" strokeWidth="1" />
          </pattern>
        </defs>
        <rect width="100%" height="100%" fill="url(#grid)" />
        {/* roads */}
        <line x1="0" y1="100" x2="345" y2="100" stroke="rgba(255,255,255,0.08)" strokeWidth="18" />
        <line x1="180" y1="0" x2="180" y2="200" stroke="rgba(255,255,255,0.08)" strokeWidth="14" />
        <line x1="60" y1="40" x2="345" y2="40" stroke="rgba(255,255,255,0.05)" strokeWidth="8" />
        <line x1="0" y1="160" x2="280" y2="160" stroke="rgba(255,255,255,0.05)" strokeWidth="8" />
        {/* subway accent — yellow line */}
        <path d="M 0 130 Q 80 130 110 110" stroke={C.line9} strokeWidth="3" fill="none" opacity="0.8" />
      </svg>

      {/* subway exit marker */}
      <div style={{
        position: 'absolute', left: 80, top: 92,
        display: 'flex', alignItems: 'center', gap: 4,
      }}>
        <span style={{
          width: 18, height: 18, borderRadius: '50%', background: C.line9,
          color: '#fff', ...TYPO.caption, lineHeight: '14px', fontWeight: 700,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>9</span>
        <span style={{
          padding: '2px 6px', borderRadius: 4,
          background: 'rgba(0,0,0,0.7)', color: '#fff',
          ...TYPO.caption, lineHeight: '14px', fontWeight: 600,
        }}>상수역</span>
      </div>

      {/* main pin (pulsing) */}
      <div style={{
        position: 'absolute', left: '50%', top: '50%',
        transform: 'translate(-50%, -100%)',
        display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
      }}>
        <div style={{
          padding: '4px 10px', borderRadius: 8,
          background: C.purple, color: '#fff',
          ...TYPO.caption, lineHeight: '14px', fontWeight: 700,
          boxShadow: '0 4px 12px rgba(119,49,254,0.4)',
          whiteSpace: 'nowrap',
        }}>어썸 레드</div>
        <div style={{ position: 'relative' }}>
          {/* pulse ring */}
          <div style={{
            position: 'absolute', left: '50%', top: '50%',
            transform: 'translate(-50%, -50%)',
            width: 36, height: 36, borderRadius: '50%',
            background: C.purple, opacity: 0.3,
            animation: 'pinPulse 2s ease-out infinite',
          }} />
          <div style={{
            width: 14, height: 14, borderRadius: '50%',
            background: C.purple,
            border: '2px solid #fff',
            position: 'relative', zIndex: 1,
            boxShadow: '0 2px 6px rgba(0,0,0,0.5)',
          }} />
        </div>
      </div>

      {/* zoom hint */}
      <div style={{
        position: 'absolute', right: 12, bottom: 12,
        padding: '6px 12px', borderRadius: 999,
        background: 'rgba(0,0,0,0.6)', backdropFilter: 'blur(8px)',
        ...TYPO.caption, color: '#fff', lineHeight: '14px',
        display: 'flex', alignItems: 'center', gap: 4,
      }}>
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round">
          <path d="M15 3h6v6" /><path d="M9 21H3v-6" /><path d="M21 3l-7 7" /><path d="M3 21l7-7" />
        </svg>
        지도 크게 보기
      </div>
    </div>
  );
}

// Action chip below map
function ActionChip({ icon, label, onClick, accent }) {
  return (
    <button onClick={onClick} style={{
      all: 'unset', cursor: 'pointer', flex: 1,
      padding: '10px 0', borderRadius: 8,
      background: GRAY[900], border: `1px solid ${GRAY[800]}`,
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
      ...TYPO.button2, color: accent ? LIME[500] : GRAY[200],
    }}>
      {icon}
      {label}
    </button>
  );
}

// Info row — label + value
function InfoRowFull({ label, icon, children, link }) {
  return (
    <div style={{
      display: 'flex', flexDirection: 'column', gap: 8,
      padding: '16px 0',
      borderBottom: `1px solid ${GRAY[900]}`,
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        {icon}
        <span style={{ ...TYPO.button2, color: GRAY[400], fontWeight: 500 }}>{label}</span>
      </div>
      <div style={{ paddingLeft: 28 }}>
        {children}
      </div>
    </div>
  );
}

function InfoTab() {
  const [hoursOpen, setHoursOpen] = useState(false);
  const [noticeOpen, setNoticeOpen] = useState(true);

  const days = [
    ['월', '11:00 - 02:00', true],
    ['화', '11:00 - 02:00'],
    ['수', '11:00 - 02:00'],
    ['목', '11:00 - 02:00'],
    ['금', '11:00 - 02:00'],
    ['토', '11:00 - 02:00'],
    ['일', '정기휴무'],
  ];

  return (
    <div>
      {/* === 위치 === */}
      <div style={{ padding: '24px 20px 28px' }}>
        <h3 style={{ ...TYPO.h4, color: '#fff', margin: '0 0 16px' }}>위치</h3>
        <MapCard />

        {/* address */}
        <div style={{
          marginTop: 16, padding: '14px 16px',
          background: GRAY[900], borderRadius: 12,
          display: 'flex', flexDirection: 'column', gap: 8,
          border: `1px solid ${GRAY[800]}`,
        }}>
          <div style={{ display: 'flex', alignItems: 'flex-start', gap: 10 }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={C.text3} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" style={{ flexShrink: 0, marginTop: 1 }}>
              <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" /><circle cx="12" cy="10" r="3" />
            </svg>
            <span style={{ ...TYPO.body3, color: '#fff', flex: 1 }}>
              서울 마포구 잔다리로 12 지하 1층
            </span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, paddingLeft: 28 }}>
            <span style={{
              width: 17, height: 17, borderRadius: '50%', background: C.line9,
              color: '#fff', ...TYPO.caption, lineHeight: '14px', fontWeight: 700,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>9</span>
            <span style={{ ...TYPO.caption, color: GRAY[300], lineHeight: '14px' }}>
              상수역 1번 출구에서 422m
            </span>
          </div>
        </div>

        {/* action chips */}
        <div style={{ display: 'flex', gap: 8, marginTop: 10 }}>
          <ActionChip
            label="주소 복사"
            icon={<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={GRAY[200]} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
              <rect x="9" y="9" width="13" height="13" rx="2" /><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1" />
            </svg>}
          />
          <ActionChip
            label="지도"
            icon={<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={GRAY[200]} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
              <polygon points="1 6 8 3 16 6 23 3 23 18 16 21 8 18 1 21 1 6" /><line x1="8" y1="3" x2="8" y2="18" /><line x1="16" y1="6" x2="16" y2="21" />
            </svg>}
          />
          <ActionChip
            label="길찾기"
            accent
            icon={<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={LIME[500]} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <polygon points="3 11 22 2 13 21 11 13 3 11" />
            </svg>}
          />
        </div>
      </div>

      {/* divider */}
      <SectionDivider />

      {/* === 상세 정보 === */}
      <div style={{ padding: '24px 20px 32px' }}>
        <h3 style={{ ...TYPO.h4, color: '#fff', margin: '0 0 8px' }}>상세 정보</h3>

        {/* 영업 시간 (with expand) */}
        <InfoRowFull
          label="영업 시간"
          icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={GRAY[400]} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
            <circle cx="12" cy="12" r="10" /><polyline points="12 6 12 12 16 14" />
          </svg>}
        >
          <button onClick={() => setHoursOpen(!hoursOpen)} style={{
            all: 'unset', cursor: 'pointer', width: '100%',
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <span style={{
                padding: '2px 8px', borderRadius: 99,
                background: 'rgba(181,255,96,0.16)', color: LIME[500],
                ...TYPO.caption, lineHeight: '14px', fontWeight: 700,
              }}>영업중</span>
              <span style={{ ...TYPO.body3, color: '#fff' }}>11:00 - 02:00</span>
            </div>
            <div style={{ transform: hoursOpen ? 'rotate(180deg)' : 'rotate(0)', transition: 'transform .2s' }}>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={GRAY[500]} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="6 9 12 15 18 9" />
              </svg>
            </div>
          </button>
          <div style={{ maxHeight: hoursOpen ? 250 : 0, overflow: 'hidden', transition: 'max-height .3s' }}>
            <div style={{ marginTop: 12, display: 'flex', flexDirection: 'column', gap: 8 }}>
              {days.map(([d, h, today]) => (
                <div key={d} style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                  <span style={{ width: 18, ...TYPO.body4, color: today ? '#fff' : GRAY[500], fontWeight: today ? 700 : 400 }}>{d}</span>
                  <span style={{ ...TYPO.body4, color: today ? '#fff' : GRAY[500], fontWeight: today ? 600 : 400 }}>{h}</span>
                  {today && <span style={{ ...TYPO.caption, color: C.purple, fontWeight: 700, padding: '1px 6px', borderRadius: 4, background: C.purpleSoft, lineHeight: '14px' }}>오늘</span>}
                </div>
              ))}
            </div>
          </div>
        </InfoRowFull>

        {/* 전화번호 */}
        <InfoRowFull
          label="전화번호"
          icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={GRAY[400]} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
            <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.13.96.37 1.9.72 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.91.35 1.85.59 2.81.72A2 2 0 0 1 22 16.92z" />
          </svg>}
        >
          <a href="tel:02-1234-1234" style={{
            ...TYPO.body3, color: '#fff', textDecoration: 'none',
            display: 'inline-flex', alignItems: 'center', gap: 6,
          }}>
            02-1234-1234
            <span style={{ ...TYPO.caption, color: LIME[500], lineHeight: '14px' }}>전화 걸기</span>
          </a>
        </InfoRowFull>

        {/* SNS 링크 */}
        <InfoRowFull
          label="인스타그램"
          icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={GRAY[400]} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
            <rect x="2" y="2" width="20" height="20" rx="5" /><path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z" /><line x1="17.5" y1="6.5" x2="17.51" y2="6.5" />
          </svg>}
        >
          <a href="#" onClick={e => e.preventDefault()} style={{
            ...TYPO.body3, color: '#8FB5FF', textDecoration: 'none',
            display: 'inline-flex', alignItems: 'center', gap: 6,
          }}>
            @awesomered_omg
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#8FB5FF" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M7 17L17 7" /><path d="M7 7h10v10" />
            </svg>
          </a>
        </InfoRowFull>

        <InfoRowFull
          label="오픈 채팅"
          icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={GRAY[400]} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
            <path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z" />
          </svg>}
        >
          <a href="#" onClick={e => e.preventDefault()} style={{
            ...TYPO.body3, color: '#8FB5FF', textDecoration: 'none',
            display: 'inline-flex', alignItems: 'center', gap: 6,
          }}>
            open.kakao.com/o/gYnkW0yf
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#8FB5FF" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M7 17L17 7" /><path d="M7 7h10v10" />
            </svg>
          </a>
        </InfoRowFull>

        {/* 안내 및 유의사항 */}
        <div style={{ marginTop: 16 }}>
          <button onClick={() => setNoticeOpen(!noticeOpen)} style={{
            all: 'unset', cursor: 'pointer',
            boxSizing: 'border-box', width: '100%',
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
            padding: '12px 14px',
            background: 'rgba(255, 92, 95, 0.08)',
            border: `1px solid rgba(255, 92, 95, 0.25)`,
            borderRadius: noticeOpen ? '12px 12px 0 0' : 12,
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={RED[500]} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
                <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" />
                <line x1="12" y1="9" x2="12" y2="13" /><line x1="12" y1="17" x2="12.01" y2="17" />
              </svg>
              <span style={{ ...TYPO.button2, color: RED[500], fontWeight: 700 }}>안내 및 유의사항</span>
            </div>
            <div style={{ transform: noticeOpen ? 'rotate(180deg)' : 'rotate(0)', transition: 'transform .2s' }}>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={RED[500]} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="6 9 12 15 18 9" />
              </svg>
            </div>
          </button>
          {noticeOpen && (
            <div style={{
              boxSizing: 'border-box', width: '100%',
              padding: '14px 14px 16px',
              background: 'rgba(255, 92, 95, 0.04)',
              border: `1px solid rgba(255, 92, 95, 0.25)`,
              borderTop: 'none',
              borderRadius: '0 0 12px 12px',
              display: 'flex', flexDirection: 'column', gap: 10,
            }}>
              {[
                '성인만 입장 가능합니다.',
                '프로모션 기간에는 운영 시간과 가격이 변동될 수 있습니다.',
                '예약 변경 및 취소는 방문일 전 3일까지 앱을 통해 가능하며, 2일 ~ 하루 전 취소 시 50% 환불, 당일 취소 및 노쇼는 환불 불가입니다.',
              ].map((t, i) => (
                <div key={i} style={{ display: 'flex', gap: 8 }}>
                  <span style={{ ...TYPO.body4, color: GRAY[500], lineHeight: '20px' }}>•</span>
                  <span style={{ ...TYPO.body4, color: GRAY[200], lineHeight: '20px', flex: 1 }}>{t}</span>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

// ============ SKELETON LOADING ============
function Skel({ w, h, r = 6, style }) {
  return (
    <div style={{
      width: w, height: h, borderRadius: r,
      background: `linear-gradient(90deg, ${GRAY[900]} 0%, ${GRAY[700]} 50%, ${GRAY[900]} 100%)`,
      backgroundSize: '200% 100%',
      animation: 'shimmer 1.4s ease-in-out infinite',
      flexShrink: 0,
      ...style,
    }} />
  );
}

function HeroSkeleton() {
  return (
    <div style={{ width: '100%', height: 270, flexShrink: 0, background: GRAY[900] }}>
      <Skel w="100%" h={270} r={0} />
    </div>
  );
}

function TitleSkeleton() {
  return (
    <div style={{ padding: '20px 20px 24px', display: 'flex', flexDirection: 'column', gap: 14 }}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        <Skel w={120} h={14} />
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Skel w={160} h={30} r={8} />
          <Skel w={68} h={32} r={99} />
        </div>
      </div>
      <Skel w={130} h={18} />
      <Skel w="75%" h={20} />
      <div style={{ display: 'flex', gap: 6 }}>
        {[56, 70, 80, 50].map((w, i) => <Skel key={i} w={w} h={24} r={99} />)}
      </div>
    </div>
  );
}

function InfoSkeleton() {
  return (
    <div style={{ padding: '24px 20px', display: 'flex', flexDirection: 'column', gap: 18 }}>
      {[1, 2, 3, 4].map(i => (
        <div key={i} style={{ display: 'flex', gap: 12, alignItems: 'flex-start' }}>
          <Skel w={17} h={17} r={4} />
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 6 }}>
            <Skel w={`${50 + i * 10}%`} h={14} />
            {i === 1 && <Skel w="40%" h={12} />}
          </div>
        </div>
      ))}
    </div>
  );
}

function MenuSkeleton() {
  return (
    <div style={{ padding: '24px 20px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 14 }}>
        <Skel w={64} h={20} />
        <Skel w={56} h={14} />
      </div>
      <div>
        {[1, 2, 3].map(i => (
          <div key={i} style={{
            display: 'flex', gap: 14, padding: '14px 0',
            borderBottom: `1px solid ${GRAY[900]}`, alignItems: 'center',
          }}>
            <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 8 }}>
              <Skel w="40%" h={14} />
              <Skel w="70%" h={12} />
              <Skel w="30%" h={16} />
            </div>
            <Skel w={88} h={88} r={10} />
          </div>
        ))}
      </div>
    </div>
  );
}

function PhotosSkeleton() {
  return (
    <div style={{ padding: '24px 20px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 14 }}>
        <Skel w={64} h={20} />
        <Skel w={56} h={14} />
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr 1fr', gridTemplateRows: '1fr 1fr', gap: 6, height: 110 }}>
        <Skel w="100%" h="100%" r={10} style={{ gridRow: 'span 2' }} />
        <Skel w="100%" h="100%" r={10} />
        <Skel w="100%" h="100%" r={10} />
        <Skel w="100%" h="100%" r={10} />
        <Skel w="100%" h="100%" r={10} />
      </div>
    </div>
  );
}

function NearbySkeleton() {
  return (
    <div style={{ padding: '24px 0 24px 20px' }}>
      <div style={{ paddingRight: 20, display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 14 }}>
        <Skel w={80} h={20} />
        <Skel w={56} h={14} />
      </div>
      <div style={{ display: 'flex', gap: 12, paddingRight: 20, overflowX: 'hidden' }}>
        {[1, 2, 3, 4].map(i => (
          <div key={i} style={{ width: 124, flexShrink: 0 }}>
            <Skel w={124} h={124} r={10} style={{ marginBottom: 8 }} />
            <Skel w="80%" h={14} style={{ marginBottom: 6 }} />
            <Skel w="60%" h={12} />
          </div>
        ))}
      </div>
    </div>
  );
}

function HomeSkeleton() {
  return (
    <>
      <InfoSkeleton />
      <SectionDivider />
      <MenuSkeleton />
      <SectionDivider />
      <PhotosSkeleton />
      <SectionDivider />
      <NearbySkeleton />
      <div style={{ height: 24 }} />
    </>
  );
}

// 사진 탭 전체 스켈레톤 (매스너리)
function PhotosTabSkeleton() {
  return (
    <div>
      <div style={{ padding: '16px 20px 12px', display: 'flex', gap: 8 }}>
        {[44, 64, 56, 50].map((w, i) => <Skel key={i} w={w} h={30} r={99} />)}
      </div>
      <div style={{ padding: '16px 20px 0', display: 'flex', gap: 8 }}>
        {[[262, 180, 220, 270], [180, 220, 180, 200]].map((hs, ci) => (
          <div key={ci} style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 8 }}>
            {hs.map((h, i) => <Skel key={i} w="100%" h={h} r={6} />)}
          </div>
        ))}
      </div>
    </div>
  );
}

// 메뉴 탭 전체 스켈레톤
function MenuTabSkeleton() {
  return (
    <div>
      <div style={{ padding: '24px 0 28px', borderBottom: `2px solid ${GRAY[900]}` }}>
        <div style={{ padding: '0 20px 16px' }}><Skel w={88} h={20} /></div>
        <div style={{ display: 'flex', gap: 8, padding: '0 20px' }}>
          {[1, 2, 3].map(i => <Skel key={i} w={121} h={121} r={8} />)}
        </div>
      </div>
      <div style={{ padding: '16px 20px 12px', display: 'flex', gap: 8 }}>
        {[60, 48, 56, 80].map((w, i) => <Skel key={i} w={w} h={32} r={99} />)}
      </div>
      <div style={{ padding: '8px 20px 24px' }}>
        <Skel w={80} h={20} style={{ marginBottom: 16 }} />
        {[1, 2, 3].map(i => (
          <div key={i} style={{
            display: 'flex', gap: 16, padding: '16px 0',
            borderTop: `1px solid ${GRAY[900]}`, alignItems: 'center',
          }}>
            <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 10 }}>
              <Skel w="45%" h={16} />
              <Skel w="70%" h={12} />
              <Skel w="30%" h={16} />
            </div>
            <Skel w={100} h={100} r={6} />
          </div>
        ))}
      </div>
    </div>
  );
}

// 리뷰 탭 전체 스켈레톤
function ReviewsTabSkeleton() {
  return (
    <div style={{ padding: '20px 20px 32px', display: 'flex', flexDirection: 'column', gap: 20 }}>
      <Skel w="100%" h={44} r={999} />
      <Skel w="100%" h={92} r={12} />
      <div style={{ display: 'flex', justifyContent: 'space-between' }}>
        <Skel w={56} h={16} />
        <Skel w={120} h={20} r={99} />
      </div>
      {[1, 2, 3].map(i => (
        <div key={i} style={{ display: 'flex', flexDirection: 'column', gap: 10, paddingBottom: 16, borderBottom: `1px solid ${GRAY[900]}` }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <Skel w={32} h={32} r={99} />
            <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
              <Skel w={70} h={12} />
              <Skel w={40} h={10} />
            </div>
          </div>
          <Skel w="100%" h={14} />
          <Skel w="80%" h={14} />
        </div>
      ))}
    </div>
  );
}

// 매장 정보 탭 전체 스켈레톤
function InfoTabSkeleton() {
  return (
    <div style={{ padding: '24px 20px', display: 'flex', flexDirection: 'column', gap: 24 }}>
      {[1, 2, 3, 4].map(i => (
        <div key={i} style={{ display: 'flex', gap: 12 }}>
          <Skel w={20} h={20} r={6} />
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 8 }}>
            <Skel w="60%" h={14} />
            <Skel w="40%" h={12} />
          </div>
        </div>
      ))}
      <Skel w="100%" h={160} r={12} />
    </div>
  );
}

// ============ STUB TAB ============
function StubTab({ title }) {
  return (
    <div style={{
      flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center',
      padding: 48, flexDirection: 'column', gap: 8,
    }}>
      <span style={{ ...TYPO.h4, color: GRAY[500] }}>{title} 준비중</span>
      <span style={{ ...TYPO.body4, color: GRAY[600] }}>곧 만나보실 수 있어요</span>
    </div>
  );
}

// ============ SECTION HEADER ============
function SectionHeader({ title, count }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 14 }}>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 6 }}>
        <h2 style={{ fontSize: 18, color: '#fff', fontWeight: 700, margin: 0, letterSpacing: '-0.01em' }}>{title}</h2>
        {count && <span style={{ fontSize: 14, color: C.text4, fontWeight: 500 }}>{count}</span>}
      </div>
      <button style={{
        all: 'unset', cursor: 'pointer',
        display: 'flex', alignItems: 'center', gap: 2,
        fontSize: 12, color: C.text4
      }}>
        전체보기 <IconChevRight size={14} stroke={C.text4} />
      </button>
    </div>);

}

// ============ PHOTOS ============
function PhotosSection() {
  const photos = [
  'linear-gradient(135deg, #2b1655, #7731FE)',
  'linear-gradient(135deg, #ff4d8d, #6622cc)',
  'linear-gradient(135deg, #B5FF60, #2B6BFF)'];

  return (
    <div style={{ padding: '24px 20px' }}>
      <SectionHeader title="사진" count="28" />
      <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr 1fr', gridTemplateRows: '1fr 1fr', gap: 6, height: 110 }}>
        <div style={{ gridRow: 'span 2', background: photos[0], borderRadius: 10, position: 'relative', overflow: 'hidden' }}>
          <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(circle at 40% 40%, rgba(255,255,255,0.2), transparent 60%)' }} />
        </div>
        <div style={{ background: photos[1], borderRadius: 10, position: 'relative', overflow: 'hidden' }}>
          <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(circle at 60% 30%, rgba(255,255,255,0.2), transparent 60%)' }} />
        </div>
        <div style={{ background: photos[2], borderRadius: 10, position: 'relative', overflow: 'hidden' }}>
          <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(circle at 40% 60%, rgba(255,255,255,0.2), transparent 60%)' }} />
        </div>
        <div style={{ background: '#1a1a20', borderRadius: 10, position: 'relative', overflow: 'hidden' }}>
          <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(circle at 50% 50%, rgba(119,49,254,0.4), transparent 70%)' }} />
          <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', flexDirection: 'column', color: '#fff' }}>
            <span style={{ ...TYPO.h4, color: '#fff' }}>+24</span>
            <span style={{ ...TYPO.caption, color: C.text3 }}>더보기</span>
          </div>
        </div>
        <div style={{ background: photos[1], borderRadius: 10, position: 'relative', overflow: 'hidden', opacity: 0.7 }}>
          <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(circle at 60% 30%, rgba(255,255,255,0.2), transparent 60%)' }} />
        </div>
      </div>
    </div>);

}

// ============ NEARBY CLUBS ============
function NearbyClubs() {
  const clubs = [
  { name: '홍대 클럽 레이저', area: '홍대', genre: '힙합', rating: 4.5, color: 'linear-gradient(135deg, #ff006e, #8338ec)' },
  { name: '버뮤다', area: '홍대', genre: '힙합', rating: 4.3, color: 'linear-gradient(135deg, #06ffa5, #3a86ff)' },
  { name: '인클', area: '홍대', genre: '힙합', rating: 4.7, color: 'linear-gradient(135deg, #fb5607, #ffbe0b)' },
  { name: '벨로주', area: '홍대', genre: '재즈', rating: 4.6, color: 'linear-gradient(135deg, #2a2d34, #6c757d)' }];

  return (
    <div style={{ padding: '24px 0 24px 20px' }}>
      <div style={{ paddingRight: 20 }}>
        <SectionHeader title="주변 클럽" />
      </div>
      <div style={{
        display: 'flex', gap: 12, overflowX: 'auto', paddingRight: 20,
        scrollbarWidth: 'none'
      }}>
        {clubs.map((c) =>
        <div key={c.name} style={{ width: 124, flexShrink: 0 }}>
            <div style={{
            width: 124, height: 124, borderRadius: 10, background: c.color,
            position: 'relative', overflow: 'hidden', marginBottom: 8
          }}>
              <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(circle at 40% 40%, rgba(255,255,255,0.2), transparent 60%)' }} />
              <div style={{
              position: 'absolute', top: 6, left: 6,
              padding: '2px 6px', borderRadius: 4,
              background: 'rgba(0,0,0,0.6)', backdropFilter: 'blur(8px)',
              display: 'flex', alignItems: 'center', gap: 3
            }}>
                <IconStar size={10} />
                <span style={{ fontSize: 10, color: '#fff', fontWeight: 600 }}>{c.rating}</span>
              </div>
            </div>
            <div style={{ fontSize: 13, color: '#fff', fontWeight: 600, marginBottom: 2 }}>{c.name}</div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: 11, color: C.text4 }}>
              <span>{c.area}</span>
              <span style={{ width: 2, height: 2, borderRadius: 99, background: C.text6 }} />
              <span>{c.genre}</span>
            </div>
          </div>
        )}
      </div>
    </div>);

}

// ============ BOTTOM CTA ============
function BottomBar() {
  return (
    <div style={{
      position: 'relative',
      background: 'rgba(14,14,17,0.85)',
      backdropFilter: 'blur(20px)',
      borderTop: `1px solid ${C.divider2}`,
      padding: '12px 20px 28px'
    }}>
      {/* tooltip */}
      <div style={{
        position: 'absolute', left: 20, top: -28,
        background: '#fff', color: '#0E0E11',
        padding: '4px 10px', borderRadius: 6,
        ...TYPO.caption, fontWeight: 600,
        animation: 'tooltipBob 2s ease-in-out infinite'
      }}>
        온라인 웨이팅 가능
        <div style={{
          position: 'absolute', bottom: -4, left: 22,
          width: 8, height: 8, background: '#fff',
          transform: 'rotate(45deg)'
        }} />
      </div>
      <div style={{ display: 'flex', gap: 8 }}>
        <button style={{
          flex: 1, padding: '13px 0', borderRadius: 8,
          background: 'transparent', color: '#fff',
          border: `1px solid ${C.purple}`,
          ...TYPO.button1, fontWeight: 700, cursor: 'pointer'
        }}>웨이팅 등록</button>
        <button style={{
          flex: 1.3, padding: '13px 0', borderRadius: 8,
          background: C.purpleDeep, color: '#fff',
          border: 'none', ...TYPO.button1, fontWeight: 700, cursor: 'pointer',
          boxShadow: '0 4px 16px rgba(119,49,254,0.35)'
        }}>테이블 예약</button>
      </div>
    </div>);

}

// ============ ROOT ============
function App() {
  const [tab, setTab] = useState('홈');
  const [saved, setSaved] = useState(false);
  const scrollRef = useRef(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const t = setTimeout(() => setLoading(false), 2200);
    return () => clearTimeout(t);
  }, []);

  return (
    <div style={{
      width: '100%', height: '100%', background: C.bg,
      color: C.text, fontFamily: "'Pretendard', -apple-system, BlinkMacSystemFont, sans-serif",
      display: 'flex', flexDirection: 'column',
      overflow: 'hidden'
    }}>
      <div ref={scrollRef} style={{ flex: 1, overflowY: 'auto', scrollbarWidth: 'none', display: 'flex', flexDirection: 'column' }}>
        {loading ? <HeroSkeleton /> : <Hero saved={saved} onSaved={() => setSaved(!saved)} />}
        {loading ? <TitleSkeleton /> : <TitleBlock />}
        <SectionDivider />
        <Tabs active={tab} onChange={setTab} />
        {tab === '홈' && (
          loading ? <HomeSkeleton /> : <>
            <InfoSection />
            <SectionDivider />
            <MenuSection />
            <SectionDivider />
            <PhotosSection />
            <SectionDivider />
            <NearbyClubs />
            <div style={{ height: 24 }} />
          </>
        )}
        {tab === '메뉴' && (loading ? <MenuTabSkeleton /> : <MenuTab scrollRef={scrollRef} />)}
        {tab === '사진' && (loading ? <PhotosTabSkeleton /> : <PhotosTab />)}
        {tab === '리뷰' && (loading ? <ReviewsTabSkeleton /> : <ReviewsTab />)}
        {tab === '매장 정보' && (loading ? <InfoTabSkeleton /> : <InfoTab />)}
      </div>
    </div>);

}

// ============ MOUNT ============
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <IOSDevice dark={true} width={393} height={852}>
    <App />
  </IOSDevice>
);