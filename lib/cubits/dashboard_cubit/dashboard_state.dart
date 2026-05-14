import 'package:captain_app/models/dashboard_model.dart';

class DashboardState {
  final DashboardData? data;
  final bool isLoading;
  final String? errorMessage;

  const DashboardState({this.data, this.isLoading = false, this.errorMessage});

  DashboardState copyWith({
    DashboardData? data,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DashboardState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
