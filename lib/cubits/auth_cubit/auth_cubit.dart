import 'package:captain_app/api/auth_api/auth_api.dart' as authapi;
import 'package:captain_app/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'auth_state.dart';
import '../../models/auth_model.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> login(
    String username,
    String password,
    DeliveryType role,
  ) async {
    emit(AuthLoading());
    try {
      final response = await authapi.login(username, password, role);

      if (response.user.status != CaptainStatus.active) {
        emit(const AuthError('حسابك غير مفعّل، تواصل مع الإدارة'));
        return;
      }

      emit(AuthAuthenticated(response.user, token: response.token));
      _sendFcmTokenToBackend(response.token, role: response.user.role);

      FirebaseMessaging.instance.onTokenRefresh.listen((newFcmToken) {
        _sendFcmTokenToBackend(response.token, fcmToken: newFcmToken, role: response.user.role);
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
    } catch (_) {
    }
  }

  // ✅ الدالة دي بقت صح — مقفولة صح + بتستخدم في fromJson
  Future<void> _validateTokenThenSendFcm(
    String authToken,
    DeliveryType role,
  ) async {
    try {
      final isValid = await authapi.validateToken(authToken, role);
      if (!isValid) {
        emit(AuthUnauthenticated());
        return;
      }
      _sendFcmTokenToBackend(authToken, role: role);
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  } // ✅ القوس ده كان ناقص

  void logout() {
    emit(AuthUnauthenticated());
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'authenticated') return AuthUnauthenticated();

    final token = json['token'] as String?;
    if (token == null || token.isEmpty) return AuthUnauthenticated();

    final user = AuthModel.fromJson(json['user']);
    final state = AuthAuthenticated(user, token: token);

    // ✅ بقت بتستخدم _validateTokenThenSendFcm بدل _sendFcmTokenToBackend
    _validateTokenThenSendFcm(token, user.role);

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