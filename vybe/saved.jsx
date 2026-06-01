/* global React, ReactDOM, IOSDevice, COLORS, TYPO, GRAY, PURPLE, LIME */
const { useState } = React;

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
  Back: ({ size = 24 }) => (<svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
    <polyline points="15 18 9 12 15 6" />
  </svg>),
  Heart: ({ size = 20, active = true }) => (<svg width={size} height={size} viewBox="0 0 24 24" fill={active ? PURPLE[500] : 'none'} stroke={active ? PURPLE[500] : '#fff'} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
  </svg>),
  Star: ({ size = 12 }) => (<svg width={size} height={size} viewBox="0 0 24 24" fill={LIME[500]} stroke={LIME[500]} strokeWidth="1" strokeLinecap="round" strokeLinejoin="round">
    <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
  </svg>),
  Pin: ({ size = 12, color = GRAY[500] }) => (<svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" /><circle cx="12" cy="10" r="3" />
  </svg>),
  Clock: ({ size = 12, color = GRAY[500] }) => (<svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <circle cx="12" cy="12" r="10" /><polyline points="12 6 12 12 16 14" />
  </svg>),
  Chevron: ({ size = 12, color = GRAY[400] }) => (<svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round">
    <polyline points="6 9 12 15 18 9" />
  </svg>),
  Grid: ({ size = 18, color = '#fff' }) => (<svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <rect x="3" y="3" width="7" height="7" /><rect x="14" y="3" width="7" height="7" />
    <rect x="3" y="14" width="7" height="7" /><rect x="14" y="14" width="7" height="7" />
  </svg>),
  List: ({ size = 18, color = '#fff' }) => (<svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <line x1="8" y1="6" x2="21" y2="6" /><line x1="8" y1="12" x2="21" y2="12" /><line x1="8" y1="18" x2="21" y2="18" />
    <line x1="3" y1="6" x2="3.01" y2="6" /><line x1="3" y1="12" x2="3.01" y2="12" /><line x1="3" y1="18" x2="3.01" y2="18" />
  </svg>),
  Edit: ({ size = 18, color = GRAY[300] }) => (<svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z" />
  </svg>),
  Plus: ({ size = 14, color = '#fff' }) => (<svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round">
    <line x1="12" y1="5" x2="12" y2="19" /><line x1="5" y1="12" x2="19" y2="12" />
  </svg>),
  Empty: ({ size = 80 }) => (<svg width={size} height={size} viewBox="0 0 80 80" fill="none">
    <circle cx="40" cy="40" r="38" stroke={GRAY[800]} strokeWidth="1.5" strokeDasharray="3 4" />
    <path d="M55 33a8 8 0 0 0-11 0l-4 4-4-4a8 8 0 0 0-11.3 11.3L40 56l15.3-11.3A8 8 0 0 0 55 33z" stroke={GRAY[700]} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" fill={GRAY[900]} />
  </svg>),
};

// ============ DATA ============
// 폴더(컬렉션) 시스템 — 사용자가 찜을 분류해서 모을 수 있도록
const FOLDERS = [
  { key: 'all',      label: '전체',       count: 12 },
  { key: 'go',       label: '갈 곳',       count: 5, emoji: '✨' },
  { key: 'weekend',  label: '주말 후보',    count: 4, emoji: '🎉' },
  { key: 'date',     label: '데이트',      count: 2, emoji: '💜' },
  { key: 'gangnam',  label: '강남',        count: 1, emoji: '📍' },
];

