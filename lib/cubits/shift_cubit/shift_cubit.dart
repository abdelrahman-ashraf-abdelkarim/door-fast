import 'dart:async';
import 'package:captain_app/cubits/auth_cubit/auth_cubit.dart';
import 'package:captain_app/cubits/auth_cubit/auth_state.dart';
import 'package:captain_app/services/shift_service.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../models/auth_model.dart';
import 'shift_state.dart';

class ShiftCubit extends HydratedCubit<ShiftState> {
  final AuthCubit authCubit;
  final ShiftService shiftService;
  late final StreamSubscription<AuthState> authSubscription;
  Timer? _timer;

  ShiftCubit(this.authCubit, this.shiftService) : super(ShiftState.initial()) {
    _resumeTimerIfNeeded();

    Future.microtask(() {
      _onAuthChanged(authCubit.state);
    });

    authSubscription = authCubit.stream.listen(_onAuthChanged);
  }

  void _onAuthChanged(AuthState authState) {
    if (authState is AuthAuthenticated) {
      final user = authState.user;

      emit(state.copyWith(user: user));

      if (user.status == CaptainStatus.active) {
        startShift();
      } else {
        endShift();
      }
    } else if (authState is AuthUnauthenticated) {
      endShift();
      emit(state.copyWith(clearUser: true));
    }
  }

  // أضف method جديدة تستقبل الـ event من WebSocket
  void onShiftActivated() {
    if (state.user == null) return;

    final updatedUser = state.user!.copyWith(status: CaptainStatus.active);
    emit(state.copyWith(user: updatedUser));
    startShift();
    
  }

  void onShiftDeactivated() {
    if (state.user == null) return;

    final updatedUser = state.user!.copyWith(status: CaptainStatus.nonActive);
    emit(state.copyWith(user: updatedUser));
    endShift();
  }

  Future<void> startShift() async {
    if (state.user?.status != CaptainStatus.active) return;

    DateTime start;
    try {
      final authState = authCubit.state;
      if (authState is AuthAuthenticated) {
        final fetched = await shiftService.fetchShiftStartTime(authState.token);
        start = fetched ?? state.user?.loginAt ?? DateTime.now();
      } else {
        start = state.user?.loginAt ?? DateTime.now();
      }
    } catch (e) {
      start = state.user?.loginAt ?? DateTime.now();
    }

    emit(state.copyWith(startTime: start, duration: Duration.zero));

    _startTimer(start);
  }

  void _startTimer(DateTime start) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final duration = DateTime.now().difference(start);
      emit(state.copyWith(duration: duration));
    });
  }

  void _resumeTimerIfNeeded() {
    final start = state.startTime;
    if (start == null) return;

    emit(state.copyWith(duration: DateTime.now().difference(start)));
    _startTimer(start);
  }

  void endShift() {
    _timer?.cancel();
    emit(state.copyWith(clearStartTime: true, duration: Duration.zero));
  }

  @override
  ShiftState? fromJson(Map<String, dynamic> json) {
    return ShiftState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(ShiftState state) {
    return state.toJson();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    authSubscription.cancel();
    return super.close();
  }
}
