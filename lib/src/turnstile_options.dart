import 'package:flutter/widgets.dart';

import 'turnstile_enums.dart';
import 'turnstile_pro_widget.dart';

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
    this.execution = TurnstileExecution.render,
    this.feedbackEnabled = true,
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

  /// When the challenge runs. With [TurnstileExecution.execute] call
  /// [TurnstileController.execute] to start it.
  final TurnstileExecution execution;

  /// Whether Cloudflare may ask the visitor for feedback after a failed
  /// challenge. Maps to Cloudflare's `feedback-enabled` option.
  final bool feedbackEnabled;

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
    TurnstileExecution? execution,
    bool? feedbackEnabled,
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
      execution: execution ?? this.execution,
      feedbackEnabled: feedbackEnabled ?? this.feedbackEnabled,
      borderRadius: borderRadius ?? this.borderRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      curve: curve ?? this.curve,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }

  /// Whether [other] would render the Turnstile challenge differently, i.e.
  /// whether a change requires the page to be reloaded.
  bool rendersDifferentlyFrom(TurnstileOptions other) =>
      size != other.size ||
      theme != other.theme ||
      language != other.language ||
      retryAutomatically != other.retryAutomatically ||
      retryInterval != other.retryInterval ||
      refreshExpired != other.refreshExpired ||
      refreshTimeout != other.refreshTimeout ||
      appearance != other.appearance ||
      execution != other.execution ||
      feedbackEnabled != other.feedbackEnabled;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TurnstileOptions &&
          !rendersDifferentlyFrom(other) &&
          borderRadius == other.borderRadius &&
          backgroundColor == other.backgroundColor &&
          curve == other.curve &&
          animationDuration == other.animationDuration;

  @override
  int get hashCode => Object.hash(
        size,
        theme,
        language,
        retryAutomatically,
        retryInterval,
        refreshExpired,
        refreshTimeout,
        appearance,
        execution,
        feedbackEnabled,
        borderRadius,
        backgroundColor,
        curve,
        animationDuration,
      );
}
