import 'package:flutter/material.dart';
import 'package:vybe/design_system/colors.dart';

class NearbyScreen extends StatelessWidget {
  const NearbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: VybeColors.background,
      body: Center(
        child: Text(
          'This is nearby screen',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
