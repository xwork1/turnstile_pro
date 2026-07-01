## 0.1.1

- Fix: widget could stay invisible on iOS/WKWebView because the appear
  animation was gated on the JS `ready` message, which can be delayed or
  missed. The animation is now driven from mount, so the widget is always
  shown once laid out.
- Change: default `baseUrl` is now `https://localhost/` so the page is a
  secure context (recommended by Turnstile on iOS).

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
