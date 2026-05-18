import 'package:captain_app/core/constants.dart';
import 'package:captain_app/core/show_confirmation_dialog.dart';
import 'package:captain_app/cubits/auth_cubit/auth_cubit.dart';
import 'package:captain_app/cubits/auth_cubit/auth_state.dart';
import 'package:captain_app/cubits/invoice_cubit/invoice_cubit.dart';
import 'package:captain_app/cubits/invoice_cubit/invoice_state.dart';
import 'package:captain_app/cubits/order_cubit/order_cubit.dart';
import 'package:captain_app/models/auth_model.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:captain_app/widgets/contact_card.dart';
import 'package:captain_app/widgets/container_button_widget.dart';
import 'package:captain_app/widgets/item_price_card.dart';
import 'package:captain_app/widgets/order_details_grouped_item_card.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;
  const OrderDetailsScreen({super.key, required this.order});

  String _invoiceUrl(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final role = authState is AuthAuthenticated
        ? authState.user.role
        : DeliveryType.delivery;
    return AppConstants.invoiceUrl(order.id, role);
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      return const SizedBox.shrink();
    }
    final token = authState.token;

    return BlocProvider(
      create: (_) => InvoiceCubit(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('تفاصيل الطلب', style: TextStyle(fontSize: 17.sp)),
                Text(
                  "#${order.orderNumber}",
                  style: TextStyle(
                    color: AppColors.pickupMarkerOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 17.sp,
                  ),
                ),
              ],
            ),
            centerTitle: true,
          ),
          backgroundColor: AppColors.screenBackground,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.kind == OrderKind.personToPerson)
                  ContactCard(
                    title: 'المرسل',
                    contact: order.sender,
                    iconBg: const Color(0xFFE3F2FD),
                    iconFg: const Color(0xFF1565C0),
                    titleLocation: "عنوان الاستلام",
                    orderLocation: order.senderAddress,
                  ),
                SizedBox(height: 12.h),
                ContactCard(
                  title: 'المستلم',
                  contact: order.receiver,
                  iconBg: const Color(0xFFFFF3E0),
                  iconFg: AppColors.accentOrange,
                  titleLocation: "عنوان التسليم",
                  orderLocation: order.receiverAddress,
                ),

                // ── Notes ────────────────────────────────────────────
                if (order.notes.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.penToSquare,
                        size: 20.r,
                        color: Colors.red[800],
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'الملاحظات',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      color: const Color.fromARGB(255, 185, 16, 16),
                      strokeWidth: 1,
                      strokeCap: StrokeCap.round,
                      padding: EdgeInsets.all(0),
                      dashPattern: const [4, 3],
                      radius: Radius.circular(8.r),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: const Color.fromARGB(
                          255,
                          253,
                          236,
                          236,
                        ).withValues(alpha: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.notes,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              fontFamily: "Roboto",
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // ── Order items ──────────────────────────────────────
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.basketShopping,
                      size: 20.r,
                      color: AppColors.accentOrange,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'محتويات الطلب',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                ...() {
                  final grouped = <String, List<OrderItem>>{};
                  for (final item in order.items) {
                    final key = item.marketPlace.isEmpty
                        ? 'غير محدد'
                        : item.marketPlace;
                    grouped.putIfAbsent(key, () => []).add(item);
                  }
                  return grouped.entries.map(
                    (entry) => OrderDetailsGroupedItemCard(
                      marketPlace: entry.key,
                      items: entry.value,
                    ),
                  );
                }(),

                SizedBox(height: 16.h),
                ItemPriceCard(order: order),
                SizedBox(height: 20.h),

                // ── Action buttons ───────────────────────────────────
                if (order.status == OrderStatus.accepted)
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showConfirmationDialog(
                            context,
                            title: 'تأكيد',
                            message: 'هل تم توصيل الطلب؟',
                            onConfirm: (_) {
                              context.read<OrdersCubit>().completeOrder(
                                order.id,
                                token,
                              );
                              Navigator.pop(context);
                            },
                            colorContainer: AppColors.buttonOrderDialog,
                            buttonText: 'تم التوصيل',
                          );
                        },
                        child: ContainerButtonWidget(
                          color: AppColors.buttonOrderCard,
                          text: '✓ تم التوصيل بنجاح',
                        ),
                      ),
                      SizedBox(height: 16.h),
                      GestureDetector(
                        onTap: () {
                          showConfirmationDialog(
                            context,
                            title: 'سبب الرفض',
                            message: 'لماذا تريد رفض هذا الطلب؟',
                            isCancelled: true,
                            colorContainer: Colors.red[800],
                            onConfirm: (reason) {
                              context.read<OrdersCubit>().cancelOrder(
                                order.id,
                                reason ?? '',
                                token,
                              );
                              Navigator.pop(context);
                            },
                            buttonText: 'تأكيد الرفض',
                          );
                        },
                        child: ContainerButtonWidget(
                          color: Colors.red,
                          textColor: Colors.red,
                          isWhite: true,
                          text: 'إلغاء الطلب',
                        ),
                      ),
                    ],
                  ),

                if (order.status == OrderStatus.delivered)
                  BlocConsumer<InvoiceCubit, InvoiceState>(
                    listener: (context, state) {
                      if (state is InvoiceError) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(state.message)));
                      }
                    },
                    builder: (context, state) {
                      if (state is InvoiceLoading) {
                        return ContainerButtonWidget(
                          color: AppColors.buttonOrderCard,
                          isText: false,
                          widget: const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: () {
                          context.read<InvoiceCubit>().downloadAndShare(
                            url: _invoiceUrl(context),
                            orderNumber: order.orderNumber,
                            customerPhone: order.receiverPhoneOne,
                            token: token,
                          );
                        },
                        child: ContainerButtonWidget(
                          color: AppColors.buttonOrderCard,
                          text: 'ارسال الفاتوره للعميل',
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
