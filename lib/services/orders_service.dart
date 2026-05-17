import 'package:captain_app/api/api.dart';
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
  final Api _api;
  OrdersService({required Api api}) : _api = api;

  // جلب الطلبات الجديدة
  Future<List<Order>> fetchOrders(String token) async {
    try {
      final data = await _api.get(
        url: '${_api.baseUrl}/orders/new',
        token: token,
      );
      return (data['orders'] as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // قبول طلب
  Future<void> acceptOrder(String orderId, String token) async {
    await _api.post(
      url: '${_api.baseUrl}/orders/$orderId/accept',
      body: {},
      token: token,
    );
  }

  Future<Order> fetchOrderById(String orderId, String token) async {
    try {
      final data = await _api.get(
        url: '${_api.baseUrl}/orders/$orderId',
        token: token,
      );
      if (data == null || data['success'] == false) {
        throw OrderNotFoundException(orderId);
      }
      return Order.fromJson(data['order']);
    } on OrderNotFoundException {
      rethrow; // ← خلّيه يعدي للـ cubit
    } on Exception catch (e) {
      if (e.toString().contains('404')) {
        throw OrderNotFoundException(orderId); // ← 404 = مش موجود
      }
      rethrow;
    }
  }

  Future<List<Order>> fetchReceivedOrders(String token) async {
    final data = await _api.get(
      url: '${_api.baseUrl}/orders/received',
      token: token,
    );
    return (data['orders'] as List)
        .map((json) => Order.fromJson(json))
        .toList();
  }

  Future<List<Order>> fetchDeliveredOrders(String token) async {
    final data = await _api.get(
      url: '${_api.baseUrl}/orders/delivered',
      token: token,
    );
    return (data['orders'] as List)
        .map((json) => Order.fromJson(json))
        .toList();
  }

  // تسليم طلب
  Future<void> completeOrder(String orderId, String token) async {
    await _api.post(
      url: '${_api.baseUrl}/orders/$orderId/deliver',
      body: {},
      token: token,
    );
  }

  // إلغاء طلب
  Future<void> cancelOrder(String orderId, String reason, String token) async {
    await _api.post(
      url: '${_api.baseUrl}/orders/$orderId/cancel',
      body: {'reason': reason},
      token: token,
    );
  }
}
