abstract class AppVersionState {}

class AppVersionInitial extends AppVersionState {}

class AppVersionLoading extends AppVersionState {}

class AppVersionUpToDate extends AppVersionState {}

class AppVersionOptionalUpdate extends AppVersionState {
  final String updateUrl;

  AppVersionOptionalUpdate({required this.updateUrl});
}

class AppVersionForceUpdate extends AppVersionState {
  final String updateUrl;

  AppVersionForceUpdate({required this.updateUrl});
}

class AppVersionError extends AppVersionState {}
