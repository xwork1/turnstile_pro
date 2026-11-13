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
- ▶️ `execution: execute` mode — run the challenge on demand with `controller.execute()`
- 🎮 `TurnstileController` (`ChangeNotifier`) with `reset()`, `reload()`, `execute()` and the current `token` / `isReady` state
- 📣 `onTokenReceived`, `onError`, `onWidgetReady`, `onBeforeInteractive`, `onAfterInteractive`
- 🔒 The web view never navigates away from the challenge; tapped links are reported via `onExternalLink`
- 🔄 Changing `siteKey`, `options`, `action` or `cData` re-renders the challenge automatically

## Installation

```yaml
dependencies:
  turnstile_pro: ^0.2.0
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
    // 'expired', 'timeout', 'unsupported', 'script_load_error',
    // 'render_error: …', 'parse_error' or a Cloudflare error code
    // such as '110200'.
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

The controller is a `ChangeNotifier`, so it can drive UI directly:

```dart
ListenableBuilder(
  listenable: controller,
  builder: (context, _) => ElevatedButton(
    onPressed: controller.hasToken ? submit : null,
    child: const Text('Submit'),
  ),
)
```

### Run the challenge on demand

With `TurnstileExecution.execute` the widget is rendered but the challenge only
starts when you call `execute()` (e.g. when the form is submitted):

```dart
TurnstilePro(
  siteKey: '...',
  controller: controller,
  options: const TurnstileOptions(
    execution: TurnstileExecution.execute,
    appearance: TurnstileAppearance.interactionOnly,
  ),
  onTokenReceived: (token) => submitForm(token),
);

// On submit:
await controller.execute();
```

### Links inside the widget

Cloudflare shows "Privacy" / "Terms" links in the widget. The web view never
leaves the challenge page; tapped urls are passed to `onExternalLink` so you
can open them yourself (e.g. with `url_launcher`):

```dart
TurnstilePro(
  siteKey: '...',
  onExternalLink: (url) => launchUrl(Uri.parse(url)),
  onTokenReceived: (t) {},
)
```

Remember to dispose the controller:

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
| `onError`         | `ValueChanged<String>?`| `null`               | `expired` / `timeout` / `unsupported` / `script_load_error` / `render_error: …` / `parse_error` / Cloudflare error code |
| `onWidgetReady`   | `VoidCallback?`        | `null`               | Fired once per page load, when rendered          |
| `onBeforeInteractive` | `VoidCallback?`    | `null`               | Challenge is about to become interactive         |
| `onAfterInteractive`  | `VoidCallback?`    | `null`               | Interactive challenge finished                   |
| `onExternalLink`  | `ValueChanged<String>?`| `null`               | A link inside the widget was tapped              |
| `controller`      | `TurnstileController?` | `null`               | `reset()` / `reload()` / `execute()`, `token`    |
| `options`         | `TurnstileOptions`     | `TurnstileOptions()` | Appearance & behavior (see below)                |
| `baseUrl`         | `String`               | `https://localhost/` | Origin used for the widget                       |
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
| `execution`          | `TurnstileExecution`   | `render`           | `render` / `execute` (on demand)         |
| `feedbackEnabled`    | `bool`                 | `true`             | Allow Cloudflare's feedback prompt       |
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
