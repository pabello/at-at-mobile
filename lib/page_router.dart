import 'package:at_at_mobile/pages/bluetooth_page.dart';
import 'package:at_at_mobile/pages/home_page.dart';
import 'package:at_at_mobile/pages/settings_page.dart';
import 'package:at_at_mobile/scaffold_with_navbar.dart';
import 'package:go_router/go_router.dart';

GoRouter router = GoRouter(
  // initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavbar(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const MyHomePage(title: 'AT-AT Controller App'),
        ),
        GoRoute(
          path: '/bluetooth',
          builder: (context, state) => const BluetoothPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    )
  ]
);