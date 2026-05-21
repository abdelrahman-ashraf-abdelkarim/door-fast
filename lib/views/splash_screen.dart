import 'package:captain_app/core/constants.dart';
import 'package:captain_app/core/splash_navigator.dart';
import 'package:captain_app/cubits/app_version_cubit/app_version_cubit.dart';
import 'package:captain_app/cubits/app_version_cubit/app_version_state.dart';
import 'package:captain_app/cubits/auth_cubit/auth_cubit.dart';
import 'package:captain_app/cubits/shift_cubit/shift_cubit.dart';
import 'package:captain_app/cubits/shift_cubit/shift_state.dart';
import 'package:captain_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _animationDone = false;
  bool _versionCheckStarted = false;
  bool _versionCheckDone = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FlutterNativeSplash.remove();
      await NotificationService.requestAllPermissions();
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 600,
      ), // ✅ أسرع — الـ native splash بيعرض الـ logo، الـ animation بس للـ polish
    )..forward();

    _animation = Tween<double>(
      begin: 0.5, // ✅ من 0.92 مش 0.5 — الـ logo مش بيظهر من فراغ
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // ✅ ابدأ الـ version check بالتوازي مع الـ animation فوراً
    _checkVersion();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationDone = true;
        // ✅ لو الـ version check خلصت قبل الـ animation، navigate فوراً
        if (_versionCheckDone) _navigateNormally();
      }
    });
  }

  Future<void> _checkVersion() async {
    if (!mounted || _versionCheckStarted) return;

    _versionCheckStarted = true;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (!mounted) return;
      await context.read<AppVersionCubit>().checkVersion(packageInfo.version);
    } catch (_) {
      // ✅ لو في error، انتظر الـ animation تخلص الأول لو لسه شغالة
      if (_animationDone) {
        _navigateNormally();
      }
      // لو مش done، الـ animation listener هيـ call _navigateNormally
    }
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  void _navigateNormally() {
    // ✅ لازم الاتنين يخلصوا قبل ما نـ navigate
    if (!_animationDone || !mounted || _hasNavigated) {
      if (mounted && !_hasNavigated) _versionCheckDone = true;
      return;
    }

    _versionCheckDone = true;

    final authState = context.read<AuthCubit>().state;
    final shiftState = context.read<ShiftCubit>().state;

    final destination = SplashNavigator.resolve(authState, shiftState);
    if (destination == null) return; // انتظر ShiftCubit listener

    _hasNavigated = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  // ─── Update Dialogs ───────────────────────────────────────────────────────

  Future<void> _showForceUpdateDialog(String updateUrl) async {
    _versionCheckDone = true;

    if (!mounted || _hasNavigated) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: PopScope(
            canPop: false,
            child: AlertDialog(
              backgroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: Text(
                'تحديث إجباري',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'يجب تحديث التطبيق للاستمرار',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16.sp,
                ),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      foregroundColor: AppColors.cardBackground,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(false);
                      _launchUpdateUrl(updateUrl);
                    },
                    child: Text(
                      'تحديث الآن',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showOptionalUpdateDialog(String updateUrl) async {
    if (!mounted || _hasNavigated) return;

    final shouldNavigate = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Text(
              'تحديث متاح',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'يوجد إصدار جديد من التطبيق',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(
                  'لاحقاً',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  foregroundColor: AppColors.cardBackground,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () => _launchUpdateUrl(updateUrl),
                child: Text(
                  'تحديث الآن',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (shouldNavigate != false) {
      _navigateNormally();
    }
  }

  Future<void> _launchUpdateUrl(String updateUrl) async {
    final uri = Uri.parse(updateUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AppVersionCubit, AppVersionState>(
          listener: (context, state) {
            if (state is AppVersionForceUpdate) {
              _showForceUpdateDialog(state.updateUrl);
            } else if (state is AppVersionOptionalUpdate) {
              _showOptionalUpdateDialog(state.updateUrl);
            } else if (state is AppVersionUpToDate ||
                state is AppVersionError) {
              _navigateNormally();
            }
          },
        ),
        BlocListener<ShiftCubit, ShiftState>(
          listener: (context, shiftState) {
            if (!_versionCheckDone) return;
            if (shiftState.user != null) {
              _navigateNormally();
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.splashBackground,
        body: Center(
          child: ScaleTransition(
            scale: _animation,
            child: Image.asset(
              'assets/images/logo-removebg-preview.png',
              width: 180.w,
            ),
          ),
        ),
      ),
    );
  }
}
