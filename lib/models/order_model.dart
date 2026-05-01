enum OrderStatus { waiting, accepted, delivered, cancelled, newOrder }

enum OrderStatusFilter { waiting, accepted, delivered, newOrder }

enum OrderKind { company, personToPerson }

class OrderContact {
  final String name;
  final String? phone;
  final String notes;

  const OrderContact({
    required this.name,
    required this.phone,
    this.notes = '',
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
  final OrderContact dropoffContact;
  final OrderContact? pickupContact;
  final OrderKind kind;
  final String pickupLocation;
  final String deliveryLocation;
  final double deliveryPrice;
  final String paymentMethod;
  final String notes;
  final String? cancelReason;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final double? pickupLat;
  final double? pickupLng;
  final double? deliveryLat;
  final double? deliveryLng;

  String get customerName => dropoffContact.name;
  String get phone => dropoffContact.phone ?? "";
  bool get isPersonToPerson => kind == OrderKind.personToPerson;
  bool get isPending {
    return status == OrderStatus.waiting || status == OrderStatus.newOrder;
  }

  String get formattedId {
    return '#${id.padLeft(6, '0')}';
  }

  int get totalItemsCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get itemsTotalPrice {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get totalPrice {
    return itemsTotalPrice + deliveryPrice;
  }

  Duration get waitingDuration {
    return DateTime.now().difference(createdAt);
  }

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

  Order({
    required this.id,
    required this.dropoffContact,
    this.pickupContact,
    this.kind = OrderKind.company,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.deliveryPrice,
    required this.paymentMethod,
    required this.notes,
    this.cancelReason,
    required this.status,
    DateTime? createdAt,
    this.acceptedAt,
    this.items = const [],
    this.pickupLat,
    this.pickupLng,
    this.deliveryLat,
    this.deliveryLng,
  }) : createdAt = createdAt ?? DateTime.now();

  Order copyWith({
    OrderStatus? status,
    List<OrderItem>? items,
    String? cancelReason,
    OrderContact? pickupContact,
    OrderContact? dropoffContact,
    OrderKind? kind,
    DateTime? createdAt,
    DateTime? acceptedAt,
  }) {
    return Order(
      id: id,
      dropoffContact: dropoffContact ?? this.dropoffContact,
      pickupContact: pickupContact ?? this.pickupContact,
      kind: kind ?? this.kind,
      pickupLocation: pickupLocation,
      deliveryLocation: deliveryLocation,
      deliveryPrice: deliveryPrice,
      paymentMethod: paymentMethod,
      notes: notes,
      cancelReason: cancelReason ?? this.cancelReason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      items: items ?? this.items,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      deliveryLat: deliveryLat,
      deliveryLng: deliveryLng,
    );
  }
}
