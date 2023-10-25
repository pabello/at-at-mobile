import 'package:at_at_mobile/navigation_bar.dart';
import 'package:flutter/material.dart';

class ScaffoldWithNavbar extends StatelessWidget {
  const ScaffoldWithNavbar({
    required this.child,
    super.key
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Test'),
      ),
      body: Center(
        child: child
      ),
      bottomNavigationBar: const MyNavigationBar(),
    );
  }
}