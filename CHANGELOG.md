## 0.2.0

- Feature: `TurnstileExecution` option (`execution`) and
  `TurnstileController.execute()` to run the challenge on demand.
- Feature: `TurnstileController` is now a `ChangeNotifier` exposing `token`,
  `hasToken` and `isReady`.
- Feature: `onBeforeInteractive` / `onAfterInteractive` callbacks.
- Feature: `feedbackEnabled` option (Cloudflare `feedback-enabled`).
- Feature: `onExternalLink` callback. Links inside the widget (Privacy/Terms)
  no longer navigate the web view away from the challenge.
- Feature: `onError` now also reports `unsupported` and `script_load_error`
  (Turnstile script could not be loaded, e.g. offline).
- Fix: invalid render parameters (e.g. a malformed `action` / `cData`) are
  reported via `onError` as `render_error: …` instead of failing silently.
- Fix: all values embedded in the page (`siteKey`, `language`, `action`,
  `cData`, …) are now properly JSON-escaped; quotes, backslashes, newlines or
  `</script>` no longer break the page.
- Fix: `onWidgetReady` is called once per page load instead of on every
  resize re-render.
- Fix: changing `siteKey`, `options`, `action`, `cData` or `baseUrl` now
  re-renders the challenge.
- Fix: the controller is detached when the widget is disposed or the
  controller is swapped.
- `TurnstileOptions` now implements `==` / `hashCode`.

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
