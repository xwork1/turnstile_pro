import 'package:flutter/widgets.dart';

import 'turnstile_enums.dart';

/// Groups the appearance and behavior options of a [TurnstilePro] widget.
///
/// `siteKey`, callbacks and the controller stay on the widget itself; the
/// fields here only control how the Turnstile widget is rendered.
class TurnstileOptions {
  const TurnstileOptions({
    this.size = TurnstileSize.flexible,
    this.theme = TurnstileTheme.auto,
    this.language = 'auto',
    this.retryAutomatically = true,
    this.retryInterval = 8000,
    this.refreshExpired = TurnstileRefreshMode.auto,
    this.refreshTimeout = TurnstileRefreshMode.auto,
    this.appearance = TurnstileAppearance.always,
    this.borderRadius,
    this.backgroundColor = const Color(0x00000000),
    this.curve = Curves.easeInOut,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : assert(retryInterval >= 0, 'retryInterval must not be negative');

  /// Widget size mode.
  final TurnstileSize size;

  /// Color theme.
  final TurnstileTheme theme;

  /// Widget language (e.g. `tr`, `en`, `auto`).
  final String language;

  /// Automatically retry when a challenge fails.
  final bool retryAutomatically;

  /// Delay between automatic retries, in milliseconds.
  final int retryInterval;

  /// Behavior when the token expires.
  final TurnstileRefreshMode refreshExpired;

  /// Behavior when a non-interactive challenge times out.
  final TurnstileRefreshMode refreshTimeout;

  /// When the widget becomes visible.
  final TurnstileAppearance appearance;

  /// Corner radius of the widget. No clipping is applied when `null`.
  final BorderRadius? borderRadius;

  /// Widget background color (defaults to transparent).
  final Color backgroundColor;

  /// Animation curve used while the widget appears.
  final Curve curve;

  /// Duration of the appear animation. [Duration.zero] disables it.
  final Duration animationDuration;

  TurnstileOptions copyWith({
    TurnstileSize? size,
    TurnstileTheme? theme,
    String? language,
    bool? retryAutomatically,
    int? retryInterval,
    TurnstileRefreshMode? refreshExpired,
    TurnstileRefreshMode? refreshTimeout,
    TurnstileAppearance? appearance,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    Curve? curve,
    Duration? animationDuration,
  }) {
    return TurnstileOptions(
      size: size ?? this.size,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      retryAutomatically: retryAutomatically ?? this.retryAutomatically,
      retryInterval: retryInterval ?? this.retryInterval,
      refreshExpired: refreshExpired ?? this.refreshExpired,
      refreshTimeout: refreshTimeout ?? this.refreshTimeout,
      appearance: appearance ?? this.appearance,
      borderRadius: borderRadius ?? this.borderRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      curve: curve ?? this.curve,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}
