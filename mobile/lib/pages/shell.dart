import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/events/share_redirect.dart';
import '../components/events/unauth_redirect.dart';
import '../components/reselect.dart';
import '../i18n/strings.g.dart';

class Shell extends StatelessWidget {
  const Shell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final notifier = ReselectNotifier();

    return ReselectScope(
      notifier: notifier,
      child: UnauthRedirect(
        child: ShareRedirect(
          child: Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.inbox),
                  label: t.nav.unread,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.search),
                  label: t.nav.search,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings),
                  label: t.nav.settings,
                ),
              ],
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (int tappedIndex) {
                if (tappedIndex == navigationShell.currentIndex) {
                  notifier.notifyReselect();
                } else {
                  navigationShell.goBranch(tappedIndex);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
