import 'dart:convert';

import 'package:captain_app/core/constants.dart';
import 'package:captain_app/api/api.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:flutter/services.dart';

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

  // fake orders for testing
  Future<Map<String, dynamic>> getOrders() async {
    final response = await rootBundle.loadString('assets/json/orders.json');

    return jsonDecode(response);
  }

  // جلب الطلبات الجديدة
  Future<List<Order>> fetchOrders(String token) async {
    print('📡 Calling: ${AppConstants.baseUrl}/orders/new');
    try {
      final data = await _api.get(
        url: '${AppConstants.baseUrl}/orders/new',
        token: token,
      );
      print('✅ Response: $data');
      return (data['orders'] as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

  // قبول طلب
  Future<void> acceptOrder(String orderId, String token) async {
    await _api.post(
      url: '${AppConstants.baseUrl}/orders/$orderId/accept',
      body: {},
      token: token,
    );
  }

  Future<Order> fetchOrderById(String orderId, String token) async {
    try {
      final data = await _api.get(
        url: '${AppConstants.baseUrl}/orders/$orderId',
        token: token,
      );
      print('📦 fetchOrderById response: $data');
      if (data == null || data['success'] == false) {
        throw OrderNotFoundException(orderId);
      }
      return Order.fromJson(data['order']);
    } on OrderNotFoundException {
      print('🚫 OrderNotFoundException thrown');
      rethrow; // ← خلّيه يعدي للـ cubit
    } on Exception catch (e) {
      print('⚠️ Exception: ${e.toString()}');
      if (e.toString().contains('404')) {
        throw OrderNotFoundException(orderId); // ← 404 = مش موجود
      }
      rethrow;
    }
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
