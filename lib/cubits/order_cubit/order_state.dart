import 'package:captain_app/models/order_model.dart';

class OrdersState {
  final List<Order> orders;

  OrdersState({required this.orders});

  OrdersState copyWith({List<Order>? orders}) {
    return OrdersState(
      orders: orders ?? this.orders,
    );
  }
}
