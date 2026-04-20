import 'package:flutter/material.dart';
import 'package:vybe/design_system/colors.dart';

class PassWalletScreen extends StatelessWidget {
  const PassWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: VybeColors.background,
      body: Center(
        child: Text(
          'This is pass wallet screen',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
