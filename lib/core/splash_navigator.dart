// lib/core/splash_navigator.dart
//
// منطق قرار الـ navigation بعد الـ splash screen — مفصول عن الـ UI.
// السبب: الـ SplashScreen كانت بتقرأ AuthCubit وShiftCubit وتاخد قرار
// الـ navigation جوه الـ widget — ده business logic مش UI.
//
// الاستخدام:
//   final destination = SplashNavigator.resolve(authState, shiftState);
//   if (destination != null) Navigator.pushReplacement(...);

import 'package:captain_app/cubits/auth_cubit/auth_state.dart';
import 'package:captain_app/cubits/shift_cubit/shift_state.dart';
import 'package:captain_app/views/home_shell.dart';
import 'package:captain_app/views/login_screen.dart';
import 'package:flutter/widgets.dart';

abstract class SplashNavigator {
  /// يحدد الـ destination المناسبة بعد الـ splash.
  ///
  /// بيرجع:
  /// - `HomeShell`  — لو المستخدم authenticated والـ shift data جاهزة
  /// - `LoginScreen` — لو المستخدم مش authenticated
  /// - `null`        — لو لسه محتاجين ننتظر (مثلاً shift data لسه مش جاهزة)
  static Widget? resolve(AuthState authState, ShiftState shiftState) {
    if (authState is! AuthAuthenticated) return const LoginScreen();
    if (shiftState.user == null) return null; // انتظر ShiftCubit
    return const HomeShell();
  }
}
  