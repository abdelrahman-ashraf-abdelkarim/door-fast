import 'package:captain_app/views/home_shell.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void openOrdersScreen() {
  final navigatorState = navigatorKey.currentState;

  if (navigatorState == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) => openOrdersScreen());
    return;
  }

  navigatorState.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const HomeShell(initialIndex: 1)),
    (route) => false,
  );
}