const SAVED_CLUBS = [
  {
    id: 1, name: '어썸레드',        area: '홍대', genre: '힙합 클럽',
    rating: 4.76, savedAt: '오늘 저장', open: true, hours: '02:00에 영업 종료',
    photo: 'linear-gradient(135deg, #7731FE, #ff4d8d)',
    folder: 'go', tag: 'VYBE 추천', href: 'club_detail.html',
  },
  {
    id: 2, name: '홍대 클럽 레이저', area: '홍대', genre: '힙합 클럽',
    rating: 4.5, savedAt: '어제 저장', open: true, hours: '03:00에 영업 종료',
    photo: 'linear-gradient(135deg, #ff006e, #8338ec)',
    folder: 'go',
  },
  {
    id: 3, name: '버뮤다',          area: '홍대', genre: '힙합 클럽',
    rating: 4.3, savedAt: '3일 전 저장', open: true, hours: '02:00에 영업 종료',
    photo: 'linear-gradient(135deg, #06ffa5, #3a86ff)',
    folder: 'weekend',
  },
  {
    id: 4, name: '인클',            area: '홍대', genre: '힙합 클럽',
    rating: 4.7, savedAt: '1주 전 저장', open: true, hours: '04:00에 영업 종료',
    photo: 'linear-gradient(135deg, #fb5607, #ffbe0b)',
    folder: 'weekend',
  },
  {
    id: 5, name: '벨로주',          area: '홍대', genre: '재즈 클럽',
    rating: 4.5, savedAt: '1주 전 저장', open: true, hours: '01:30에 영업 종료',
    photo: 'linear-gradient(135deg, #2a2d34, #6c757d)',
    folder: 'date',
  },
  {
    id: 6, name: 'OCTAGON',         area: '강남', genre: 'EDM 클럽',
    rating: 4.8, savedAt: '2주 전 저장', open: false, hours: '내일 22:00 오픈',
    photo: 'linear-gradient(135deg, #2B6BFF, #7731FE)',
    folder: 'gangnam', tag: 'HOT',
  },
];

