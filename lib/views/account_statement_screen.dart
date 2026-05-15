import 'package:captain_app/api/api.dart';
import 'package:captain_app/core/constants.dart';
import 'package:captain_app/core/format_date_for_account.dart';
import 'package:captain_app/cubits/account_statement_cubit/account_statement_cubit.dart';
import 'package:captain_app/cubits/account_statement_cubit/account_statement_state.dart';
import 'package:captain_app/cubits/auth_cubit/auth_cubit.dart';
import 'package:captain_app/cubits/auth_cubit/auth_state.dart';
import 'package:captain_app/models/transaction_model.dart';
import 'package:captain_app/services/wallet_service.dart';
import 'package:captain_app/services/web_socket_service.dart';
import 'package:captain_app/views/transaction_log_screen.dart';
import 'package:captain_app/widgets/current_balance_card.dart';
import 'package:captain_app/widgets/dues_card_widget.dart';
import 'package:captain_app/widgets/transaction_log_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AccountStatementScreen extends StatelessWidget {
  const AccountStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return const SizedBox();

    return BlocProvider(
      create: (_) => AccountStatementCubit(
        walletService: WalletService(api: Api(context.read<AuthCubit>())),
        webSocketService: WebSocketService(),
        token: authState.token,
      )..loadStatement(),
      child: const _AccountStatementView(),
    );
  }
}

class _AccountStatementView extends StatelessWidget {
  const _AccountStatementView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "كشف الحساب",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.screenBackground,
        centerTitle: true,
      ),
      body: BlocBuilder<AccountStatementCubit, AccountStatementState>(
        builder: (context, state) {
          // ─── Loading ────────────────────────────────────────────────────
          if (state is AccountStatementLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ─── Error ──────────────────────────────────────────────────────
          if (state is AccountStatementError) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<AccountStatementCubit>().loadStatement(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          // ─── Loaded ─────────────────────────────────────────────────────
          if (state is AccountStatementLoaded) {
            final wallet = state.wallet;
            final previewTransactions = state.displayedTransactions
                .take(3)
                .toList();

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── الرصيد الحالي ─────────────────────────────────
                      CurrentBalanceCard(balance: wallet.currentBalance),

                      const SizedBox(height: 16),

                      // ─── إجمالي المدين والدائن ─────────────────────────
                      Row(
                        children: [
                          DuesCardWidget(
                            title: "اجمالى المدين",
                            text: wallet.totalDebit.toStringAsFixed(0),
                            icon: Icons.arrow_downward_sharp,
                            iconBackgroundColor:
                                AppColors.customerIconSecondaryBackground,
                            iconForegroundColor:
                                AppColors.customerIconSecondaryForeground,
                          ),
                          DuesCardWidget(
                            title: "اجمالى الدائن",
                            text: wallet.totalCredit.toStringAsFixed(0),
                            icon: Icons.arrow_upward_sharp,
                            iconBackgroundColor:
                                AppColors.customerIconPrimaryBackground,
                            iconForegroundColor:
                                AppColors.customerIconPrimaryForeground,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ─── سجل العمليات ──────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "سجل العمليات",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context
                                        .read<AccountStatementCubit>(),
                                    child: const TransactionLogScreen(),
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "عرض الكل",
                              style: TextStyle(
                                color: AppColors.accentOrange,
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ─── أول 3 عمليات ──────────────────────────────────
                      ...previewTransactions.map(
                        (t) => _TransactionItem(transaction: t),
                      ),
                    ],
                  ),
                ),

                // ─── Badge "تحديث جديد" عند وصول بيانات WebSocket ────────
                if (state.hasNewRealtime)
                  Positioned(
                    top: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => context
                            .read<AccountStatementCubit>()
                            .acknowledgeRealtime(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(99, 112, 102, 224),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_upward,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'تحديث جديد',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

// ─── Widget مساعد لكل عملية ───────────────────────────────────────────────────
class _TransactionItem extends StatelessWidget {
  const _TransactionItem({required this.transaction});
  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final isDebit = transaction.isDebit;

    // استخدم transaction_date لو موجودة، وإلا created_at
    final date = transaction.createdAt;
    final parts = formatDateParts(date);
    final priceStr =
        '${isDebit ? '+' : '-'}${transaction.amount.toStringAsFixed(0)} ج.م';

    final icon = transaction.type == 'delivery_fee_received'
        ? FontAwesomeIcons.truckFast
        : FontAwesomeIcons.moneyBills;

    return TransactionLogWidget(
      icon: icon,
      foregroundIconColor: isDebit
          ? AppColors.customerIconSecondaryForeground
          : AppColors.customerIconPrimaryForeground,
      backgroundIconColor: isDebit
          ? AppColors.customerIconSecondaryBackground
          : AppColors.customerIconPrimaryBackground,
      title: transaction.description,
      day: parts.day,
      month: parts.month,
      yearAndHour: parts.yearAndHour,
      price: priceStr,
      isEntry: isDebit,
    );
  }
}
