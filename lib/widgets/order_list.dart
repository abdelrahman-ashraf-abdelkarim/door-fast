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
}
