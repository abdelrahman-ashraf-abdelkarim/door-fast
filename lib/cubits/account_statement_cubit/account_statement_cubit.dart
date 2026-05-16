import 'dart:async';

import 'package:captain_app/cubits/account_statement_cubit/account_statement_state.dart';
import 'package:captain_app/models/transaction_model.dart';
import 'package:captain_app/services/wallet_service.dart';
import 'package:captain_app/services/web_socket_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountStatementCubit extends Cubit<AccountStatementState> {
  final WalletService _walletService;
  final WebSocketService _webSocketService;
  final String token;

  StreamSubscription<Map<String, dynamic>>? _wsSub;

  AccountStatementCubit({
    required WalletService walletService,
    required WebSocketService webSocketService,
    required this.token,
  }) : _walletService = walletService,
       _webSocketService = webSocketService,
       super(AccountStatementInitial());

  // ─── 1. تحميل البيانات عبر HTTP ──────────────────────────────────────────
  // يُستخدم للتحميل الأول وللـ reload بعد وصول event من WebSocket
  Future<void> loadStatement() async {
    emit(AccountStatementLoading());
    try {
      final wallet = await _walletService.fetchWalletStatement(token);
      emit(AccountStatementLoaded(wallet));
      _subscribeToWebSocket();
    } catch (e) {
      emit(AccountStatementError(e.toString()));
    }
  }

  // ─── 2. الاشتراك في stream الـ WebSocket ─────────────────────────────────
  void _subscribeToWebSocket() {
    _wsSub?.cancel();

    _wsSub = _webSocketService.stream.listen((event) {
      final eventType = event['event'] as String?;

      // ─── wallet.updated من Backend ────────────────────────────────────────
      // البيانات الواصلة: { balance, amount, type, direction }
      // البيانات ناقصة (مفيش id, description, created_at)
      // → نحدث الرصيد فوراً، ثم reload صامت لجلب التفاصيل الكاملة
      if (eventType == 'wallet_updated') {
        _onWalletUpdated(event);
      }
    });
  }

  // ─── 3. استقبال حدث wallet.updated ───────────────────────────────────────
  void _onWalletUpdated(Map<String, dynamic> event) {
    final current = state;
    if (current is! AccountStatementLoaded) return;

    // ① حدّث الرصيد فوراً في الـ UI من البيانات الواصلة (بدون انتظار)
    final newBalance = double.tryParse(event['balance']?.toString() ?? '');
    if (newBalance != null) {
      emit(
        current.copyWith(
          wallet: current.wallet.copyWith(currentBalance: newBalance),
          hasNewRealtime: true,
        ),
      );
    }

    // ② اعمل reload في الخلفية لجلب كامل بيانات الـ transaction الجديدة
    _reloadSilently();
  }

  // ─── 4. Reload صامت — يحدّث البيانات بدون spinner ───────────────────────
  Future<void> _reloadSilently() async {
    try {
      final wallet = await _walletService.fetchWalletStatement(token);

      final current = state;
      if (current is! AccountStatementLoaded) {
        emit(AccountStatementLoaded(wallet));
        return;
      }

      // طبّق الفلتر الحالي على البيانات الجديدة
      final filtered = _applyFilter(
        wallet.transactions,
        current.filterFrom,
        current.filterTo,
      );

      emit(
        current.copyWith(
          wallet: wallet,
          displayedTransactions: filtered,
          hasNewRealtime: true,
        ),
      );
    } catch (_) {
      // فشل الـ reload الصامت — البيانات الحالية تفضل زي ما هي
    }
  }

  // ─── 5. فلتر محلي بالتاريخ ───────────────────────────────────────────────
  void filterByDate(DateTime? from, DateTime? to) {
    final current = state;
    if (current is! AccountStatementLoaded) return;

    if (from == null && to == null) {
      emit(
        current.copyWith(
          displayedTransactions: current.wallet.transactions,
          clearFilter: true,
        ),
      );
      return;
    }

    final filtered = _applyFilter(current.wallet.transactions, from, to);
    emit(
      current.copyWith(
        displayedTransactions: filtered,
        filterFrom: from,
        filterTo: to,
      ),
    );
  }

  // ─── 6. إيصال إشعار "تمت رؤية البيانات الجديدة" ─────────────────────────
  void acknowledgeRealtime() {
    final current = state;
    if (current is! AccountStatementLoaded) return;
    emit(current.copyWith(hasNewRealtime: false));
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  List<TransactionModel> _applyFilter(
    List<TransactionModel> transactions,
    DateTime? from,
    DateTime? to,
  ) {
    if (from == null && to == null) return transactions;

    return transactions.where((t) {
      final d = t.createdAt.toUtc().add(const Duration(hours: 3));
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
  }

  // ─── تنظيف الـ subscription عند إغلاق الـ Cubit ─────────────────────────
  @override
  Future<void> close() {
    _wsSub?.cancel();
    return super.close();
  }
}
