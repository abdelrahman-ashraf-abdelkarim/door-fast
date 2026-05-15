class TransactionModel {
  final int id;
  final int logId;
  final int? walletId;
  final String type;
  final double amount;
  final String direction; // 'debit' or 'credit'
  final double balanceAfter;
  final String description;
  final int? relatedWalletId;
  final int? orderId;
  final int? createdBy;
  final DateTime? transactionDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TransactionModel({
    required this.id,
    required this.logId,
    this.walletId,
    required this.type,
    required this.amount,
    required this.direction,
    required this.balanceAfter,
    required this.description,
    this.relatedWalletId,
    this.orderId,
    this.createdBy,
    this.transactionDate,
    required this.createdAt,
    this.updatedAt,
  });

  // ─── Getters مساعدة ───────────────────────────────────────────────────────
  bool get isDebit => direction == 'debit';
  bool get isCredit => direction == 'credit';

  double? get debit => isDebit ? amount : null;
  double? get credit => isCredit ? amount : null;
  double get balance => balanceAfter;

  // ─── fromJson ─────────────────────────────────────────────────────────────
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      logId: json['log_id'] ?? 0,
      walletId: json['wallet_id'],
      type: json['type'] ?? '',
      amount: double.parse(json['amount'].toString()),
      direction: json['direction'] ?? 'debit',
      balanceAfter: double.parse(json['balance_after'].toString()),
      description: json['description'] ?? '',
      relatedWalletId: json['related_wallet_id'],
      orderId: json['order_id'],
      createdBy: json['created_by'],
      transactionDate: json['transaction_date'] != null
          ? DateTime.parse(json['transaction_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // ─── toJson (مفيد لو محتاج تبعت البيانات) ────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'type': type,
      'amount': amount.toString(),
      'direction': direction,
      'balance_after': balanceAfter.toString(),
      'description': description,
      'related_wallet_id': relatedWalletId,
      'order_id': orderId,
      'created_by': createdBy,
      'transaction_date': transactionDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
