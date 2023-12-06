import 'package:at_at_mobile/pages/bluetooth_page.dart';
import 'package:at_at_mobile/pages/home_page.dart';
import 'package:at_at_mobile/pages/settings_page.dart';
import 'package:at_at_mobile/scaffold_with_navbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
        return ScaffoldWithNavbar(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: 'AT-AT controller',
              path: '/',
              builder: (context, state) => const MyHomePage(title: 'AT-AT Controller App'),
            ),
          ]
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              name: 'Bluetooth settings',
              path: '/bluetooth',
              builder: (context, state) => const BluetoothPage(title: 'Bluetooth settings'),
            ),
          ]
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              name: 'Settings',
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ]
        ),
      ],
    )
  ]
);