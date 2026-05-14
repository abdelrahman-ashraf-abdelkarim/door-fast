import 'package:captain_app/api/auth_api/auth_api.dart' as authapi;
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'auth_state.dart';
import '../../models/auth_model.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  /// تسجيل الدخول (بيانات تجريبية)
  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final response = await authapi.login(username, password);
      // احفظ التوكن

      if (response.user.status != CaptainStatus.active) {
        emit(const AuthError('حسابك غير مفعّل، تواصل مع الإدارة'));
        return;
      }

      emit(AuthAuthenticated(response.user, token: response.token));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// تسجيل الخروج
  void logout() {
    emit(AuthUnauthenticated());
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'authenticated') return AuthUnauthenticated();

    return AuthAuthenticated(
      AuthModel.fromJson(json['user']),
      token: json['token'],
    );
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (state is AuthAuthenticated) {
      return {
        'type': 'authenticated',
        'user': state.user.toJson(),
        'token': state.token,
      };
    }

    return {'type': 'unauthenticated'};
  }
}
