import 'package:captain_app/core/app_navigation.dart';
import 'package:captain_app/cubits/auth_cubit/auth_cubit.dart';
import 'package:captain_app/cubits/order_cubit/order_cubit.dart';
import 'package:captain_app/cubits/shift_cubit/shift_cubit.dart';
import 'package:captain_app/services/notification_service.dart';
import 'package:captain_app/views/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
  await NotificationService.init();

  HydratedBloc.storage = storage;
  runApp(const CaptainApp());
}

class CaptainApp extends StatelessWidget {
  const CaptainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider<ShiftCubit>(
          create: (context) => ShiftCubit(context.read<AuthCubit>()),
        ),
        BlocProvider<OrdersCubit>(create: (context) => OrdersCubit()),
      ],
      child: MaterialApp(
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
          scaffoldBackgroundColor: Color(0xffF5F5F5),
        ),
        navigatorKey: navigatorKey,
        home: const SplashScreen(),
      ),
    );
  }
}
