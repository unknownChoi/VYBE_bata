import 'package:flutter/material.dart';
import 'package:vybe/design_system/colors.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: VybeColors.background,
      body: Center(
        child: Text(
          'This is search screen',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
