import 'package:captain_app/models/order_model.dart';
import 'package:captain_app/widgets/order_list.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyOrderScreen extends StatelessWidget {
  const MyOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("طلباتى"),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: "طلبات جديدة"),
              Tab(text: "طلبات مقبولة"),
              Tab(text: "تم التوصيل"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrdersList(status: OrderStatusFilter.waiting),
            OrdersList(status: OrderStatusFilter.accepted),
            OrdersList(status: OrderStatusFilter.delivered),
          ],
        ),
      ),
    );
  }
}
