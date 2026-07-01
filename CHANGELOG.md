## 0.1.0

Initial release.

- `TurnstilePro` widget rendering Cloudflare Turnstile via `webview_flutter`.
- `TurnstileOptions` bundling appearance/behavior:
  - Size modes: `normal`, `compact`, `flexible` (auto default height per size).
  - Theme: `light`, `dark`, `auto`; configurable `language`.
  - Auto-retry (`retry` / `retryInterval`) and refresh behavior
    (`refreshExpired`, `refreshTimeout`).
  - `appearance`, `borderRadius`, `backgroundColor`, appear `curve` and
    `animationDuration`.
- `action` / `cData` support.
- Optional `loadingWidget` shown until the challenge is ready.
- `TurnstileController` with `reset()` and `reload()`.
- Callbacks: `onTokenReceived`, `onError` (`error` / `expired` / `timeout`),
  `onWidgetReady`.
- Reliable `flexible` full-width rendering (waits for a non-zero layout width
  and re-renders on resize).
- No `flutter_inappwebview` dependency.
