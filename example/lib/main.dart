import 'package:flutter/material.dart';
import 'package:turnstile_pro/turnstile_pro.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'turnstile_pro example',
      home: TurnstileDemoPage(),
    );
  }
}

class TurnstileDemoPage extends StatefulWidget {
  const TurnstileDemoPage({super.key});

  @override
  State<TurnstileDemoPage> createState() => _TurnstileDemoPageState();
}

class _TurnstileDemoPageState extends State<TurnstileDemoPage> {
  final TurnstileController _controller = TurnstileController();
  String _status = 'Waiting for token…';

  // Cloudflare test site key (always passes). Replace with your own.
  static const String _testSiteKey = '1x00000000000000000000AA';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('turnstile_pro')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TurnstilePro(
              siteKey: _testSiteKey,
              controller: _controller,
              options: const TurnstileOptions(
                size: TurnstileSize.flexible,
                theme: TurnstileTheme.auto,
                language: 'en',
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              loadingWidget: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              onWidgetReady: () => setState(() => _status = 'Widget ready'),
              onTokenReceived: (token) =>
                  setState(() => _status = 'Token: $token'),
              onError: (error) => setState(() => _status = 'Error: $error'),
            ),
            const SizedBox(height: 24),
            Text(_status, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _controller.reset(),
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
