import 'dart:async';
import 'package:captain_app/cubits/auth_cubit/auth_cubit.dart';
import 'package:captain_app/cubits/auth_cubit/auth_state.dart';
import 'package:captain_app/services/notification_service.dart';
import 'package:captain_app/views/home_shell.dart';
import 'package:captain_app/views/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _navTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      _navigateAfterSplash();
    });
  }

  void _navigateAfterSplash() {
    final authState = context.read<AuthCubit>().state;
    final destination = authState is AuthAuthenticated
        ? const HomeShell()
        : const LoginScreen();

    if (authState is AuthAuthenticated) {
      NotificationService.scheduleMockOrderNotifications();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8c624),
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Image.asset(
            'assets/images/logo-removebg-preview.png',
            width: 180,
          ),
        ),
      ),
    );
  }
}