// ============ HEADER ============
function Header({ count }) {
  return (
    <div style={{
      position: 'sticky', top: 0, zIndex: 10,
      background: COLORS.bg,
      borderBottom: `1px solid ${GRAY[900]}`,
    }}>
      <div style={{
        height: 44, padding: '0 16px',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      }}>
        <button onClick={() => history.length > 1 ? history.back() : (window.location.href = 'home.html')} style={{
          all: 'unset', cursor: 'pointer',
          width: 32, height: 32, display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <I.Back />
        </button>
        <h1 style={{ ...TYPO.body3, color: '#fff', fontWeight: 600, margin: 0 }}>
          찜한 클럽
        </h1>
        <button style={{
          all: 'unset', cursor: 'pointer',
          width: 32, height: 32, display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <I.Edit />
        </button>
      </div>
    </div>
  );
}

// ============ STATS BAR ============
function StatsBar({ count, openCount }) {
  return (
    <div style={{
      padding: '20px 20px 12px',
      display: 'flex', alignItems: 'baseline', justifyContent: 'space-between',
    }}>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
        <span style={{ ...TYPO.h2, color: '#fff', fontWeight: 700 }}>{count}</span>
        <span style={{ ...TYPO.body3, color: GRAY[400] }}>곳을 찜했어요</span>
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
        <span style={{ width: 6, height: 6, borderRadius: 99, background: LIME[500], boxShadow: '0 0 6px rgba(181,255,96,0.6)' }} />
        <span style={{ ...TYPO.caption, color: GRAY[300], lineHeight: '14px', fontWeight: 600 }}>
          지금 {openCount}곳 영업중
        </span>
      </div>
    </div>
  );
}

// ============ FOLDER TABS (collection chips) ============
function FolderTabs({ active, onChange }) {
  return (
    <div style={{
      padding: '8px 16px 16px',
      display: 'flex', gap: 6, overflowX: 'auto', scrollbarWidth: 'none',
    }}>
      {FOLDERS.map(f => {
        const sel = f.key === active;
        return (
          <button key={f.key} onClick={() => onChange(f.key)} style={{
            all: 'unset', cursor: 'pointer', flexShrink: 0,
            padding: '8px 14px', borderRadius: 999,
            background: sel ? PURPLE[700] : GRAY[900],
            border: sel ? 'none' : `1px solid ${GRAY[800]}`,
            display: 'flex', alignItems: 'center', gap: 6,
            ...TYPO.button2, fontWeight: sel ? 600 : 500,
            color: sel ? '#fff' : GRAY[300],
            transition: 'all .2s',
          }}>
            {f.emoji && <span style={{ fontSize: 13 }}>{f.emoji}</span>}
            <span>{f.label}</span>
            <span style={{
              ...TYPO.caption, lineHeight: '14px',
              color: sel ? 'rgba(255,255,255,0.7)' : GRAY[500],
              fontWeight: 500,
            }}>{f.count}</span>
          </button>
        );
      })}
      <button style={{
        all: 'unset', cursor: 'pointer', flexShrink: 0,
        width: 36, height: 36, borderRadius: '50%',
        background: GRAY[900], border: `1px solid ${GRAY[800]}`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <I.Plus color={GRAY[400]} />
      </button>
    </div>
  );
}

// ============ VIEW SWITCHER + SORT ============
function ToolBar({ view, onView, sort, onSort }) {
  return (
    <div style={{
      padding: '0 20px 16px',
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
    }}>
      <button style={{
        all: 'unset', cursor: 'pointer',
        display: 'flex', alignItems: 'center', gap: 2,
        ...TYPO.caption, color: GRAY[300], lineHeight: '14px', fontWeight: 500,
      }}>
        {sort === 'recent' ? '최근 찜한 순' : sort === 'rating' ? '평점 높은 순' : '가까운 순'}
        <I.Chevron size={12} color={GRAY[300]} />
      </button>

      <div style={{
        display: 'flex', background: GRAY[900],
        borderRadius: 8, padding: 3, gap: 2,
      }}>
        <button onClick={() => onView('list')} style={{
          all: 'unset', cursor: 'pointer',
          width: 30, height: 26, borderRadius: 6,
          background: view === 'list' ? GRAY[700] : 'transparent',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <I.List size={14} color={view === 'list' ? '#fff' : GRAY[500]} />
        </button>
        <button onClick={() => onView('grid')} style={{
          all: 'unset', cursor: 'pointer',
          width: 30, height: 26, borderRadius: 6,
          background: view === 'grid' ? GRAY[700] : 'transparent',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <I.Grid size={14} color={view === 'grid' ? '#fff' : GRAY[500]} />
        </button>
      </div>
    </div>
  );
}

// ============ LIST CARD ============
function ListCard({ club, onUnsave }) {
  return (
    <a href={club.href || '#'} onClick={e => !club.href && e.preventDefault()} style={{
      display: 'flex', gap: 14, padding: '14px 20px',
      textDecoration: 'none',
      borderBottom: `1px solid ${GRAY[900]}`,
    }}>
      <div style={{
        width: 96, height: 96, borderRadius: 10, flexShrink: 0,
        background: club.photo, position: 'relative', overflow: 'hidden',
        border: `1px solid ${GRAY[900]}`,
      }}>
        <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(circle at 30% 30%, rgba(255,255,255,0.22), transparent 60%)' }} />
        {club.tag && (
          <div style={{
            position: 'absolute', top: 6, left: 6,
            padding: '2px 6px', borderRadius: 4,
            background: club.tag === 'HOT' ? '#FF3B6E' : 'rgba(0,0,0,0.7)',
            backdropFilter: 'blur(6px)',
            display: 'flex', alignItems: 'center', gap: 3,
            ...TYPO.caption, color: club.tag === 'HOT' ? '#fff' : LIME[500],
            lineHeight: '12px', fontWeight: 700,
          }}>
            {club.tag !== 'HOT' && <I.Star size={9} />}
            {club.tag}
          </div>
        )}
      </div>

      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 6, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 8 }}>
          <span style={{
            ...TYPO.body3, color: '#fff', fontWeight: 600,
            whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', flex: 1,
          }}>{club.name}</span>
          <button onClick={e => { e.preventDefault(); onUnsave(club.id); }} style={{
            all: 'unset', cursor: 'pointer', padding: 4, marginTop: -4, flexShrink: 0,
          }}>
            <I.Heart size={20} active />
          </button>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <I.Star size={12} />
          <span style={{ ...TYPO.caption, color: '#fff', lineHeight: '14px', fontWeight: 600 }}>{club.rating.toFixed(2)}</span>
          <span style={{ width: 1, height: 10, background: GRAY[700] }} />
          <span style={{ ...TYPO.caption, color: GRAY[500], lineHeight: '14px' }}>{club.area}</span>
          <span style={{ width: 2, height: 2, background: GRAY[600], borderRadius: 99 }} />
          <span style={{ ...TYPO.caption, color: GRAY[500], lineHeight: '14px' }}>{club.genre}</span>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <I.Clock size={12} color={club.open ? LIME[500] : GRAY[600]} />
          <span style={{
            ...TYPO.caption, lineHeight: '14px', fontWeight: 600,
            color: club.open ? LIME[500] : GRAY[500],
          }}>{club.open ? '영업중' : '영업종료'}</span>
          <span style={{ width: 2, height: 2, background: GRAY[600], borderRadius: 99 }} />
          <span style={{ ...TYPO.caption, color: GRAY[400], lineHeight: '14px' }}>{club.hours}</span>
        </div>

        <span style={{ ...TYPO.caption, color: GRAY[600], lineHeight: '14px', marginTop: 2 }}>
          {club.savedAt}
        </span>
      </div>
    </a>
  );
}

// ============ GRID CARD ============
function GridCard({ club, onUnsave }) {
  return (
    <a href={club.href || '#'} onClick={e => !club.href && e.preventDefault()} style={{
      display: 'flex', flexDirection: 'column', gap: 8,
      textDecoration: 'none',
    }}>
      <div style={{
        width: '100%', aspectRatio: '1 / 1', borderRadius: 12,
        background: club.photo, position: 'relative', overflow: 'hidden',
        border: `1px solid ${GRAY[900]}`,
      }}>
        <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(circle at 30% 30%, rgba(255,255,255,0.22), transparent 60%)' }} />

        {club.tag && (
          <div style={{
            position: 'absolute', top: 8, left: 8,
            padding: '2px 7px', borderRadius: 4,
            background: club.tag === 'HOT' ? '#FF3B6E' : 'rgba(0,0,0,0.7)',
            backdropFilter: 'blur(6px)',
            display: 'flex', alignItems: 'center', gap: 3,
            ...TYPO.caption, color: club.tag === 'HOT' ? '#fff' : LIME[500],
            lineHeight: '12px', fontWeight: 700,
          }}>
            {club.tag !== 'HOT' && <I.Star size={9} />}
            {club.tag}
          </div>
        )}

        <button onClick={e => { e.preventDefault(); onUnsave(club.id); }} style={{
          all: 'unset', cursor: 'pointer',
          position: 'absolute', top: 6, right: 6,
          width: 32, height: 32, borderRadius: '50%',
          background: 'rgba(0,0,0,0.5)', backdropFilter: 'blur(6px)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <I.Heart size={16} active />
        </button>

        {/* bottom rating overlay */}
        <div style={{
          position: 'absolute', left: 8, bottom: 8,
          padding: '3px 8px', borderRadius: 999,
          background: 'rgba(0,0,0,0.65)', backdropFilter: 'blur(8px)',
          display: 'flex', alignItems: 'center', gap: 3,
        }}>
          <I.Star size={10} />
          <span style={{ ...TYPO.caption, color: '#fff', lineHeight: '12px', fontWeight: 700 }}>{club.rating.toFixed(2)}</span>
        </div>

        {!club.open && (
          <div style={{
            position: 'absolute', inset: 0,
            background: 'rgba(16,16,19,0.5)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            ...TYPO.caption, color: '#fff', lineHeight: '14px', fontWeight: 600,
          }}>
            영업 종료
          </div>
        )}
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
        <span style={{
          ...TYPO.body4, color: '#fff', fontWeight: 600,
          whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis',
        }}>{club.name}</span>
        <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
          <span style={{ ...TYPO.caption, color: GRAY[500], lineHeight: '14px' }}>{club.area}</span>
          <span style={{ width: 2, height: 2, background: GRAY[600], borderRadius: 99 }} />
          <span style={{ ...TYPO.caption, color: GRAY[500], lineHeight: '14px' }}>{club.genre}</span>
        </div>
      </div>
    </a>
  );
}

// ============ EMPTY STATE ============
function Empty() {
  return (
    <div style={{
      padding: '80px 24px',
      display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 20,
    }}>
      <I.Empty />
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6 }}>
        <span style={{ ...TYPO.h4, color: '#fff', fontWeight: 600 }}>아직 찜한 클럽이 없어요</span>
        <span style={{ ...TYPO.body4, color: GRAY[500], textAlign: 'center', lineHeight: '20px' }}>
          마음에 드는 클럽의 하트를 눌러서<br />나만의 리스트를 만들어보세요
        </span>
      </div>
      <a href="home.html" style={{
        textDecoration: 'none',
        padding: '12px 22px', borderRadius: 999,
        background: PURPLE[500], color: '#fff',
        ...TYPO.button1, fontWeight: 600,
        display: 'inline-flex', alignItems: 'center', gap: 6,
      }}>
        클럽 둘러보기
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round">
          <polyline points="9 18 15 12 9 6" />
        </svg>
      </a>
    </div>
  );
}

// ============ ROOT ============
function App() {
  const [folder, setFolder] = useState('all');
  const [view, setView] = useState('list');
  const [sort, setSort] = useState('recent');
  const [saved, setSaved] = useState(SAVED_CLUBS);

  const filtered = folder === 'all' ? saved : saved.filter(c => c.folder === folder);
  const openCount = saved.filter(c => c.open).length;

  const unsave = (id) => setSaved(s => s.filter(c => c.id !== id));

  return (
    <div style={{
      width: '100%', height: '100%', background: C.bg,
      color: '#fff', fontFamily: "'Pretendard', sans-serif",
      display: 'flex', flexDirection: 'column', overflow: 'hidden',
    }}>
      <Header count={saved.length} />

      <div style={{ flex: 1, overflowY: 'auto', scrollbarWidth: 'none' }}>
        {saved.length === 0 ? (
          <Empty />
        ) : (
          <>
            <StatsBar count={saved.length} openCount={openCount} />
            <FolderTabs active={folder} onChange={setFolder} />
            <ToolBar view={view} onView={setView} sort={sort} onSort={setSort} />

            {filtered.length === 0 ? (
              <div style={{
                padding: '60px 24px', textAlign: 'center',
                display: 'flex', flexDirection: 'column', gap: 6, alignItems: 'center',
              }}>
                <span style={{ fontSize: 28 }}>📂</span>
                <span style={{ ...TYPO.body3, color: GRAY[300], fontWeight: 600 }}>
                  이 폴더에는 아직 찜이 없어요
                </span>
                <span style={{ ...TYPO.caption, color: GRAY[500], lineHeight: '16px' }}>
                  찜한 클럽을 이 폴더로 옮겨보세요
                </span>
              </div>
            ) : view === 'list' ? (
              <div style={{ display: 'flex', flexDirection: 'column' }}>
                {filtered.map(c => <ListCard key={c.id} club={c} onUnsave={unsave} />)}
              </div>
            ) : (
              <div style={{
                padding: '0 20px 24px',
                display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14,
              }}>
                {filtered.map(c => <GridCard key={c.id} club={c} onUnsave={unsave} />)}
              </div>
            )}
            <div style={{ height: 32 }} />
          </>
        )}
      </div>
    </div>
  );
}

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <IOSDevice dark={true} width={393} height={852}>
    <App />
  </IOSDevice>
);
