import 'package:captain_app/core/constants.dart';
import 'package:captain_app/core/format_arabic_date_for_dashboard.dart';
import 'package:captain_app/core/time_now.dart';
import 'package:captain_app/cubits/order_cubit/order_cubit.dart';
import 'package:captain_app/cubits/order_cubit/order_state.dart';
import 'package:captain_app/cubits/shift_cubit/shift_cubit.dart';
import 'package:captain_app/cubits/shift_cubit/shift_state.dart';
import 'package:captain_app/models/auth_model.dart';
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
      builder: (context, state) {
        final isOnline = state.user?.status == CaptainStatus.active;

        return Scaffold(
          appBar: AppBar(
            title: AppBarWidget(
              isOnline: isOnline,
              userName: state.user?.name ?? 'كابتن',
            ),
            backgroundColor: AppColors.screenBackground,
          ),
          body: BlocBuilder<OrdersCubit, OrdersState>(
            builder: (context, orderState) {
              final ordersCubit = context.read<OrdersCubit>();

              if (!isOnline) {
                return const _OfflineMessage();
              }

              return _DashboardContent(ordersCubit: ordersCubit);
            },
          ),
        );
      },
    );
  }
}

class _OfflineMessage extends StatelessWidget {
  const _OfflineMessage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'انت غير نشط حاليا',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Color(0xffbe2c2d),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.ordersCubit});

  final OrdersCubit ordersCubit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
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
          const SizedBox(height: 20),
          _TotalEarningsCard(totalEarnings: ordersCubit.totalDeliveryEarnings),
          const SizedBox(height: 20),
          _StatsGrid(ordersCubit: ordersCubit),
          const SizedBox(height: 20),
          _CancelledOrdersCard(cancelledCount: ordersCubit.cancelledCount),
        ],
      ),
    );
  }
}

class _TotalEarningsCard extends StatelessWidget {
  const _TotalEarningsCard({required this.totalEarnings});

  final double totalEarnings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white70,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            'خدمة التوصيل',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.teal,
            ),
          ),
          // const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ' ${totalEarnings.toString()} ',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'ج',
                style: TextStyle(fontSize: 22, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.ordersCubit});

  final OrdersCubit ordersCubit;

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
        ///  start time and work duration should be in the same card,
        ///  and if the shift is not started show "انت غير نشط حاليا" instead of the time and duration
        ///  Add real data for each stat card
        const StatCard(
          title: 'بداية الوردية',
          valueWidget: StartShiftTimeWidget(),
          icon: Icons.access_time,
        ),
        const StatCard(
          title: 'مدة العمل',
          valueWidget: WorkTimerWidget(),
          icon: Icons.timer_outlined,
        ),

        /// end task
        StatCard(
          title: 'طلبات مكتمله',
          value: ordersCubit.deliveredCount.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        StatCard(
          title: 'طلبات معلقة',
          value: ordersCubit.pendingCount.toString(),
          icon: Icons.add_circle,
          color: Colors.blue,
        ),
        StatCard(
          title: 'اجمالى التحصيل اليومى',
          value: "${ordersCubit.totalDeliveryEarnings.toStringAsFixed(0)} ج",
          // icon: Icons.local_shipping,
          color: Colors.orange,
        ),
        const StatCard(
          title: 'إجمالي الخصومات',
          value: '10 ج',
          icon: Icons.money_off,
          color: Colors.red,
        ),
      ],
    );
  }
}

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
