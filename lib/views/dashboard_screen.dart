import 'package:captain_app/core/constants.dart';
import 'package:captain_app/core/format_arabic_date_for_dashboard.dart';
import 'package:captain_app/core/time_now.dart';
import 'package:captain_app/cubits/auth_cubit/auth_cubit.dart';
import 'package:captain_app/cubits/auth_cubit/auth_state.dart';
import 'package:captain_app/cubits/dashboard_cubit/dashboard_cubit.dart';
import 'package:captain_app/cubits/dashboard_cubit/dashboard_state.dart';
import 'package:captain_app/cubits/shift_cubit/shift_cubit.dart';
import 'package:captain_app/cubits/shift_cubit/shift_state.dart';
import 'package:captain_app/models/auth_model.dart';
import 'package:captain_app/models/dashboard_model.dart';
import 'package:captain_app/views/login_screen.dart';
import 'package:captain_app/widgets/app_bar.dart';
import 'package:captain_app/widgets/stat_card.dart';
import 'package:captain_app/widgets/work_time_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShiftCubit, ShiftState>(
      builder: (context, shiftState) {
        final isOnline = shiftState.user?.status == CaptainStatus.active;
        // ✅ نجيب الـ role من الـ AuthCubit
        final authState = context.read<AuthCubit>().state;
        final role = authState is AuthAuthenticated
            ? authState.user.role
            : DeliveryType.delivery;

        return Scaffold(
          appBar: AppBar(
            title: AppBarWidget(
              isOnline: isOnline,
              userName: shiftState.user?.name ?? 'كابتن',
              role: role,
            ),
            titleSpacing: 7,
            scrolledUnderElevation: 0,
            backgroundColor: AppColors.screenBackground,
            leading: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
                const VerticalDivider(
                  thickness: 1,
                  width: 1,
                  indent: 12,
                  endIndent: 12,
                ),
              ],
            ),
            // leadingWidth: 45,
          ),
          body: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, dashState) {
              if (!isOnline) return const _OfflineMessage();

              if (dashState.isLoading && dashState.data == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (dashState.data == null) {
                return const Center(child: Text('تعذر تحميل البيانات'));
              }

              return _DashboardContent(data: dashState.data!);
            },
          ),
        );
      },
    );
  }
}

// ─── Offline ──────────────────────────────────────────────────

class _OfflineMessage extends StatelessWidget {
  const _OfflineMessage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'انت غير نشط حاليا',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xffbe2c2d),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Content ──────────────────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'احصائياتي اليوم',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'أداءك ليوم ${formatArabicDateDashboard(DateTime.now())}',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DeliveryEarningsCard(feesToday: data.feesToday),
          const SizedBox(height: 20),
          _StatsGrid(data: data),
          const SizedBox(height: 20),
          _CancelledOrdersCard(cancelledCount: data.cancelledToday),
        ],
      ),
    );
  }
}

// ─── Earnings Card ────────────────────────────────────────────

class _DeliveryEarningsCard extends StatelessWidget {
  const _DeliveryEarningsCard({required this.feesToday});

  final double feesToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white70,
        border: Border(bottom: BorderSide(width: 4, color: Colors.teal)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            'خدمة التوصيل',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  ' ${feesToday.toStringAsFixed(0)} ',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
              Text('ج', style: TextStyle(fontSize: 22, color: Colors.teal)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Stats Grid ───────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        const StatCard(
          title: 'بداية الوردية',
          valueWidget: StartShiftTimeWidget(),
          color: Colors.black,
          icon: Icons.access_time,
        ),
        const StatCard(
          title: 'مدة العمل',
          valueWidget: WorkTimerWidget(),
          color: Colors.black,
          icon: Icons.timer_outlined,
        ),
        StatCard(
          title: 'طلبات مكتمله',
          value: data.deliveredToday.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        StatCard(
          title: 'طلبات مقبولة',
          value: data.activeOrders.toString(),
          icon: Icons.add_circle,
          color: Colors.blue,
        ),
        StatCard(
          title: ' التحصيل اليومى',
          value: '${data.feesToday.toStringAsFixed(0)} ج',
          icon: Icons.monetization_on_outlined,
          color: Colors.orange,
        ),
        const StatCard(
          title: 'إجمالي الخصومات',
          value: '0 ج', // مش موجود في الـ API حالياً
          icon: Icons.money_off,
          color: Colors.red,
        ),
        StatCard(
          title: 'الشريحة المحققة',
          value: data.currentTier != 0
              ? 'الشريحة ${data.currentTier}'
              : '__ لا يوجد',
          color: Colors.deepPurpleAccent,
        ),
        StatCard(
          title: 'إجمالي الأرباح',
          value: '${data.profitToday.toStringAsFixed(0)} ج',
          color: Colors.deepPurpleAccent,
        ),
      ],
    );
  }
}

// ─── Cancelled Card ───────────────────────────────────────────

class _CancelledOrdersCard extends StatelessWidget {
  const _CancelledOrdersCard({required this.cancelledCount});

  final int cancelledCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.pink[50],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.red[100],
                child: const Icon(Icons.cancel, color: Color(0xffbe2c2d)),
              ),
              const SizedBox(width: 4),
              const Text(
                'طلبات ملغاة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            ' $cancelledCount ',
            style: const TextStyle(
              fontSize: 20,
              color: Color(0xffbe2c2d),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
