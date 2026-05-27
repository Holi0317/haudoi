import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../i18n/strings.g.dart';
import '../../providers/api/auth.dart';

class UnauthRedirect extends ConsumerWidget {
  const UnauthRedirect({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (previous, next) {
      if (next == AuthStateEnum.unauthenticated ||
          next == AuthStateEnum.notConfig) {
        context.go("/login");
      }

      if (previous != AuthStateEnum.networkErr &&
          next == AuthStateEnum.networkErr) {
        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.unauthRedirect.networkErr),
            action: SnackBarAction(
              label: t.unauthRedirect.logout,
              onPressed: () => ref.read(authProvider.notifier).logout(context),
            ),
          ),
        );
      }
    });

    return switch (authState) {
      AuthStateEnum.authenticated ||
      AuthStateEnum
          .networkErr => // Show child even in network error, so user can retry.
      child ?? const SizedBox.shrink(),
      AuthStateEnum.loading ||
      AuthStateEnum.unauthenticated ||
      AuthStateEnum.notConfig => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    };
  }
}
