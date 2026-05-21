import 'dart:async';
import 'dart:collection';

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

  // ✅ Queue هي المصدر الوحيد للحقيقة — مش wallet.transactions
  final ListQueue<TransactionModel> _queue = ListQueue();
  static const int _maxTransactions = 60;

  AccountStatementCubit({
    required WalletService walletService,
    required WebSocketService webSocketService,
    required this.token,
  }) : _walletService = walletService,
       _webSocketService = webSocketService,
       super(AccountStatementInitial());

  // ─── 1. تحميل أول مرة ────────────────────────────────────────────────────
  Future<void> loadStatement() async {
    emit(AccountStatementLoading());
    try {
      final wallet = await _walletService.fetchWalletStatement(token);
      if (isClosed) return;

      // ✅ ملّي الـ Queue وحدّد بـ 60
      _queue.clear();
      for (final t in wallet.transactions.take(_maxTransactions)) {
        _queue.addLast(t);
      }

      // ✅ الـ State بياخد snapshot من الـ Queue — مش wallet.transactions مباشرة
      final queueSnapshot = _queue.toList();
      emit(
        AccountStatementLoaded(
          wallet.copyWith(transactions: queueSnapshot),
          queueSnapshot,
        ),
      );
      _subscribeToWebSocket();
    } catch (e) {
      if (isClosed) return;
      emit(AccountStatementError(e.toString()));
    }
  }

  // ─── 2. WebSocket ─────────────────────────────────────────────────────────
  void _subscribeToWebSocket() {
    _wsSub?.cancel();
    _wsSub = _webSocketService.stream.listen((event) {
      if (event['event'] == 'wallet_updated') {
        _onWalletUpdated(event);
      }
    });
  }

  // ─── 3. استقبال wallet_updated ───────────────────────────────────────────
  void _onWalletUpdated(Map<String, dynamic> event) {
    final current = state;
    if (current is! AccountStatementLoaded) return;

    // ① حدّث الرصيد فوراً بدون HTTP
    final newBalance = double.tryParse(event['balance']?.toString() ?? '');
    if (newBalance != null) {
      emit(
        current.copyWith(
          wallet: current.wallet.copyWith(currentBalance: newBalance),
          hasNewRealtime: true,
        ),
      );
    }

    // ② اجلب الـ transaction الجديدة في الخلفية
    _reloadSilently();
  }

  // ─── 4. Reload صامت — يضيف فوق الـ Queue بدون rebuild كامل ──────────────
  Future<void> _reloadSilently() async {
    try {
      final wallet = await _walletService.fetchWalletStatement(token);
      if (isClosed) return;

      // ✅ إيجاد الـ IDs الموجودة في الـ Queue
      final existingIds = _queue.map((t) => t.id).toSet();

      // ✅ ضيف الجديدة فوق فقط (بالترتيب — الأحدث أولاً)
      final newTransactions = wallet.transactions
          .where((t) => !existingIds.contains(t.id))
          .toList();

      for (final t in newTransactions) {
        _queue.addFirst(t);
        if (_queue.length > _maxTransactions) {
          _queue.removeLast(); // ← O(1)
        }
      }

      final current = state;
      if (current is! AccountStatementLoaded) return;

      // ✅ الفلتر بيشتغل على الـ Queue مش wallet.transactions
      final queueSnapshot = _queue.toList();
      final filtered = _applyFilter(
        queueSnapshot,
        current.filterFrom,
        current.filterTo,
      );

      emit(
        current.copyWith(
          wallet: wallet.copyWith(transactions: queueSnapshot),
          displayedTransactions: filtered,
          hasNewRealtime: true,
        ),
      );
    } catch (_) {}
  }

  // ─── 5. فلتر محلي ────────────────────────────────────────────────────────
  void filterByDate(DateTime? from, DateTime? to) {
    final current = state;
    if (current is! AccountStatementLoaded) return;

    // ✅ الفلتر من الـ Queue — مش wallet.transactions
    final queueSnapshot = _queue.toList();

    if (from == null && to == null) {
      emit(
        current.copyWith(
          displayedTransactions: queueSnapshot,
          clearFilter: true,
        ),
      );
      return;
    }

    final filtered = _applyFilter(queueSnapshot, from, to);
    emit(
      current.copyWith(
        displayedTransactions: filtered,
        filterFrom: from,
        filterTo: to,
      ),
    );
  }

  // ─── 6. Acknowledge ──────────────────────────────────────────────────────
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

  @override
  Future<void> close() {
    _wsSub?.cancel();
    return super.close();
  }
}
