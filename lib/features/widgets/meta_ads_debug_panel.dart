import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/meta_analytics_service.dart';

/// Debug-only panel for verifying the Meta (Facebook) App Events integration
/// without having to complete a real signup or login.
///
/// Renders **nothing in release builds** — the whole widget short-circuits to
/// an empty box when [kDebugMode] is false, so it is safe to leave wired into
/// a production screen.
///
/// The status block is the important half: it reads the App ID back out of the
/// native SDK, so it tells you what the manifest/plist actually resolved to
/// rather than what you believe they contain. If `ready` is false or `appId`
/// still shows the placeholder, no event from this app will ever reach Meta.
///
/// Every button flushes immediately (see [MetaAnalytics.flush]) so events show
/// up in Events Manager in seconds instead of on the SDK's own batch timer.
class MetaAdsDebugPanel extends StatefulWidget {
  const MetaAdsDebugPanel({super.key});

  @override
  State<MetaAdsDebugPanel> createState() => _MetaAdsDebugPanelState();
}

class _MetaAdsDebugPanelState extends State<MetaAdsDebugPanel> {
  Map<String, String> _status = const {};
  String _lastAction = '';

  @override
  void initState() {
    super.initState();
    if (kDebugMode) _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    final status = await MetaAnalytics.instance.debugStatus();
    if (!mounted) return;
    setState(() => _status = status);
  }

  /// Runs [action], then flushes and reports it in the panel. Flushing after
  /// every button press is what makes the event appear in Events Manager
  /// straight away instead of waiting on the SDK batch timer.
  Future<void> _run(String label, Future<void> Function() action) async {
    await action();
    await MetaAnalytics.instance.flush();
    if (!mounted) return;
    setState(() => _lastAction = 'Sent: $label');
    await _refreshStatus();
  }

  @override
  Widget build(BuildContext context) {
    // Compiled out of release builds — kDebugMode is a const, so the tree
    // walker below is tree-shaken away entirely.
    if (!kDebugMode) return const SizedBox.shrink();

    final meta = MetaAnalytics.instance;
    final isReady = _status['ready'] == 'true';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade700),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isReady ? Icons.check_circle : Icons.error_outline,
                size: 18,
                color: isReady ? Colors.green.shade700 : Colors.red.shade700,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Meta Ads debug (debug builds only)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _refreshStatus,
              ),
            ],
          ),
          const SizedBox(height: 8),

          /// SDK state, read back from the native side. Long-press to copy —
          /// the anonymous ID is handy when asking Meta support why an event
          /// did not land.
          for (final entry in _status.entries)
            InkWell(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: entry.value));
                setState(() => _lastAction = 'Copied ${entry.key}');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                ),
              ),
            ),

          if (!isReady) ...[
            const SizedBox(height: 6),
            Text(
              'Not ready — check facebook_app_id in strings.xml (Android) '
              'and FacebookAppID in Info.plist (iOS).',
              style: TextStyle(fontSize: 11, color: Colors.red.shade900),
            ),
          ],

          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _DebugButton(
                label: 'Test event',
                onTap: () => _run('kathoram_test_event', meta.logTestEvent),
              ),
              _DebugButton(
                label: 'Registration',
                onTap: () => _run(
                  'fb_mobile_complete_registration',
                  () => meta.logRegistration(method: 'debug'),
                ),
              ),
              _DebugButton(
                label: 'Login',
                onTap: () => _run(
                  'Login',
                  () => meta.logLogin(method: 'debug'),
                ),
              ),
              _DebugButton(
                // App Open is auto-logged by the SDK in normal use; this
                // button forces one so you can watch it arrive on demand.
                label: 'App Open',
                onTap: () => _run('fb_mobile_activate_app', meta.logAppOpen),
              ),
            ],
          ),

          if (_lastAction.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _lastAction,
              style: TextStyle(fontSize: 11, color: Colors.green.shade900),
            ),
          ],
        ],
      ),
    );
  }
}

class _DebugButton extends StatelessWidget {
  const _DebugButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 11),
      ),
      child: Text(label),
    );
  }
}
