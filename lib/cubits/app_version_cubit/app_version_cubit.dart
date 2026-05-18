import 'package:captain_app/cubits/app_version_cubit/app_version_state.dart';
import 'package:captain_app/services/app_version_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppVersionCubit extends Cubit<AppVersionState> {
  final AppVersionService _appVersionService;

  AppVersionCubit({required AppVersionService appVersionService})
    : _appVersionService = appVersionService,
      super(AppVersionInitial());

  Future<void> checkVersion(String currentVersion) async {
    emit(AppVersionLoading());

    try {
      final appVersion = await _appVersionService.checkVersion();

      if (appVersion.isForceUpdate(currentVersion)) {
        emit(AppVersionForceUpdate(updateUrl: appVersion.updateUrl));
        return;
      }

      if (appVersion.isOptionalUpdate(currentVersion)) {
        emit(AppVersionOptionalUpdate(updateUrl: appVersion.updateUrl));
        return;
      }

      emit(AppVersionUpToDate());
    } catch (_) {
      emit(AppVersionError());
    }
  }
}
