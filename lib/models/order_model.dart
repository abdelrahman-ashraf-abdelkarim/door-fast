enum OrderStatus { waiting, accepted, delivered, cancelled, newOrder }

enum OrderStatusFilter { waiting, accepted, delivered, newOrder }

enum OrderKind { company, personToPerson }

enum Discountype { percent, amount }

class OrderContact {
  final String name;
  final String? phoneOne;
  final String? phoneTwo;

  final String notes;
  final String? address;
  final String? linkAddress;

  const OrderContact({
    required this.name,
    required this.phoneOne,
    this.phoneTwo,
    this.notes = '',
    this.address = '',
    this.linkAddress = '',
  });
}

class OrderItem {
  final String productName;
  final int quantity;
  final double deliveryPrice;
  final String details;
  final String marketPlace;

  const OrderItem({
    required this.productName,
    required this.quantity,
    required this.deliveryPrice,
    this.details = '',
    this.marketPlace = '',
  });

  double get totalPrice => quantity * deliveryPrice;
}

class Order {
  final String id;
  final String orderNumber;
  final OrderContact receiver;
  final OrderContact? sender;
  final OrderKind kind;
  final double deliveryFee;
  final Discountype? discountType;
  final String notes;
  final String? cancelReason;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final double? descount;
  final bool isDeliveryChosen;

  String get receiverName => receiver.name;
  String get receiverPhoneOne => receiver.phoneOne ?? "";
  String get receiverPhoneTwo => receiver.phoneTwo ?? "";
  String get receiverAddress => receiver.address ?? "";
  String get receiverLinkAddress => receiver.linkAddress ?? "";
  String get senderName => sender?.name ?? "";
  String get senderPhoneOne => sender?.phoneOne ?? "";
  String get senderPhoneTwo => sender?.phoneTwo ?? "";
  String get senderAddress => sender?.address ?? "";
  String get senderLinkAddress => sender?.linkAddress ?? "";
  bool get isPersonToPerson => sender != null;
  bool get isPending =>
      status == OrderStatus.waiting || status == OrderStatus.newOrder;

  int get totalItemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get itemsTotalPrice =>
      items.fold(0, (sum, item) => sum + item.totalPrice);

  double get discountValue {
    if (descount == 0 || discountType == null) return 0;
    if (discountType == Discountype.percent) {
      return ((itemsTotalPrice + deliveryFee) * (descount! / 100));
    }
    return descount!; // amount
  }

  double get totalPrice => itemsTotalPrice + deliveryFee - discountValue;

  Duration get waitingDuration => DateTime.now().difference(createdAt);

  Duration get acceptedDuration {
    final acceptedTime = acceptedAt;
    if (acceptedTime == null) return Duration.zero;
    return DateTime.now().difference(acceptedTime);
  }

  Duration get activeDuration {
    if (isPending) return waitingDuration;
    if (status == OrderStatus.accepted) return acceptedDuration;
    return acceptedAt == null ? waitingDuration : acceptedDuration;
  }

  /// يجمّع الـ items حسب الـ marketplace اسمه — انتقل من الـ UI للـ model
  /// مثال: { 'كارفور': [item1, item2], 'غير محدد': [item3] }
  Map<String, List<OrderItem>> get groupedByMarketplace {
    final grouped = <String, List<OrderItem>>{};
    for (final item in items) {
      final key = item.marketPlace.isEmpty ? 'غير محدد' : item.marketPlace;
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  static OrderStatus _parseStatus(Object? status) {
    switch (status?.toString()) {
      case 'pending':
        return OrderStatus.waiting;
      case 'received':
        return OrderStatus.accepted;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.waiting;
    }
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return const {};
  }

  static List<dynamic> _asList(Object? value) {
    if (value is List) return value;
    return const [];
  }

  static String _asString(Object? value, [String fallback = '']) {
    return value?.toString() ?? fallback;
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static bool _asBool(Object? value) {
    if (value is bool) return value;
    final normalized = value?.toString().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }

  static DateTime? _tryParseDate(Object? value) {
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '');
  }

  Order({
    required this.id,
    required this.orderNumber,
    required this.receiver,
    this.sender,
    this.kind = OrderKind.company,
    required this.deliveryFee,
    this.descount,
    this.discountType,
    required this.notes,
    this.cancelReason,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.items = const [],
    this.isDeliveryChosen = false,
  });

  Order copyWith({
    OrderStatus? status,
    List<OrderItem>? items,
    String? cancelReason,
    OrderContact? sender,
    OrderKind? kind,
    DateTime? createdAt,
    DateTime? acceptedAt,
    double? descount,
    Discountype? discountType,
  }) {
    return Order(
      id: id,
      orderNumber: orderNumber,
      receiver: receiver,
      sender: sender ?? this.sender,
      kind: kind ?? this.kind,
      deliveryFee: deliveryFee,
      notes: notes,
      cancelReason: cancelReason ?? this.cancelReason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      items: items ?? this.items,
      descount: descount ?? this.descount,
      discountType: discountType ?? this.discountType,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    // [FIX-14] safe null handling for API fields that may be missing
    final client = _asMap(json['client']);
    final sendTo = _asMap(json['send_to']);
    final hasSendTo = sendTo.isNotEmpty;

    final receiver = OrderContact(
      name: _asString(sendTo['name'] ?? client['name']),
      phoneOne: _asString(sendTo['phone'] ?? client['phone']),
      phoneTwo: _asString(sendTo['phone2'] ?? client['phone2']),
      address: _asString(sendTo['address'] ?? client['address']),
      linkAddress: _asString(
        sendTo['delivery_link'] ?? client['delivery_link'],
      ),
    );

    /// 👇 المرسل موجود بس في حالة person-to-person
    OrderContact? sender;

    if (hasSendTo) {
      sender = OrderContact(
        name: _asString(client['name']),
        phoneOne: _asString(client['phone']),
        phoneTwo: _asString(client['phone2']),
        address: _asString(client['address']),
        linkAddress: _asString(client['delivery_link']),
      );
    }
    return Order(
      id: _asString(json['id']),
      orderNumber: _asString(json['order_number']),
      receiver: receiver,
      sender: sender,
      kind: hasSendTo ? OrderKind.personToPerson : OrderKind.company,
      deliveryFee: _asDouble(json['delivery_fee']),
      notes: _asString(json['notes']),
      isDeliveryChosen: _asBool(json['is_delivery_chosen']),
      status: Order._parseStatus(json['status']),
      createdAt: _tryParseDate(json['created_at']) ?? DateTime.now(),
      acceptedAt: _tryParseDate(json['accepted_at']),
      descount: json['discount'] != null ? _asDouble(json['discount']) : null,
      items: _asList(json['items']).map((item) {
        final itemMap = _asMap(item);
        final shop = _asMap(itemMap['shop']);
        return OrderItem(
          productName: _asString(itemMap['item_name']),
          quantity: _asInt(itemMap['quantity']),
          deliveryPrice: _asDouble(itemMap['unit_price']),
          marketPlace: _asString(shop['name']),
        );
      }).toList(),
      discountType: json['discount_type'] == 'percent'
          ? Discountype.percent
          : json['discount_type'] == 'amount'
          ? Discountype.amount
          : null,
    );
  }
}
