import 'package:captain_app/cubits/wallet_cubit/wallet_state.dart';
import 'package:captain_app/services/wallet_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletService _walletService;
  final String token;

  WalletCubit({required WalletService walletService, required this.token})
    : _walletService = walletService,
      super(WalletInitial());

  // ─── جيب البيانات من الـ API ───────────────────────────────
  Future<void> loadStatement() async {
    emit(WalletLoading());
    try {
      final wallet = await _walletService.fetchWalletStatement(token);
      emit(WalletLoaded(wallet));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  // ─── فلتر محلي بدون API ────────────────────────────────────
  void filterByDate(DateTime? from, DateTime? to) {
    final current = state;
    if (current is! WalletLoaded) return;

    if (from == null && to == null) {
      emit(WalletLoaded(current.wallet));
      return;
    }

    final filtered = current.wallet.transactions.where((t) {
      // ─── استخرج date فقط بـ UTC ────────────────────────
      final d = t.createdAt;
      final dateOnly = DateTime.utc(d.year, d.month, d.day);

      final fromOnly = from != null
          ? DateTime.utc(from.year, from.month, from.day)
          : null;
      final toOnly = to != null
          ? DateTime.utc(to.year, to.month, to.day)
          : null;

      final afterFrom = fromOnly == null || !dateOnly.isBefore(fromOnly);
      final beforeTo = toOnly == null || !dateOnly.isAfter(toOnly);

      return afterFrom && beforeTo;
    }).toList();

    emit(WalletLoaded.filtered(current.wallet, filtered));
  }
}
