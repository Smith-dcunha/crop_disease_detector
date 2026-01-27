import 'package:flutter/material.dart';

/// App Color Scheme - Agriculture/Nature Theme
class AppColors {
  // Primary Colors - Green Nature Theme
  static const Color primary = Color(0xFF2D6A4F);        // Deep Forest Green
  static const Color primaryLight = Color(0xFF40916C);   // Medium Green
  static const Color primaryDark = Color(0xFF1B4332);    // Dark Green

  // Secondary Colors - Earthy Tones
  static const Color secondary = Color(0xFF52B788);      // Bright Green
  static const Color secondaryLight = Color(0xFF74C69D); // Light Green
  static const Color accent = Color(0xFFD4A574);         // Warm Brown/Gold

  // Background Colors
  static const Color background = Color(0xFFF8F9FA);     // Light Gray
  static const Color surface = Color(0xFFFFFFFF);        // White
  static const Color cardBackground = Color(0xFFFFFFFF); // White

  // Text Colors
  static const Color textPrimary = Color(0xFF212529);    // Almost Black
  static const Color textSecondary = Color(0xFF6C757D);  // Gray
  static const Color textLight = Color(0xFFADB5BD);      // Light Gray
  static const Color textOnPrimary = Color(0xFFFFFFFF);  // White

  // Status Colors
  static const Color success = Color(0xFF52B788);        // Green
  static const Color warning = Color(0xFFFFB703);        // Yellow
  static const Color error = Color(0xFFE63946);          // Red
  static const Color info = Color(0xFF4895EF);           // Blue

  // Disease Severity Colors
  static const Color severityLow = Color(0xFF74C69D);    // Light Green
  static const Color severityMedium = Color(0xFFFFB703); // Yellow
  static const Color severityHigh = Color(0xFFF77F00);   // Orange
  static const Color severityCritical = Color(0xFFDC2F02); // Red

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF52B788), Color(0xFF74C69D)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
  );

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);    // 10% black
  static const Color shadowMedium = Color(0x33000000);   // 20% black

  // Border Colors
  static const Color border = Color(0xFFDEE2E6);
  static const Color borderLight = Color(0xFFE9ECEF);

  // Overlay Colors
  static const Color overlay = Color(0x80000000);        // 50% black
  static const Color overlayLight = Color(0x40000000);   // 25% black

  // Dark Mode Colors (for future implementation)
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color darkTextPrimary = Color(0xFFE9ECEF);
}