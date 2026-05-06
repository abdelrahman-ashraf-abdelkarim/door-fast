import 'package:flutter/material.dart';

class AppColors {
  static const screenBackground = Color(0xFFF5F6FA);
  static const cardBackground = Colors.white;
  static const lightSurface = Color(0xFFF1F2F5);
  static const customerIconPrimaryBackground = Color(0xffFFDCC4);
  static const customerIconPrimaryForeground = Color(0xff914c00);
  static const customerIconSecondaryBackground = Color(0xffd9fbf7);
  static const customerIconSecondaryForeground = Color(0xff016a63);
  static const accentOrange = Color(0xFFB56A00);
  static const primaryTeal = Colors.teal;
  static const successGreen = Colors.green;
  static const dangerRed = Colors.red;
  static const mapMarkerRed = Colors.red;
  static const pickupMarkerOrange = Colors.orange;
  static const textPrimary = Color(0xFF121212);
  static const textSecondary = Color(0xFF7A7A7A);
  static const buttonOrderCard = Color.fromARGB(255, 13, 155, 108);
  static const buttonOrderDialog = Color(0xff7066E0);
}

class AppConstants {
  static const List<({Color background, Color foreground})> marketPalette = [
    (background: Color(0xFFFFF3E0), foreground: Color(0xFFB56A00)),
    (background: Color(0xFFE8F5E9), foreground: Color(0xFF2E7D32)),
    (background: Color(0xFFE3F2FD), foreground: Color(0xFF1565C0)),
    (background: Color(0xFFFCE4EC), foreground: Color(0xFFC2185B)),
    (background: Color(0xFFF3E5F5), foreground: Color(0xFF7B1FA2)),
    (background: Color(0xFFE0F2F1), foreground: Color(0xFF00695C)),
  ];

  static const mapOverlayGradientColors = [
    Color(0x14000000),
    Color(0x59000000),
  ];

  static const acceptButtonGradientColors = [
    AppColors.accentOrange,
    AppColors.pickupMarkerOrange,
  ];

  static const rejectButtonGradientColors = [
    Color(0xFFD32F2F),
    Color(0xFFFF5252),
  ];

  static const String baseUrl = "http://192.168.1.9:8000/api/delivery";
}
