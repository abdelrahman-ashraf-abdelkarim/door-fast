import 'dart:math';

import 'package:captain_app/models/order_model.dart';
import 'package:captain_app/services/orders_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('acceptOrder accepts a pending order once only', () async {
    final service = OrdersService(random: Random(1));
    addTearDown(service.dispose);

    final orders = await service.fetchOrders();
    final pendingOrder = orders.firstWhere((order) => order.isPending);

    final acceptedOrder = await service.acceptOrder(pendingOrder.id);

    expect(acceptedOrder.status, OrderStatus.accepted);
    expect(acceptedOrder.acceptedAt, isNotNull);
    expect(
      () => service.acceptOrder(pendingOrder.id),
      throwsA(isA<OrderAlreadyAcceptedException>()),
    );
  });
}
