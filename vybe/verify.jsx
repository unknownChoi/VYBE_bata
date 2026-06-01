/* global React, ReactDOM, IOSDevice, IOSKeyboard, COLORS, TYPO, GRAY, PURPLE, LIME */
const { useState, useRef, useEffect } = React;

const C = {
  bg: COLORS.bg,
  text: COLORS.white,
  text3: GRAY[400],
  text4: GRAY[500],
  text5: GRAY[600],
  text6: GRAY[700],
  purple: PURPLE[500],
  purpleDeep: PURPLE[700],
  purpleDisabled: PURPLE.disabled,
  lime: LIME[500],
};

// ============ STEPS ============
const STEPS = [
  {
    key: 'name',
    accent: '이름',
    tail: '을 입력해주세요.',
    caption: null,
    placeholder: '홍길동',
    max: 10,
    inputMode: 'text',
    kind: 'text',
    minLen: 2,
    label: '이름',
  },
  {
    key: 'birth',
    accent: '생년월일',
    tail: '을 입력해주세요.',
    caption: '이 서비스는 만 19세 이상만 이용 가능합니다.',
    placeholder: '생년월일 6자리',
    max: 7, // YYMMDD + 성별 1자리
    inputMode: 'numeric',
    kind: 'rrn',
    minLen: 7,
    label: '주민번호',
  },
  {
    key: 'phone',
    accent: '휴대폰번호',
    tail: '를 입력해주세요.',
    caption: '인증번호를 문자로 보내드려요.',
    placeholder: '01012345678',
    max: 11,
    inputMode: 'tel',
    kind: 'phone',
    minLen: 10,
    label: '휴대폰번호',
  },
  {
    key: 'code',
    accent: '인증번호',
    tail: '를 입력해주세요.',
    caption: '문자로 받은 6자리 숫자를 입력해주세요.',
    placeholder: '6자리 숫자',
    max: 6,
    inputMode: 'numeric',
    kind: 'code',
    minLen: 6,
    label: '인증번호',
  },
];

