import 'dart:async';

import 'package:captain_app/cubits/auth_cubit/auth_cubit.dart';
import 'package:captain_app/cubits/auth_cubit/auth_state.dart';
import 'package:captain_app/cubits/dashboard_cubit/dashboard_cubit.dart';
import 'package:captain_app/cubits/order_cubit/order_cubit.dart';
import 'package:captain_app/cubits/shift_cubit/shift_cubit.dart';
import 'package:captain_app/cubits/shift_cubit/shift_state.dart';
import 'package:captain_app/models/auth_model.dart';
import 'package:captain_app/views/account_statement_screen.dart';
import 'package:captain_app/views/dashboard_screen.dart';
import 'package:captain_app/views/login_screen.dart';
import 'package:captain_app/views/my_order_screen.dart';
import 'package:captain_app/widgets/offline_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    DashboardScreen(),
    MyOrderScreen(),
    AccountStatementScreen(),
  ];

  StreamSubscription? _wsSubscription;
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    final token = authState.token;
    final captainId = authState.user.id;
    final role = authState.user.role;

    context.read<OrdersCubit>().loadOrders(token, captainId, role: role);
    context.read<DashboardCubit>().loadDashboard(token);
    final authCubit = context.read<AuthCubit>();

    _wsSubscription = context.read<OrdersCubit>().wsStream.listen((data) async {
      if (!mounted) return;
      final event = data['event'];
      // [FIX-04] removed duplicate shift_activated handler
      if (event == 'account_deactivated') {
        _wsSubscription?.cancel();
        _wsSubscription = null;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) authCubit.logout();
        });
        return;
      }
    });
  }

  @override
  void dispose() {
    _wsSubscription?.cancel(); // ✅ cancel عند الإغلاق
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: BlocBuilder<ShiftCubit, ShiftState>(
        builder: (context, shiftState) {
          final isOnline = shiftState.user?.status == CaptainStatus.active;

          // ← لو مش نشط، اعرض رسالة في كل الصفحات
          if (!isOnline) {
            return const Scaffold(
              body: SafeArea(child: OfflineMessageWidget()),
            );
          }

          return Scaffold(
            body: IndexedStack(index: _currentIndex, children: _screens),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Material(
                elevation: 12,
                color: Colors.white,
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  selectedItemColor: Colors.deepOrangeAccent,
                  unselectedItemColor: Colors.grey,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
                  onTap: (index) => setState(() => _currentIndex = index),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard_outlined),
                      activeIcon: Icon(Icons.dashboard),
                      label: 'الرئيسية',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.receipt_long_outlined),
                      activeIcon: Icon(Icons.receipt_long),
                      label: 'الطلبات',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.account_balance_wallet_outlined),
                      activeIcon: Icon(Icons.account_balance_wallet),
                      label: 'كشف حسابى',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
