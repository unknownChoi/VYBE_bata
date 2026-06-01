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
  lime: LIME[500],
};

// ============ ICONS (inline strokes) ============
const I = {
  Bell: (p) => (<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#ECECEC" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" {...p}>
    <path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9" /><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0" />
  </svg>),
  Profile: (p) => (<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#ECECEC" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" {...p}>
    <circle cx="12" cy="8" r="4" /><path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8" />
  </svg>),
  Pin: (p) => (<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#ECECEC" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" {...p}>
    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" /><circle cx="12" cy="10" r="3" />
  </svg>),
  ChevRight: (p) => (<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#CACACB" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" {...p}>
    <polyline points="9 18 15 12 9 6" />
  </svg>),
  Home: ({ active }) => (<svg width="24" height="24" viewBox="0 0 24 24" fill={active ? LIME[500] : 'none'} stroke={active ? LIME[500] : '#fff'} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
    <path d="M3 10.5L12 3l9 7.5V20a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z" />
  </svg>),
  Around: ({ active }) => (<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke={active ? LIME[500] : '#fff'} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" /><circle cx="12" cy="10" r="3" />
  </svg>),
  Wallet: ({ active }) => (<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke={active ? LIME[500] : '#fff'} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
    <rect x="2" y="6" width="20" height="14" rx="2.5" /><path d="M16 13h2" /><path d="M2 10h20" />
  </svg>),
  Search: ({ active }) => (<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke={active ? LIME[500] : '#fff'} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
    <circle cx="11" cy="11" r="7" /><line x1="20" y1="20" x2="16.5" y2="16.5" />
  </svg>),
  Me: ({ active }) => (<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke={active ? LIME[500] : '#fff'} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
    <circle cx="12" cy="8" r="4" /><path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8" />
  </svg>),
  Star: ({ size = 12 }) => (<svg width={size} height={size} viewBox="0 0 24 24" fill={LIME[500]} stroke={LIME[500]} strokeWidth="1" strokeLinecap="round" strokeLinejoin="round">
    <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
  </svg>),
};

// ============ TOP BAR ============
function TopBar({ scrolled }) {
  return (
    <div style={{
      position: 'sticky', top: 0, zIndex: 5,
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '10px 24px',
      background: scrolled ? 'rgba(16,16,19,0.85)' : 'transparent',
      backdropFilter: scrolled ? 'blur(16px)' : 'none',
      WebkitBackdropFilter: scrolled ? 'blur(16px)' : 'none',
      borderBottom: `1px solid ${scrolled ? GRAY[900] : 'transparent'}`,
      transition: 'background .2s, border-color .2s',
    }}>
      {/* vybe wordmark */}
      <div style={{
        fontFamily: 'Pretendard', fontSize: 22, fontWeight: 800,
        letterSpacing: '-0.04em', display: 'flex',
      }}>
        <span style={{ color: '#fff' }}>v</span>
        <span style={{ color: LIME[500] }}>y</span>
        <span style={{ color: '#fff' }}>b</span>
        <span style={{ color: PURPLE[500] }}>e</span>
      </div>
      <div style={{ display: 'flex', gap: 14, alignItems: 'center' }}>
        <button style={iconBtn}><I.Bell /></button>
        <button style={iconBtn}><I.Profile /></button>
      </div>
    </div>
  );
}
const iconBtn = { all: 'unset', cursor: 'pointer', width: 24, height: 24, display: 'flex' };

// ============ GREETING ============
function Greeting() {
  const hour = new Date().getHours();
  const moment = hour < 5 ? '늦은 밤' : hour < 12 ? '오전' : hour < 18 ? '오후' : '오늘 밤';
  return (
    <div style={{ padding: '8px 24px 4px', display: 'flex', flexDirection: 'column', gap: 4 }}>
      <span style={{ ...TYPO.h3, fontWeight: 600, color: '#fff' }}>
        안녕, 길동님 <span style={{ display: 'inline-block', transform: 'translateY(-1px)' }}>👋</span>
      </span>
      <span style={{ ...TYPO.body3, color: GRAY[500] }}>
        {moment} 어디서 놀까요?
      </span>
    </div>
  );
}

