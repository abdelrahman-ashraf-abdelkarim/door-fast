import 'package:captain_app/models/transaction_model.dart';
import 'package:captain_app/models/wallet_model.dart';

abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final WalletModel wallet;
  final List<TransactionModel> filteredTransactions;

  // كل العمليات بدون فلتر
  WalletLoaded(this.wallet) : filteredTransactions = wallet.transactions;

  // عمليات مفلترة
  WalletLoaded.filtered(this.wallet, this.filteredTransactions);
}

class WalletError extends WalletState {
  final String message;
  WalletError(this.message);
}