import 'dart:convert';

import 'turnstile_enums.dart';
import 'turnstile_options.dart';

/// Encodes [value] as a JavaScript string literal that is safe to embed in an
/// inline `<script>` block.
String _js(String? value) => value == null
    ? 'undefined'
    : jsonEncode(value)
        .replaceAll('<', '\\u003c')
        .replaceAll('>', '\\u003e')
        .replaceAll('\u2028', '\\u2028')
        .replaceAll('\u2029', '\\u2029');

/// Builds the HTML page that hosts the Turnstile challenge.
///
/// Internal to the package (not exported); kept separate so it can be tested.
String buildTurnstileHtml({
  required String siteKey,
  required TurnstileOptions options,
  String? action,
  String? cData,
}) {
  final TurnstileOptions o = options;
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
<script>
  function post(payload) {
    try { TurnstileChannel.postMessage(JSON.stringify(payload)); } catch (e) {}
  }
  function onTurnstileScriptError() { post({ type: 'script-error' }); }
</script>
<script src="https://challenges.cloudflare.com/turnstile/v0/api.js?onload=onTurnstileLoad&render=explicit" async defer onerror="onTurnstileScriptError()"></script>
</head>
<body>
<div id="cf"></div>
<script>
  var turnstileWidgetId;
  var lastWidth = 0;
  var readySent = false;
  var executed = false;
  var flexible = ${o.size == TurnstileSize.flexible};
  var executeMode = ${o.execution == TurnstileExecution.execute};

  function renderTurnstile() {
    var el = document.getElementById('cf');
    try {
    turnstileWidgetId = turnstile.render(el, {
      sitekey: ${_js(siteKey)},
      theme: ${_js(o.theme.value)},
      language: ${_js(o.language)},
      size: ${_js(o.size.value)},
      retry: ${_js(o.retryAutomatically ? 'auto' : 'never')},
      'retry-interval': ${o.retryInterval},
      'refresh-expired': ${_js(o.refreshExpired.value)},
      'refresh-timeout': ${_js(o.refreshTimeout.value)},
      appearance: ${_js(o.appearance.value)},
      execution: ${_js(o.execution.value)},
      'feedback-enabled': ${o.feedbackEnabled},
      action: ${_js(action)},
      cData: ${_js(cData)},
      callback: function (token) { post({ type: 'token', token: token }); },
      'error-callback': function (error) { post({ type: 'error', error: String(error) }); return true; },
      'expired-callback': function () { post({ type: 'expired' }); },
      'timeout-callback': function () { post({ type: 'timeout' }); },
      'unsupported-callback': function () { post({ type: 'unsupported' }); },
      'before-interactive-callback': function () { post({ type: 'before-interactive' }); },
      'after-interactive-callback': function () { post({ type: 'after-interactive' }); }
    });
    } catch (e) {
      post({ type: 'error', error: 'render_error: ' + (e && e.message ? e.message : String(e)) });
      return;
    }
    lastWidth = el.clientWidth;
    if (!readySent) {
      readySent = true;
      post({ type: 'ready' });
      if (flexible) observeResize(el);
    }
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
        post({ type: 'reset' });
        renderTurnstile();
        if (executeMode && executed) turnstileExecute();
      }
    });
    ro.observe(el);
  }

  function turnstileReset() {
    if (typeof turnstile !== 'undefined' && turnstileWidgetId !== undefined) {
      turnstile.reset(turnstileWidgetId);
    }
  }

  function turnstileExecute() {
    if (typeof turnstile !== 'undefined' && turnstileWidgetId !== undefined) {
      executed = true;
      turnstile.execute(turnstileWidgetId);
    }
  }
</script>
</body>
</html>
''';
}
