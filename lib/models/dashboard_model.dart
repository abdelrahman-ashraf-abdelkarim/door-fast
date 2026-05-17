class DashboardData {
  final bool shiftActive;
  final int shiftId;
  final int newOrders;
  final int activeOrders;
  final int deliveredToday;
  final int cancelledToday;
  final double feesToday;
  final double profitToday;
  final int currentTier;
  final double collectionToday;
  final double discountToday;

  const DashboardData({
    required this.shiftActive,
    required this.shiftId,
    required this.newOrders,
    required this.activeOrders,
    required this.deliveredToday,
    required this.cancelledToday,
    required this.feesToday,
    required this.profitToday,
    required this.currentTier,
    required this.collectionToday,
    required this.discountToday,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return DashboardData(
      shiftActive: data['shift_active'] as bool? ?? false,
      shiftId: data['shift_id'] as int? ?? 0,
      newOrders: data['new_orders'] as int? ?? 0,
      activeOrders: data['active_orders'] as int? ?? 0,
      deliveredToday: data['delivered_today'] as int? ?? 0,
      discountToday: (data['discount_today'] as num?)?.toDouble() ?? 0,
      cancelledToday: data['cancelled_today'] as int? ?? 0,
      feesToday: (data['fees_today'] as num?)?.toDouble() ?? 0.0,
      collectionToday: (data['collection_today'] as num?)?.toDouble() ?? 0.0,
      profitToday: (data['profit_today'] as num?)?.toDouble() ?? 0.0,
      currentTier: data['current_tier'] as int? ?? 0,
    );
  }
}
