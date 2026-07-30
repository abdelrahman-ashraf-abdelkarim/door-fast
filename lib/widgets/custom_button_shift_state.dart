import 'package:captain_app/core/constants.dart';
import 'package:captain_app/cubits/shift_cubit/shift_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButtonShiftState extends StatelessWidget {
  const CustomButtonShiftState({super.key, required this.isShiftStarted});
  final bool isShiftStarted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<ShiftCubit>().toggleShift();
      },
      child: Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: isShiftStarted
              ? AppColors.loginAccent
              : AppColors.successGreen,
        ),
        child: Center(
          child: Text(
            isShiftStarted ? 'إنهاء الشفت' : 'بدء الشفت',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
