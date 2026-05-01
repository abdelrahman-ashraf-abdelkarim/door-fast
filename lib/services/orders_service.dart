import 'dart:async';
import 'dart:math';

import 'package:captain_app/data/demy_order.dart';
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
  OrdersService({Random? random}) : _random = random ?? Random() {
    _orders = dummyOrders.map(_hydrateOrder).toList();
    _nextOrderId = _orders.length + 1;
  }

  final Random _random;
  final StreamController<List<Order>> _ordersController =
      StreamController<List<Order>>.broadcast();

  late List<Order> _orders;
  late int _nextOrderId;
  Timer? _newOrderTimer;
  Timer? _acceptedCleanupTimer;

  Stream<List<Order>> get ordersStream => _ordersController.stream;

  Future<List<Order>> fetchOrders() async {
    await _simulateApiLatency();
    _emitOrders();
    return List.unmodifiable(_orders);
  }

  Future<Order> acceptOrder(String orderId) async {
    await _simulateApiLatency();

    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex == -1) {
      throw OrderNotFoundException(orderId);
    }

    final order = _orders[orderIndex];
    if (!order.isPending) {
      throw OrderAlreadyAcceptedException(orderId);
    }

    final acceptedOrder = order.copyWith(
      status: OrderStatus.accepted,
      acceptedAt: DateTime.now(),
      cancelReason: null,
    );

    _orders[orderIndex] = acceptedOrder;
    _emitOrders();
    return acceptedOrder;
  }

  Future<Order> cancelOrder(String orderId, String reason) async {
    await _simulateApiLatency();

    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex == -1) {
      throw OrderNotFoundException(orderId);
    }

    final cancelledOrder = _orders[orderIndex].copyWith(
      status: OrderStatus.cancelled,
      cancelReason: reason,
    );

    _orders[orderIndex] = cancelledOrder;
    _emitOrders();
    return cancelledOrder;
  }

  Future<Order> completeOrder(String orderId) async {
    await _simulateApiLatency();

    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex == -1) {
      throw OrderNotFoundException(orderId);
    }

    final deliveredOrder = _orders[orderIndex].copyWith(
      status: OrderStatus.delivered,
    );

    _orders[orderIndex] = deliveredOrder;
    _emitOrders();
    return deliveredOrder;
  }

  void startRealTimeSimulation() {
    _scheduleNextGeneratedOrder();

    _acceptedCleanupTimer ??= Timer.periodic(const Duration(seconds: 10), (_) {
      _removeAcceptedOrdersForOtherCaptains();
    });
  }

  void dispose() {
    _newOrderTimer?.cancel();
    _acceptedCleanupTimer?.cancel();
    _ordersController.close();
  }

  Future<void> _simulateApiLatency() {
    return Future.delayed(Duration(milliseconds: 350 + _random.nextInt(450)));
  }

  void _addGeneratedOrder() {
    final order = _buildGeneratedOrder();
    _orders = [order, ..._orders];
    _emitOrders();
  }

  void _scheduleNextGeneratedOrder() {
    if (_newOrderTimer?.isActive ?? false) return;

    final nextDelay = Duration(seconds: 5 + _random.nextInt(6));
    _newOrderTimer = Timer(nextDelay, () {
      _addGeneratedOrder();
      _newOrderTimer = null;
      _scheduleNextGeneratedOrder();
    });
  }

  void _removeAcceptedOrdersForOtherCaptains() {
    final now = DateTime.now();
    final visibleOrders = _orders.where((order) {
      if (order.status != OrderStatus.accepted || order.acceptedAt == null) {
        return true;
      }

      return now.difference(order.acceptedAt!) < const Duration(seconds: 30);
    }).toList();

    if (visibleOrders.length == _orders.length) return;

    _orders = visibleOrders;
    _emitOrders();
  }

  Order _buildGeneratedOrder() {
    final pickup = _pick(_pickupLocations);
    final delivery = _pick(_deliveryLocations);
    final market = _pick(_markets);
    final item = _pick(_products);
    final id = (_nextOrderId++).toString();

    return Order(
      id: id,
      dropoffContact: OrderContact(
        name: '${_pick(_customerNames)} (المستلم)',
        phone: _buildPhoneNumber(),
        notes: _random.nextBool() ? 'يرجى الاتصال قبل الوصول' : '',
      ),
      kind: _random.nextBool() ? OrderKind.company : OrderKind.personToPerson,
      pickupLocation: pickup,
      deliveryLocation: delivery,
      deliveryPrice: (35 + _random.nextInt(45)).toDouble(),
      status: _random.nextBool() ? OrderStatus.waiting : OrderStatus.newOrder,
      paymentMethod: _random.nextBool() ? 'كاش' : 'بطاقة',
      notes: _random.nextBool() ? 'طلب جديد من النظام التجريبي' : '',
      createdAt: DateTime.now(),
      items: [
        OrderItem(
          productName: item,
          quantity: 1 + _random.nextInt(3),
          deliveryPrice: (25 + _random.nextInt(100)).toDouble(),
          details: _random.nextBool() ? 'بدون إضافات' : '',
          marketPlace: market,
        ),
      ],
      pickupLat: 30.0444 + (_random.nextDouble() - 0.5) / 10,
      pickupLng: 31.2357 + (_random.nextDouble() - 0.5) / 10,
      deliveryLat: 30.0444 + (_random.nextDouble() - 0.5) / 10,
      deliveryLng: 31.2357 + (_random.nextDouble() - 0.5) / 10,
    );
  }

  Order _hydrateOrder(Order order) {
    return order.copyWith(
      createdAt: DateTime.now().subtract(
        Duration(seconds: 20 + _random.nextInt(160)),
      ),
    );
  }

  String _buildPhoneNumber() {
    final suffix = List.generate(8, (_) => _random.nextInt(10)).join();
    return '010$suffix';
  }

  T _pick<T>(List<T> values) {
    return values[_random.nextInt(values.length)];
  }

  void _emitOrders() {
    if (_ordersController.isClosed) return;
    _ordersController.add(List.unmodifiable(_orders));
  }
}

const _pickupLocations = [
  'مدينة نصر',
  'التجمع الخامس',
  'المعادي',
  'الجيزة',
  'شبرا',
];

const _deliveryLocations = [
  'الدقي',
  'وسط البلد',
  'المهندسين',
  'حلوان',
  'مصر الجديدة',
];

const _markets = ['برجر هاوس', 'بيتزا كينج', 'شاورما الشام', 'جرين بول'];

const _products = [
  'برجر لحم',
  'بيتزا مارجريتا',
  'شاورما فراخ',
  'سلطة سيزر',
  'مشروبات',
];

const _customerNames = [
  'أحمد محمد',
  'هبة علي',
  'محمد حسن',
  'منى خالد',
  'سامي محمود',
];
