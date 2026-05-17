import 'package:captain_app/core/constants.dart';
import 'package:captain_app/core/format_date_for_account.dart';
import 'package:captain_app/cubits/account_statement_cubit/account_statement_cubit.dart';
import 'package:captain_app/cubits/account_statement_cubit/account_statement_state.dart';
import 'package:captain_app/widgets/data_filter_card.dart';
import 'package:captain_app/widgets/transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransactionLogScreen extends StatelessWidget {
  const TransactionLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('سجل العمليات المالية'), centerTitle: true),
        body: BlocBuilder<AccountStatementCubit, AccountStatementState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                // ─── فلتر التاريخ ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Card(
                      color: AppColors.cardBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "تصفيه حسب التاريخ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today_outlined,
                                  color:
                                      AppColors.customerIconPrimaryForeground,
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "من",
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    "إلى",
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            DateFilterCard(
                              onFilter: (from, to) {
                                context
                                    .read<AccountStatementCubit>()
                                    .filterByDate(from, to);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ─── Loading ───────────────────────────────────────────────
                if (state is AccountStatementLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                // ─── Error ─────────────────────────────────────────────────
                else if (state is AccountStatementError)
                  SliverFillRemaining(child: Center(child: Text(state.message)))
                // ─── قائمة العمليات ────────────────────────────────────────
                else if (state is AccountStatementLoaded) ...[
                  if (state.displayedTransactions.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'لا توجد عمليات',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = state.displayedTransactions[index];
                        return TransactionCard(
                          logId: item.logId,
                          date: formatDate(item.createdAt),
                          note: item.description,
                          debit: item.debit,
                          credit: item.credit,
                          balance: item.balance,
                        );
                      }, childCount: state.displayedTransactions.length),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
