# turnstile_pro

A lightweight [Cloudflare Turnstile](https://developers.cloudflare.com/turnstile/)
widget for Flutter, rendered through the official
[`webview_flutter`](https://pub.dev/packages/webview_flutter).

Unlike some alternatives, **it does not pull in `flutter_inappwebview`** — which
keeps your dependency tree small and avoids Android Gradle Plugin (AGP 9+)
incompatibilities caused by that plugin's legacy ProGuard configuration.

## Features

- ✅ Renders Turnstile via the official `webview_flutter`
- 📐 Size modes: `normal`, `compact`, `flexible` (with sensible default heights)
- 🎨 Themes: `light`, `dark`, `auto` and configurable `language`
- 🔁 Auto-retry and refresh control (`retry`, `refreshExpired`, `refreshTimeout`)
- 👁️ `appearance`, and server-side `action` / `cData` tagging
- 🖼️ Styling via `TurnstileOptions`: `borderRadius`, `backgroundColor`, appear `curve` + `animationDuration`
- ⏳ Optional `loadingWidget` shown until the challenge is ready
- 🎮 `TurnstileController` with `reset()` and `reload()`
- 📣 `onTokenReceived`, `onError` (`error` / `expired` / `timeout`), `onWidgetReady`

## Installation

```yaml
dependencies:
  turnstile_pro: ^0.1.0
```

### Platform setup

This package uses `webview_flutter`, so follow its platform requirements:

- **Android**: `minSdkVersion 21+`, internet permission in the manifest.
- **iOS**: no extra setup for remote content.

## Usage

```dart
import 'package:turnstile_pro/turnstile_pro.dart';

TurnstilePro(
  siteKey: '1x00000000000000000000AA',
  onTokenReceived: (token) {
    // Send this token to your backend for verification.
    debugPrint('token: $token');
  },
  onError: (error) {
    // error is one of: 'error', 'expired', 'timeout', 'parse_error'
    debugPrint('turnstile error: $error');
  },
)
```

### Configuring appearance & behavior

All visual/behavioral settings live in [`TurnstileOptions`]:

```dart
TurnstilePro(
  siteKey: '...',
  options: const TurnstileOptions(
    size: TurnstileSize.flexible,
    theme: TurnstileTheme.light,
    language: 'tr',
    borderRadius: BorderRadius.all(Radius.circular(10)),
    curve: Curves.easeInOut,
    animationDuration: Duration(milliseconds: 300),
    refreshTimeout: TurnstileRefreshMode.manual,
  ),
  loadingWidget: const Center(child: CircularProgressIndicator()),
  onTokenReceived: (t) {},
)
```

### Full-width (flexible) layout

`flexible` expands to the parent's width. Because a WebView has no intrinsic
width, the widget forces `width: double.infinity`, so place it in a container
that provides a bounded width (e.g. a `Column` with horizontal padding). The
widget also waits for a non-zero layout width before rendering, so `flexible`
reliably fills the row instead of collapsing to its minimum size:

```dart
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: TurnstilePro(
    siteKey: '...',
    options: const TurnstileOptions(size: TurnstileSize.flexible),
    onTokenReceived: (t) {},
  ),
)
```

### Programmatic control

```dart
final controller = TurnstileController();

TurnstilePro(
  siteKey: '...',
  controller: controller,
  onTokenReceived: (t) {},
);

// Later — e.g. after a failed form submission:
await controller.reset();
```

Remember to dispose it:

```dart
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

## API

### `TurnstilePro` (widget)

| Parameter         | Type                   | Default              | Description                                      |
| ----------------- | ---------------------- | -------------------- | ------------------------------------------------ |
| `siteKey`         | `String`               | —                    | Cloudflare Turnstile site key (required)         |
| `onTokenReceived` | `ValueChanged<String>` | —                    | Called with the verification token               |
| `onError`         | `ValueChanged<String>?`| `null`               | `error` / `expired` / `timeout` / `parse_error`  |
| `onWidgetReady`   | `VoidCallback?`        | `null`               | Fired once the widget is rendered                |
| `controller`      | `TurnstileController?` | `null`               | For `reset()` / `reload()`                       |
| `options`         | `TurnstileOptions`     | `TurnstileOptions()` | Appearance & behavior (see below)                |
| `baseUrl`         | `String`               | `http://localhost/`  | Origin used for the widget                       |
| `action`          | `String?`              | `null`               | Server-side action tag                           |
| `cData`           | `String?`              | `null`               | Customer data passed to the challenge            |
| `height`          | `double?`              | per-size default     | Widget height (logical px)                       |
| `loadingWidget`   | `Widget?`              | `null`               | Placeholder shown until ready                    |

### `TurnstileOptions`

| Field                | Type                   | Default            | Description                              |
| -------------------- | ---------------------- | ------------------ | ---------------------------------------- |
| `size`               | `TurnstileSize`        | `flexible`         | `normal` / `compact` / `flexible`        |
| `theme`              | `TurnstileTheme`       | `auto`             | `light` / `dark` / `auto`                |
| `language`           | `String`               | `auto`             | Widget language (e.g. `tr`, `en`)        |
| `retryAutomatically` | `bool`                 | `true`             | Retry on failed challenge                |
| `retryInterval`      | `int`                  | `8000`             | Retry interval in ms                     |
| `refreshExpired`     | `TurnstileRefreshMode` | `auto`             | Behavior when token expires              |
| `refreshTimeout`     | `TurnstileRefreshMode` | `auto`             | Behavior on interactive timeout          |
| `appearance`         | `TurnstileAppearance`  | `always`           | `always` / `execute` / `interactionOnly` |
| `borderRadius`       | `BorderRadius?`        | `null`             | Corner radius (clips the widget)         |
| `backgroundColor`    | `Color`                | transparent        | Background color                         |
| `curve`              | `Curve`                | `Curves.easeInOut` | Appear animation curve                   |
| `animationDuration`  | `Duration`             | `300ms`            | Appear animation duration                |

## How verification works

The widget only produces a token on the client. You must **validate the token
server-side** by POSTing it to
`https://challenges.cloudflare.com/turnstile/v0/siteverify` with your secret
key. Never trust the token without server verification.

## License

MIT — see [LICENSE](LICENSE).
