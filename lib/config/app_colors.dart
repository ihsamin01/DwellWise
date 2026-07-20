import 'package:flutter/material.dart';

/// Semantic neutral colors for the tenant screens (Home/Search/Saved/nav),
/// which paint with literal hex colors rather than [ThemeData] lookups.
/// Resolving through here — instead of hardcoding — is what makes those
/// screens respond to the Light/Dark/System theme setting.
///
/// Brand accents (CTA orange, success green, error red) stay constant across
/// brightness since they already contrast well on both light and dark
/// surfaces; only the neutral chrome and the blue "primary" accent swap.
class AppColors {
  final Color background;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color placeholder;
  final Color primary;
  final Color primaryTint;

  const AppColors._({
    required this.background,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.placeholder,
    required this.primary,
    required this.primaryTint,
  });

  static const _light = AppColors._(
    background: Color(0xffF3F4F6),
    surface: Colors.white,
    border: Color(0xffD1D5DB),
    textPrimary: Color(0xff1F2937),
    textSecondary: Color(0xff6B7280),
    placeholder: Color(0xffE5E7EB),
    primary: Color(0xff1E40AF),
    primaryTint: Color(0xffEFF6FF),
  );

  static const _dark = AppColors._(
    background: Color(0xff121212),
    surface: Color(0xff1E1E1E),
    border: Color(0xff374151),
    textPrimary: Color(0xffF3F4F6),
    textSecondary: Color(0xff9CA3AF),
    placeholder: Color(0xff2A2E36),
    primary: Color(0xff60A5FA),
    primaryTint: Color(0xff1E3A5F),
  );

  static AppColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? _dark : _light;
  }
}
