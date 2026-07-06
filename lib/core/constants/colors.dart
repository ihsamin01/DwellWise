import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core brand colors
  static const Color primary = Color(0xff005C55);
  static const Color secondary = Color(0xffFEA619);
  static const Color success = Color(0xff10B981);
  static const Color background = Color(0xffF9F9FF);

  // Surface elevation containers
  static const Color lowest = Color(0xffFFFFFF);
  static const Color low = Color(0xffF0F3FF);
  static const Color high = Color(0xffDEE8FF);
  static const Color highest = Color(0xffD8E3FB);

  // Text colors
  static const Color textPrimary = Color(0xff1A202C);
  static const Color textSecondary = Color(0xff718096);
  static const Color textLight = Color(0xffA0AEC0);
  
  // Custom glassmorphic tints
  static Color glassBackground = Colors.white.withOpacity(0.15);
  static Color glassBorder = Colors.white.withOpacity(0.3);
}
