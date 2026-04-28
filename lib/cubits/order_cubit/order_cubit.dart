import 'package:captain_app/cubits/order_cubit/order_state.dart';
import 'package:captain_app/data/demy_order.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:captain_app/services/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(OrdersState(orders: dummyOrders));
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
          cancelReason: newStatus == OrderStatus.cancelled ? cancelReason : null,
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

  /// الحصول على الطلبات الجديدة فقط
  List<Order> get pendingOrders =>
      state.orders.where((o) => o.status == OrderStatus.waiting).toList();

  /// الحصول على الطلبات المقبولة
  List<Order> get acceptedOrders =>
      state.orders.where((o) => o.status == OrderStatus.accepted).toList();

  /// الحصول على الطلبات التي تم تسليمها
  List<Order> get deliveredOrders =>
      state.orders.where((o) => o.status == OrderStatus.delivered).toList();

  /// عدد الطلبات حسب الحالة
  /// عدد الطلبات الجديدة
  int get pendingCount =>
      state.orders.where((o) => o.status == OrderStatus.waiting).length;

  /// عدد الطلبات المقبولة
  int get acceptedCount =>
      state.orders.where((o) => o.status == OrderStatus.accepted).length;

  /// عدد الطلبات التي تم تسليمها
  int get deliveredCount =>
      state.orders.where((o) => o.status == OrderStatus.delivered).length;

  /// عدد الطلبات الملغاة
  int get cancelledCount =>
      state.orders.where((o) => o.status == OrderStatus.cancelled).length;

  /// إجمالي الأرباح من الطلبات التي تم تسليمها
  double get totalEarnings => state.orders
      .where((o) => o.status == OrderStatus.delivered)
      .fold(0.0, (sum, order) => sum + order.totalPrice);

  /// اجمالى ارباح الكابتن من الطلبات التى تم توصيلها
  double get totalDeliveryEarnings => state.orders
      .where((o) => o.status == OrderStatus.delivered)
      .fold(0.0, (sum, order) => sum + order.deliveryPrice);

}
