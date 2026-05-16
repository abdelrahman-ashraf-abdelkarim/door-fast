import 'package:captain_app/core/constants.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:captain_app/widgets/order_details_reciver_card.dart';
import 'package:captain_app/widgets/total_order_small_details.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class OrderContainer extends StatelessWidget {
  const OrderContainer({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final bool isSender = order.isPersonToPerson && order.sender != null
        ? true
        : false;
    final isCustomerHidden =
        order.status == OrderStatus.waiting ||
        order.status == OrderStatus.newOrder;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        // color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: isCustomerHidden
          ? Center(child: Icon(Icons.lock, color: Colors.black54, size: 28))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                isSender
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blueGrey.withValues(alpha: 0.1),
                          ),
                          color: Colors.blueGrey.withValues(alpha: 0.05),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "العميل",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_2_sharp,
                                  color: Colors.blueGrey,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    order.senderName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    order.senderAddress,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Roboto",
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: Icon(
                                Icons.arrow_downward_sharp,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            DottedBorder(
                              options: RoundedRectDottedBorderOptions(
                                color: const Color(
                                  0xff10B981,
                                ), // نفس لون success
                                strokeWidth: 1,
                                strokeCap: StrokeCap.round,
                                padding: const EdgeInsets.all(0),
                                dashPattern: [4, 3], // ----
                                radius: const Radius.circular(8),
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color(
                                    0xffECFDF5,
                                  ).withValues(alpha: 0.5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "المستلم",
                                      style: TextStyle(
                                        color: AppColors.successGreen,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            order.receiverAddress,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              fontFamily: "Roboto",
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : OrderDetailsReciverCard(order: order),
                const SizedBox(height: 16),
                TotalOrderSmallDetails(order: order),
              ],
            ),
    );
  }
}

class ButtonCard extends StatelessWidget {
  const ButtonCard({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
