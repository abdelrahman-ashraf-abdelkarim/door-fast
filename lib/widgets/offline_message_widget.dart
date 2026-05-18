import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OfflineMessageWidget extends StatelessWidget {
  const OfflineMessageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'انت غير نشط حاليا',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xffbe2c2d),
            ),
          ),
        ),
      ),
    );
  }
}
