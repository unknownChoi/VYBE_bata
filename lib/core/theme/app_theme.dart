import 'package:flutter/material.dart';
import 'package:vybe/design_system/colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: VybeColors.background,
        fontFamily: 'Pretendard',
        colorScheme: const ColorScheme.dark(
          primary: VybeColors.mainPurple500,
          secondary: VybeColors.mainLime500,
          surface: VybeColors.surface,
        ),
      );
}
