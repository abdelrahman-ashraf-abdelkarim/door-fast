import 'dart:async';
import 'package:captain_app/cubits/auth_cubit/auth_cubit.dart';
import 'package:captain_app/cubits/auth_cubit/auth_state.dart';
import 'package:captain_app/services/shift_service.dart';
import 'package:captain_app/services/web_socket_service.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../models/auth_model.dart';
import 'shift_state.dart';

class ShiftCubit extends HydratedCubit<ShiftState> {
  final AuthCubit authCubit;
  final ShiftService shiftService;
  late final StreamSubscription<AuthState> _authSubscription;
  StreamSubscription<Map<String, dynamic>>? _wsSubscription;
  Timer? _timer;

  ShiftCubit(this.authCubit, this.shiftService) : super(ShiftState.initial()) {
    _resumeTimerIfNeeded();
    Future.microtask(() => _onAuthChanged(authCubit.state));
    _authSubscription = authCubit.stream.listen(_onAuthChanged);
    _listenToWebSocket();
  }

  // ✅ public — بيتكال من HomeShell بعد reconnect
  void relistenToWebSocket() => _listenToWebSocket();

  void _listenToWebSocket() {
    _wsSubscription?.cancel();
    // ✅ دايماً بيسمع على نفس الـ stream الثابت في الـ singleton
    _wsSubscription = WebSocketService().stream.listen((data) {
      final event = data['event'];
      if (event == 'shift_activated') onShiftActivated();
      if (event == 'shift_deactivated') onShiftDeactivated();
    });
  }

  void _onAuthChanged(AuthState authState) {
    if (authState is AuthAuthenticated) {
      emit(state.copyWith(user: authState.user));
      startShift();
    } else if (authState is AuthUnauthenticated) {
      endShift();
      emit(state.copyWith(clearUser: true));
    }
  }

  void onShiftActivated() {
    if (state.user == null) return;
    final updatedUser = state.user!.copyWith(shiftStatus: ShiftStatus.active);
    emit(state.copyWith(user: updatedUser));
    startShift();
  }

  void onShiftDeactivated() {
    if (state.user == null) return;
    final updatedUser = state.user!.copyWith(
      shiftStatus: ShiftStatus.nonActive,
    );
    emit(state.copyWith(user: updatedUser));
    endShift();
  }

  Future<void> startShift() async {
    try {
      final authState = authCubit.state;
      if (authState is! AuthAuthenticated) return;

      final result = await shiftService.fetchShiftTimes(authState.token);
      if (isClosed) return;

      if (!result.hasActiveShift) {
        if (state.user != null) {
          final updatedUser = state.user!.copyWith(
            shiftStatus: ShiftStatus.nonActive,
          );
          emit(state.copyWith(user: updatedUser));
        }
        endShift();
        return;
      }

      if (state.user != null) {
        final updatedUser = state.user!.copyWith(
          shiftStatus: ShiftStatus.active,
        );
        emit(state.copyWith(user: updatedUser));
      }

      final start = result.shiftStart ?? state.user?.loginAt ?? DateTime.now();
      emit(state.copyWith(startTime: start, duration: Duration.zero));
      _startTimer(start);
    } catch (_) {
      final start = state.user?.loginAt ?? DateTime.now();
      if (isClosed) return;
      emit(state.copyWith(startTime: start, duration: Duration.zero));
      _startTimer(start);
    }
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
  ShiftState? fromJson(Map<String, dynamic> json) => ShiftState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(ShiftState state) => state.toJson();

  @override
  Future<void> close() {
    _timer?.cancel();
    _authSubscription.cancel();
    _wsSubscription?.cancel();
    return super.close();
  }
}
