# Frontend Changes: Theme Toggle Button

## What was added

A dark/light mode toggle button fixed to the top-right corner of the UI.

## Files modified

### `frontend/index.html`
- Added `<button id="themeToggle">` with two inline SVGs: a sun icon (shown in dark mode) and a moon icon (shown in light mode)
- Both SVGs have `aria-hidden="true"`; the button itself has `aria-label="Toggle light/dark theme"` and `title="Toggle theme"` for accessibility

### `frontend/style.css`
- Added `body[data-theme="light"]` CSS variable overrides (background, surface, text, border colors adjusted for light mode)
- Added `transition: background-color 0.3s ease, color 0.3s ease` to `body` and key structural elements for smooth theme switching
- Added `#themeToggle` styles: `position: fixed; top: 1rem; right: 1rem`, circular (44×44px), matches existing surface/border design language
- Added hover/focus/active states with focus ring matching the existing `--focus-ring` variable
- Added icon transition logic: icons use `opacity` + `transform` (rotate + scale) for the swap animation; dark mode shows sun, light mode shows moon

### `frontend/script.js`
- Added `initTheme()`: reads `localStorage` key `theme` on page load and applies `data-theme="light"` to `<body>` if set
- Added `toggleTheme()`: toggles the `data-theme` attribute and persists the choice to `localStorage`
- Wired `themeToggle` click listener in `setupEventListeners()`
- Called `initTheme()` before `setupEventListeners()` in the `DOMContentLoaded` handler so the correct theme is applied before first paint

## Design decisions

- **Default is dark mode** — matches the original app design; no attribute on `<body>` = dark
- **`localStorage` persistence** — preference survives page reloads
- **CSS variable override pattern** — `body[data-theme="light"]` overrides the same variable names declared on `:root`, so no component styles needed to change
- **Icon animation** — `opacity` + `rotate/scale` transform gives a natural feel without a JS animation loop; both icons are always in the DOM so no layout shift on toggle
- **Accessibility** — button is keyboard-focusable, has a visible focus ring, descriptive `aria-label`, and icon SVGs are marked `aria-hidden`
