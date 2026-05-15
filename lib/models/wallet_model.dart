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

  // ─── fromJson ─────────────────────────────────────────────────────────────
  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final paginated = data['transactions'];

    return WalletModel(
      currentBalance: (data['current_balance'] as num).toDouble(),
      totalDebit: (data['total_debit'] as num).toDouble(),
      totalCredit: (data['total_credit'] as num).toDouble(),
      transactions: (paginated['data'] as List)
          .map((t) => TransactionModel.fromJson(t))
          .toList(),
      currentPage: paginated['current_page'],
      lastPage: paginated['last_page'],
      total: paginated['total'],
    );
  }
}
