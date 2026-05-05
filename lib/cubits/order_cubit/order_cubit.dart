import 'package:captain_app/cubits/order_cubit/order_state.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:captain_app/services/notification_service.dart';
import 'package:captain_app/services/orders_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit({OrdersService? ordersService})
    : _ordersService = ordersService ?? OrdersService(),
      super(const OrdersState(orders: []));

  static const _pendingStatuses = {OrderStatus.waiting, OrderStatus.newOrder};
  final OrdersService _ordersService;

  Future<void> loadOrders(String token) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final resulte = await Future.wait([
        _ordersService.fetchOrders(token),
        _ordersService.fetchReceivedOrders(token),
        _ordersService.fetchDeliveredOrders(token),
      ]);
      final allOrders = [...resulte[0], ...resulte[1], ...resulte[2]];
      emit(state.copyWith(orders: allOrders, isLoading: false));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> acceptOrder(String orderId, String token) async {
    try {
      await _ordersService.acceptOrder(orderId, token);
      final updatedOrders = state.orders.map((o) {
        if (o.id == orderId) {
          return o.copyWith(
            status: OrderStatus.accepted,
            acceptedAt: DateTime.now(),
          );
        }
        return o;
      }).toList();
      // await loadOrders(token); /
      emit(state.copyWith(orders: updatedOrders));
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> cancelOrder(String orderId, String reason, String token) async {
    try {
      await _ordersService.cancelOrder(orderId, reason, token);
      await loadOrders(token); // رفريش بعد الإلغاء
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> completeOrder(String orderId, String token) async {
    try {
      await _ordersService.completeOrder(orderId, token);
      await loadOrders(token); // رفريش بعد التسليم
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  void _showNewOrderNotification() {
    NotificationService.showNotification(title: 'طلب جديد 🚚');
  }

  List<Order> get pendingOrders =>
      state.orders.where((o) => _pendingStatuses.contains(o.status)).toList();

  List<Order> get acceptedOrders =>
      state.orders.where((o) => o.status == OrderStatus.accepted).toList();

  List<Order> get deliveredOrders =>
      state.orders.where((o) => o.status == OrderStatus.delivered).toList();

  int get pendingCount => pendingOrders.length;
  int get acceptedCount => acceptedOrders.length;
  int get deliveredCount => deliveredOrders.length;
  int get cancelledCount =>
      state.orders.where((o) => o.status == OrderStatus.cancelled).length;

  double get totalDeliveryEarnings => state.orders
      .where((o) => o.status == OrderStatus.delivered)
      .fold(0.0, (sum, o) => sum + o.deliveryPrice);

  @override
  Future<void> close() {
    return super.close();
  }
}
