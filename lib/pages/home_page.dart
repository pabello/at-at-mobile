import 'package:at_at_mobile/directions_button.dart';
import 'package:flutter/material.dart';


class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SteeringButtons()
    );
  }
}