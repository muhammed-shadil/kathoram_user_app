import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Centralised WhatsApp support helper.
///
/// Use [SupportHelper.openWhatsApp] anywhere you need to open a support chat,
/// or drop in the ready-made [SupportFab] floating action button for a
/// consistent look & feel across screens.
class SupportHelper {
  SupportHelper._();

  /// WhatsApp support number (with country code, no `+`).
  static const String supportNumber = '919061255179';

  /// Default message pre-filled in the WhatsApp chat.
  static const String defaultMessage = 'Hi, I need help with Kathoram app';

  /// Opens a WhatsApp chat with the support number, pre-filled with [message].
  static Future<void> openWhatsApp({String message = defaultMessage}) async {
    // Uri.https encodes the query for us so spaces/special chars are safe.
    final uri = Uri.https('wa.me', '/$supportNumber', {'text': message});
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Reusable circular "Chat with Support" floating action button that opens
/// WhatsApp support. Keeps the support entry point looking the same everywhere.
class SupportFab extends StatelessWidget {
  const SupportFab({
    super.key,
    this.message = SupportHelper.defaultMessage,
    this.backgroundColor = Colors.blue,
    this.iconColor = Colors.white,
    this.tooltip = 'Chat with Support',
    this.size = 35.0,
    this.mini = false,
  });

  /// Message pre-filled in the WhatsApp chat.
  final String message;

  /// Background colour of the button.
  final Color backgroundColor;

  /// Colour of the support icon.
  final Color iconColor;

  /// Long-press tooltip.
  final String tooltip;

  /// Size of the button.
  final double size;
final bool mini;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: mini,
      shape: const CircleBorder(),
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      onPressed: () => SupportHelper.openWhatsApp(message: message),
      child: Icon(
        Icons.support_agent_outlined,
        color: iconColor,
        size: size,
      ),
    );
  }
}
