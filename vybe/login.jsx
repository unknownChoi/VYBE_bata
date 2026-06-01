/* global React, ReactDOM, IOSDevice, COLORS, TYPO, GRAY, PURPLE, LIME */
const { useState, useEffect } = React;

// Local shortcuts (reads from tokens.jsx)
const C = {
  bg: COLORS.bg,
  text: COLORS.white,
  text3: GRAY[400],
  text4: GRAY[500],
  text5: GRAY[600],
  purple: PURPLE[500],
  lime: LIME[500],
};

// ============ ICONS ============
const KakaoIcon = ({ size = 18 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="#191919">
    <path d="M12 3C6.48 3 2 6.48 2 10.8c0 2.76 1.8 5.16 4.5 6.55l-1.15 4.2c-.1.38.32.68.65.47L11 19.18c.33.02.66.04 1 .04 5.52 0 10-3.48 10-7.8S17.52 3 12 3z" />
  </svg>
);

const NaverIcon = ({ size = 14 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="#fff">
    <path d="M14.5 3v9.2L9.5 3H3v18h6.5v-9.2L14.5 21H21V3h-6.5z" />
  </svg>
);

const AppleIcon = ({ size = 18 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="#101013">
    <path d="M17.05 12.04c-.03-2.74 2.24-4.06 2.34-4.13-1.27-1.86-3.26-2.12-3.97-2.15-1.69-.17-3.3 1-4.16 1-.87 0-2.19-.97-3.6-.95-1.85.03-3.56 1.07-4.51 2.72-1.93 3.34-.49 8.27 1.39 10.97.92 1.32 2.01 2.81 3.43 2.76 1.38-.06 1.9-.89 3.57-.89s2.14.89 3.6.86c1.49-.03 2.43-1.35 3.34-2.68 1.05-1.54 1.49-3.03 1.51-3.11-.03-.01-2.89-1.11-2.92-4.4zM14.4 4.04c.76-.93 1.27-2.21 1.13-3.49-1.09.04-2.42.73-3.21 1.65-.7.82-1.32 2.13-1.16 3.39 1.22.1 2.47-.62 3.24-1.55z" />
  </svg>
);

// ============ EQ BARS (subtle motion) ============
function EQBars() {
  const bars = [0.6, 0.9, 0.4, 0.8, 0.5, 0.95, 0.7, 0.55, 0.85, 0.45, 0.7, 0.6];
  return (
    <div style={{
      display: 'flex', alignItems: 'flex-end', gap: 3, height: 22,
      opacity: 0.6,
    }}>
      {bars.map((h, i) => (
        <div key={i} style={{
          width: 2, height: '100%', borderRadius: 99,
          background: i % 3 === 0 ? C.lime : C.purple,
          animation: `eqBounce ${0.8 + (i % 4) * 0.15}s ease-in-out infinite alternate`,
          animationDelay: `${i * 0.07}s`,
          transformOrigin: 'bottom',
          transform: `scaleY(${h})`,
        }} />
      ))}
    </div>
  );
}

// ============ HERO VISUAL ============
function HeroVisual() {
  return (
    <div style={{
      position: 'absolute', inset: 0, pointerEvents: 'none', overflow: 'hidden',
    }}>
      {/* purple bloom top-left */}
      <div style={{
        position: 'absolute', top: -80, left: -100,
        width: 360, height: 360, borderRadius: '50%',
        background: 'radial-gradient(circle, rgba(119,49,254,0.55), transparent 65%)',
        filter: 'blur(20px)',
        animation: 'breath1 8s ease-in-out infinite',
      }} />
      {/* lime bloom mid-right */}
      <div style={{
        position: 'absolute', top: 180, right: -120,
        width: 320, height: 320, borderRadius: '50%',
        background: 'radial-gradient(circle, rgba(181,255,96,0.32), transparent 65%)',
        filter: 'blur(20px)',
        animation: 'breath2 10s ease-in-out infinite',
      }} />
      {/* pink/magenta bloom bottom */}
      <div style={{
        position: 'absolute', bottom: 200, left: 40,
        width: 260, height: 260, borderRadius: '50%',
        background: 'radial-gradient(circle, rgba(255,77,141,0.28), transparent 65%)',
        filter: 'blur(20px)',
        animation: 'breath1 12s ease-in-out infinite',
      }} />
      {/* grain noise */}
      <div style={{
        position: 'absolute', inset: 0,
        backgroundImage: 'radial-gradient(rgba(255,255,255,0.04) 1px, transparent 1px)',
        backgroundSize: '3px 3px',
        opacity: 0.5,
      }} />
    </div>
  );
}

// ============ LOGO ============
function VybeLogo({ size = 26 }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 8,
      fontSize: size, fontWeight: 800, letterSpacing: '-0.04em',
      fontFamily: 'Pretendard',
      color: '#fff',
    }}>
      <div style={{
        width: size, height: size, borderRadius: size * 0.3,
        background: `linear-gradient(135deg, ${C.purple}, ${C.lime})`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontSize: size * 0.62, fontWeight: 900, color: '#000',
      }}>v</div>
      vybe
    </div>
  );
}

