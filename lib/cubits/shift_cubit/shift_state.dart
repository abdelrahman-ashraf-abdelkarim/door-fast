import 'package:equatable/equatable.dart';
import '../../models/auth_model.dart';

class ShiftState extends Equatable {
  final DateTime? startTime;
  final Duration duration;
  final AuthModel? user;

  const ShiftState({this.startTime, required this.duration, this.user});

  factory ShiftState.initial() {
    return const ShiftState(
      startTime: null,
      duration: Duration.zero,
      user: null,
    );
  }

  bool get isStarted => startTime != null;

  ShiftState copyWith({
    DateTime? startTime,
    Duration? duration,
    AuthModel? user,
  }) {
    return ShiftState(
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [startTime, duration, user];
  bool get isUserActive => user?.status == CaptainStatus.active;
}
