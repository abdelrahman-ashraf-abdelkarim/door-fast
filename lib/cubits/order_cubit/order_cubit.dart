import 'dart:async';

import 'package:captain_app/api/api.dart';
import 'package:captain_app/core/app_logger.dart';
import 'package:captain_app/cubits/order_cubit/order_state.dart';
import 'package:captain_app/models/auth_model.dart';
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
  DeliveryType _role = DeliveryType.delivery;

  // ✅ اتشال _wsConnected — كان بيمنع إعادة الـ subscribe بعد رجوع الـ app
  // دلوقتي _listenToWebSocket() بتعمل cancel للـ subscription القديمة
  // وتعمل واحدة جديدة في كل مرة تتكال فيها، من غير مشاكل

  OrdersCubit({OrdersService? ordersService, required this.api})
    : _ordersService = ordersService ?? OrdersService(api: api),
      super(const OrdersState(orders: []));

  static const _pendingStatuses = {OrderStatus.waiting, OrderStatus.newOrder};

  bool get _isReserve => _role == DeliveryType.reserve;

  // ─── Load ─────────────────────────────────────────────────────

  Future<void> loadOrders(
    String token,
    String captainId, {
    DeliveryType role = DeliveryType.delivery,
  }) async {
    _token = token;
    _captainId = captainId;
    _role = role;

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final results = await Future.wait([
        _ordersService.fetchOrders(token),
        _ordersService.fetchReceivedOrders(token),
        _ordersService.fetchDeliveredOrders(token),
      ]);
      final allOrders = [...results[0], ...results[1], ...results[2]];
      if (isClosed) return;
      emit(state.copyWith(orders: allOrders, isLoading: false));

      // ✅ دايماً بيعمل connect + listen في كل loadOrders
      // _connectWebSocket بتعمل connect مرة واحدة بس (الـ WS singleton يتجاهلها لو متوصل)
      // لكن _listenToWebSocket بتعمل cancel للـ subscription القديمة وتعمل جديدة
      await _connectWebSocket(token, captainId);
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  // ─── WebSocket ────────────────────────────────────────────────

  Future<void> _connectWebSocket(String token, String captainId) async {
    // ✅ connect في الـ singleton (بيتجاهل التاني لو _initialized = true)
    await _wsService.connect(token, captainId);
    // ✅ دايماً بنعمل listen جديد عشان نضمن ما يفوتناش أي event
    _listenToWebSocket();
  }

  // ✅ public — بيتكال من HomeShell بعد reconnect
  void relistenToWebSocket() => _listenToWebSocket();

  void _listenToWebSocket() {
    // ✅ بنكنسل الـ subscription القديمة الأول
    _wsSubscription?.cancel();
    _wsSubscription = _wsService.stream.listen((data) {
      final event = data['event'];

      // shift events → ShiftCubit
      // account_deactivated → AuthCubit
      // OrdersCubit بيتعامل بس مع order events

      final rawId = data['order_id'];
      if (rawId == null) return;
      final orderId = rawId.toString();

      if (event == 'reserve_new_order') {
        if (!_isReserve) return;
        _fetchAndAddNewOrder(orderId);
      } else if (event == 'new_order') {
        if (_isReserve) return;
        _fetchAndAddNewOrder(orderId);
      } else if (event == 'order_updated') {
        if (_isReserve) return;
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

  // ─── Fetch Helpers ────────────────────────────────────────────

  Future<void> _fetchAndAddNewOrder(String orderId) async {
    if (_token == null) return;
    try {
      if (state.orders.any((o) => o.id == orderId)) return;
      final newOrder = await _ordersService.fetchOrderById(orderId, _token!);
      if (isClosed) return;
      emit(state.copyWith(orders: [...state.orders, newOrder]));
      NotificationService.showNotification(
        title: 'طلب جديد',
        body: 'رقم الطلب: ${newOrder.orderNumber}',
      );
    } catch (_) {}
  }

  Future<void> _fetchAndUpdateOrder(String orderId) async {
    if (_token == null) return;
    try {
      final updated = await _ordersService.fetchOrderById(orderId, _token!);
      final exists = state.orders.any((o) => o.id == orderId);
      if (isClosed) return;

      if (!exists) {
        emit(state.copyWith(orders: [...state.orders, updated]));
        NotificationService.showNotification(
          title: updated.isDeliveryChosen ? 'الطلب مرسل اليك' : 'طلب جديد',
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
    } catch (_) {}
  }

  void _removeOrder(String orderId) {
    final updatedList = state.orders.where((o) => o.id != orderId).toList();
    emit(state.copyWith(orders: updatedList));
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
      if (isClosed) return;
      emit(state.copyWith(orders: updatedOrders));
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> cancelOrder(String orderId, String reason, String token) async {
    if (_token == null || _captainId == null) {
      AppLogger.w(
        'OrderCubit',
        'cancelOrder aborted: token or captainId is null',
      );
      return;
    }
    try {
      await _ordersService.cancelOrder(orderId, reason, token);
      if (isClosed) return;
      await loadOrders(_token!, _captainId!, role: _role);
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> completeOrder(String orderId, String token) async {
    if (_token == null || _captainId == null) {
      AppLogger.w(
        'OrderCubit',
        'completeOrder aborted: token or captainId is null',
      );
      return;
    }
    try {
      await _ordersService.completeOrder(orderId, token);
      if (isClosed) return;
      await loadOrders(_token!, _captainId!, role: _role);
    } catch (error) {
      if (isClosed) return;
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
      .fold(0.0, (sum, o) => sum + o.deliveryFee);
}
