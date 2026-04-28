import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../../models/auth_model.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  /// تسجيل الدخول (بيانات تجريبية)
  Future<void> login(String name, String password) async {
    emit(AuthLoading());

    await Future.delayed(const Duration(seconds: 2));

    // محاكاة استجابة API
    final user = AuthModel(id: '1', name: name, status: CaptainStatus.active);

    emit(AuthAuthenticated(user));
  }

  /// تسجيل الخروج
  void logout() {
    emit(AuthUnauthenticated());
  }

  /// تغيير حالة الكابتن (نشط / غير نشط)
  void updateCaptainStatus(CaptainStatus status) {
    if (state is AuthAuthenticated) {
      final currentUser = (state as AuthAuthenticated).user;
      emit(AuthAuthenticated(currentUser.copyWith(status: status)));
    }
  }
}
