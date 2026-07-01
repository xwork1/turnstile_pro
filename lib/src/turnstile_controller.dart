import 'package:webview_flutter/webview_flutter.dart';

/// Controls a [TurnstilePro] widget programmatically.
///
/// Do not attach the same controller instance to more than one widget.
///
/// ```dart
/// final controller = TurnstileController();
/// // ...
/// TurnstilePro(siteKey: '...', controller: controller, onTokenReceived: ...);
/// // When needed:
/// controller.reset();
/// ```
class TurnstileController {
  WebViewController? _webViewController;

  /// Called by the widget; you normally don't need to call this yourself.
  void attach(WebViewController controller) {
    _webViewController = controller;
  }

  /// Resets the Turnstile widget and starts a new challenge.
  Future<void> reset() async {
    await _webViewController?.runJavaScript('turnstileReset();');
  }

  /// Reloads the page (re-renders the widget from scratch).
  Future<void> reload() async {
    await _webViewController?.reload();
  }

  /// Detaches the underlying controller.
  void dispose() {
    _webViewController = null;
  }
}
