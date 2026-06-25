import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/offline_mode_service.dart';
import 'offline_dashboard_screen.dart';

/// Reference: "Internet Connected" — either way go to offline dashboard after OK.
/// [context] must be a valid navigator context (e.g. [NavigatorState.context]),
/// not a [Drawer] subtree context that was disposed after closing the drawer.
Future<void> showSwitchToOfflineDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Internet Connected'),
      content: const Text(
        'You are connected to internet. You can turn off internet connection in OFFLINE MODE.',
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.pop(ctx);
            await OfflineModeService.instance.setOfflineMode(true);
            if (!context.mounted) return;
            // Next frame so the route stack is stable after the dialog pops.
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const OfflineDashboardScreen(),
                ),
                (_) => false,
              );
            });
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Future<void> showNoBluetoothPrinterDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: const Text('No devices found ,Connect to device'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('YES', style: TextStyle(color: AppColors.primary)),
        ),
      ],
    ),
  );
}
