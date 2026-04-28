import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:captain_app/cubits/auth_cubit/auth_cubit.dart';
import 'package:captain_app/cubits/auth_cubit/auth_state.dart';
import '../../models/auth_model.dart';
import 'shift_state.dart';

class ShiftCubit extends Cubit<ShiftState> {
  final AuthCubit authCubit;
  late final StreamSubscription<AuthState> authSubscription;
  Timer? _timer;

  ShiftCubit(this.authCubit) : super(ShiftState.initial()) {
    // تعيين الحالة الابتدائية بعد بناء الشجرة
    Future.microtask(() {
      _onAuthChanged(authCubit.state);
    });

    // الاستماع لأي تغييرات مستقبلية
    authSubscription = authCubit.stream.listen(_onAuthChanged);
  }

  /// 🔄 يتم استدعاؤها عند تغير حالة المصادقة
  void _onAuthChanged(AuthState authState) {
    if (authState is AuthAuthenticated) {
      final user = authState.user;

      emit(state.copyWith(user: user));

      if (user.status == CaptainStatus.active) {
        startShift();
      } else {
        endShift();
      }
    } else {
      endShift();
      emit(state.copyWith(user: null));
    }
  }

  /// ▶️ بدء الشيفت
  void startShift() {
    if (state.user?.status != CaptainStatus.active) return;
    if (state.startTime != null) return;

    final start = DateTime.now();

    emit(state.copyWith(startTime: start, duration: Duration.zero));

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final duration = DateTime.now().difference(start);
      emit(state.copyWith(duration: duration));
    });
  }

  /// ⏹️ إنهاء الشيفت
  void endShift() {
    _timer?.cancel();
    emit(state.copyWith(startTime: null, duration: Duration.zero));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    authSubscription.cancel();
    return super.close();
  }
}
