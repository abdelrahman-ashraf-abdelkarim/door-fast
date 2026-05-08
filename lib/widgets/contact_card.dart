import 'package:captain_app/core/constants.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:captain_app/widgets/show_model_sheet_bottom_widget.dart';
import 'package:flutter/material.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
    required this.title,
    this.contact,
    required this.iconBg,
    required this.iconFg,
    required this.titleLocation,
    required this.orderLocation,
  });
  final String title;
  final OrderContact? contact;
  final Color iconBg;
  final Color iconFg;
  final String titleLocation;
  final String orderLocation;

  String get contactName => contact?.name.trim() ?? '';
  String get contactNotes => contact?.notes.trim() ?? '';
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.person, color: iconFg, size: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contactName.isEmpty ? 'غير متاح' : contactName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (contactNotes.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            contactNotes,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: AppColors.successGreen,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (_) {
                            return ShowModelSheetBottomWidget(contact: contact);
                          },
                        );
                      },
                      child: Icon(
                        Icons.perm_contact_calendar_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  // Column(
                  //   children: [
                  //     if (canCall) ...[
                  //       Row(
                  //         children: [
                  //           GestureDetector(
                  //             onTap: () => _callPhone(contactPhone),
                  //             child: Container(
                  //               width: 45,
                  //               height: 45,
                  //               decoration: BoxDecoration(
                  //                 color: AppColors.successGreen,
                  //                 borderRadius: BorderRadius.circular(14),
                  //               ),
                  //               child: const Icon(
                  //                 Icons.call,
                  //                 color: Colors.white,
                  //                 size: 24,
                  //               ),
                  //             ),
                  //           ),
                  //           const SizedBox(width: 8),
                  //           GestureDetector(
                  //             onTap: () => _openWhatsApp(
                  //               phone: "2$contactPhone",
                  //               message: 'السلام عليكم، معاك مندوب التوصيل',
                  //             ),
                  //             child: Container(
                  //               width: 45,
                  //               height: 45,
                  //               alignment: Alignment.center,
                  //               decoration: BoxDecoration(
                  //                 color: AppColors.successGreen,
                  //                 borderRadius: BorderRadius.circular(14),
                  //               ),
                  //               child: const FaIcon(
                  //                 FontAwesomeIcons.whatsapp,
                  //                 color: Colors.white,
                  //                 size: 24,
                  //                 fontWeight: FontWeight.w900,
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //     const SizedBox(height: 8),
                  //     if (canCallTwo) ...[
                  //       Row(
                  //         children: [
                  //           GestureDetector(
                  //             onTap: () => _callPhone(contactPhoneTwo),
                  //             child: Container(
                  //               width: 45,
                  //               height: 45,
                  //               decoration: BoxDecoration(
                  //                 color: Color(0xFF128C7E),
                  //                 borderRadius: BorderRadius.circular(14),
                  //               ),
                  //               child: const Icon(
                  //                 Icons.call,
                  //                 color: Colors.white,
                  //                 size: 24,
                  //               ),
                  //             ),
                  //           ),
                  //           const SizedBox(width: 8),
                  //           GestureDetector(
                  //             onTap: () => _openWhatsApp(
                  //               phone: "2$contactPhoneTwo",
                  //               message: 'السلام عليكم، معاك مندوب التوصيل',
                  //             ),
                  //             child: Container(
                  //               width: 45,
                  //               height: 45,
                  //               alignment: Alignment.center,
                  //               decoration: BoxDecoration(
                  //                 color: Color(0xFF128C7E),
                  //                 borderRadius: BorderRadius.circular(14),
                  //               ),
                  //               child: const FaIcon(
                  //                 FontAwesomeIcons.whatsapp,
                  //                 color: Colors.white,
                  //                 size: 24,
                  //                 fontWeight: FontWeight.w900,
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ],
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.lightSurface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.navigation_rounded,
                    color: AppColors.pickupMarkerOrange,
                    size: 36,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          titleLocation,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          orderLocation,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
