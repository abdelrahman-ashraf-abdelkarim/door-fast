import 'package:captain_app/core/constants.dart';
import 'package:flutter/material.dart';

void showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  required void Function(String? rejectionReason) onConfirm,
  Color? colorContainer,
  required String buttonText,
  bool isCancelled = false,
}) {
  final reasonController = TextEditingController();

  showDialog(
    context: context,
    builder: (dialogContext) {
      String? errorText;

      return StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(title, textAlign: TextAlign.center),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            // height: MediaQuery.of(context).size.height * 0.20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(message),
                if (isCancelled) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    keyboardType: TextInputType.text,
                    onChanged: (_) {
                      if (errorText != null) {
                        setState(() {
                          errorText = null;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'سبب الرفض',
                      hintText: 'اكتب سبب الرفض هنا',
                      errorText: errorText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textSecondary,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("إلغاء"),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      final reason = reasonController.text.trim();
                      if (isCancelled && reason.isEmpty) {
                        if (!dialogContext.mounted) return;
                        setState(() {
                          errorText = 'سبب الرفض مطلوب';
                        });
                        return;
                      }
                      Navigator.pop(dialogContext);
                      Future.microtask(() {
                        onConfirm(isCancelled ? reason : null);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(buttonText),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
