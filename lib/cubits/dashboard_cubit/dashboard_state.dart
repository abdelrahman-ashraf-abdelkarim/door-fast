import 'package:captain_app/models/dashboard_model.dart';
import 'package:equatable/equatable.dart';

// [FIX-08] extend Equatable to prevent unnecessary rebuilds
class DashboardState extends Equatable {
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

  @override
  List<Object?> get props => [data, isLoading, errorMessage];
}
