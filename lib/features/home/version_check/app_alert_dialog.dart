import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Shared visual tokens so the version dialogs stay consistent with the rest
/// of the app (blue theme, pill buttons, tinted circular icon badge).
const _kBrandGradient = LinearGradient(
  colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const _kIconTint = Color(0xFFE7F0FF);

/// Dialog shown when a newer app version is available.
///
/// When [onCancel] is null the dialog is non-dismissible (force update):
/// back press is disabled and no "Later" button is shown.
class AppUpdateAlertDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final String title;
  final String description;
  final IconData icon;

  const AppUpdateAlertDialog({
    super.key,
    required this.onConfirm,
    this.onCancel,
    this.title = "Update Available",
    this.description =
        "A new version of the app is available. Update now for the latest features and improvements.",
    this.icon = Icons.system_update_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: onCancel != null, // force update => block back press
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _IconBadge(icon: icon),
            const SizedBox(height: 18),
            _DialogTitle(title),
            const SizedBox(height: 10),
            _DialogMessage(description),
            const SizedBox(height: 26),
            Row(
              children: [
                if (onCancel != null) ...[
                  Expanded(
                    child: _SecondaryButton(
                      text: "Later",
                      onTap: onCancel!,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: _PrimaryButton(
                    text: "Update Now",
                    icon: Icons.download_rounded,
                    onTap: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Non-dismissible dialog shown when the backend signals a maintenance break.
class AppMaintenanceDialog extends StatelessWidget {
  final String message;

  const AppMaintenanceDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _IconBadge(icon: Icons.build_rounded),
            const SizedBox(height: 18),
            const _DialogTitle("Under Maintenance"),
            const SizedBox(height: 10),
            _DialogMessage(
              message.trim().isNotEmpty
                  ? message
                  : "We're making things better. Please check back in a little while.",
            ),
            const SizedBox(height: 18),
            // Subtle reassurance row, in the app's blue accent.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _kIconTint,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.schedule_rounded,
                      size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    "Thanks for your patience",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── shared pieces ─────────────────────────

class _IconBadge extends StatelessWidget {
  final IconData icon;
  const _IconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: const BoxDecoration(
        color: _kIconTint,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            gradient: _kBrandGradient,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 28, color: Colors.white),
        ),
      ),
    );
  }
}

class _DialogTitle extends StatelessWidget {
  final String title;
  const _DialogTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

class _DialogMessage extends StatelessWidget {
  final String message;
  const _DialogMessage(this.message);

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13.5,
        height: 1.45,
        color: Colors.grey.shade600,
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  const _PrimaryButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: _kBrandGradient,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _SecondaryButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }
}
