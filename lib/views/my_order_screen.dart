import 'package:captain_app/models/order_model.dart';
import 'package:captain_app/widgets/order_list.dart';
import 'package:flutter/material.dart';

class MyOrderScreen extends StatelessWidget {
  const MyOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("طلباتى"),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: "طلبات مقبولة"),
              Tab(text: "تم التوصيل"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrdersList(status: OrderStatusFilter.accepted),
            OrdersList(status: OrderStatusFilter.delivered),
          ],
        ),
      ),
    );
  }
}
