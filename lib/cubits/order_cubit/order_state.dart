import 'package:captain_app/models/order_model.dart';

class OrdersState {
  final List<Order> orders;
  final bool isLoading;
  final String? errorMessage;

  const OrdersState({
    required this.orders,
    this.isLoading = false,
    this.errorMessage,
  });

  OrdersState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
