import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Standard "exit app?" confirmation dialog. Returns true if the user chose to
/// exit. Yes is the prominent blue button (exits); Cancel is a plain text
/// button that keeps you in the app.
Future<bool> showExitConfirmationDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Exit app'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xff1877F2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

/// Wraps [child] so pressing the system back button on a top-level screen
/// (where it would otherwise close the app) asks for confirmation first.
class ExitConfirmationScope extends StatelessWidget {
  const ExitConfirmationScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await showExitConfirmationDialog(context);
        if (shouldExit) {
          await SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}
