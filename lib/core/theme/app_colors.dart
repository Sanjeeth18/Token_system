import 'package:flutter/material.dart';

/// Central color palette for the PSG Mess Token application.
/// All UI colors should reference these constants for consistency.
abstract class AppColors {
  // ─── Brand Gradients ────────────────────────────────────────────────────────
  static const Color gradientStart = Color(0xFF0A0E1A); // Deep navy
  static const Color gradientEnd = Color(0xFF0D2240);   // Dark blue

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  static const LinearGradient backgroundGradient = brandGradient;

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF162544), Color(0xFF0F1A2E)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A6EFF), Color(0xFF0050CC)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C853), Color(0xFF009624)],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
  );

  // ─── Accent ─────────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFF1A6EFF);       // Electric blue
  static const Color accentLight = Color(0xFF5B9BFF);
  static const Color accentDark = Color(0xFF0050CC);

  // ─── Surface / Background ───────────────────────────────────────────────────
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF111827);        // Card surface
  static const Color surfaceElevated = Color(0xFF1C2537); // Elevated cards
  static const Color surfaceBorder = Color(0xFF1E2D45);
  static const Color cardBorder = surfaceBorder;

  // ─── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFEEF2FF);
  static const Color textSecondary = Color(0xFF8A9DC0);
  static const Color textMuted = Color(0xFF4A5568);
  static const Color textOnAccent = Colors.white;

  // ─── Status ─────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF00C853);
  static const Color successSurface = Color(0xFF0D2A1A);
  static const Color warning = Color(0xFFFFAB00);
  static const Color warningSurface = Color(0xFF2A1E00);
  static const Color error = Color(0xFFE53935);
  static const Color errorSurface = Color(0xFF2A0A0A);
  static const Color info = Color(0xFF1A6EFF);
  static const Color infoSurface = Color(0xFF0A1A40);

  // ─── Token Type Colors ───────────────────────────────────────────────────────
  static const Color vegGreen = Color(0xFF00C853);
  static const Color vegSurface = Color(0xFF0D2A1A);
  static const Color nonVegRed = Color(0xFFE53935);
  static const Color nonVegSurface = Color(0xFF2A0A0A);
  static const Color eggYellow = Color(0xFFFFD600);
  static const Color eggOrange = Color(0xFFFF9100);
  static const Color eggSurface = Color(0xFF2A2200);

  // ─── Role Badge Colors ───────────────────────────────────────────────────────
  static const Color adminColor = Color(0xFFAA00FF);   // Purple
  static const Color managerColor = Color(0xFF1A6EFF); // Blue
  static const Color employeeColor = Color(0xFF00BCD4); // Cyan
  static const Color studentColor = Color(0xFF00C853); // Green

  static const Color adminBadge = adminColor;
  static const Color managerBadge = managerColor;
  static const Color employeeBadge = employeeColor;
  static const Color studentBadge = studentColor;

  // ─── Divider / Border ────────────────────────────────────────────────────────
  static const Color divider = Color(0xFF1E2D45);
  static const Color inputBorder = Color(0xFF1E3A5F);
  static const Color inputFocusBorder = Color(0xFF1A6EFF);

  // ─── Glass Effect ────────────────────────────────────────────────────────────
  static const Color glassSurface = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
}
