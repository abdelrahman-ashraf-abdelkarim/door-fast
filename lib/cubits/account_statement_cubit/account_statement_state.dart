import 'package:captain_app/models/transaction_model.dart';
import 'package:captain_app/models/wallet_model.dart';

abstract class AccountStatementState {}

// ─── الحالة الابتدائية ────────────────────────────────────────────────────────
class AccountStatementInitial extends AccountStatementState {}

// ─── جاري التحميل (أول مرة) ──────────────────────────────────────────────────
class AccountStatementLoading extends AccountStatementState {}

// ─── البيانات موجودة (HTTP أو WebSocket) ─────────────────────────────────────
class AccountStatementLoaded extends AccountStatementState {
  /// البيانات الكاملة كما جاءت من الـ API
  final WalletModel wallet;

  /// القائمة المعروضة (قد تكون مفلترة بالتاريخ)
  final List<TransactionModel> displayedTransactions;

  /// نطاق الفلتر الحالي — null يعني "بدون فلتر"
  final DateTime? filterFrom;
  final DateTime? filterTo;

  /// true = وصلت transaction جديدة عبر WebSocket للتو
  final bool hasNewRealtime;

  // ─── Constructor لأول تحميل (بدون فلتر) ─────────────────────────────────
  AccountStatementLoaded(this.wallet, List<TransactionModel> transactions)
    : displayedTransactions = wallet.transactions,
      filterFrom = null,
      filterTo = null,
      hasNewRealtime = false;

  // ─── Constructor خاص (داخلي للـ copyWith) ───────────────────────────────
  AccountStatementLoaded._({
    required this.wallet,
    required this.displayedTransactions,
    required this.filterFrom,
    required this.filterTo,
    required this.hasNewRealtime,
  });

  // ─── copyWith لتحديث جزء من الحالة فقط ──────────────────────────────────
  AccountStatementLoaded copyWith({
    WalletModel? wallet,
    List<TransactionModel>? displayedTransactions,
    DateTime? filterFrom,
    DateTime? filterTo,
    bool clearFilter = false,
    bool? hasNewRealtime,
  }) {
    return AccountStatementLoaded._(
      wallet: wallet ?? this.wallet,
      displayedTransactions:
          displayedTransactions ?? this.displayedTransactions,
      filterFrom: clearFilter ? null : (filterFrom ?? this.filterFrom),
      filterTo: clearFilter ? null : (filterTo ?? this.filterTo),
      hasNewRealtime: hasNewRealtime ?? this.hasNewRealtime,
    );
  }
}

// ─── خطأ ──────────────────────────────────────────────────────────────────────
class AccountStatementError extends AccountStatementState {
  final String message;
  AccountStatementError(this.message);
}
