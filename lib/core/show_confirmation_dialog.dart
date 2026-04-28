import 'package:flutter/material.dart';

void showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  required void Function(String? rejectionReason) onConfirm,
  Color? color,
  List<Color>? gradientColors,
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
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('إلغاء'),
            ),
            if (gradientColors != null)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(12),
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
              )
            else
              ElevatedButton(
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
                style: ElevatedButton.styleFrom(backgroundColor: color),
                child: Text(buttonText),
              ),
          ],
        ),
      );
    },
  );
}