// ============ LOCATION ROW ============
function LocationRow() {
  return (
    <button style={{
      all: 'unset', cursor: 'pointer',
      margin: '16px 24px 4px',
      padding: '12px 16px',
      display: 'flex', alignItems: 'center', gap: 8,
      background: GRAY[900], borderRadius: 999,
      border: `1px solid ${GRAY[800]}`,
    }}>
      <I.Pin />
      <span style={{ ...TYPO.body3, color: GRAY[300] }}>내 주변 클럽 찾기</span>
      <div style={{ flex: 1 }} />
      <I.ChevRight />
    </button>
  );
}

// ============ HERO BANNER ============
const HEROES = [
  {
    tag: '# 6월의 핫플',
    title: '나만 알고 싶은\n히든 플레이스',
    sub: '요즘 가장 핫한 홍대클럽',
    bg: 'linear-gradient(135deg, #2b1655 0%, #7731FE 55%, #ff4d8d 100%)',
  },
  {
    tag: '# 이번주 라인업',
    title: '주말이 짧다고\n느껴진다면',
    sub: '강남·홍대 클럽 위켄드 가이드',
    bg: 'linear-gradient(135deg, #0f0f23 0%, #2B6BFF 60%, #7731FE 100%)',
  },
  {
    tag: '# 신규 오픈',
    title: '이주 새로 문을 연\n3곳의 라운지',
    sub: '지금 가야 자리 잡는다',
    bg: 'linear-gradient(135deg, #1a0b3d 0%, #6622cc 60%, #B5FF60 130%)',
  },
  {
    tag: '# DJ 라인업',
    title: '국내 최정상 DJ\n4월의 라인업',
    sub: '놓치면 후회하는 셋',
    bg: 'linear-gradient(135deg, #2a0d4a 0%, #ff4d8d 60%, #7731FE 100%)',
  },
  {
    tag: '# 무료 입장',
    title: '오늘 밤은 공짜로\n입장하자',
    sub: '입장료 0원 매장 모음',
    bg: 'linear-gradient(135deg, #0a0a1f 0%, #94CF51 50%, #B5FF60 100%)',
  },
];

function Hero() {
  const [idx, setIdx] = useState(0);
  const ref = useRef(null);

  const onScroll = () => {
    const el = ref.current;
    if (!el) return;
    const w = el.clientWidth;
    setIdx(Math.round(el.scrollLeft / w));
  };

  return (
    <div style={{ position: 'relative', height: 240 }}>
      <div
        ref={ref}
        onScroll={onScroll}
        style={{
          display: 'flex', overflowX: 'auto', scrollSnapType: 'x mandatory',
          height: '100%', scrollbarWidth: 'none',
        }}
      >
        {HEROES.map((h, i) => (
          <div key={i} style={{
            flex: '0 0 100%', height: '100%',
            background: h.bg, scrollSnapAlign: 'start',
            position: 'relative', overflow: 'hidden',
          }}>
            {/* photo placeholder grain */}
            <div style={{
              position: 'absolute', inset: 0,
              background: 'radial-gradient(70% 100% at 90% 60%, rgba(0,0,0,0.0), rgba(0,0,0,0.55))',
            }} />
            <div style={{
              position: 'absolute', inset: 0,
              background: 'linear-gradient(180deg, rgba(0,0,0,0.0) 30%, rgba(0,0,0,0.55) 100%)',
            }} />
            <div style={{
              position: 'absolute', left: 24, top: 32, right: 100,
              display: 'flex', flexDirection: 'column', gap: 12,
            }}>
              <span style={{ ...TYPO.body3, color: LIME[500] }}>{h.tag}</span>
              <h2 style={{
                ...TYPO.h3, fontWeight: 600, color: '#fff',
                margin: 0, whiteSpace: 'pre-line',
              }}>{h.title}</h2>
              <span style={{ ...TYPO.body3, color: GRAY[400] }}>{h.sub}</span>
            </div>
          </div>
        ))}
      </div>

      {/* counter pill */}
      <div style={{
        position: 'absolute', right: 24, bottom: 16,
        padding: '4px 12px', borderRadius: 999,
        background: 'rgba(25,25,25,0.7)', backdropFilter: 'blur(8px)',
        ...TYPO.caption, color: '#fff', lineHeight: '16px',
      }}>
        {idx + 1} / {HEROES.length}
      </div>

      {/* dot indicator */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 16,
        display: 'flex', justifyContent: 'center', gap: 4,
        pointerEvents: 'none',
      }}>
        {HEROES.map((_, i) => (
          <div key={i} style={{
            width: i === idx ? 18 : 5, height: 5, borderRadius: 99,
            background: i === idx ? LIME[500] : 'rgba(255,255,255,0.4)',
            transition: 'all .25s',
          }} />
        ))}
      </div>
    </div>
  );
}