// ============ ICONS ============
const IconChevLeft = ({ size = 24, stroke = '#fff' }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={stroke} strokeWidth={2.2} strokeLinecap="round" strokeLinejoin="round">
    <polyline points="15 18 9 12 15 6" />
  </svg>
);
const IconInfo = ({ size = 14 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={GRAY[500]} stroke="none">
    <circle cx="12" cy="12" r="10" />
    <rect x="11" y="10" width="2" height="6" rx="1" fill="#101013" />
    <circle cx="12" cy="7.5" r="1.1" fill="#101013" />
  </svg>
);
const IconClearCircle = ({ size = 22 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={GRAY[700]} stroke="none">
    <circle cx="12" cy="12" r="10" />
    <line x1="15" y1="9" x2="9" y2="15" stroke={GRAY[300]} strokeWidth={2} strokeLinecap="round" />
    <line x1="9" y1="9" x2="15" y2="15" stroke={GRAY[300]} strokeWidth={2} strokeLinecap="round" />
  </svg>
);

// ============ NAV BAR ============
function NavBar({ onBack, title }) {
  return (
    <div style={{
      height: 44, position: 'relative', flexShrink: 0,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      <button onClick={onBack} style={{
        all: 'unset', position: 'absolute', left: 16, top: 0, bottom: 0,
        width: 32, cursor: 'pointer',
        display: 'flex', alignItems: 'center',
      }}>
        <IconChevLeft />
      </button>
      <h2 style={{
        ...TYPO.body3, fontWeight: 600, color: COLORS.white, margin: 0,
      }}>{title}</h2>
    </div>
  );
}

// ============ HEADING ============
function Heading({ step }) {
  return (
    <div style={{ padding: '32px 24px 28px', display: 'flex', flexDirection: 'column', gap: 12 }}>
      <div style={{ ...TYPO.h3, fontSize: 24, lineHeight: '30px', fontWeight: 600 }}>
        <span style={{ color: C.lime }}>{step.accent}</span>
        <span style={{ color: COLORS.white }}>{step.tail}</span>
      </div>
      {step.caption && (
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <IconInfo />
          <span style={{ ...TYPO.caption, color: GRAY[500], lineHeight: '14px' }}>
            {step.caption}
          </span>
        </div>
      )}
    </div>
  );
}

// ============ INPUT DISPLAY ============
// Renders the visual representation of typed digits + dots for masked formats.
function MaskedDisplay({ value, kind, placeholder }) {
  // RRN: 7 typed digits (6 birth + 1 gender) + dash + 6 hidden dots
  // Phone: 11 digits with 010-XXXX-XXXX format
  // Code: 6 dots
  if (kind === 'rrn') {
    const before = value.slice(0, 6);
    const after = value.slice(6, 7);
    const dotsAfter = Math.max(0, 6 - after.length);

    return (
      <div style={{
        display: 'flex', alignItems: 'center', gap: 8,
        ...TYPO.h3, fontSize: 24, lineHeight: '26px', fontWeight: 500,
        color: COLORS.white, minHeight: 26,
      }}>
        {value.length === 0 ? (
          <span style={{ color: GRAY[600] }}>{placeholder}</span>
        ) : (
          <span style={{ letterSpacing: '4px' }}>
            {before.split('').join(' ')}
          </span>
        )}
        <span style={{ color: GRAY[400], marginInline: 2 }}>—</span>
        {after && <span style={{ letterSpacing: '4px' }}>{after}</span>}
        <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
          {Array.from({ length: dotsAfter }).map((_, i) => (
            <span key={i} style={{ width: 8, height: 8, borderRadius: 99, background: GRAY[700] }} />
          ))}
        </div>
      </div>
    );
  }

  if (kind === 'phone') {
    const a = value.slice(0, 3);
    const b = value.slice(3, 7);
    const c = value.slice(7, 11);
    const totalLen = value.length;
    return (
      <div style={{
        display: 'flex', alignItems: 'center', gap: 6,
        ...TYPO.h3, fontSize: 24, lineHeight: '26px', fontWeight: 500,
        color: COLORS.white, minHeight: 26,
      }}>
        {totalLen === 0 ? (
          <span style={{ color: GRAY[600] }}>{placeholder}</span>
        ) : (
          <>
            <span style={{ letterSpacing: '2px' }}>{a}</span>
            {totalLen > 3 && <span style={{ color: GRAY[500] }}>-</span>}
            {totalLen > 3 && <span style={{ letterSpacing: '2px' }}>{b}</span>}
            {totalLen > 7 && <span style={{ color: GRAY[500] }}>-</span>}
            {totalLen > 7 && <span style={{ letterSpacing: '2px' }}>{c}</span>}
          </>
        )}
      </div>
    );
  }

  if (kind === 'code') {
    return (
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, minHeight: 32 }}>
        {Array.from({ length: 6 }).map((_, i) => (
          <div key={i} style={{
            width: 32, height: 40,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            ...TYPO.h3, fontSize: 28, fontWeight: 600,
            color: COLORS.white,
          }}>
            {value[i] || <span style={{ width: 8, height: 8, borderRadius: 99, background: GRAY[700] }} />}
          </div>
        ))}
      </div>
    );
  }

  // text
  return (
    <div style={{
      ...TYPO.h3, fontSize: 24, lineHeight: '26px', fontWeight: 500,
      color: value ? COLORS.white : GRAY[600], minHeight: 26,
    }}>
      {value || placeholder}
    </div>
  );
}

// ============ FIELD ============
function ActiveField({ step, value, onChange, autoFocus }) {
  const ref = useRef(null);
  const [focused, setFocused] = useState(false);

  useEffect(() => {
    if (autoFocus) ref.current?.focus();
  }, [autoFocus, step.key]);

  const handle = (e) => {
    let v = e.target.value;
    if (step.kind !== 'text') v = v.replace(/[^0-9]/g, '');
    if (step.max) v = v.slice(0, step.max);
    onChange(v);
  };

  const accent = focused || value ? C.purple : GRAY[700];

  return (
    <div style={{
      padding: '0 24px', position: 'relative',
    }}>
      <label style={{
        position: 'relative', display: 'block',
        cursor: 'text',
      }}>
        {/* the real input — invisible, captures keystrokes */}
        <input
          ref={ref}
          value={value}
          onChange={handle}
          onFocus={() => setFocused(true)}
          onBlur={() => setFocused(false)}
          inputMode={step.inputMode}
          style={{
            position: 'absolute', inset: 0,
            background: 'transparent', border: 'none', outline: 'none',
            color: 'transparent', caretColor: 'transparent',
            fontSize: 16, width: '100%', height: '100%',
            zIndex: 2,
          }}
        />
        {/* visual layer */}
        <div style={{
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          paddingBottom: 10, pointerEvents: 'none',
          borderBottom: `1.5px solid ${accent}`,
          transition: 'border-color .2s',
          minHeight: 36,
        }}>
          <MaskedDisplay value={value} kind={step.kind} placeholder={step.placeholder} />
          {value && (
            <button
              onClick={(e) => { e.preventDefault(); e.stopPropagation(); onChange(''); ref.current?.focus(); }}
              style={{
                all: 'unset', cursor: 'pointer', display: 'flex',
                padding: 4, pointerEvents: 'auto',
              }}
            >
              <IconClearCircle />
            </button>
          )}
        </div>
      </label>

      {step.key === 'code' && (
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 14 }}>
          <span style={{ ...TYPO.caption, color: GRAY[500], lineHeight: '16px' }}>
            인증번호가 오지 않나요?
          </span>
          <button style={{ all: 'unset', cursor: 'pointer', ...TYPO.button2, color: C.lime }}>
            다시 받기 (02:54)
          </button>
        </div>
      )}
    </div>
  );
}

