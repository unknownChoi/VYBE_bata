/* global React, ReactDOM, IOSDevice, COLORS, TYPO, GRAY, PURPLE, LIME */
const { useState, useRef, useEffect } = React;

const C = {
  bg: COLORS.bg,
  text: COLORS.white,
  text2: GRAY[200],
  text3: GRAY[400],
  text4: GRAY[500],
  text5: GRAY[600],
  text6: GRAY[700],
  surface: GRAY[900],
  purple: PURPLE[500],
  purpleDeep: PURPLE[700],
  lime: LIME[500],
};

// ============ ICONS ============
const I = {
  Back: (p) => (<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#CACACB" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" {...p}>
    <polyline points="15 18 9 12 15 6" />
  </svg>),
  Search: (p) => (<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#9F9FA1" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...p}>
    <circle cx="11" cy="11" r="7" /><line x1="20" y1="20" x2="16.5" y2="16.5" />
  </svg>),
  Pin: ({ size = 14, color = GRAY[600] }) => (<svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" /><circle cx="12" cy="10" r="3" />
  </svg>),
  Clock: ({ size = 14, color = GRAY[600] }) => (<svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <circle cx="12" cy="12" r="10" /><polyline points="12 6 12 12 16 14" />
  </svg>),
  Ticket: ({ size = 14, color = GRAY[600] }) => (<svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M2 9a3 3 0 0 1 0 6v2a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-2a3 3 0 0 1 0-6V7a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2z" />
    <path d="M13 5v2" /><path d="M13 17v2" /><path d="M13 11v2" />
  </svg>),
  Star: ({ size = 12, color = LIME[500] }) => (<svg width={size} height={size} viewBox="0 0 24 24" fill={color} stroke={color} strokeWidth="1" strokeLinecap="round" strokeLinejoin="round">
    <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
  </svg>),
  Chevron: ({ size = 12, color = GRAY[200] }) => (<svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round">
    <polyline points="6 9 12 15 18 9" />
  </svg>),
  Filter: ({ size = 12, color = GRAY[200] }) => (<svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round">
    <line x1="4" y1="6" x2="20" y2="6" /><line x1="7" y1="12" x2="17" y2="12" /><line x1="10" y1="18" x2="14" y2="18" />
  </svg>),
  Locate: (p) => (<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...p}>
    <circle cx="12" cy="12" r="3" /><line x1="12" y1="2" x2="12" y2="5" /><line x1="12" y1="19" x2="12" y2="22" />
    <line x1="2" y1="12" x2="5" y2="12" /><line x1="19" y1="12" x2="22" y2="12" />
  </svg>),
  Layers: (p) => (<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#CACACB" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...p}>
    <polygon points="12 2 2 7 12 12 22 7 12 2" /><polyline points="2 17 12 22 22 17" /><polyline points="2 12 12 17 22 12" />
  </svg>),
};

