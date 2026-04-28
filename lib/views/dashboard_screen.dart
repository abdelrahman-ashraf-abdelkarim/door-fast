import 'package:captain_app/core/format_arabic_date_for_dashboard.dart';
import 'package:captain_app/core/time_now.dart';
import 'package:captain_app/cubits/order_cubit/order_cubit.dart';
import 'package:captain_app/cubits/order_cubit/order_state.dart';
import 'package:captain_app/cubits/shift_cubit/shift_cubit.dart';
import 'package:captain_app/cubits/shift_cubit/shift_state.dart';
import 'package:captain_app/models/auth_model.dart';
import 'package:captain_app/widgets/app_bar.dart';
import 'package:captain_app/widgets/stat_card.dart';
import 'package:captain_app/widgets/work_time_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShiftCubit, ShiftState>(
      builder: (context, state) {
        final isOnline = state.user?.status == CaptainStatus.active;
        return Scaffold(
          appBar: AppBar(
            title: AppBarWidget(
              isOnline: isOnline,
              userName: state.user?.name ?? "كابتن",
            ),
          ),
          body: BlocBuilder<OrdersCubit, OrdersState>(
            builder: (context, orderState) {
              final cubit = context.read<OrdersCubit>();
              return !isOnline
                  ? Center(
                      child: Text(
                        "انت غير نشط حاليا",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffbe2c2d),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "احصائياتي اليوم",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'أداءك ليوم ${formatArabicDateDashboard(DateTime.now())}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 20),

                          Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white70,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "اجمالى التحصيل اليومى",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.teal,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${cubit.totalEarnings.toStringAsFixed(0)} ",
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "ج",
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// 📊 الإحصائيات
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.5,
                            children: [
                              StatCard(
                                title: "بداية الوردية",
                                valueWidget: StartShiftTimeWidget(),
                                icon: Icons.access_time,
                                cardColor: true,
                              ),
                              StatCard(
                                title: "مدة العمل",
                                valueWidget: WorkTimerWidget(),
                                icon: Icons.timer_outlined,
                                cardColor: true,
                              ),
                              StatCard(
                                title: "طلبات مكتمله",
                                value: cubit.deliveredCount.toString(),
                                icon: Icons.check_circle,
                                color: Colors.green,
                              ),
                              StatCard(
                                title: "طلبات معلقة",
                                value: cubit.pendingCount.toString(),
                                icon: Icons.add_circle,
                                color: Colors.blue,
                              ),
                              StatCard(
                                title: "خدمة التوصيل",
                                value: cubit.totalDeliveryEarnings.toString(),
                                icon: Icons.local_shipping,
                                color: Colors.orange,
                                cardColor: true,
                              ),
                              StatCard(
                                title: "إجمالي الخصومات",
                                value: "10 ج",
                                icon: Icons.money_off,
                                color: Colors.red,
                                cardColor: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          /// 🚫 طلبات ملغاة
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.pink[50],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.red[100],
                                      child: Icon(
                                        Icons.cancel,
                                        color: Color(0xffbe2c2d),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "طلبات ملغاة",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  " ${cubit.cancelledCount.toString()} ",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xffbe2c2d),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
            },
          ),
        );
      },
    );
  }
}
// SizedBox(height: 20),
// Container(
//   width: double.infinity,
//   padding: EdgeInsets.all(16),
//   decoration: BoxDecoration(
//     borderRadius: BorderRadius.circular(16),
//     color: Colors.white,
//   ),
// child: Column(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: [
//     Row(
//       mainAxisAlignment:
//           MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           "الطاقة الاستيعابية",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),

//         const SizedBox(width: 10),
//         Container(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 12,
//             vertical: 6,
//           ),
//           decoration: BoxDecoration(
//             color: Color(0xff97F3E2),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             '${cubit.deliveredCount} / 20',
//             style: const TextStyle(
//               color: Colors.teal,
//             ),
//           ),

//           /// عدد الطلبات المكتمله / الطاقه الاسيعابيه للدليفرى
//         ),
//       ],
//     ),
// const SizedBox(height: 20),
// LinearProgressIndicator(
//   value: cubit.myEnergyOrder,
//
/// الطاقه الاستيعابيه للدليفرى/ عدد الطلبات المكتمله
//   minHeight: 8,
//   borderRadius: BorderRadius.circular(16),
//   backgroundColor: Color(0xffE0E0E0),
//   color: Color(0xff00796B),
// ),
// const SizedBox(height: 10),
// Text(
//   'لديك مساحة لـ ${20 - cubit.deliveredCount} طلب إضافيًا في حقيبتك حاليًا.',
//   style: const TextStyle(color: Colors.grey),
// ),
//   ],
// ),
// ),
// const SizedBox(height: 20),
// ShiftButton(isOnline: isOnline),

// class ShiftButton extends StatelessWidget {
//   const ShiftButton({super.key, required this.isOnline});
//   final bool isOnline;
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: () {
//           if (isOnline) {
//             context.read<ShiftCubit>().startShift();
//           } else {
//             context.read<ShiftCubit>().endShift();
//           }
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Color(0xff97F3E2),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//         ),
//         child: isOnline
//             ? Text(
//                 "بدأ الشفت",
//                 style: TextStyle(
//                   color: Colors.teal,
//                   fontWeight: FontWeight.bold,
//                 ),
//               )
//             : Text(
//                 "انهاء الشفت",
//                 style: TextStyle(
//                   color: Colors.red[900],
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//       ),
//     );
//   }
// }
