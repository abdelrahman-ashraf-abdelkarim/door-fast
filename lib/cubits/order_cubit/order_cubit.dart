import 'package:captain_app/cubits/order_cubit/order_state.dart';
import 'package:captain_app/data/demy_order.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:captain_app/services/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(OrdersState(orders: dummyOrders));

  static const _pendingStatuses = {OrderStatus.waiting, OrderStatus.newOrder};

  bool isOnline = true;

  /// تحديث حالة الطلب
  void updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    String? cancelReason,
  }) {
    final updatedOrders = state.orders.map((order) {
      if (order.id == orderId) {
        return order.copyWith(
          status: newStatus,
          cancelReason: newStatus == OrderStatus.cancelled
              ? cancelReason
              : null,
        );
      }
      return order;
    }).toList();

    emit(state.copyWith(orders: updatedOrders));
  }

  void addOrder(Order order) {
    final updatedOrders = List<Order>.from(state.orders)..add(order);
    emit(state.copyWith(orders: updatedOrders));

    // إرسال إشعار
    NotificationService.showNotification(
      title: "طلب جديد 🚚",
      body:
          "طلب من ${order.pickupLocation} إلى ${order.deliveryLocation} - ${order.deliveryPrice} ج",
    );
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
}
