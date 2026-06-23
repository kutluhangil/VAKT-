import 'package:flutter/material.dart';

/// Vakti brand palette — editorial "golden hour" identity.
/// Dark ink ground, warm paper, a single saffron accent. No generic gradients.
class AppColors {
  AppColors._();

  // Brand
  static const ink = Color(0xFF14181F); // dark ground
  static const paper = Color(0xFFF7F3EC); // warm paper (light ground)
  static const saffron = Color(0xFFE0A24B); // accent — golden hour
  static const saffronDeep = Color(0xFFC07F2E);

  // Light theme
  static const lightBg = paper;
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF1B1F27);
  static const lightMuted = Color(0xFF6B7280);
  static const lightBorder = Color(0xFFE6DFD3); // thin dividers

  // Dark theme
  static const darkBg = ink;
  static const darkSurface = Color(0xFF1C222B);
  static const darkText = Color(0xFFF2EFE9);
  static const darkMuted = Color(0xFF9BA3AF);
  static const darkBorder = Color(0xFF2A323D);

  // Category tints (subtle background accents)
  static const tintDigestion = Color(0xFF7FB069);
  static const tintImmunity = Color(0xFFE07A5F);
  static const tintSleep = Color(0xFF6C7BBF);
  static const tintEnergy = Color(0xFFE0A24B);
  static const tintSkin = Color(0xFFD98CA3);
  static const tintHydration = Color(0xFF5BA6C9);
  static const tintBoundaries = Color(0xFF8E7CC3);
  static const tintEmotions = Color(0xFFD98CA3);
  static const tintCoop = Color(0xFF7FB069);
  static const tintConfidence = Color(0xFFE0A24B);
  static const tintEarlyYears = Color(0xFF5BA6C9);
}
