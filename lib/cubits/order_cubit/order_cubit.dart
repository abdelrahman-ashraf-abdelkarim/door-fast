import 'dart:async';

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
  StreamSubscription<List<Order>>? _ordersSubscription;
  bool isOnline = true;

  Future<void> loadOrders() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final orders = await _ordersService.fetchOrders();
      emit(state.copyWith(orders: orders, isLoading: false));
      listenToRealTimeOrders();
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  void listenToRealTimeOrders() {
    _ordersService.startRealTimeSimulation();
    _ordersSubscription ??= _ordersService.ordersStream.listen((orders) {
      final knownOrderIds = state.orders.map((order) => order.id).toSet();
      final newOrders = orders.where((order) {
        return order.isPending && !knownOrderIds.contains(order.id);
      });

      emit(state.copyWith(orders: orders, errorMessage: null));

      for (final order in newOrders) {
        _showNewOrderNotification(order);
      }
    });
  }

  Future<void> acceptOrder(String orderId) async {
    try {
      await _ordersService.acceptOrder(orderId);
    } on OrderAlreadyAcceptedException {
      emit(state.copyWith(errorMessage: 'لا يمكن قبول نفس الطلب مرتين'));
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await _ordersService.cancelOrder(orderId, reason);
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> completeOrder(String orderId) async {
    try {
      await _ordersService.completeOrder(orderId);
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  void addOrder(Order order) {
    final updatedOrders = List<Order>.from(state.orders)..add(order);
    emit(state.copyWith(orders: updatedOrders));
    _showNewOrderNotification(order);
  }

  List<Order> _ordersWithStatus(OrderStatus status) {
    return state.orders.where((order) => order.status == status).toList();
  }

  List<Order> _ordersWithStatuses(Set<OrderStatus> statuses) {
    return state.orders
        .where((order) => statuses.contains(order.status))
        .toList();
  }

  int _countOrdersWithStatus(OrderStatus status) {
    return state.orders.where((order) => order.status == status).length;
  }

  void _showNewOrderNotification(Order order) {
    NotificationService.showNotification(
      title: 'طلب جديد 🚚',
    );
  }

  /// الحصول على الطلبات الجديدة فقط
  List<Order> get pendingOrders => _ordersWithStatuses(_pendingStatuses);

  /// الحصول على الطلبات المقبولة
  List<Order> get acceptedOrders => _ordersWithStatus(OrderStatus.accepted);

  /// الحصول على الطلبات التي تم تسليمها
  List<Order> get deliveredOrders => _ordersWithStatus(OrderStatus.delivered);

  /// عدد الطلبات حسب الحالة
  /// عدد الطلبات الجديدة
  int get pendingCount => _ordersWithStatuses(_pendingStatuses).length;

  /// عدد الطلبات المقبولة
  int get acceptedCount => _countOrdersWithStatus(OrderStatus.accepted);

  /// عدد الطلبات التي تم تسليمها
  int get deliveredCount => _countOrdersWithStatus(OrderStatus.delivered);

  /// عدد الطلبات الملغاة
  int get cancelledCount => _countOrdersWithStatus(OrderStatus.cancelled);

  /// إجمالي الأرباح من الطلبات التي تم تسليمها
  double get totalEarnings => state.orders
      .where((o) => o.status == OrderStatus.delivered)
      .fold(0.0, (sum, order) => sum + order.totalPrice);

  /// اجمالى ارباح الكابتن من الطلبات التى تم توصيلها
  double get totalDeliveryEarnings => state.orders
      .where((o) => o.status == OrderStatus.delivered)
      .fold(0.0, (sum, order) => sum + order.deliveryPrice);

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    _ordersService.dispose();
    return super.close();
  }
}
