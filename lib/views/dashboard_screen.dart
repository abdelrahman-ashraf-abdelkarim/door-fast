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
import 'package:captain_app/widgets/offline_message_widget.dart';
import 'package:captain_app/widgets/stat_card.dart';
import 'package:captain_app/widgets/work_time_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            titleSpacing: 7.w,
            scrolledUnderElevation: 0,
            backgroundColor: AppColors.screenBackground,
            leading: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
                VerticalDivider(
                  thickness: 1,
                  width: 1.w,
                  indent: 12.h,
                  endIndent: 12.h,
                ),
              ],
            ),
            // leadingWidth: 45,
          ),
          body: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, dashState) {
              if (!isOnline) return const OfflineMessageWidget();

              if (dashState.isLoading && dashState.data == null) {
                return Center(child: CircularProgressIndicator());
              }

              if (dashState.data == null) {
                return Center(child: Text('تعذر تحميل البيانات'));
              }

              return _DashboardContent(data: dashState.data!);
            },
          ),
        );
      },
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
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'احصائياتي اليوم',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'أداءك ليوم ${formatArabicDateDashboard(DateTime.now())}',
                    style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _DeliveryEarningsCard(feesToday: data.feesToday),
          SizedBox(height: 20.h),
          _StatsGrid(data: data),
          SizedBox(height: 20.h),
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
      height: 120.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white70,
        border: Border(
          bottom: BorderSide(width: 4.w, color: Colors.teal),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'خدمة التوصيل',
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  ' ${feesToday.toStringAsFixed(2)} ',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
              Text(
                'ج',
                style: TextStyle(fontSize: 22.sp, color: Colors.teal),
              ),
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
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
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
          value: '${data.collectionToday.toStringAsFixed(2)} ج',
          icon: Icons.monetization_on_outlined,
          color: Colors.orange,
        ),
        StatCard(
          title: 'إجمالي الخصومات',
          value:
              '${data.discountToday.toStringAsFixed(2)} ج', // مش موجود في الـ API حالياً
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
          value: '${data.profitToday.toStringAsFixed(2)} ج',
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
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.pink[50],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: Colors.red[100],
                child: Icon(Icons.cancel, color: AppColors.dangerRed2),
              ),
              SizedBox(width: 4.w),
              Text(
                'طلبات ملغاة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            ' $cancelledCount ',
            style: TextStyle(
              fontSize: 20.sp,
              color: AppColors.dangerRed2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
