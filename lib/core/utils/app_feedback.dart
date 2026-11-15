import 'package:flutter/material.dart';

class AppFeedback {
  static void showSuccess(BuildContext context, String message) {
    _showFloatingSnackBar(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showFloatingSnackBar(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
    );
  }

  static void showError(BuildContext context, String message) {
    _showFloatingSnackBar(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showFloatingSnackBar(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
    );
  }

  static void _showFloatingSnackBar(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 4.0,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(icon, color: foregroundColor, size: 20.0),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