// ============ DIVIDER ============
const ThickDivider = () => <div style={{ height: 8, background: GRAY[900] }} />;

// ============ CATEGORY GRID ============
const CATS = [
  { key: 'vybe',    label: 'VYBE 추천',  src: 'assets/icons/lounge.svg' },
  { key: 'hot',     label: '핫플레이스',  src: 'assets/icons/hot_place.svg' },
  { key: 'free',    label: '입장료 무료', src: 'assets/icons/free_entry.svg' },
  { key: 'drink',   label: '서비스 음료', src: 'assets/icons/service_drink.svg' },
  { key: 'hiphop',  label: '힙합',       src: 'assets/icons/hiphop.svg' },
  { key: 'edm',     label: 'EDM',       src: 'assets/icons/edm.svg' },
  { key: 'kpop',    label: 'K-POP',     src: 'assets/icons/kpop.svg' },
  { key: 'lounge',  label: '라운지',     src: 'assets/icons/vybe_recommend.svg' },
];

function CategoryGrid() {
  const [active, setActive] = useState('vybe');
  return (
    <div style={{ padding: '24px 16px 8px' }}>
      <div style={{
        display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)',
        rowGap: 16, columnGap: 8,
      }}>
        {CATS.map(c => {
          const sel = active === c.key;
          return (
            <button key={c.key} onClick={() => setActive(c.key)} style={{
              all: 'unset', cursor: 'pointer',
              display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
            }}>
              <div style={{
                width: 60, height: 60, borderRadius: 14,
                background: GRAY[900],
                border: `1px solid ${sel ? LIME[500] : 'transparent'}`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                boxShadow: sel ? `0 0 0 2px rgba(181,255,96,0.18)` : 'none',
                transition: 'all .15s',
              }}>
                <img src={c.src} alt={c.label} width={36} height={36} style={{
                  filter: sel ? 'brightness(1.2)' : 'none',
                }} />
              </div>
              <span style={{
                ...TYPO.caption, lineHeight: '14px',
                color: sel ? LIME[500] : GRAY[200],
                fontWeight: 600,
              }}>{c.label}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

// ============ SECTION HEADER ============
function SectionHeader({ title, onMore }) {
  return (
    <div style={{
      padding: '0 24px 16px',
      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
    }}>
      <h3 style={{ ...TYPO.h4, color: '#fff', margin: 0 }}>{title}</h3>
      <button onClick={onMore} style={{
        all: 'unset', cursor: 'pointer',
        display: 'flex', alignItems: 'center', gap: 4,
      }}>
        <span style={{ ...TYPO.caption, color: GRAY[400], lineHeight: '14px' }}>전체보기</span>
        <I.ChevRight />
      </button>
    </div>
  );
}

// ============ CLUB CARDS (horizontal scroll) ============
const CLUBS = [
  { name: '홍대 클럽 레이저', area: '홍대', genre: '힙합', rating: 4.6, bg: 'linear-gradient(135deg, #ff006e, #8338ec)' },
  { name: '버뮤다',         area: '홍대', genre: '힙합', rating: 4.3, bg: 'linear-gradient(135deg, #06ffa5, #3a86ff)' },
  { name: '인클',           area: '홍대', genre: '힙합', rating: 4.7, bg: 'linear-gradient(135deg, #fb5607, #ffbe0b)' },
  { name: '어썸 레드',       area: '홍대', genre: '힙합', rating: 4.8, bg: 'linear-gradient(135deg, #7731FE, #ff4d8d)', href: 'club_detail.html' },
  { name: '벨로주',         area: '홍대', genre: '재즈', rating: 4.5, bg: 'linear-gradient(135deg, #2a2d34, #6c757d)' },
];

function ClubScroller() {
  return (
    <div style={{
      display: 'flex', gap: 12, padding: '0 24px',
      overflowX: 'auto', scrollbarWidth: 'none',
    }}>
      {CLUBS.map(c => (
        <a key={c.name} href={c.href || '#'} onClick={e => !c.href && e.preventDefault()} style={{
          width: 112, flexShrink: 0,
          display: 'flex', flexDirection: 'column', gap: 8,
          textDecoration: 'none',
        }}>
          <div style={{
            width: 112, height: 112, borderRadius: 8,
            background: c.bg, border: `1px solid ${GRAY[900]}`,
            position: 'relative', overflow: 'hidden',
          }}>
            <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(circle at 40% 40%, rgba(255,255,255,0.18), transparent 60%)' }} />
            <div style={{
              position: 'absolute', top: 6, left: 6,
              padding: '2px 6px', borderRadius: 99,
              background: 'rgba(0,0,0,0.55)', backdropFilter: 'blur(6px)',
              display: 'flex', alignItems: 'center', gap: 3,
            }}>
              <I.Star size={10} />
              <span style={{ ...TYPO.caption, color: '#fff', lineHeight: '12px', fontWeight: 600 }}>{c.rating}</span>
            </div>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
            <span style={{ ...TYPO.body4, color: '#fff', fontWeight: 500 }}>{c.name}</span>
            <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
              <span style={{ ...TYPO.caption, color: GRAY[500], lineHeight: '14px' }}>{c.area}</span>
              <span style={{ width: 2, height: 2, background: GRAY[600], borderRadius: 99 }} />
              <span style={{ ...TYPO.caption, color: GRAY[500], lineHeight: '14px' }}>{c.genre}</span>
            </div>
          </div>
        </a>
      ))}
    </div>
  );
}

// ============ BOTTOM TAB BAR ============
function TabBar() {
  const [active, setActive] = useState('home');
  const tabs = [
    { key: 'home',   label: '홈',     Icon: I.Home },
    { key: 'near',   label: '주변',   Icon: I.Around },
    { key: 'wallet', label: '패스월렛', Icon: I.Wallet },
    { key: 'search', label: '검색',   Icon: I.Search },
    { key: 'me',     label: '내 정보', Icon: I.Me },
  ];
  return (
    <div style={{
      borderTop: `1px solid ${GRAY[900]}`,
      background: COLORS.bg,
      padding: '12px 24px 8px',
      display: 'flex', justifyContent: 'space-between',
      flexShrink: 0,
    }}>
      {tabs.map(t => {
        const sel = t.key === active;
        const Icon = t.Icon;
        return (
          <button key={t.key} onClick={() => setActive(t.key)} style={{
            all: 'unset', cursor: 'pointer',
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
            minWidth: 40, position: 'relative',
          }}>
            <div style={{
              width: 4, height: 4, borderRadius: 99,
              background: sel ? LIME[500] : 'transparent',
              marginBottom: 2,
            }} />
            <Icon active={sel} />
            <span style={{
              ...TYPO.caption, lineHeight: '14px',
              color: sel ? LIME[500] : '#fff',
              fontWeight: sel ? 600 : 400,
            }}>{t.label}</span>
          </button>
        );
      })}
    </div>
  );
}

// ============ TONIGHT EVENTS ============
const EVENTS = [
  { time: '22:00', club: '어썬 레드', title: 'FRIDAY HIPHOP NIGHT', dj: 'DJ KOLA, DJ TOFU', tag: 'LIVE', bg: 'linear-gradient(135deg, #7731FE 0%, #ff4d8d 100%)', href: 'club_detail.html' },
  { time: '23:00', club: '클럽 레이저', title: 'NEON DREAMS · EDM SET', dj: 'DJ ARC, GUEST MILA', tag: 'TONIGHT', bg: 'linear-gradient(135deg, #2B6BFF 0%, #B5FF60 130%)' },
  { time: '00:00', club: '버뮤다', title: 'AFTER HOURS LOUNGE', dj: 'DJ HYPE', tag: 'LATE', bg: 'linear-gradient(135deg, #0f0f23 0%, #4a2580 50%, #7731FE 100%)' },
];

function TonightEvents() {
  return (
    <div style={{ padding: '24px 0 8px' }}>
      <SectionHeader title="오늘 밤 이런 일이" />
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10, padding: '0 24px' }}>
        {EVENTS.map(e => (
          <a key={e.title} href={e.href || '#'} onClick={ev => !e.href && ev.preventDefault()} style={{
            display: 'flex', alignItems: 'stretch', gap: 14,
            background: GRAY[900], borderRadius: 14,
            padding: 12, textDecoration: 'none',
            border: `1px solid ${GRAY[800]}`,
          }}>
            <div style={{
              width: 64, flexShrink: 0, borderRadius: 10,
              background: e.bg, position: 'relative', overflow: 'hidden',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(circle at 30% 30%, rgba(255,255,255,0.25), transparent 60%)' }} />
              <div style={{
                position: 'relative',
                fontFamily: 'Pretendard', color: '#fff',
                fontSize: 18, fontWeight: 700, letterSpacing: '-0.02em',
              }}>{e.time}</div>
            </div>
            <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', gap: 4, minWidth: 0 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                <span style={{
                  ...TYPO.caption, lineHeight: '14px',
                  padding: '2px 6px', borderRadius: 4,
                  background: e.tag === 'LIVE' ? LIME[500] : e.tag === 'LATE' ? PURPLE.disabled : PURPLE[500],
                  color: e.tag === 'LIVE' ? COLORS.bg : '#fff',
                  fontWeight: 700, letterSpacing: '0.04em',
                }}>{e.tag}</span>
                <span style={{ ...TYPO.caption, color: GRAY[400], lineHeight: '14px' }}>{e.club}</span>
              </div>
              <span style={{
                ...TYPO.body4, fontWeight: 600, color: '#fff',
                whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis',
              }}>{e.title}</span>
              <span style={{ ...TYPO.caption, color: GRAY[500], lineHeight: '14px' }}>{e.dj}</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center' }}>
              <I.ChevRight />
            </div>
          </a>
        ))}
      </div>
    </div>
  );
}

// ============ ROOT ============
function App() {
  const scrollRef = useRef(null);
  const [scrolled, setScrolled] = useState(false);

  const onScroll = () => {
    const t = scrollRef.current?.scrollTop || 0;
    setScrolled(t > 24);
  };

  return (
    <div style={{
      width: '100%', height: '100%', background: C.bg,
      color: C.text, fontFamily: "'Pretendard', sans-serif",
      display: 'flex', flexDirection: 'column',
      overflow: 'hidden',
    }}>
      <div ref={scrollRef} onScroll={onScroll} style={{ flex: 1, overflowY: 'auto', scrollbarWidth: 'none', position: 'relative' }}>
        <TopBar scrolled={scrolled} />
        <Greeting />
        <LocationRow />
        <Hero />
        <ThickDivider />
        <CategoryGrid />
        <ThickDivider />
        <TonightEvents />
        <ThickDivider />
        <div style={{ padding: '24px 0 8px' }}>
          <SectionHeader title="주변 클럽" />
          <ClubScroller />
        </div>
        <div style={{ height: 32 }} />
      </div>
      <TabBar />
    </div>
  );
}

// ============ MOUNT ============
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <IOSDevice dark={true} width={393} height={852}>
    <App />
  </IOSDevice>
);
