import 'package:flutter/material.dart';
import 'package:vybe/design_system/colors.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: VybeColors.background,
      body: Center(
        child: Text(
          'This is my page screen',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
