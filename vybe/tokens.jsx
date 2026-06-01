/* global window */
// ============================================================
// vybe — Design Tokens
// ============================================================

// Colors -----------------------------------------------------
const PURPLE = {
  500: '#7731FE',
  700: '#622ACF',
  900: '#4E24A0',
  disabled: '#2F1A5A',
};

const LIME = {
  500: '#B5FF60',
  700: '#94CF51',
  900: '#739F41',
  disabled: '#42582A',
};

const GRAY = {
  100: '#F8F8F8',
  200: '#ECECEC',
  300: '#DBDBDC',
  400: '#CACACB',
  500: '#9F9FA1',
  600: '#707071',
  700: '#535355',
  800: '#404042',
  900: '#2F2F33',
};

const RED = {
  500: '#FF5C5F',
  700: '#CF4D50',
  900: '#9F3E40',
};

const BLUE = {
  500: '#2B6BFF',
  700: '#2659D0',
  900: '#2047A1',
};

const COLORS = {
  bg: '#101013',       // app background (gray 900 시각적 변형)
  surface: GRAY[900],
  white: '#FFFFFF',
  black: '#000000',
  purple: PURPLE,
  lime: LIME,
  gray: GRAY,
  red: RED,
  blue: BLUE,
};

// Typography -------------------------------------------------
// All Pretendard, letter-spacing -2.5%
const _ls = '-0.025em';
const TYPO = {
  h1:      { fontWeight: 700, fontSize: 32, lineHeight: '34px', letterSpacing: _ls },
  h2:      { fontWeight: 700, fontSize: 28, lineHeight: '30px', letterSpacing: _ls },
  h3:      { fontWeight: 600, fontSize: 24, lineHeight: '26px', letterSpacing: _ls },
  h4:      { fontWeight: 600, fontSize: 20, lineHeight: '22px', letterSpacing: _ls },
  body1:   { fontWeight: 400, fontSize: 20, lineHeight: '22px', letterSpacing: _ls },
  body2:   { fontWeight: 400, fontSize: 18, lineHeight: '20px', letterSpacing: _ls },
  body3:   { fontWeight: 400, fontSize: 16, lineHeight: '18px', letterSpacing: _ls },
  body4:   { fontWeight: 400, fontSize: 14, lineHeight: '16px', letterSpacing: _ls },
  tagline: { fontWeight: 700, fontSize: 14, lineHeight: '24px', letterSpacing: _ls },
  caption: { fontWeight: 400, fontSize: 12, lineHeight: '24px', letterSpacing: _ls },
  button1: { fontWeight: 600, fontSize: 16, lineHeight: '18px', letterSpacing: _ls },
  button2: { fontWeight: 600, fontSize: 14, lineHeight: '16px', letterSpacing: _ls },
};

// Expose to all babel scripts
Object.assign(window, { COLORS, TYPO, PURPLE, LIME, GRAY, RED, BLUE });
