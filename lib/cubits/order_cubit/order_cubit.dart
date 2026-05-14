// lib/cubits/order_cubit/order_cubit.dart
import 'dart:async';

import 'package:captain_app/api/api.dart';
import 'package:captain_app/cubits/order_cubit/order_state.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:captain_app/services/notification_service.dart';
import 'package:captain_app/services/orders_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:captain_app/services/web_socket_service.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersService _ordersService;
  final Api api;
  final WebSocketService _wsService = WebSocketService();
  StreamSubscription? _wsSubscription;

  String? _token;
  String? _captainId;
  bool _wsConnected = false;

  OrdersCubit({OrdersService? ordersService, required Api api})
    : _ordersService = ordersService ?? OrdersService(api: api),
      api = api,
      super(const OrdersState(orders: []));

  static const _pendingStatuses = {OrderStatus.waiting, OrderStatus.newOrder};

  // ─── Load ─────────────────────────────────────────────────────

  Future<void> loadOrders(String token, String captainId) async {
    _token = token;
    _captainId = captainId;
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final results = await Future.wait([
        _ordersService.fetchOrders(token),
        _ordersService.fetchReceivedOrders(token),
        _ordersService.fetchDeliveredOrders(token),
      ]);
      final allOrders = [...results[0], ...results[1], ...results[2]];
      emit(state.copyWith(orders: allOrders, isLoading: false));

      if (!_wsConnected) {
        _wsConnected = true;
        _connectWebSocket(token, captainId);
      }
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  // ─── Pusher ───────────────────────────────────────────────────

  void _connectWebSocket(String token, String captainId) {
    _wsService.connect(token, captainId);

    _wsSubscription = _wsService.stream.listen((data) {
      final event = data['event'];
      final rawId = data['order_id'];

      if (rawId == null) return;

      final orderId = rawId.toString();

      if (event == 'new_order') {
        _fetchAndAddNewOrder(orderId);
      } else if (event == 'order_updated') {
        final status = data['status']?.toString();
        final deliveryId = data['delivery_id']?.toString();
        if (status == 'cancelled' ||
            (status == 'received' && deliveryId != _captainId)) {
          _removeOrder(orderId);
        } else {
          _fetchAndUpdateOrder(orderId);
        }
      } else if (event == 'order_cancelled') {
        _removeOrder(orderId);
      }
    });
  }

  void _removeOrder(String orderId) {
    final updatedList = state.orders.where((o) => o.id != orderId).toList();
    emit(state.copyWith(orders: updatedList));
  }

  Stream<Map<String, dynamic>> get wsStream => _wsService.stream;

  Future<void> _fetchAndAddNewOrder(String orderId) async {
    if (_token == null) return;
    try {
      if (state.orders.any((o) => o.id == orderId)) return;
      final newOrder = await _ordersService.fetchOrderById(orderId, _token!);
      emit(state.copyWith(orders: [newOrder, ...state.orders]));
      NotificationService.showNotification(title: 'طلب جديد ', body: "");
    } catch (_) {}
  }

  Future<void> _fetchAndUpdateOrder(String orderId) async {
    if (_token == null) return;
    try {
      final updated = await _ordersService.fetchOrderById(orderId, _token!);
      final exists = state.orders.any((o) => o.id == orderId);

      if (!exists) {
        emit(state.copyWith(orders: [updated, ...state.orders]));
        NotificationService.showNotification(
          title: 'طلب جديد ',
          body: 'رقم الطلب: ${updated.orderNumber}',
        );
      } else {
        final updatedList = state.orders.map((o) {
          return o.id == orderId ? updated : o;
        }).toList();
        emit(state.copyWith(orders: updatedList));
      }
    } on OrderNotFoundException {
      _removeOrder(orderId);
    } catch (e) {
      print('❌ _fetchAndUpdateOrder error: $e');
    }
  }

  // ─── Actions ──────────────────────────────────────────────────

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
      emit(state.copyWith(orders: updatedOrders));
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> cancelOrder(String orderId, String reason, String token) async {
    try {
      await _ordersService.cancelOrder(orderId, reason, token);
      await loadOrders(_token!, _captainId!);
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> completeOrder(String orderId, String token) async {
    try {
      await _ordersService.completeOrder(orderId, token);
      await loadOrders(_token!, _captainId!);
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  // ─── Cleanup ──────────────────────────────────────────────────

  @override
  Future<void> close() async {
    await _wsSubscription?.cancel();
    await _wsService.disconnect();
    return super.close();
  }

  // ─── Getters ──────────────────────────────────────────────────

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
}
