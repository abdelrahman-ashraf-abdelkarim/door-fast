import 'package:captain_app/api/auth_api/auth_api.dart' as authapi;
import 'package:captain_app/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'auth_state.dart';
import '../../models/auth_model.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  /// تسجيل الدخول (بيانات تجريبية)
  Future<void> login(
    String username,
    String password,
    DeliveryType role,
  ) async {
    emit(AuthLoading());
    try {
      final response = await authapi.login(username, password, role);
      // احفظ التوكن

      if (response.user.status != CaptainStatus.active) {
        emit(const AuthError('حسابك غير مفعّل، تواصل مع الإدارة'));
        return;
      }

      emit(AuthAuthenticated(response.user, token: response.token));
      _sendFcmTokenToBackend(response.token, role: response.user.role);

      FirebaseMessaging.instance.onTokenRefresh.listen((newFcmToken) {
        _sendFcmTokenToBackend(response.token, fcmToken: newFcmToken);
      });
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _sendFcmTokenToBackend(
  String authToken, {
  String? fcmToken,
  DeliveryType role = DeliveryType.delivery,
}) async {
  try {
    final token = fcmToken ?? await NotificationService.getFcmToken();
    if (token == null) return;

      await authapi.updateFcmToken(authToken, token, role);
    print('📱 FCM Token: $token');
  } catch (e) {
    print('⚠️ FCM token send failed: $e');
  }
}
  /// تسجيل الخروج
  void logout() {
    emit(AuthUnauthenticated());
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'authenticated') return AuthUnauthenticated();

    final state = AuthAuthenticated(
      AuthModel.fromJson(json['user']),
      token: json['token'],
    );
    _sendFcmTokenToBackend(state.token);
    return state;
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
