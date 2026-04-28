import 'package:captain_app/views/account_statement_screen.dart';
import 'package:captain_app/views/dashboard_screen.dart';
import 'package:captain_app/views/my_order_screen.dart';
import 'package:captain_app/views/new_order_screen.dart';
import 'package:flutter/material.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    OrdersScreen(),
    MyOrderScreen(),
    AccountStatementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
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
                  icon: Icon(Icons.local_shipping_rounded),
                  activeIcon: Icon(Icons.local_shipping),
                  label: 'طلباتي',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  activeIcon: Icon(Icons.account_balance_wallet),
                  label: 'الأرباح',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
