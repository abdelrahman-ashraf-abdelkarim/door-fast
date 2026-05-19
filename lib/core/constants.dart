import 'package:captain_app/models/auth_model.dart';
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
  static const successGreen = Color(0xFF22C55E);
  static const dangerRed = Colors.red;
  static const mapMarkerRed = Colors.red;
  static const pickupMarkerOrange = Colors.orange;
  static const textPrimary = Color(0xFF121212);
  static const textSecondary = Color(0xFF7A7A7A);
  static const orderCardGreen = Color.fromARGB(255, 13, 155, 108);
  static const buttonOrderCard = orderCardGreen;
  static const buttonOrderDialog = Color(0xff7066E0);
  static const dangerRed2 = Color(0xffbe2c2d);
  static const loginAccent = Color(0xffBA282E);
  static const successLight = Color(0xffECFDF5);
  static const successText = Color(0xff10B981);
  static const infoLight = Color(0xffBAE6FD);
  static const infoText = Color(0xff0369A1);
  static const loginBackground = Color(0xFFF7F7F7);
  static const loginHeaderBackground = Color(0xffF9C724);
  static const roleSelectorBackground = Color(0xFFEEEEEE);
  static const appScaffoldBackground = Color(0xffF5F5F5);
  static const splashBackground = Color(0xfff8c624);
  static const senderIconBackground = Color(0xFFE3F2FD);
  static const senderIconForeground = Color(0xFF1565C0);
  static const receiverIconBackground = Color(0xFFFFF3E0);
  static const notesBorder = Color.fromARGB(255, 185, 16, 16);
  static const notesBackground = Color.fromARGB(255, 253, 236, 236);
  static const balanceGradientStart = Color(0xFFB85C00);
  static const balanceGradientEnd = Color(0xFFFF8C00);
  static const filterFieldBackground = Color(0xFFEAEAEA);
  static const realtimeBadgeBackground = Color.fromARGB(99, 112, 102, 224);
  static const whatsAppGreen = Color(0xff25D366);
  static const whatsAppDarkGreen = Color(0xff128C7E);
  static const mapButtonOrange = Color(0xFFFF9800);
}

class AppConstants {
  static const String roleBackup = 'إحتياطي';
  static const String rolePrimary = 'أساسي';

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

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );
  static const String deliveryBaseUrl = "$baseUrl/delivery";
  static const String reserveBaseUrl = "$baseUrl/reserve";

  static String getBaseUrl(DeliveryType role) {
    return role == DeliveryType.reserve ? reserveBaseUrl : deliveryBaseUrl;
  }

  static String invoiceUrl(String orderId, DeliveryType role) =>
      "${getBaseUrl(role)}/orders/$orderId/invoice";

  static const String reverbAppKey = String.fromEnvironment(
    'REVERB_KEY',
    defaultValue: '',
  );
  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'ws://localhost:8000',
  );
  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: reverbAppKey,
  );
  static const String reverbHost = String.fromEnvironment(
    'REVERB_HOST',
    defaultValue: 'localhost',
  );
  static const int reverbPort = int.fromEnvironment(
    'REVERB_PORT',
    defaultValue: 8000,
  );
  static const String cluster = String.fromEnvironment(
    'PUSHER_CLUSTER',
    defaultValue: 'mt1',
  );
  static const int pdfCacheValidityMinutes = 30;
}
