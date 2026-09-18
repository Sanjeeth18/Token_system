import 'package:flutter/material.dart';

/// Central color palette for the PSG Mess Token application.
/// Redesigned with vibrant Red, Emerald Green, Warm Gold/Yellow, Crisp White,
/// and deep midnight slate background tones for maximum visual appeal.
abstract class AppColors {
  // Brand Gradients
  static const Color gradientStart = Color(0xFF0B0F19); // Midnight slate
  static const Color gradientEnd = Color(0xFF0F172A);   // Deep slate

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  static const LinearGradient backgroundGradient = brandGradient;

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF111827)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE11D48), Color(0xFFBE123C)], // Crimson Ruby Red
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF047857)], // Emerald Green
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFB91C1C)], // Crimson Red
  );

  static const LinearGradient eggGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)], // Amber Gold / Yellow
  );

  static const LinearGradient adminGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA855F7), Color(0xFF7E22CE)], // Amethyst Purple
  );

  // Primary Accent
  static const Color accent = Color(0xFFE11D48);       // Crimson Ruby Red
  static const Color accentLight = Color(0xFFF43F5E);  // Bright Rose
  static const Color accentDark = Color(0xFFBE123C);   // Deep Rose

  // Surface / Background
  static const Color background = Color(0xFF0B0F19);
  static const Color surface = Color(0xFF161F30);        // Card surface
  static const Color surfaceElevated = Color(0xFF1F2C42); // Elevated cards
  static const Color surfaceBorder = Color(0xFF2A3A54);
  static const Color cardBorder = surfaceBorder;

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);    // Crisp Pure White
  static const Color textSecondary = Color(0xFF94A3B8);  // Slate Silver
  static const Color textMuted = Color(0xFF64748B);      // Cool Muted Slate
  static const Color textOnAccent = Colors.white;

  // Status
  static const Color success = Color(0xFF10B981);         // Emerald Green
  static const Color successSurface = Color(0xFF022C22);
  static const Color warning = Color(0xFFF59E0B);         // Amber Yellow
  static const Color warningSurface = Color(0xFF451A03);
  static const Color error = Color(0xFFEF4444);           // Crimson Red
  static const Color errorSurface = Color(0xFF450A0A);
  static const Color info = Color(0xFF38BDF8);            // Electric Cyan
  static const Color infoSurface = Color(0xFF0C4A6E);

  // Token Type Colors
  static const Color vegGreen = Color(0xFF10B981);       // Emerald Green
  static const Color vegSurface = Color(0xFF064E3B);
  static const Color nonVegRed = Color(0xFFEF4444);       // Crimson Red
  static const Color nonVegSurface = Color(0xFF7F1D1D);
  static const Color eggYellow = Color(0xFFF59E0B);      // Amber Gold Yellow
  static const Color eggOrange = Color(0xFFF59E0B);      // Amber Gold Yellow
  static const Color eggSurface = Color(0xFF78350F);

  // Role Badge Colors
  static const Color adminColor = Color(0xFFC084FC);   // Amethyst Light Purple
  static const Color managerColor = Color(0xFF38BDF8); // Cyan Light Blue
  static const Color employeeColor = Color(0xFFFB923C); // Warm Orange Amber
  static const Color studentColor = Color(0xFF34D399); // Mint Emerald Green

  static const Color adminBadge = adminColor;
  static const Color managerBadge = managerColor;
  static const Color employeeBadge = employeeColor;
  static const Color studentBadge = studentColor;

  // Divider / Border
  static const Color divider = Color(0xFF2A3A54);
  static const Color inputBorder = Color(0xFF2A3A54);
  static const Color inputFocusBorder = Color(0xFFE11D48);

  // Glass Effect
  static const Color glassSurface = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
}
