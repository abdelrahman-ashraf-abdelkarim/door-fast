import 'package:captain_app/models/transaction_model.dart';

class WalletModel {
  final double currentBalance;
  final double totalDebit;
  final double totalCredit;
  final List<TransactionModel> transactions;
  final int currentPage;
  final int lastPage;
  final int total;

  WalletModel({
    required this.currentBalance,
    required this.totalDebit,
    required this.totalCredit,
    required this.transactions,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  // ─── copyWith ─────────────────────────────────────────────────────────────
  WalletModel copyWith({
    double? currentBalance,
    double? totalDebit,
    double? totalCredit,
    List<TransactionModel>? transactions,
    int? currentPage,
    int? lastPage,
    int? total,
  }) {
    return WalletModel(
      currentBalance: currentBalance ?? this.currentBalance,
      totalDebit: totalDebit ?? this.totalDebit,
      totalCredit: totalCredit ?? this.totalCredit,
      transactions: transactions ?? this.transactions,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
    );
  }

  // ─── helpers داخلية ───────────────────────────────────────────────────────

  /// يحوّل أي قيمة لـ double بأمان
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  /// يحوّل أي قيمة لـ int بأمان
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  // ─── fromJson ─────────────────────────────────────────────────────────────
  factory WalletModel.fromJson(Map<String, dynamic> json) {
    // ── الـ data الرئيسية ──────────────────────────────────────────────────
    // لو json['data'] مش Map نرجع model فاضي بدل crash
    final rawData = json['data'];
    final data = rawData is Map<String, dynamic>
        ? rawData
        : (rawData is Map
              ? Map<String, dynamic>.from(rawData)
              : <String, dynamic>{});

    // ── بيانات الـ pagination ──────────────────────────────────────────────
    // لو data['transactions'] مش Map نستخدم map فاضي
    final rawPaginated = data['transactions'];
    final paginated = rawPaginated is Map<String, dynamic>
        ? rawPaginated
        : (rawPaginated is Map
              ? Map<String, dynamic>.from(rawPaginated)
              : <String, dynamic>{});

    // ── قائمة الـ transactions ─────────────────────────────────────────────
    // لو paginated['data'] مش List نستخدم قائمة فاضية
    final rawList = paginated['data'];
    final transactionList = rawList is List ? rawList : <dynamic>[];

    return WalletModel(
      currentBalance: _toDouble(data['current_balance']),
      totalDebit: _toDouble(data['total_debit']),
      totalCredit: _toDouble(data['total_credit']),
      transactions: transactionList
          .whereType<Map>()
          .map(
            (t) => TransactionModel.fromJson(
              t is Map<String, dynamic> ? t : Map<String, dynamic>.from(t),
            ),
          )
          .toList(),
      currentPage: _toInt(paginated['current_page']),
      lastPage: _toInt(paginated['last_page']),
      total: _toInt(paginated['total']),
    );
  }
}
