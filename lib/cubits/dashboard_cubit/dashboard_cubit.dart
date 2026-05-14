// lib/cubits/dashboard_cubit/dashboard_cubit.dart

import 'dart:async';

import 'package:captain_app/api/api.dart';
import 'package:captain_app/core/constants.dart';
import 'package:captain_app/cubits/auth_cubit/auth_cubit.dart';
import 'package:captain_app/cubits/dashboard_cubit/dashboard_state.dart';
import 'package:captain_app/models/dashboard_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final Api _api = Api(AuthCubit());

  Timer? _timer;

  DashboardCubit() : super(const DashboardState());

  Future<void> loadDashboard(String token) async {
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
    _timer?.cancel();
    // تعديل بعد التجربه
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      loadDashboard(token);
    });
  }

  Future<void> refresh(String token) => loadDashboard(token);
}
