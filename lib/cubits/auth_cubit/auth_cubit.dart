import 'dart:async';
import 'package:captain_app/api/auth_api/auth_api.dart' as authapi;
import 'package:captain_app/services/notification_service.dart';
import 'package:captain_app/services/web_socket_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'auth_state.dart';
import '../../models/auth_model.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  static const String _authTokenKey = 'auth_token';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  StreamSubscription<String>? _fcmTokenRefreshSub;
  StreamSubscription<Map<String, dynamic>>? _wsSubscription;

  AuthModel? _hydratedUser;
  String? _legacyHydratedToken;

  AuthCubit() : super(AuthInitial()) {
    initAsync();
  }

  Future<void> initAsync() async {
    final authState = state;
    final user = authState is AuthAuthenticated
        ? authState.user
        : _hydratedUser;

    if (user == null) return;

    var token = await _secureStorage.read(key: _authTokenKey);
    if ((token == null || token.isEmpty) &&
        _legacyHydratedToken != null &&
        _legacyHydratedToken!.isNotEmpty) {
      token = _legacyHydratedToken;
      await _secureStorage.write(key: _authTokenKey, value: token);
    }

    if (token == null || token.isEmpty) {
      emit(AuthUnauthenticated());
      return;
    }

    emit(AuthAuthenticated(user, token: token));
    _validateTokenThenSendFcm(token, user.role);
    _listenToWebSocket();
  }

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

      await _secureStorage.write(key: _authTokenKey, value: response.token);
      await _fcmTokenRefreshSub?.cancel();

      _fcmTokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((
        newFcmToken,
      ) {
        _sendFcmTokenToBackend(
          response.token,
          fcmToken: newFcmToken,
          role: response.user.role,
        );
      });

      emit(AuthAuthenticated(response.user, token: response.token));
      _sendFcmTokenToBackend(response.token, role: response.user.role);
      _listenToWebSocket();
    } catch (e) {
      if (e is authapi.AuthException) {
        emit(AuthError(e.toString()));
      } else {
        emit(const AuthError('حدث خطأ، تحقق من الاتصال بالإنترنت'));
      }
    }
  }

  // ✅ public — بيتكال من HomeShell بعد reconnect
  void relistenToWebSocket() => _listenToWebSocket();

  void _listenToWebSocket() {
    _wsSubscription?.cancel();
    // ✅ دايماً بيسمع على نفس الـ stream الثابت في الـ singleton
    _wsSubscription = WebSocketService().stream.listen((data) {
      if (data['event'] == 'account_deactivated') {
        logout();
      }
    });
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
    } catch (_) {}
  }

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
  }

  Future<void> logout() async {
    await _fcmTokenRefreshSub?.cancel();
    await _wsSubscription?.cancel();
    _fcmTokenRefreshSub = null;
    _wsSubscription = null;
    await _secureStorage.delete(key: _authTokenKey);
    emit(AuthUnauthenticated());
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'authenticated') return AuthUnauthenticated();

    final user = AuthModel.fromJson(json['user']);
    _hydratedUser = user;
    _legacyHydratedToken = json['token'] as String?;
    return AuthInitial();
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (state is AuthAuthenticated) {
      return {'type': 'authenticated', 'user': state.user.toJson()};
    }
    return {'type': 'unauthenticated'};
  }

  @override
  Future<void> close() async {
    await _fcmTokenRefreshSub?.cancel();
    await _wsSubscription?.cancel();
    return super.close();
  }
}
