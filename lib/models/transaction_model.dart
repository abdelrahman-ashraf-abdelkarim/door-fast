import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  /// النص المعروض للمبلغ مع الإشارة والعملة — انتقل من الـ UI للـ model
  String get displayAmount =>
      '${isDebit ? '+' : '-'}${amount.toStringAsFixed(0)} ج.م';

  /// الأيقونة المناسبة لنوع العملية — انتقل من الـ UI للـ model
  FaIconData get displayIcon => type == 'delivery_fee_received'
      ? FontAwesomeIcons.truckFast
      : FontAwesomeIcons.moneyBills;

  // ─── helpers داخلية ───────────────────────────────────────────────────────

  /// يحوّل أي قيمة لـ double بأمان — يرجع 0.0 لو القيمة null أو مش رقم
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  /// يحوّل أي قيمة لـ int بأمان — يرجع 0 لو القيمة null أو مش رقم
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  /// يحوّل أي قيمة لـ int? بأمان — يرجع null لو القيمة null
  static int? _toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  /// يحوّل String لـ DateTime بأمان — يرجع null لو فشل الـ parse
  static DateTime? _toDateOrNull(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  // ─── fromJson ─────────────────────────────────────────────────────────────
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: _toInt(json['id']),
      logId: _toInt(json['log_id']),
      walletId: _toIntOrNull(json['wallet_id']),
      type: json['type']?.toString() ?? '',
      amount: _toDouble(json['amount']),
      direction: json['direction']?.toString() ?? 'debit',
      balanceAfter: _toDouble(json['balance_after']),
      description: json['description']?.toString() ?? '',
      relatedWalletId: _toIntOrNull(json['related_wallet_id']),
      orderId: _toIntOrNull(json['order_id']),
      createdBy: _toIntOrNull(json['created_by']),
      transactionDate: _toDateOrNull(json['transaction_date']),
      // لو created_at مش موجودة نستخدم الوقت الحالي كـ fallback بدل crash
      createdAt: _toDateOrNull(json['created_at']) ?? DateTime.now(),
      updatedAt: _toDateOrNull(json['updated_at']),
    );
  }

  // ─── toJson ───────────────────────────────────────────────────────────────
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
