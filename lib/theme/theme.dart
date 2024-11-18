// lib/theme/theme.dart

import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF19A7D7); // Warna utama dari Figma
  static const Color secondaryColor = Color(0xFF148DC2); // Warna sekunder
  static const Color backgroundColor = Color(0xFF1597C9); // Warna latar belakang
  static const Color yellow1 = Color(0xFFFFC945);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTextStyle {
  static const TextStyle headline1 = TextStyle(
    fontFamily: 'Roboto', // Font yang dipilih di Figma
    fontWeight: FontWeight.bold,
    fontSize: 24,
    color: AppColors.primaryColor,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.normal,
    fontSize: 16,
    color: AppColors.primaryColor,
  );
}

class AppSpacing {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 32.0;
}

class AppBorders {
  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(12.0));
}
