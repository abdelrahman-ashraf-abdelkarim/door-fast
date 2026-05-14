import 'dart:async';

import 'package:captain_app/api/api.dart';
import 'package:captain_app/core/constants.dart';
import 'package:captain_app/cubits/dashboard_cubit/dashboard_state.dart';
import 'package:captain_app/models/dashboard_model.dart';
import 'package:captain_app/services/web_socket_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final Api _api;
  final WebSocketService _wsService = WebSocketService();
  StreamSubscription? _wsSubscription;
  String? _token;

  DashboardCubit({required Api api})
    : _api = api,
      super(const DashboardState());

  Future<void> loadDashboard(String token) async {
    _token = token;
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final data = await _api.get(
        url: '${AppConstants.baseUrl}/dashboard',
        token: token,
      );
      emit(
        state.copyWith(data: DashboardData.fromJson(data), isLoading: false),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }

    // ─── WebSocket listener ────────────────────────────────
    _wsSubscription ??= _wsService.stream.listen((data) {
      final event = data['event'];
      if (event == 'new_order' ||
          event == 'order_updated' ||
          event == 'order_cancelled' ||
          event == 'shift_activated' ||
          event == 'shift_deactivated') {
        if (_token != null) _refresh();
      }
    });
  }

  // ─── refresh بدون loading indicator ──────────────────────
  Future<void> _refresh() async {
    if (_token == null) return;
    try {
      final data = await _api.get(
        url: '${AppConstants.baseUrl}/dashboard',
        token: _token!,
      );
      emit(state.copyWith(data: DashboardData.fromJson(data)));
    } catch (_) {}
  }

  Future<void> refresh(String token) => loadDashboard(token);

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    return super.close();
  }
}
