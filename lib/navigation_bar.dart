import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyNavigationBar extends StatefulWidget {
  const MyNavigationBar({super.key});

  @override
  State<MyNavigationBar> createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      color: Theme.of(context).colorScheme.inversePrimary,
      backgroundColor: Theme.of(context).colorScheme.background,
      animationDuration: const Duration(milliseconds: 450),
      onTap: (index) {
        switch(index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/bluetooth');
            break;
          case 2:
            context.go('/settings');
            break;
        }
      },
      items: const [
        Icon(Icons.home),
        Icon(Icons.bluetooth),
        Icon(Icons.settings),
      ],
    );
  }
}