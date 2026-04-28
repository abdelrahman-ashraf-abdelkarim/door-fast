import 'package:captain_app/cubits/order_cubit/order_cubit.dart';
import 'package:captain_app/cubits/order_cubit/order_state.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:captain_app/widgets/order_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الطلبات'), centerTitle: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'طلبات جديدة',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                BlocBuilder<OrdersCubit, OrdersState>(
                  builder: (context, state) {
                    final hasOrders =
                        context.read<OrdersCubit>().pendingOrders.isNotEmpty;
                    return Text(
                      hasOrders
                          ? 'لديك طلبات جاهزة للاستلام'
                          : 'لا يوجد طلبات حاليًا',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    );
                  },
                ),
              ],
            ),
          ),
          const Expanded(
            child: OrdersList(
              status: OrderStatusFilter.waiting,
              paddingValue: 0,
            ),
          ),
        ],
      ),
    );
  }
}
