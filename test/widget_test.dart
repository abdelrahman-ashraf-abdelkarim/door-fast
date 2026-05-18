import 'package:bloc_test/bloc_test.dart';
import 'package:captain_app/cubits/app_version_cubit/app_version_cubit.dart';
import 'package:captain_app/cubits/app_version_cubit/app_version_state.dart';
import 'package:captain_app/models/app_version_model.dart';
import 'package:captain_app/services/app_version_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppVersionService extends Mock implements AppVersionService {}

void main() {
  const updateUrl = 'https://yourdomain.com/downloads/captain-app.apk';

  group('compareVersions', () {
    test('returns 0 when versions are equal', () {
      expect(compareVersions('1.0.0', '1.0.0'), 0);
    });

    test('returns -1 when first version is lower', () {
      expect(compareVersions('1.0.0', '1.1.0'), -1);
    });

    test('returns 1 when first version is higher', () {
      expect(compareVersions('1.1.0', '1.0.0'), 1);
    });

    test('compares major, minor, and patch numerically', () {
      expect(compareVersions('2.0.0', '1.9.9'), 1);
    });

    test('ignores build number when comparing versions', () {
      expect(compareVersions('1.0.0+1', '1.0.0'), 0);
    });

    test('treats missing patch number as zero', () {
      expect(compareVersions('1.0', '1.0.0'), 0);
    });
  });

  group('AppVersionModel.fromJson', () {
    test(
      'parses minimum_version, latest_version, and update_url correctly',
      () {
        final model = AppVersionModel.fromJson({
          'minimum_version': '1.1.0',
          'latest_version': '1.2.0',
          'update_url': updateUrl,
        });

        expect(model.minimumVersion, '1.1.0');
        expect(model.latestVersion, '1.2.0');
        expect(model.updateUrl, updateUrl);
      },
    );

    test('uses fallback values when fields are missing', () {
      final model = AppVersionModel.fromJson({});

      expect(model.minimumVersion, '0.0.0');
      expect(model.latestVersion, '0.0.0');
      expect(model.updateUrl, '');
    });
  });

  group('AppVersionModel.isForceUpdate', () {
    test('returns true when current version is below minimum version', () {
      final model = AppVersionModel(
        minimumVersion: '1.1.0',
        latestVersion: '1.2.0',
        updateUrl: updateUrl,
      );

      expect(model.isForceUpdate('1.0.0'), isTrue);
    });

    test('returns false when current version equals minimum version', () {
      final model = AppVersionModel(
        minimumVersion: '1.1.0',
        latestVersion: '1.2.0',
        updateUrl: updateUrl,
      );

      expect(model.isForceUpdate('1.1.0'), isFalse);
    });

    test('returns false when current version is above minimum version', () {
      final model = AppVersionModel(
        minimumVersion: '1.1.0',
        latestVersion: '1.2.0',
        updateUrl: updateUrl,
      );

      expect(model.isForceUpdate('1.2.0'), isFalse);
    });
  });

  group('AppVersionModel.isOptionalUpdate', () {
    test('returns true when current version is between minimum and latest', () {
      final model = AppVersionModel(
        minimumVersion: '1.0.0',
        latestVersion: '1.2.0',
        updateUrl: updateUrl,
      );

      expect(model.isOptionalUpdate('1.0.0'), isTrue);
    });

    test('returns false when current version equals latest version', () {
      final model = AppVersionModel(
        minimumVersion: '1.0.0',
        latestVersion: '1.2.0',
        updateUrl: updateUrl,
      );

      expect(model.isOptionalUpdate('1.2.0'), isFalse);
    });

    test('returns false for force update versions', () {
      final model = AppVersionModel(
        minimumVersion: '1.0.0',
        latestVersion: '1.2.0',
        updateUrl: updateUrl,
      );

      expect(model.isOptionalUpdate('0.9.0'), isFalse);
    });
  });

  group('AppVersionCubit', () {
    late MockAppVersionService appVersionService;

    setUp(() {
      appVersionService = MockAppVersionService();
    });

    AppVersionCubit buildCubit() {
      return AppVersionCubit(appVersionService: appVersionService);
    }

    blocTest<AppVersionCubit, AppVersionState>(
      'emits [AppVersionLoading, AppVersionForceUpdate] when isForceUpdate is true',
      build: buildCubit,
      setUp: () {
        when(() => appVersionService.checkVersion()).thenAnswer(
          (_) async => const AppVersionModel(
            minimumVersion: '1.1.0',
            latestVersion: '1.2.0',
            updateUrl: updateUrl,
          ),
        );
      },
      act: (cubit) => cubit.checkVersion('1.0.0'),
      expect: () => [
        isA<AppVersionLoading>(),
        isA<AppVersionForceUpdate>().having(
          (state) => state.updateUrl,
          'updateUrl',
          updateUrl,
        ),
      ],
      verify: (_) {
        verify(() => appVersionService.checkVersion()).called(1);
      },
    );

    blocTest<AppVersionCubit, AppVersionState>(
      'emits [AppVersionLoading, AppVersionOptionalUpdate] when isOptionalUpdate is true',
      build: buildCubit,
      setUp: () {
        when(() => appVersionService.checkVersion()).thenAnswer(
          (_) async => const AppVersionModel(
            minimumVersion: '1.0.0',
            latestVersion: '1.2.0',
            updateUrl: updateUrl,
          ),
        );
      },
      act: (cubit) => cubit.checkVersion('1.0.0'),
      expect: () => [
        isA<AppVersionLoading>(),
        isA<AppVersionOptionalUpdate>().having(
          (state) => state.updateUrl,
          'updateUrl',
          updateUrl,
        ),
      ],
      verify: (_) {
        verify(() => appVersionService.checkVersion()).called(1);
      },
    );

    blocTest<AppVersionCubit, AppVersionState>(
      'emits [AppVersionLoading, AppVersionUpToDate] when app is up to date',
      build: buildCubit,
      setUp: () {
        when(() => appVersionService.checkVersion()).thenAnswer(
          (_) async => const AppVersionModel(
            minimumVersion: '1.0.0',
            latestVersion: '1.2.0',
            updateUrl: updateUrl,
          ),
        );
      },
      act: (cubit) => cubit.checkVersion('1.2.0'),
      expect: () => [isA<AppVersionLoading>(), isA<AppVersionUpToDate>()],
      verify: (_) {
        verify(() => appVersionService.checkVersion()).called(1);
      },
    );

    blocTest<AppVersionCubit, AppVersionState>(
      'emits [AppVersionLoading, AppVersionError] when service throws exception',
      build: buildCubit,
      setUp: () {
        when(
          () => appVersionService.checkVersion(),
        ).thenThrow(Exception('version check failed'));
      },
      act: (cubit) => cubit.checkVersion('1.0.0'),
      expect: () => [isA<AppVersionLoading>(), isA<AppVersionError>()],
      verify: (_) {
        verify(() => appVersionService.checkVersion()).called(1);
      },
    );
  });
}
