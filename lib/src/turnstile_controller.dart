part of 'turnstile_pro_widget.dart';

/// Controls a [TurnstilePro] widget programmatically and exposes its state.
///
/// The controller is a [ChangeNotifier]: listeners are notified whenever
/// [token] or [isReady] changes, so it can drive UI (e.g. enabling a submit
/// button) with a `ListenableBuilder`.
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
class TurnstileController extends ChangeNotifier {
  WebViewController? _webViewController;
  _TurnstileProState? _state;
  String? _token;
  bool _isReady = false;
  bool _disposed = false;

  /// The latest valid token, or `null` if there is none yet or it has expired,
  /// errored, or been reset.
  String? get token => _token;

  /// Whether a valid token is currently available.
  bool get hasToken => _token != null;

  /// Whether the Turnstile widget has been rendered.
  bool get isReady => _isReady;

  /// Called by the widget; you normally don't need to call this yourself.
  void attach(WebViewController controller) {
    _webViewController = controller;
  }

  void _attachState(_TurnstileProState state) {
    _state = state;
    _webViewController = state._webViewController;
  }

  void _detachState(_TurnstileProState state) {
    if (_state != state) return;
    _state = null;
    _webViewController = null;
    _setToken(null);
    _setReady(false);
  }

  void _setToken(String? value) {
    if (_disposed || _token == value) return;
    _token = value;
    notifyListeners();
  }

  void _setReady(bool value) {
    if (_disposed || _isReady == value) return;
    _isReady = value;
    notifyListeners();
  }

  /// Resets the Turnstile widget and starts a new challenge.
  Future<void> reset() async {
    _setToken(null);
    await _webViewController?.runJavaScript('turnstileReset();');
  }

  /// Runs the challenge when [TurnstileOptions.execution] is
  /// [TurnstileExecution.execute]. Has no effect otherwise.
  Future<void> execute() async {
    await _webViewController?.runJavaScript('turnstileExecute();');
  }

  /// Reloads the page (re-renders the widget from scratch).
  Future<void> reload() async {
    final _TurnstileProState? state = _state;
    if (state != null) {
      await state._load();
    } else {
      await _webViewController?.reload();
    }
  }

  /// Detaches the underlying controller and releases listeners.
  @override
  void dispose() {
    _webViewController = null;
    _state = null;
    _disposed = true;
    super.dispose();
  }
}