// ============ LOGIN BUTTON ============
function LoginBtn({ icon, label, bg, fg, accent }) {
  const [hover, setHover] = useState(false);
  return (
    <button
      onMouseDown={() => setHover(true)}
      onMouseUp={() => setHover(false)}
      onMouseLeave={() => setHover(false)}
      style={{
        width: '100%', height: 54,
        background: bg, color: fg,
        border: 'none', borderRadius: 999,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        position: 'relative', cursor: 'pointer',
        ...TYPO.button1, fontFamily: 'Pretendard',
        transform: hover ? 'scale(0.98)' : 'scale(1)',
        transition: 'transform .15s ease',
        boxShadow: accent ? `0 6px 24px ${accent}` : 'none',
      }}
    >
      <span style={{ position: 'absolute', left: 22, display: 'flex' }}>{icon}</span>
      {label}
    </button>
  );
}

// ============ INLINE VYBE WORDMARK ============
function VybeMark() {
  return (
    <span style={{
      fontWeight: 800, letterSpacing: '0.01em',
      fontFamily: 'Pretendard',
    }}>
      <span style={{ color: '#fff' }}>V</span>
      <span style={{ color: C.lime }}>Y</span>
      <span style={{ color: '#fff' }}>B</span>
      <span style={{ color: C.purple }}>E</span>
    </span>
  );
}

// ============ ID VERIFY SHEET ============
function IDIcon() {
  return (
    <div style={{
      width: 72, height: 72, borderRadius: '50%', position: 'relative',
      background: 'radial-gradient(circle at 50% 35%, rgba(181,255,96,0.22), rgba(119,49,254,0.18) 70%)',
      border: `1.5px solid ${LIME[500]}`,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      boxShadow: `0 0 24px rgba(181,255,96,0.18), inset 0 0 18px rgba(119,49,254,0.15)`,
    }}>
      {/* sparkles around */}
      <span style={{ position: 'absolute', top: 6, right: 10, width: 3, height: 3, borderRadius: 99, background: LIME[500] }} />
      <span style={{ position: 'absolute', bottom: 12, left: 8, width: 2.5, height: 2.5, borderRadius: 99, background: PURPLE[500] }} />
      <span style={{ position: 'absolute', top: 18, left: 5, width: 2, height: 2, borderRadius: 99, background: LIME[500], opacity: 0.7 }} />

      {/* big 19+ */}
      <div style={{
        display: 'flex', alignItems: 'baseline', gap: 1,
        fontFamily: 'Pretendard',
        color: COLORS.white,
        lineHeight: 1,
      }}>
        <span style={{
          fontSize: 32, fontWeight: 800, letterSpacing: '-0.04em',
          background: `linear-gradient(180deg, ${LIME[500]} 0%, ${LIME[700]} 100%)`,
          WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
          backgroundClip: 'text',
        }}>19</span>
        <span style={{
          fontSize: 20, fontWeight: 800, color: LIME[500],
          marginLeft: 1,
        }}>+</span>
      </div>
    </div>
  );
}

