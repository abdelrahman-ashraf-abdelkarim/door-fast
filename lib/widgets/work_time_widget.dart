import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/shift_cubit/shift_cubit.dart';
import '../cubits/shift_cubit/shift_state.dart';

class WorkTimerWidget extends StatelessWidget {
  const WorkTimerWidget({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShiftCubit, ShiftState>(
      builder: (context, state) {
        return Text(
          _formatDuration(state.duration),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        );
      },
    );
  }
}
