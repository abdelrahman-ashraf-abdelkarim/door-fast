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

  factory ShiftState.fromJson(Map<String, dynamic> json) {
    final startTimeValue = json['startTime'] as String?;
    final startTime = startTimeValue == null
        ? null
        : DateTime.tryParse(startTimeValue);

    return ShiftState(
      startTime: startTime,
      duration: startTime == null
          ? Duration(milliseconds: json['durationInMilliseconds'] as int? ?? 0)
          : DateTime.now().difference(startTime),
      user: json['user'] == null
          ? null
          : AuthModel.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
    );
  }

  bool get isStarted => startTime != null;

  ShiftState copyWith({
    DateTime? startTime,
    Duration? duration,
    AuthModel? user,
    bool clearStartTime = false,
    bool clearUser = false,
  }) {
    return ShiftState(
      startTime: clearStartTime ? null : startTime ?? this.startTime,
      duration: duration ?? this.duration,
      user: clearUser ? null : user ?? this.user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime?.toIso8601String(),
      'durationInMilliseconds': duration.inMilliseconds,
      'user': user?.toJson(),
    };
  }

  @override
  List<Object?> get props => [startTime, duration, user];
  bool get isUserActive => user?.status == CaptainStatus.active;
}