// ============ FILLED ROW (below current) ============
function FilledRow({ step, value }) {
  return (
    <div style={{
      padding: '0 24px', marginTop: 32,
      display: 'flex', flexDirection: 'column', gap: 8,
    }}>
      <span style={{ ...TYPO.caption, color: GRAY[600], lineHeight: '12px' }}>{step.label}</span>
      <div style={{
        ...TYPO.h3, fontSize: 24, lineHeight: '26px', fontWeight: 500,
        color: GRAY[600],
        paddingBottom: 10,
        borderBottom: `1.5px solid ${GRAY[800]}`,
      }}>
        {formatDisplay(step.kind, value)}
      </div>
    </div>
  );
}

function formatDisplay(kind, v) {
  if (!v) return '';
  if (kind === 'phone' && v.length > 3) {
    if (v.length <= 7) return v.replace(/(\d{3})(\d+)/, '$1-$2');
    return v.replace(/(\d{3})(\d{4})(\d+)/, '$1-$2-$3');
  }
  if (kind === 'rrn' && v.length > 6) {
    return v.slice(0, 6) + '-' + v.slice(6).padEnd(7, '●');
  }
  if (kind === 'rrn') return v;
  return v;
}

// ============ CTA (sits on top of keyboard) ============
function BottomCTA({ enabled, onClick, label }) {
  return (
    <div style={{
      width: '100%',
      background: enabled ? C.purple : C.purpleDisabled,
      flexShrink: 0,
      transition: 'background .2s',
    }}>
      <button
        disabled={!enabled}
        onClick={onClick}
        style={{
          all: 'unset', width: '100%',
          height: 56, padding: 0,
          textAlign: 'center', cursor: enabled ? 'pointer' : 'default',
          color: enabled ? COLORS.white : 'rgba(255,255,255,0.8)',
          ...TYPO.button1, fontWeight: 600,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}
      >
        {label}
      </button>
    </div>
  );
}

// ============ ROOT ============
function App() {
  const [stepIdx, setStepIdx] = useState(1); // 기본 시연용: 생년월일 단계
  const [values, setValues] = useState({ name: '홍길동', birth: '', phone: '', code: '' });

  const step = STEPS[stepIdx];
  const value = values[step.key];
  const isLast = stepIdx === STEPS.length - 1;
  const enabled = value.length >= step.minLen;

  const goNext = () => {
    if (!enabled) return;
    if (isLast) return;
    setStepIdx(stepIdx + 1);
  };
  const goBack = () => {
    if (stepIdx === 0) return;
    setStepIdx(stepIdx - 1);
  };

  // Previously completed step (display below)
  const prev = stepIdx > 0 ? STEPS[stepIdx - 1] : null;
  const prevValue = prev ? values[prev.key] : null;

  return (
    <div style={{
      width: '100%', height: '100%', background: C.bg,
      color: C.text, fontFamily: "'Pretendard', sans-serif",
      display: 'flex', flexDirection: 'column',
      overflow: 'hidden',
    }}>
      <NavBar title="본인 인증" onBack={goBack} />

      <div style={{ flex: 1, overflowY: 'auto', display: 'flex', flexDirection: 'column' }}>
        <Heading step={step} />
        <ActiveField
          step={step}
          value={value}
          autoFocus
          onChange={(v) => setValues({ ...values, [step.key]: v })}
        />
        {prev && prevValue && (
          <FilledRow step={prev} value={prevValue} />
        )}
      </div>

      <BottomCTA
        enabled={enabled}
        onClick={goNext}
        label={isLast ? '인증 완료' : '확인'}
      />
    </div>
  );
}

// ============ MOUNT ============
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <IOSDevice dark={true} width={393} height={852} keyboard={true}>
    <App />
  </IOSDevice>
);
