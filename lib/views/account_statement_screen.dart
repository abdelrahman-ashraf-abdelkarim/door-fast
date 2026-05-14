import 'package:captain_app/api/api.dart';
import 'package:captain_app/core/constants.dart';
import 'package:captain_app/cubits/auth_cubit/auth_cubit.dart';
import 'package:captain_app/cubits/auth_cubit/auth_state.dart';
import 'package:captain_app/cubits/wallet_cubit/wallet_cubit.dart';
import 'package:captain_app/cubits/wallet_cubit/wallet_state.dart';
import 'package:captain_app/models/transaction_model.dart';
import 'package:captain_app/services/wallet_service.dart';
import 'package:captain_app/views/transaction_log_screen.dart';
import 'package:captain_app/widgets/current_balance_card.dart';
import 'package:captain_app/widgets/dues_card_widget.dart';
import 'package:captain_app/widgets/transaction_log_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class AccountStatementScreen extends StatelessWidget {
  const AccountStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return const SizedBox();

    return BlocProvider(
      create: (_) => WalletCubit(
        walletService: WalletService(api: Api(context.read<AuthCubit>())),
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
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WalletError) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<WalletCubit>().loadStatement(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is WalletLoaded) {
            final wallet = state.wallet;
            final previewTransactions = wallet.transactions.take(3).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── الرصيد الحالي ───────────────────────────────
                  CurrentBalanceCard(balance: wallet.currentBalance),

                  const SizedBox(height: 16),

                  // ─── إجمالي المدين والدائن ───────────────────────
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

                  // ─── سجل العمليات ────────────────────────────────
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
                                value: context.read<WalletCubit>(),
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

                  // ─── أول 3 عمليات ────────────────────────────────
                  ...previewTransactions.map(
                    (t) => _TransactionItem(transaction: t),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

// ─── Widget مساعد لكل عملية ──────────────────────────────────────────────────
class _TransactionItem extends StatelessWidget {
  const _TransactionItem({required this.transaction});
  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final isDebit = transaction.isDebit;
    final date = transaction.createdAt;

    final dayStr = date.day.toString();
    final monthStr = _arabicMonth(date.month);
    final yearHourStr = '${date.year} . ${DateFormat('hh:mm a').format(date)}';
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
      day: dayStr,
      month: monthStr,
      yearAndHour: yearHourStr,
      price: priceStr,
      isEntry: isDebit,
    );
  }

  String _arabicMonth(int month) {
    const months = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return ' ${months[month]} ';
  }
}
