/// Size mode of the Turnstile widget. Maps to Cloudflare's `size` option.
enum TurnstileSize {
  /// Fixed 300x65.
  normal('normal', 300, 65),

  /// Compact 150x140.
  compact('compact', 150, 140),

  /// Expands to the parent's width, ~65px tall.
  flexible('flexible', double.infinity, 65);

  const TurnstileSize(this.value, this.width, this.defaultHeight);

  /// Value passed to the Cloudflare API.
  final String value;

  /// Suggested width (logical px). Infinite for [flexible].
  final double width;

  /// Default height (logical px) used when no explicit height is given.
  final double defaultHeight;
}

/// Color theme of the widget. Maps to Cloudflare's `theme` option.
enum TurnstileTheme {
  light('light'),
  dark('dark'),
  auto('auto');

  const TurnstileTheme(this.value);

  final String value;
}

/// Behavior when the token expires or an interactive challenge times out.
/// Maps to Cloudflare's `refresh-expired` and `refresh-timeout` options.
enum TurnstileRefreshMode {
  /// Automatically refresh/retry.
  auto('auto'),

  /// Wait for user interaction.
  manual('manual'),

  /// Never refresh/retry.
  never('never');

  const TurnstileRefreshMode(this.value);

  final String value;
}

/// Controls when the widget is visible. Maps to Cloudflare's `appearance`
/// option.
enum TurnstileAppearance {
  /// Always visible.
  always('always'),

  /// Visible only while a challenge is executed.
  execute('execute'),

  /// Visible only when interaction is required.
  interactionOnly('interaction-only');

  const TurnstileAppearance(this.value);

  final String value;
}
