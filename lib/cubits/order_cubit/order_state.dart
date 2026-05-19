import 'package:captain_app/models/order_model.dart';
import 'package:equatable/equatable.dart';

// [FIX-18] sentinel object to distinguish "not passed" from "null"
const _omit = Object();

// [FIX-08] extend Equatable to prevent unnecessary rebuilds
class OrdersState extends Equatable {
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
    Object? errorMessage = _omit,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _omit
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [orders, isLoading, errorMessage];
}