function VerifySheet({ open, onClose }) {
  return (
    <>
      {/* backdrop */}
      <div
        onClick={onClose}
        style={{
          position: 'absolute', inset: 0, zIndex: 10,
          background: open ? 'rgba(0,0,0,0.55)' : 'transparent',
          backdropFilter: open ? 'blur(4px)' : 'none',
          opacity: open ? 1 : 0,
          pointerEvents: open ? 'auto' : 'none',
          transition: 'opacity .25s ease, backdrop-filter .25s ease',
        }}
      />
      {/* sheet */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 11,
        background: '#1C1C20',
        borderTopLeftRadius: 24, borderTopRightRadius: 24,
        padding: '12px 24px 40px',
        transform: open ? 'translateY(0)' : 'translateY(100%)',
        transition: 'transform .35s cubic-bezier(0.32, 0.72, 0, 1)',
        display: 'flex', flexDirection: 'column', gap: 32, alignItems: 'center',
        boxShadow: '0 -8px 32px rgba(0,0,0,0.5)',
      }}>
        {/* drag handle */}
        <div style={{
          width: 36, height: 4, borderRadius: 99,
          background: 'rgba(255,255,255,0.18)',
        }} />

        {/* icon + copy */}
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 18, marginTop: 8 }}>
          <IDIcon />
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10, alignItems: 'center' }}>
            <h2 style={{
              ...TYPO.h3, color: COLORS.white, margin: 0,
            }}>본인 인증이 필요해요</h2>
            <p style={{
              ...TYPO.body4, color: GRAY[500], textAlign: 'center',
              margin: 0, lineHeight: '22px',
            }}>
              <VybeMark />는 19세 이상만 이용할 수 있어요.<br />
              안전한 이용을 위해 본인 인증을 진행해주세요.
            </p>
          </div>
        </div>

        {/* CTA */}
        <div style={{ width: '100%', display: 'flex', flexDirection: 'column', gap: 10 }}>
          <button onClick={() => { window.location.href = 'verify.html'; }} style={{
            width: '100%', height: 54, borderRadius: 999,
            background: COLORS.white, color: COLORS.bg,
            border: 'none', cursor: 'pointer',
            ...TYPO.button1, fontFamily: 'Pretendard',
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
          }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#101013" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <rect x="3" y="5" width="18" height="14" rx="2" />
              <circle cx="9" cy="12" r="2.5" />
              <line x1="14" y1="10" x2="18" y2="10" />
              <line x1="14" y1="14" x2="18" y2="14" />
            </svg>
            본인인증으로 시작하기
          </button>
          <button onClick={onClose} style={{
            all: 'unset', cursor: 'pointer',
            width: '100%', textAlign: 'center', padding: '10px 0',
            ...TYPO.button2, color: GRAY[500],
          }}>
            다음에 할게요
          </button>
        </div>
      </div>
    </>
  );
}

// ============ ROOT ============
function App() {
  const [sheetOpen, setSheetOpen] = useState(false);
  return (
    <div style={{
      width: '100%', height: '100%', background: C.bg, position: 'relative',
      color: C.text, fontFamily: "'Pretendard', sans-serif",
      display: 'flex', flexDirection: 'column',
      overflow: 'hidden',
    }}>
      <HeroVisual />

      {/* content layer */}
      <div style={{
        position: 'relative', zIndex: 1, flex: 1,
        display: 'flex', flexDirection: 'column',
        padding: '70px 24px 40px',
      }}>
        {/* spacer */}
        <div style={{ flex: 0.7 }} />

        {/* headline */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
          <img
            src="assets/vybe-logo.png"
            alt="vybe"
            style={{ height: 44, width: 'auto', alignSelf: 'flex-start' }}
          />
          <div>
            <div style={{
              ...TYPO.h2, color: COLORS.white,
            }}>
              <span style={{ color: C.lime }}>바이브</span> 탈 준비 됐어?
            </div>
            <div style={{
              ...TYPO.h1, fontSize: 42, lineHeight: '46px',
              fontWeight: 700, color: COLORS.white, marginTop: 6,
            }}>
              우린 <span style={{
                background: `linear-gradient(135deg, ${C.purple} 0%, #B377FF 100%)`,
                WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
                backgroundClip: 'text',
              }}>끝냈어!</span>
            </div>
          </div>
        </div>

        {/* spacer */}
        <div style={{ flex: 1 }} />

        {/* login buttons */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <LoginBtn
            icon={<KakaoIcon size={20} />}
            label="카카오로 시작하기"
            bg="#FEE500"
            fg="#191919"
          />
          <LoginBtn
            icon={<NaverIcon size={14} />}
            label="네이버로 시작하기"
            bg="#02C75A"
            fg="#fff"
          />
          <LoginBtn
            icon={<AppleIcon size={20} />}
            label="Apple로 시작하기"
            bg="#fff"
            fg="#101013"
          />
        </div>

        {/* divider link */}
        <div style={{ display: 'flex', justifyContent: 'center', marginTop: 18 }}>
          <button style={{
            all: 'unset', cursor: 'pointer',
            ...TYPO.body4, color: C.text3,
            padding: '6px 12px',
          }} onClick={() => setSheetOpen(true)}>
            다른 방법으로 로그인
          </button>
        </div>

        {/* legal text */}
        <p style={{
          ...TYPO.caption, color: C.text5,
          textAlign: 'center', margin: '20px 0 0', lineHeight: '18px',
        }}>
          가입 시 <span style={{ color: C.text3, textDecoration: 'underline' }}>서비스 약관</span> 및{' '}
          <span style={{ color: C.text3, textDecoration: 'underline' }}>개인정보 처리방침</span>에 동의합니다.
        </p>
      </div>

      <VerifySheet open={sheetOpen} onClose={() => setSheetOpen(false)} />
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
