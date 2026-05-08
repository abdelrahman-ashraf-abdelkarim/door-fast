enum OrderStatus { waiting, accepted, delivered, cancelled, newOrder }

enum OrderStatusFilter { waiting, accepted, delivered, newOrder }

enum OrderKind { company, personToPerson }

class OrderContact {
  final String name;
  final String? phoneOne;
  final String? phoneTwo;

  final String notes;
  final String? address;

  const OrderContact({
    required this.name,
    required this.phoneOne,
    this.phoneTwo,
    this.notes = '',
    this.address = '',
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
  final double deliveryPrice;
  final String notes;
  final String? cancelReason;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final double? descount;

  String get receiverName => receiver.name;
  String get receiverPhoneOne => receiver.phoneOne ?? "";
  String get receiverPhoneTwo => receiver.phoneTwo ?? "";
  String get receiverAddress => receiver.address ?? "";
  String get senderName => sender?.name ?? "";
  String get senderPhoneOne => sender?.phoneOne ?? "";
  String get senderPhoneTwo => sender?.phoneTwo ?? "";
  String get senderAddress => sender?.address ?? "";
  bool get isPersonToPerson => sender != null;
  bool get isPending =>
      status == OrderStatus.waiting || status == OrderStatus.newOrder;

  int get totalItemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get itemsTotalPrice =>
      items.fold(0, (sum, item) => sum + item.totalPrice);

  double get totalPrice => itemsTotalPrice + deliveryPrice - (descount ?? 0);

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

  static OrderStatus _parseStatus(String status) {
    switch (status) {
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

  Order({
    required this.id,
    required this.orderNumber,
    required this.receiver,
    this.sender,
    this.kind = OrderKind.company,
    required this.deliveryPrice,
    this.descount,
    required this.notes,
    this.cancelReason,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.items = const [],
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
  }) {
    return Order(
      id: id,
      orderNumber: orderNumber,
      receiver: receiver,
      sender: sender ?? this.sender,
      kind: kind ?? this.kind,
      deliveryPrice: deliveryPrice,
      notes: notes,
      cancelReason: cancelReason ?? this.cancelReason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      items: items ?? this.items,
      descount: descount ?? this.descount,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    final client = json['client'];
    final sendTo = json['send_to'];

    final receiver = OrderContact(
      name: sendTo?['name'] ?? client['name'],
      phoneOne: sendTo?['phone'] ?? client['phone'],
      phoneTwo: sendTo?['phone2'] ?? client['phone2'],
      address: sendTo?['address'] ?? client['address'] ?? '',
    );

    /// 👇 المرسل موجود بس في حالة person-to-person
    OrderContact? sender;

    if (sendTo != null) {
      sender = OrderContact(
        name: client['name'],
        phoneOne: client['phone'],
        phoneTwo: client['phone2'],
        address: client['address'] ?? '',
      );
    }
    return Order(
      id: json['id'].toString(),
      orderNumber: json['order_number'],
      receiver: receiver,
      sender: sender,
      kind: sendTo != null ? OrderKind.personToPerson : OrderKind.company,
      deliveryPrice: (json['delivery_fee'] as num).toDouble(),
      notes: json['notes'] ?? '',
      status: Order._parseStatus(json['status']),
      createdAt: DateTime.parse(json['created_at']),
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'])
          : null,
      descount: json['discount'] != null
          ? (json['discount'] as num).toDouble()
          : null,
      items: (json['items'] as List)
          .map(
            (item) => OrderItem(
              productName: item['item_name'],
              quantity: item['quantity'],
              deliveryPrice: (item['unit_price'] as num).toDouble(),
              marketPlace: item['shop']?['name'] ?? '',
            ),
          )
          .toList(),
    );
  }
}
