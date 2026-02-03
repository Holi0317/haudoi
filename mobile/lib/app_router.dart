import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/edit.dart';
import 'pages/login.dart';
import 'pages/search.dart';
import 'pages/settings.dart';
import 'pages/share_receive.dart';
import 'pages/shell.dart';
import 'pages/unread.dart';

final router = GoRouter(
  initialLocation: '/unread',
  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginPage();
      },
    ),
    GoRoute(
      path: '/edit',
      builder: (BuildContext context, GoRouterState state) {
        final id = state.uri.queryParameters['id'];
        if (id == null) {
          throw Exception('Missing id parameter for /edit route');
        }

        final parsedId = int.tryParse(id);
        if (parsedId == null) {
          throw Exception('Invalid id parameter for /edit route: $id');
        }

        return EditPage(id: parsedId);
      },
    ),
    GoRoute(
      path: '/share',
      builder: (BuildContext context, GoRouterState state) {
        final url = state.uri.queryParameters['url'];
        return ShareReceivePage(sharedUrl: url);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder:
          (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell navigationShell,
          ) {
            return Shell(navigationShell: navigationShell);
          },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/unread',
              builder: (BuildContext context, GoRouterState state) {
                return const UnreadPage();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (BuildContext context, GoRouterState state) {
                return const SearchPage();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (BuildContext context, GoRouterState state) {
                return const SettingsPage();
              },
            ),
          ],
        ),
      ],
    ),
  ],
  // TODO: Add error handling, for example:
  // errorBuilder: (context, state) => ErrorScreen(error: state.error!),
);
