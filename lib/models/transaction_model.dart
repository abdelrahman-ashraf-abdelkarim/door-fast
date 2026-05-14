class TransactionModel {
  final int id;
  final String type;
  final double amount;
  final String direction; // 'debit' or 'credit'
  final double balanceAfter;
  final String description;
  final int? orderId;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.direction,
    required this.balanceAfter,
    required this.description,
    this.orderId,
    required this.createdAt,
  });

  bool get isDebit => direction == 'debit';
  bool get isCredit => direction == 'credit';

  double? get debit => isDebit ? amount : null;
  double? get credit => isCredit ? amount : null;
  double get balance => balanceAfter;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      type: json['type'] ?? '',
      amount: double.parse(json['amount'].toString()),
      direction: json['direction'] ?? 'debit',
      balanceAfter: double.parse(json['balance_after'].toString()),
      description: json['description'] ?? '',
      orderId: json['order_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
