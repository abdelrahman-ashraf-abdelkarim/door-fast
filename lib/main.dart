import 'package:captain_app/api/api.dart';
import 'package:captain_app/core/app_navigation.dart';
import 'package:captain_app/core/constants.dart';
import 'package:captain_app/cubits/app_version_cubit/app_version_cubit.dart';
import 'package:captain_app/cubits/auth_cubit/auth_cubit.dart';
import 'package:captain_app/cubits/dashboard_cubit/dashboard_cubit.dart';
import 'package:captain_app/cubits/order_cubit/order_cubit.dart';
import 'package:captain_app/cubits/shift_cubit/shift_cubit.dart';
import 'package:captain_app/services/app_version_service.dart';
import 'package:captain_app/services/notification_service.dart';
import 'package:captain_app/services/shift_service.dart';
import 'package:captain_app/views/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:captain_app/firebase_options.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  final storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await getApplicationDocumentsDirectory()).path,
          ),
  );
  HydratedBloc.storage = storage;
  await NotificationService.init();

  runApp(const CaptainApp());
}

class CaptainApp extends StatelessWidget {
  const CaptainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = AuthCubit();
    final api = Api(authCubit);
    return RepositoryProvider<Api>.value(
      value: api,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authCubit),
          BlocProvider<ShiftCubit>(
            create: (context) =>
                ShiftCubit(context.read<AuthCubit>(), ShiftService(api: api)),
          ),
          BlocProvider<OrdersCubit>(create: (context) => OrdersCubit(api: api)),
          BlocProvider(create: (_) => DashboardCubit(api: api)),
          BlocProvider(
            create: (_) =>
                AppVersionCubit(appVersionService: AppVersionService()),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: const Locale('ar'), // العربية افتراضيًا
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            title: 'Door Fast App',
            theme: ThemeData(
              primarySwatch: Colors.orange,
              fontFamily: 'Cairo',
              scaffoldBackgroundColor: AppColors.appScaffoldBackground,
            ),
            navigatorKey: navigatorKey,
            home: const SplashScreen(),
          ),
        ),
      ),
    );
  }
}
