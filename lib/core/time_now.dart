import 'package:captain_app/cubits/shift_cubit/shift_cubit.dart';
import 'package:captain_app/cubits/shift_cubit/shift_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class StartShiftTimeWidget extends StatelessWidget {
  const StartShiftTimeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShiftCubit, ShiftState>(
      builder: (context, state) {
        if (state.startTime == null) {
          return const Text('--:--');
        }

        final formattedTime = DateFormat('HH:mm').format(state.startTime!);

        return Text(
          formattedTime,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        );
      },
    );
  }
}