// ============ MAP (decorative fake map) ============
function MapBackground({ pins, selected, onSelect }) {
  return (
    <div style={{
      position: 'absolute', inset: 0,
      background: '#1a1d24',
      overflow: 'hidden',
    }}>
      {/* base map texture */}
      <svg width="100%" height="100%" viewBox="0 0 393 852" preserveAspectRatio="xMidYMid slice" style={{ position: 'absolute', inset: 0 }}>
        <defs>
          <linearGradient id="mapGrad" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor="#1f2228" />
            <stop offset="100%" stopColor="#13151a" />
          </linearGradient>
          <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
            <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#252830" strokeWidth="0.5" />
          </pattern>
        </defs>
        <rect width="393" height="852" fill="url(#mapGrad)" />
        <rect width="393" height="852" fill="url(#grid)" />

        {/* park / area shapes */}
        <ellipse cx="80" cy="340" rx="100" ry="60" fill="#1b2a1f" opacity="0.7" />
        <ellipse cx="320" cy="180" rx="120" ry="80" fill="#1b2a1f" opacity="0.5" />
        <ellipse cx="240" cy="480" rx="90" ry="40" fill="#1b2a1f" opacity="0.5" />

        {/* river */}
        <path d="M-20 600 Q 100 580, 200 620 T 420 580" stroke="#2a3848" strokeWidth="32" fill="none" opacity="0.6" />

        {/* roads */}
        <path d="M-20 200 Q 200 220, 420 180" stroke="#2c3038" strokeWidth="14" fill="none" />
        <path d="M-20 200 Q 200 220, 420 180" stroke="#3b4250" strokeWidth="1" fill="none" strokeDasharray="6 6" />
        <path d="M-20 420 L 420 440" stroke="#2c3038" strokeWidth="11" fill="none" />
        <path d="M120 -20 Q 140 400, 100 870" stroke="#2c3038" strokeWidth="12" fill="none" />
        <path d="M280 -20 Q 260 400, 300 870" stroke="#2c3038" strokeWidth="11" fill="none" />
        <path d="M50 100 L 380 130" stroke="#262a32" strokeWidth="6" fill="none" />
        <path d="M30 720 L 380 700" stroke="#2c3038" strokeWidth="10" fill="none" />

        {/* secondary thin streets */}
        <path d="M-20 280 L 420 290" stroke="#262a32" strokeWidth="3" fill="none" />
        <path d="M-20 360 L 420 370" stroke="#262a32" strokeWidth="3" fill="none" />
        <path d="M180 -20 L 200 870" stroke="#262a32" strokeWidth="3" fill="none" />
        <path d="M340 -20 L 360 870" stroke="#262a32" strokeWidth="3" fill="none" />

        {/* building footprints */}
        {[
          [40, 240, 30, 25], [80, 250, 22, 20], [110, 245, 24, 18],
          [200, 150, 35, 28], [240, 140, 28, 22], [280, 150, 20, 18],
          [50, 470, 26, 22], [160, 530, 32, 26], [330, 320, 30, 24],
          [60, 750, 28, 22], [110, 760, 22, 18], [220, 760, 30, 24], [310, 770, 24, 20],
        ].map(([x, y, w, h], i) => (
          <rect key={i} x={x} y={y} width={w} height={h} rx="2" fill="#22252c" />
        ))}

        {/* street names (light) */}
        <text x="60" y="195" fill="#3d4250" fontSize="9" fontFamily="Pretendard">홍익로</text>
        <text x="240" y="415" fill="#3d4250" fontSize="9" fontFamily="Pretendard">와우산로</text>
        <text x="130" y="640" fill="#3d4250" fontSize="9" fontFamily="Pretendard">잔다리로</text>
      </svg>

      {/* pins */}
      {pins.map((p, i) => {
        const sel = selected === i;
        return (
          <button key={i} onClick={() => onSelect(i)} style={{
            all: 'unset', cursor: 'pointer', position: 'absolute',
            left: `${p.x}%`, top: `${p.y}%`,
            transform: `translate(-50%, -100%) ${sel ? 'scale(1.05)' : 'scale(1)'}`,
            zIndex: sel ? 5 : 2,
            transition: 'transform .2s',
          }}>
            {/* pin body */}
            <div style={{
              padding: '4px 10px 4px 8px', borderRadius: 999,
              background: sel ? LIME[500] : '#fff',
              color: COLORS.bg,
              ...TYPO.caption, lineHeight: '14px', fontWeight: 700,
              display: 'flex', alignItems: 'center', gap: 4,
              boxShadow: sel ? `0 6px 20px rgba(181,255,96,0.4)` : '0 4px 12px rgba(0,0,0,0.4)',
              whiteSpace: 'nowrap',
            }}>
              <I.Star size={10} color={COLORS.bg} />
              {p.rating}
            </div>
            {/* tail */}
            <div style={{
              width: 8, height: 8, background: sel ? LIME[500] : '#fff',
              transform: 'rotate(45deg) translateY(-4px)',
              margin: '0 auto',
              boxShadow: sel ? '0 4px 8px rgba(181,255,96,0.3)' : '0 2px 4px rgba(0,0,0,0.3)',
            }} />
          </button>
        );
      })}

      {/* my-location dot */}
      <div style={{
        position: 'absolute', left: '50%', top: '38%',
        transform: 'translate(-50%, -50%)',
      }}>
        <div style={{
          position: 'absolute', inset: -10,
          borderRadius: '50%', background: 'rgba(43, 107, 255, 0.25)',
          animation: 'pulseDot 2s ease-in-out infinite',
        }} />
        <div style={{
          width: 16, height: 16, borderRadius: '50%',
          background: '#2B6BFF',
          border: '3px solid #fff',
          boxShadow: '0 0 12px rgba(43,107,255,0.6)',
          position: 'relative',
        }} />
      </div>
    </div>
  );
}

