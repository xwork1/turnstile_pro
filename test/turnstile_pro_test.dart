import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnstile_pro/src/turnstile_html.dart';
import 'package:turnstile_pro/turnstile_pro.dart';

void main() {
  group('TurnstileOptions', () {
    test('equality and hashCode', () {
      const TurnstileOptions a = TurnstileOptions(language: 'tr');
      final TurnstileOptions b = const TurnstileOptions().copyWith(
        language: 'tr',
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == a.copyWith(theme: TurnstileTheme.dark), isFalse);
    });

    test('rendersDifferentlyFrom ignores purely visual fields', () {
      const TurnstileOptions a = TurnstileOptions();
      expect(
        a.rendersDifferentlyFrom(
          a.copyWith(
            borderRadius: BorderRadius.circular(8),
            animationDuration: Duration.zero,
          ),
        ),
        isFalse,
      );
      expect(
        a.rendersDifferentlyFrom(
          a.copyWith(execution: TurnstileExecution.execute),
        ),
        isTrue,
      );
      expect(
        a.rendersDifferentlyFrom(a.copyWith(feedbackEnabled: false)),
        isTrue,
      );
    });

    test('defaults', () {
      const TurnstileOptions o = TurnstileOptions();
      expect(o.size, TurnstileSize.flexible);
      expect(o.execution, TurnstileExecution.render);
      expect(o.feedbackEnabled, isTrue);
    });
  });

  group('TurnstileController', () {
    test('initial state', () {
      final TurnstileController c = TurnstileController();
      expect(c.token, isNull);
      expect(c.hasToken, isFalse);
      expect(c.isReady, isFalse);
      c.dispose();
    });

    test('methods are no-ops when detached', () async {
      final TurnstileController c = TurnstileController();
      await c.reset();
      await c.execute();
      await c.reload();
      c.dispose();
    });
  });

  test('enum values map to Cloudflare options', () {
    expect(TurnstileExecution.execute.value, 'execute');
    expect(TurnstileAppearance.interactionOnly.value, 'interaction-only');
  });

  test('buildTurnstileHtml escapes embedded values', () {
    final String backslash = String.fromCharCode(92);
    final String newline = String.fromCharCode(10);
    final String evil =
        "O'Brien \"x\" $backslash$newline</script><script>pwn()</script>";
    final String html = buildTurnstileHtml(
      siteKey: 'key',
      options: const TurnstileOptions(),
      cData: evil,
    );
    // Only the page's own three inline/external script tags are closed.
    expect('</script>'.allMatches(html).length, 3);
    expect(html.contains('pwn()</script>'), isFalse);
    expect(html.contains('${backslash}u003c/script${backslash}u003e'), isTrue);
    expect(html.contains('sitekey: "key"'), isTrue);
    expect(html.contains('action: undefined'), isTrue);
  });
}
