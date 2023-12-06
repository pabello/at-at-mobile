import 'dart:developer';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavbar extends StatelessWidget {
  const ScaffoldWithNavbar({
    required this.navigationShell,
    super.key
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(navigationShell.route.branches[navigationShell.currentIndex].defaultRoute?.name ?? ""),
      ),
      body: navigationShell,
      bottomNavigationBar: CurvedNavigationBar(
        height: 55,
        color: Theme.of(context).colorScheme.inversePrimary,
        backgroundColor: Theme.of(context).colorScheme.background,
        animationDuration: const Duration(milliseconds: 450),
        items: const [
          Icon(Icons.home),
          Icon(Icons.bluetooth),
          Icon(Icons.settings),
        ],
        onTap: (int index) {
          log("Routing to: ${navigationShell.route.branches[index].defaultRoute?.path}");
          navigationShell.goBranch(index);
        },
      ),
    );
  }
}
