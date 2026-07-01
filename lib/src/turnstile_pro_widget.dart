import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'turnstile_controller.dart';
import 'turnstile_options.dart';

/// A lightweight, low-dependency Flutter widget that runs Cloudflare Turnstile
/// through `webview_flutter`.
///
/// It does not pull in extra native plugins (such as `flutter_inappwebview`);
/// only the official `webview_flutter` is used. Appearance/behavior is provided
/// through [TurnstileOptions]; use [TurnstileController] for `reset()`.
///
/// ```dart
/// TurnstilePro(
///   siteKey: '1x00000000000000000000AA',
///   options: const TurnstileOptions(
///     size: TurnstileSize.flexible,
///     borderRadius: BorderRadius.all(Radius.circular(10)),
///   ),
///   onTokenReceived: (token) => print(token),
///   onError: (error) => print(error),
/// )
/// ```
class TurnstilePro extends StatefulWidget {
  const TurnstilePro({
    super.key,
    required this.siteKey,
    required this.onTokenReceived,
    this.onError,
    this.onWidgetReady,
    this.controller,
    this.options = const TurnstileOptions(),
    this.baseUrl = 'http://localhost/',
    this.action,
    this.cData,
    this.height,
    this.loadingWidget,
  });

  /// Cloudflare Turnstile site key.
  final String siteKey;

  /// The token produced on a successful verification.
  final ValueChanged<String> onTokenReceived;

  /// Called on error / expiration / timeout.
  /// The value is one of `error`, `expired` or `timeout`.
  final ValueChanged<String>? onError;

  /// Called once the Turnstile script has loaded and the widget is rendered.
  final VoidCallback? onWidgetReady;

  /// Optional controller for programmatic control of the widget.
  final TurnstileController? controller;

  /// Appearance and behavior options.
  final TurnstileOptions options;

  /// Base url used for the widget's origin.
  /// Defaults to `http://localhost/`.
  final String baseUrl;

  /// Optional `action` tag for server-side parsing.
  final String? action;

  /// Optional customer data (`cData`) passed to the challenge.
  final String? cData;

  /// Widget height (logical px). Falls back to [TurnstileOptions.size] when not
  /// provided.
  final double? height;

  /// Optional placeholder shown until the widget is ready.
  final Widget? loadingWidget;

  @override
  State<TurnstilePro> createState() => _TurnstileProState();
}

class _TurnstileProState extends State<TurnstilePro> {
  late final WebViewController _webViewController;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'TurnstileChannel',
        onMessageReceived: _onMessageReceived,
      )
      ..loadHtmlString(_buildHtml(), baseUrl: widget.baseUrl);

    widget.controller?.attach(_webViewController);
  }

  @override
  void didUpdateWidget(covariant TurnstilePro oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      widget.controller?.attach(_webViewController);
    }
  }

  void _onMessageReceived(JavaScriptMessage message) {
    try {
      final Map<String, dynamic> data =
          jsonDecode(message.message) as Map<String, dynamic>;
      switch (data['type']) {
        case 'token':
          widget.onTokenReceived((data['token'] ?? '').toString());
          break;
        case 'ready':
          if (mounted && !_ready) setState(() => _ready = true);
          widget.onWidgetReady?.call();
          break;
        case 'expired':
          widget.onError?.call('expired');
          break;
        case 'timeout':
          widget.onError?.call('timeout');
          break;
        case 'error':
          widget.onError?.call((data['error'] ?? 'error').toString());
          break;
      }
    } catch (_) {
      widget.onError?.call('parse_error');
    }
  }

  String _jsString(String? value) =>
      value == null ? 'undefined' : "'${value.replaceAll("'", "\\'")}'";

  String _buildHtml() {
    final TurnstileOptions o = widget.options;
    return '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<style>
  html, body { margin: 0; padding: 0; width: 100%; background: transparent; overflow: hidden; }
  #cf { display: block; width: 100%; }
  /* Make the iframe/div injected by Turnstile span the full width. */
  #cf > * { width: 100% !important; margin: 0 auto !important; }
</style>
<script src="https://challenges.cloudflare.com/turnstile/v0/api.js?onload=onTurnstileLoad" async defer></script>
</head>
<body>
<div id="cf"></div>
<script>
  var turnstileWidgetId;
  var lastWidth = 0;

  function post(payload) {
    TurnstileChannel.postMessage(JSON.stringify(payload));
  }

  function renderTurnstile() {
    var el = document.getElementById('cf');
    turnstileWidgetId = turnstile.render(el, {
      sitekey: '${widget.siteKey}',
      theme: '${o.theme.value}',
      language: '${o.language}',
      size: '${o.size.value}',
      retry: '${o.retryAutomatically ? 'auto' : 'never'}',
      'retry-interval': ${o.retryInterval},
      'refresh-expired': '${o.refreshExpired.value}',
      'refresh-timeout': '${o.refreshTimeout.value}',
      appearance: '${o.appearance.value}',
      action: ${_jsString(widget.action)},
      cData: ${_jsString(widget.cData)},
      callback: function (token) { post({ type: 'token', token: token }); },
      'error-callback': function (error) { post({ type: 'error', error: String(error) }); },
      'expired-callback': function () { post({ type: 'expired' }); },
      'timeout-callback': function () { post({ type: 'timeout' }); }
    });
    lastWidth = el.clientWidth;
    post({ type: 'ready' });
    observeResize(el);
  }

  // Wait until layout is done and the container width is known before
  // rendering; otherwise the flexible size locks onto a zero/small width.
  function onTurnstileLoad() {
    waitForWidth(0);
  }

  function waitForWidth(tries) {
    var el = document.getElementById('cf');
    if (el && el.clientWidth > 0) {
      renderTurnstile();
    } else if (tries < 120) {
      requestAnimationFrame(function () { waitForWidth(tries + 1); });
    } else {
      renderTurnstile();
    }
  }

  // Re-render if the container width changes (e.g. orientation change).
  function observeResize(el) {
    if (typeof ResizeObserver === 'undefined') return;
    var ro = new ResizeObserver(function () {
      var w = el.clientWidth;
      if (w > 0 && Math.abs(w - lastWidth) > 2) {
        lastWidth = w;
        try { turnstile.remove(turnstileWidgetId); } catch (e) {}
        renderTurnstile();
      }
    });
    ro.observe(el);
  }

  function turnstileReset() {
    if (typeof turnstile !== 'undefined' && turnstileWidgetId !== undefined) {
      turnstile.reset(turnstileWidgetId);
    }
  }
</script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    final TurnstileOptions o = widget.options;
    final double height = widget.height ?? o.size.defaultHeight;

    Widget web = SizedBox(
      width: double.infinity,
      height: height,
      child: WebViewWidget(controller: _webViewController),
    );

    // Appear animation.
    web = AnimatedOpacity(
      opacity: _ready ? 1.0 : 0.0,
      duration: o.animationDuration,
      curve: o.curve,
      child: web,
    );

    Widget content = web;

    // Placeholder until ready.
    if (widget.loadingWidget != null) {
      content = Stack(
        alignment: Alignment.center,
        children: [
          web,
          if (!_ready) Positioned.fill(child: widget.loadingWidget!),
        ],
      );
    }

    content = Container(
      width: double.infinity,
      height: height,
      color: o.backgroundColor,
      child: content,
    );

    if (o.borderRadius != null) {
      content = ClipRRect(borderRadius: o.borderRadius!, child: content);
    }

    return content;
  }
}
