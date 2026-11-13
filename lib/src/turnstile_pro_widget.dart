import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'turnstile_html.dart';
import 'turnstile_options.dart';

part 'turnstile_controller.dart';

/// A lightweight, low-dependency Flutter widget that runs Cloudflare Turnstile
/// through `webview_flutter`.
///
/// It does not pull in extra native plugins (such as `flutter_inappwebview`);
/// only the official `webview_flutter` is used. Appearance/behavior is provided
/// through [TurnstileOptions]; use [TurnstileController] for `reset()`,
/// `execute()` and to read the current token.
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
    this.onBeforeInteractive,
    this.onAfterInteractive,
    this.onExternalLink,
    this.controller,
    this.options = const TurnstileOptions(),
    this.baseUrl = 'https://localhost/',
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
  ///
  /// The value is `expired`, `timeout`, `unsupported` (the browser is not
  /// supported by Turnstile), `script_load_error` (the Turnstile script could
  /// not be loaded, e.g. no network) or a Cloudflare error code
  /// (e.g. `110200`) reported by the challenge.
  final ValueChanged<String>? onError;

  /// Called once per page load, when the Turnstile widget is rendered.
  final VoidCallback? onWidgetReady;

  /// Called before the challenge enters interactive mode (the visitor has to
  /// click the checkbox).
  final VoidCallback? onBeforeInteractive;

  /// Called after the interactive challenge is left.
  final VoidCallback? onAfterInteractive;

  /// Called when the visitor taps a link inside the widget (e.g. Cloudflare's
  /// "Privacy" / "Terms" links). The web view never navigates away from the
  /// challenge; open the url with e.g. `url_launcher` if you want to.
  final ValueChanged<String>? onExternalLink;

  /// Optional controller for programmatic control of the widget.
  final TurnstileController? controller;

  /// Appearance and behavior options.
  final TurnstileOptions options;

  /// Base url used for the widget's origin. Use an `https://` origin so that
  /// the page is a secure context (required by Turnstile on iOS/WKWebView).
  /// Defaults to `https://localhost/`.
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
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Drive the appear animation from mount rather than the JS 'ready'
    // message. On iOS/WKWebView the channel message can be delayed or missed,
    // which would otherwise leave the widget stuck at opacity 0.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(onNavigationRequest: _onNavigationRequest),
      )
      ..addJavaScriptChannel(
        'TurnstileChannel',
        onMessageReceived: _onMessageReceived,
      );

    widget.controller?._attachState(this);
    _load();
  }

  @override
  void didUpdateWidget(covariant TurnstilePro oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detachState(this);
      widget.controller?._attachState(this);
      widget.controller?._setReady(_ready);
    }
    if (oldWidget.siteKey != widget.siteKey ||
        oldWidget.baseUrl != widget.baseUrl ||
        oldWidget.action != widget.action ||
        oldWidget.cData != widget.cData ||
        oldWidget.options.rendersDifferentlyFrom(widget.options)) {
      _load();
    }
  }

  @override
  void dispose() {
    widget.controller?._detachState(this);
    super.dispose();
  }

  /// (Re)loads the challenge page.
  Future<void> _load() {
    if (_ready && mounted) setState(() => _ready = false);
    widget.controller?._setReady(false);
    widget.controller?._setToken(null);
    return _webViewController.loadHtmlString(
      buildTurnstileHtml(
        siteKey: widget.siteKey,
        options: widget.options,
        action: widget.action,
        cData: widget.cData,
      ),
      baseUrl: widget.baseUrl,
    );
  }

  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final String url = request.url;
    // Sub-frame navigations (the Cloudflare challenge iframe) and the page
    // itself are allowed; anything that would replace the page is blocked.
    if (!request.isMainFrame ||
        url.startsWith(widget.baseUrl) ||
        url.startsWith('about:') ||
        url.startsWith('data:')) {
      return NavigationDecision.navigate;
    }
    widget.onExternalLink?.call(url);
    return NavigationDecision.prevent;
  }

  void _onMessageReceived(JavaScriptMessage message) {
    if (!mounted) return;
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(message.message) as Map<String, dynamic>;
    } catch (_) {
      widget.onError?.call('parse_error');
      return;
    }
    final TurnstileController? controller = widget.controller;
    switch (data['type']) {
      case 'token':
        final String token = (data['token'] ?? '').toString();
        controller?._setToken(token);
        widget.onTokenReceived(token);
        break;
      case 'ready':
        if (!_ready) setState(() => _ready = true);
        controller?._setReady(true);
        widget.onWidgetReady?.call();
        break;
      case 'reset':
        controller?._setToken(null);
        break;
      case 'before-interactive':
        widget.onBeforeInteractive?.call();
        break;
      case 'after-interactive':
        widget.onAfterInteractive?.call();
        break;
      case 'expired':
        controller?._setToken(null);
        widget.onError?.call('expired');
        break;
      case 'timeout':
        controller?._setToken(null);
        widget.onError?.call('timeout');
        break;
      case 'unsupported':
        controller?._setToken(null);
        widget.onError?.call('unsupported');
        break;
      case 'script-error':
        widget.onError?.call('script_load_error');
        break;
      case 'error':
        controller?._setToken(null);
        widget.onError?.call((data['error'] ?? 'error').toString());
        break;
    }
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

    // Appear animation, driven by mount (not the JS 'ready' message).
    web = AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
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
