import 'package:captain_app/core/constants.dart';
import 'package:captain_app/cubits/auth_cubit/auth_cubit.dart';
import 'package:captain_app/cubits/auth_cubit/auth_state.dart';
import 'package:captain_app/cubits/order_cubit/order_cubit.dart';
import 'package:captain_app/cubits/order_cubit/order_state.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:captain_app/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrdersList extends StatefulWidget {
  final OrderStatusFilter status;
  final double paddingValue;

  const OrdersList({super.key, this.paddingValue = 12, required this.status});

  @override
  State<OrdersList> createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        final cubit = context.read<OrdersCubit>();

        // [FIX-20] show error state when orders fail to load
        if (state.errorMessage != null) {
          return _OrdersErrorState(
            message: state.errorMessage!,
            onRetry: () => _retryLoadOrders(context),
          );
        }

        if (state.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final List<Order> orders;
        switch (widget.status) {
          case OrderStatusFilter.waiting:
          case OrderStatusFilter.newOrder:
            orders = cubit.pendingOrders;
            break;
          case OrderStatusFilter.accepted:
            orders = cubit.acceptedOrders;
            break;
          case OrderStatusFilter.delivered:
            orders = cubit.deliveredOrders;
            break;
        }

        if (orders.isEmpty) {
          return Center(
            child: Text(
              "لا توجد طلبات حالياً",
              style: TextStyle(fontSize: 16.sp),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(widget.paddingValue),
          itemCount: orders.length,
          // reverse: true,
          itemBuilder: (context, index) {
            final order = orders[index];
            return OrderCard(itemsCount: order.totalItemsCount, order: order);
          },
        );
      },
    );
  }

  void _retryLoadOrders(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    context.read<OrdersCubit>().loadOrders(
      authState.token,
      authState.user.id,
      role: authState.user.role,
    );
  }
}

class _OrdersErrorState extends StatelessWidget {
  const _OrdersErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.dangerRed, size: 56.r),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
