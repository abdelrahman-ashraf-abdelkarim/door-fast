import 'package:captain_app/core/constants.dart';
import 'package:captain_app/cubits/order_cubit/order_cubit.dart';
import 'package:captain_app/cubits/order_cubit/order_state.dart';
import 'package:captain_app/views/transaction_log_screen.dart';
import 'package:captain_app/widgets/current_balance_card.dart';
import 'package:captain_app/widgets/data_filter_card.dart';
import 'package:captain_app/widgets/dues_card_widget.dart';
import 'package:captain_app/widgets/transaction_log_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AccountStatementScreen extends StatelessWidget {
  const AccountStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        final order = context.read<OrdersCubit>();
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                "كشف الحساب",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: AppColors.cardBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "تصفيه حسب التاريخ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.calendar_today_outlined,
                                color: AppColors.customerIconPrimaryForeground,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              // SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  "من",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "إلى",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          DateFilterCard(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CurrentBalanceCard(order: order),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      DuesCardWidget(
                        title: "اجمالى المدين",
                        text: '1200',
                        icon: Icons.arrow_upward_sharp,
                        iconBackgroundColor:
                            AppColors.customerIconSecondaryBackground,
                        iconForegroundColor:
                            AppColors.customerIconSecondaryForeground,
                      ),
                      DuesCardWidget(
                        title: "اجمالى الدائن",
                        text: '1200',
                        icon: Icons.arrow_downward_sharp,
                        iconBackgroundColor:
                            AppColors.customerIconPrimaryBackground,
                        iconForegroundColor:
                            AppColors.customerIconPrimaryForeground,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
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
                              builder: (context) =>
                                  const TransactionLogScreen(),
                            ),
                          );
                        },
                        child: Text(
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
                  TransactionLogWidget(
                    icon: FontAwesomeIcons.truckFast,
                    foregraoundIconColor:
                        AppColors.customerIconSecondaryForeground,
                    backgraoundIconColor:
                        AppColors.customerIconSecondaryBackground,
                    title: 'رسوم توصيل - طلب 8852#',
                    day: '23',
                    month: ' أكتوبر ',
                    yearAndHour: '2023 . 9:00 AM',
                    price: '+150 ج.م',
                  ),
                  TransactionLogWidget(
                    icon: FontAwesomeIcons.moneyBills,
                    foregraoundIconColor:
                        AppColors.customerIconPrimaryForeground,
                    backgraoundIconColor:
                        AppColors.customerIconPrimaryBackground,
                    title: 'استلام نقدى من سامى محمد',
                    day: '15',
                    month: ' مارس ',
                    yearAndHour: '2024 . 10:00 PM',
                    price: '-500 ج.م',
                    isEntry: false,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
