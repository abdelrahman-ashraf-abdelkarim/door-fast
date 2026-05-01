import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'auth_state.dart';
import '../../models/auth_model.dart';

class AuthCubit extends HydratedCubit<AuthState> {
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

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    final stateType = json['type'] as String?;
    if (stateType != 'authenticated') return AuthUnauthenticated();

    final userJson = json['user'];
    if (userJson is! Map) return AuthUnauthenticated();

    return AuthAuthenticated(
      AuthModel.fromJson(Map<String, dynamic>.from(userJson)),
    );
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (state is AuthAuthenticated) {
      return {'type': 'authenticated', 'user': state.user.toJson()};
    }

    return {'type': 'unauthenticated'};
  }
}
