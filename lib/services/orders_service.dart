import 'package:captain_app/core/constants.dart';
import 'package:captain_app/helper/api.dart';
import 'package:captain_app/models/order_model.dart';

class OrderAlreadyAcceptedException implements Exception {
  const OrderAlreadyAcceptedException(this.orderId);
  final String orderId;
  @override
  String toString() => 'Order $orderId is already accepted';
}

class OrderNotFoundException implements Exception {
  const OrderNotFoundException(this.orderId);
  final String orderId;
  @override
  String toString() => 'Order $orderId was not found';
}

class OrdersService {
  final Api _api = Api();

  // جلب الطلبات الجديدة
  Future<List<Order>> fetchOrders(String token) async {
    final data = await _api.get(
      url: '${AppConstants.baseUrl}/orders/new',
      token: token,
    );
    return (data['orders'] as List)
        .map((json) => Order.fromJson(json))
        .toList();
  }

  // قبول طلب
  Future<void> acceptOrder(String orderId, String token) async {
    await _api.post(
      url: '${AppConstants.baseUrl}/orders/$orderId/accept',
      body: {},
      token: token,
    );
  }

  Future<List<Order>> fetchReceivedOrders(String token) async {
  final data = await _api.get(
    url: '${AppConstants.baseUrl}/orders/received',
    token: token,
  );
  return (data['orders'] as List)
      .map((json) => Order.fromJson(json))
      .toList();
}
Future<List<Order>> fetchDeliveredOrders(String token) async {
  final data = await _api.get(
    url: '${AppConstants.baseUrl}/orders/delivered',
    token: token,
  );
  return (data['orders'] as List)
      .map((json) => Order.fromJson(json))
      .toList();
}

  // تسليم طلب
  Future<void> completeOrder(String orderId, String token) async {
    await _api.post(
      url: '${AppConstants.baseUrl}/orders/$orderId/deliver',
      body: {},
      token: token,
    );
  }

  // إلغاء طلب
  Future<void> cancelOrder(String orderId, String reason, String token) async {
    await _api.post(
      url: '${AppConstants.baseUrl}/orders/$orderId/cancel',
      body: {'reason': reason},
      token: token,
    );
  }
}