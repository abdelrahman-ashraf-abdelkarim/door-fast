import 'package:captain_app/core/constants.dart';
import 'package:captain_app/core/show_confirmation_dialog.dart';
import 'package:captain_app/cubits/invoice_cubit/invoice_cubit.dart';
import 'package:captain_app/cubits/invoice_cubit/invoice_state.dart';
import 'package:captain_app/cubits/order_cubit/order_cubit.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:captain_app/widgets/contact_card.dart';
import 'package:captain_app/widgets/container_button_widget.dart';
import 'package:captain_app/widgets/delivery_map_card.dart';
import 'package:captain_app/widgets/item_price_card.dart';
import 'package:captain_app/widgets/order_details_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InvoiceCubit(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('تفاصيل الطلب'),
                Text(
                  order.formattedId,
                  style: const TextStyle(color: AppColors.pickupMarkerOrange),
                ),
              ],
            ),
            centerTitle: true,
          ),
          backgroundColor: AppColors.screenBackground,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DeliveryMapCard(order: order),
                const SizedBox(height: 16),
                if (order.kind == OrderKind.personToPerson)
                  ContactCard(
                    title: 'المرسل',
                    contact: order.pickupContact,
                    iconBg: const Color(0xFFE3F2FD),
                    iconFg: const Color(0xFF1565C0),
                    titleLocation: "عنوان الاستلام",
                    orderLocation: order.pickupLocation.toString(),
                  ),
                const SizedBox(height: 12),
                ContactCard(
                  title: 'المستلم',
                  contact: order.dropoffContact,
                  iconBg: const Color(0xFFFFF3E0),
                  iconFg: AppColors.accentOrange,
                  titleLocation: "عنوان التسليم",
                  orderLocation: order.deliveryLocation,
                ),
                const SizedBox(height: 16),
                const Text(
                  'محتويات الطلب',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...order.items.map((item) => OrderDetailsItemCard(item: item)),
                const SizedBox(height: 16),
                ItemPriceCard(order: order),
                const SizedBox(height: 20),
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
                              );
                              Navigator.pop(context);
                            },
                            gradientColors:
                                AppConstants.acceptButtonGradientColors,
                            buttonText: 'تم التوصيل',
                          );
                        },
                        child: ContainerButtonWidget(
                          colors: AppConstants.acceptButtonGradientColors,
                          text: 'تم التوصيل',
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          showConfirmationDialog(
                            context,
                            title: 'سبب الرفض',
                            message: 'لماذا تريد رفض هذا الطلب؟',
                            isCancelled: true,
                            onConfirm: (reason) {
                              context.read<OrdersCubit>().cancelOrder(
                                order.id,
                                reason ?? '',
                              );
                              Navigator.pop(context);
                            },
                            gradientColors:
                                AppConstants.rejectButtonGradientColors,
                            buttonText: 'تأكيد الرفض',
                          );
                        },
                        child: ContainerButtonWidget(
                          colors: AppConstants.rejectButtonGradientColors,
                          text: 'رفض الطلب',
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
                          colors: AppConstants.acceptButtonGradientColors,
                          isText: false,
                          widget: const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: () {
                          context.read<InvoiceCubit>().downloadAndShare(
                            // url: "https://yourapi.com/invoice/${order.id}",
                            url: "assets/pdfs/Invoice_ORD-ORD-000105.pdf",
                            orderId: order.id,
                            customerPhone: order.phone,
                          );
                        },
                        child: ContainerButtonWidget(
                          colors: AppConstants.acceptButtonGradientColors,
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
