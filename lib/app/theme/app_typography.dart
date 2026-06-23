import 'package:flutter/material.dart';

/// Typography tokens — serif display (Fraunces) + sans body/UI (Inter).
/// Scale per blueprint §3.3. Color is left null so it inherits from the theme.
class AppTypography {
  AppTypography._();

  static const _display = 'Fraunces';
  static const _ui = 'Inter';

  // Named brand styles (use directly in widgets).
  static const titleXL = TextStyle(
    fontFamily: _display,
    fontSize: 34,
    fontWeight: FontWeight.w600,
    height: 1.1,
  );

  static const titleL = TextStyle(
    fontFamily: _display,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    height: 1.15,
  );

  /// Small uppercase eyebrow label, e.g. "NE ZAMAN" / "WHEN".
  static const labelCaps = TextStyle(
    fontFamily: _ui,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
  );

  static const bodyL = TextStyle(
    fontFamily: _ui,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const bodyM = TextStyle(
    fontFamily: _ui,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  static const caption = TextStyle(
    fontFamily: _ui,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  /// Material TextTheme mapping, tinted [text] for body / [muted] for support.
  static TextTheme textTheme({required Color text, required Color muted}) {
    return TextTheme(
      displayLarge: titleXL.copyWith(color: text),
      displayMedium: titleL.copyWith(color: text),
      headlineMedium: titleL.copyWith(color: text),
      titleLarge: titleL.copyWith(color: text),
      labelSmall: labelCaps.copyWith(color: muted),
      bodyLarge: bodyL.copyWith(color: text),
      bodyMedium: bodyM.copyWith(color: text),
      bodySmall: caption.copyWith(color: muted),
    );
  }
}