// ============ TOP SEARCH BAR ============
function TopSearch() {
  return (
    <div style={{
      padding: '0 20px 8px',
    }}>
      <div style={{
        display: 'flex', alignItems: 'center', gap: 8,
        background: 'rgba(16,16,19,0.85)',
        backdropFilter: 'blur(16px)', WebkitBackdropFilter: 'blur(16px)',
        borderRadius: 999, padding: '8px 8px 8px 14px',
        border: `1px solid ${GRAY[800]}`,
        boxShadow: '0 8px 24px rgba(0,0,0,0.3)',
      }}>
        <I.Search />
        <input
          placeholder="홍대 / 클럽 이름 검색"
          style={{
            flex: 1, background: 'transparent', border: 'none', outline: 'none',
            color: '#fff', ...TYPO.body4, fontFamily: 'Pretendard',
          }}
        />
        <button style={{
          all: 'unset', cursor: 'pointer',
          width: 32, height: 32, borderRadius: '50%',
          background: GRAY[800],
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <I.Filter color="#fff" size={14} />
        </button>
      </div>
    </div>
  );
}

// ============ FILTER CHIPS (sticky just under search) ============
const FILTERS = [
  { key: 'sort',    label: '추천순', dropdown: true },
  { key: 'filter',  label: '필터',   icon: 'filter' },
  { key: 'open',    label: '영업중' },
  { key: 'free',    label: '입장료 무료' },
  { key: 'drink',   label: '서비스 음료' },
  { key: 'hot',     label: '핫플레이스' },
];

function FilterChips({ active, onToggle }) {
  return (
    <div style={{
      position: 'absolute', top: 70, left: 0, right: 0, zIndex: 9,
      padding: '8px 20px',
      display: 'flex', gap: 8, overflowX: 'auto', scrollbarWidth: 'none',
    }}>
      {FILTERS.map(f => {
        const sel = active.includes(f.key);
        return (
          <button key={f.key} onClick={() => onToggle(f.key)} style={{
            all: 'unset', cursor: 'pointer', flexShrink: 0,
            padding: '7px 12px', borderRadius: 999,
            background: sel ? PURPLE[700] : 'rgba(47,47,51,0.85)',
            backdropFilter: 'blur(8px)',
            border: sel ? 'none' : `1px solid ${GRAY[700]}`,
            ...TYPO.caption, lineHeight: '14px', fontWeight: sel ? 600 : 500,
            color: sel ? '#fff' : GRAY[200],
            display: 'flex', alignItems: 'center', gap: 4,
          }}>
            {f.label}
            {f.dropdown && <I.Chevron size={12} color={sel ? '#fff' : GRAY[200]} />}
            {f.icon === 'filter' && <I.Filter size={11} color={sel ? '#fff' : GRAY[200]} />}
          </button>
        );
      })}
    </div>
  );
}

// ============ MAP CONTROLS ============
function MapControls() {
  return (
    <div style={{
      position: 'absolute', right: 16, bottom: '52%', zIndex: 6,
      display: 'flex', flexDirection: 'column', gap: 8,
    }}>
      <button style={mapBtn}><I.Locate /></button>
      <button style={mapBtn}><I.Layers /></button>
    </div>
  );
}
const mapBtn = {
  all: 'unset', cursor: 'pointer',
  width: 44, height: 44, borderRadius: '50%',
  background: 'rgba(16,16,19,0.92)',
  backdropFilter: 'blur(12px)',
  border: `1px solid ${GRAY[800]}`,
  boxShadow: '0 4px 12px rgba(0,0,0,0.3)',
  display: 'flex', alignItems: 'center', justifyContent: 'center',
};

// ============ CLUB CARD ============
const CLUBS = [
  { id: 1, name: '어썸레드', area: '홍대', genre: '힙합 클럽',  rating: 4.76, address: '서울 마포구 잔다리로 12 지하 1층', hours: '02:00에 영업 종료', open: true, fee: '0 ~ 10,000원', recommended: true, x: 48, y: 42, photo: 'linear-gradient(135deg, #7731FE, #ff4d8d)', href: 'club_detail.html' },
  { id: 2, name: '홍대 클럽 레이저', area: '홍대', genre: '힙합 클럽', rating: 4.5, address: '서울 마포구 와우산로 23 지하 1층', hours: '03:00에 영업 종료', open: true, fee: '10,000 ~ 20,000원', x: 28, y: 60, photo: 'linear-gradient(135deg, #ff006e, #8338ec)', href: '#' },
  { id: 3, name: '버뮤다',  area: '홍대', genre: '힙합 클럽',  rating: 4.3, address: '서울 마포구 양화로 161 지하 2층', hours: '02:00에 영업 종료', open: true, fee: '0 ~ 15,000원', x: 64, y: 55, photo: 'linear-gradient(135deg, #06ffa5, #3a86ff)', href: '#' },
  { id: 4, name: '인클',    area: '홍대', genre: '힙합 클럽',  rating: 4.7, address: '서울 마포구 동교로 165', hours: '04:00에 영업 종료', open: true, fee: '20,000원', x: 36, y: 72, photo: 'linear-gradient(135deg, #fb5607, #ffbe0b)', href: '#' },
  { id: 5, name: '벨로주',  area: '홍대', genre: '재즈 클럽',  rating: 4.5, address: '서울 마포구 와우산로 19', hours: '01:30에 영업 종료', open: true, fee: '입장료 무료', x: 70, y: 78, photo: 'linear-gradient(135deg, #2a2d34, #6c757d)', href: '#' },
];

function ClubCard({ club, selected, onHover }) {
  return (
    <a
      href={club.href}
      onClick={e => club.href === '#' && e.preventDefault()}
      onMouseEnter={() => onHover && onHover(true)}
      onMouseLeave={() => onHover && onHover(false)}
      style={{
        display: 'flex', flexDirection: 'column', gap: 12,
        padding: '20px 24px',
        borderBottom: `1px solid ${GRAY[800]}`,
        background: selected ? 'rgba(119,49,254,0.06)' : 'transparent',
        textDecoration: 'none', transition: 'background .2s',
      }}
    >
      {/* header */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, flexWrap: 'wrap' }}>
          <span style={{ ...TYPO.h4, color: '#fff', margin: 0 }}>{club.name}</span>
          {club.recommended && (
            <span style={{
              display: 'inline-flex', alignItems: 'center', gap: 3,
              padding: '2px 7px', borderRadius: 999,
              background: 'rgba(181,255,96,0.14)',
              ...TYPO.caption, lineHeight: '14px', fontWeight: 600,
              color: LIME[500],
            }}>
              <I.Star size={10} />
              VYBE 추천 클럽
            </span>
          )}
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
            <I.Star size={12} />
            <span style={{ ...TYPO.caption, color: '#fff', lineHeight: '14px', fontWeight: 600 }}>{club.rating.toFixed(2)}</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
            <span style={{ ...TYPO.caption, color: GRAY[500], lineHeight: '14px' }}>{club.area}</span>
            <span style={{ width: 1, height: 10, background: GRAY[700] }} />
            <span style={{ ...TYPO.caption, color: GRAY[500], lineHeight: '14px' }}>{club.genre}</span>
          </div>
        </div>
      </div>

      {/* photo */}
      <div style={{
        width: '100%', height: 152, borderRadius: 12,
        background: club.photo,
        border: `1px solid ${GRAY[900]}`,
        position: 'relative', overflow: 'hidden',
      }}>
        <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(circle at 30% 30%, rgba(255,255,255,0.2), transparent 60%)' }} />
        {/* save fab */}
        <button onClick={e => e.preventDefault()} style={{
          all: 'unset', cursor: 'pointer',
          position: 'absolute', right: 10, bottom: 10,
          width: 36, height: 36, borderRadius: '50%',
          background: 'rgba(16,16,19,0.8)', backdropFilter: 'blur(8px)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#ECECEC" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
          </svg>
        </button>
      </div>

      {/* meta */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <I.Pin />
          <span style={{ ...TYPO.caption, color: GRAY[400], lineHeight: '14px' }}>{club.address}</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 18 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <I.Clock />
            <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
              <span style={{ ...TYPO.caption, color: club.open ? LIME[500] : GRAY[500], lineHeight: '14px', fontWeight: 600 }}>
                {club.open ? '영업중' : '영업종료'}
              </span>
              <span style={{ width: 2, height: 2, background: GRAY[600], borderRadius: 99 }} />
              <span style={{ ...TYPO.caption, color: GRAY[400], lineHeight: '14px' }}>{club.hours}</span>
            </div>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <I.Ticket />
            <span style={{ ...TYPO.caption, color: GRAY[400], lineHeight: '14px' }}>{club.fee}</span>
          </div>
        </div>
      </div>
    </a>
  );
}

// ============ BOTTOM SHEET ============
function BottomSheet({ selected, onSelect }) {
  const [expanded, setExpanded] = useState(false);
  const sheetRef = useRef(null);

  // Heights (px from bottom): collapsed ~ peek, expanded ~ full
  const COLLAPSED_H = 380;
  const EXPANDED_H = 760;
  const height = expanded ? EXPANDED_H : COLLAPSED_H;

  // Reorder so selected club is first
  const list = [...CLUBS];
  const selIdx = list.findIndex(c => c.id === selected);
  if (selIdx > 0) {
    const [s] = list.splice(selIdx, 1);
    list.unshift(s);
  }

  return (
    <div ref={sheetRef} style={{
      position: 'absolute', left: 0, right: 0, bottom: 0,
      height,
      background: GRAY[900],
      borderTopLeftRadius: 24, borderTopRightRadius: 24,
      boxShadow: '0 -10px 32px rgba(0,0,0,0.4)',
      display: 'flex', flexDirection: 'column',
      transition: 'height .3s cubic-bezier(0.32, 0.72, 0, 1)',
      overflow: 'hidden',
      zIndex: 8,
    }}>
      {/* drag handle */}
      <button onClick={() => setExpanded(!expanded)} style={{
        all: 'unset', cursor: 'pointer',
        padding: '10px 0 6px', display: 'flex', justifyContent: 'center',
        flexShrink: 0,
      }}>
        <div style={{
          width: 40, height: 4, borderRadius: 99,
          background: GRAY[600],
        }} />
      </button>

      {/* header */}
      <div style={{
        padding: '4px 24px 12px', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        flexShrink: 0,
      }}>
        <span style={{ ...TYPO.body3, color: '#fff', fontWeight: 600 }}>
          내 주변 클럽 <span style={{ color: LIME[500] }}>{CLUBS.length}</span>
        </span>
        <button onClick={() => setExpanded(!expanded)} style={{
          all: 'unset', cursor: 'pointer',
          ...TYPO.caption, color: GRAY[400], lineHeight: '14px',
          display: 'flex', alignItems: 'center', gap: 2,
        }}>
          {expanded ? '지도 보기' : '목록으로 보기'}
          <I.Chevron size={12} color={GRAY[400]} />
        </button>
      </div>

      {/* list */}
      <div style={{ flex: 1, overflowY: 'auto', scrollbarWidth: 'none' }}>
        {list.map(c => (
          <ClubCard
            key={c.id}
            club={c}
            selected={selected === c.id}
            onHover={(h) => h && onSelect(c.id)}
          />
        ))}
      </div>
    </div>
  );
}

// ============ NAV BAR (top, before search) ============
function NavBar() {
  return (
    <div style={{
      position: 'absolute', top: 56, left: 0, right: 0, zIndex: 11,
      padding: '6px 20px 8px',
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
    }}>
      <button onClick={() => { history.length > 1 ? history.back() : (window.location.href = 'home.html'); }} style={{
        all: 'unset', cursor: 'pointer',
        width: 36, height: 36, borderRadius: '50%',
        background: 'rgba(16,16,19,0.85)', backdropFilter: 'blur(8px)',
        border: `1px solid ${GRAY[800]}`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <I.Back />
      </button>
      <div style={{
        padding: '8px 14px', borderRadius: 999,
        background: 'rgba(16,16,19,0.85)', backdropFilter: 'blur(8px)',
        border: `1px solid ${GRAY[800]}`,
        ...TYPO.caption, color: GRAY[200], lineHeight: '14px', fontWeight: 600,
      }}>
        홍대 일대
      </div>
      <div style={{ width: 36 }} />
    </div>
  );
}

// ============ ROOT ============
function App() {
  const [selected, setSelected] = useState(1);
  const [activeFilters, setActiveFilters] = useState(['free']);

  const pins = CLUBS.map(c => ({ x: c.x, y: c.y, rating: c.rating, id: c.id }));

  const toggleFilter = (k) => {
    setActiveFilters(prev => prev.includes(k) ? prev.filter(x => x !== k) : [...prev, k]);
  };

  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative',
      background: C.bg, overflow: 'hidden',
      fontFamily: "'Pretendard', sans-serif", color: '#fff',
    }}>
      <MapBackground
        pins={pins}
        selected={pins.findIndex(p => p.id === selected)}
        onSelect={(i) => setSelected(pins[i].id)}
      />

      <div style={{ position: 'absolute', top: 60, left: 0, right: 0, zIndex: 10 }}>
        <TopSearch />
        <div style={{
          padding: '0 20px 8px',
          display: 'flex', gap: 8, overflowX: 'auto', scrollbarWidth: 'none',
        }}>
          {FILTERS.map(f => {
            const sel = activeFilters.includes(f.key);
            return (
              <button key={f.key} onClick={() => toggleFilter(f.key)} style={{
                all: 'unset', cursor: 'pointer', flexShrink: 0,
                padding: '7px 12px', borderRadius: 999,
                background: sel ? PURPLE[700] : 'rgba(47,47,51,0.85)',
                backdropFilter: 'blur(8px)',
                border: sel ? 'none' : `1px solid ${GRAY[700]}`,
                ...TYPO.caption, lineHeight: '14px', fontWeight: sel ? 600 : 500,
                color: sel ? '#fff' : GRAY[200],
                display: 'flex', alignItems: 'center', gap: 4,
              }}>
                {f.label}
                {f.dropdown && <I.Chevron size={11} color={sel ? '#fff' : GRAY[200]} />}
                {f.icon === 'filter' && <I.Filter size={11} color={sel ? '#fff' : GRAY[200]} />}
              </button>
            );
          })}
        </div>
      </div>

      <MapControls />

      <BottomSheet selected={selected} onSelect={setSelected} />
    </div>
  );
}

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <IOSDevice dark={true} width={393} height={852}>
    <App />
  </IOSDevice>
);
