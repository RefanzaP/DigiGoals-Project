// lib/theme/theme.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF19A7D7); // Warna utama dari Figma
  static const Color secondaryColor = Color(0xFF148DC2); // Warna sekunder
  static const Color backgroundColor = Color(0xFF1597C9); // Warna latar belakang
  static const Color yellow1 = Color(0xFFFFC945);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textColor1 = Color(0xFF1F597F);
}

class AppTextStyle {
  static const TextStyle headline1 = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.bold,
    fontSize: 32,
    color: AppColors.textColor1,
  );
    static const TextStyle headline2 = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.bold,
    fontSize: 24,
    color: AppColors.textColor1,
  );
  
  static const TextStyle LargebodyText1 = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.normal,
    fontSize: 32,
    color: AppColors.textColor1,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.normal,
    fontSize: 16,
    color: AppColors.textColor1,
  );

    static const TextStyle bodyText2 = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.normal,
    fontSize: 14,
    color: AppColors.textColor1,
  );

     static const TextStyle bodyText3 = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.normal,
    fontSize: 12,
    color: AppColors.textColor1,
  );

      static const TextStyle bodyMText1 = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w600,
    fontSize: 20,
    color: Colors.black,
  );

      static const TextStyle bodyMText2 = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: Colors.black,
  );
      static const TextStyle bodyMText3 = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w600,
    fontSize: 12,
    color: Colors.black,
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
