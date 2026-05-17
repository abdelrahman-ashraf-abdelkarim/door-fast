import 'package:captain_app/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DuesCardWidget extends StatelessWidget {
  const DuesCardWidget({
    super.key,
    required this.title,
    required this.text,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconForegroundColor,
  });

  final String title;
  final String text;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconForegroundColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: iconBackgroundColor,
                radius: 24.r,
                child: Icon(
                  icon,
                  fontWeight: FontWeight.bold,
                  color: iconForegroundColor,
                  size: 26.r,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  "$text ج.م",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
