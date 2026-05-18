import 'package:captain_app/core/constants.dart';
import 'package:captain_app/cubits/app_version_cubit/app_version_cubit.dart';
import 'package:captain_app/cubits/app_version_cubit/app_version_state.dart';
import 'package:captain_app/cubits/auth_cubit/auth_cubit.dart';
import 'package:captain_app/cubits/auth_cubit/auth_state.dart';
import 'package:captain_app/views/home_shell.dart';
import 'package:captain_app/views/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationDone = true;
        _checkVersion();
      }
    });
  }

  Future<void> _checkVersion() async {
    if (!mounted || !_animationDone || _versionCheckStarted) return;

    _versionCheckStarted = true;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (!mounted) return;
      await context.read<AppVersionCubit>().checkVersion(packageInfo.version);
    } catch (_) {
      _navigateNormally();
    }
  }

  void _navigateNormally() {
    if (!mounted || _hasNavigated) return;

    _hasNavigated = true;
    final authState = context.read<AuthCubit>().state;
    final destination = authState is AuthAuthenticated
        ? const HomeShell()
        : const LoginScreen();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  Future<void> _showForceUpdateDialog(String updateUrl) async {
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
    return BlocListener<AppVersionCubit, AppVersionState>(
      listener: (context, state) {
        if (state is AppVersionForceUpdate) {
          _showForceUpdateDialog(state.updateUrl);
        } else if (state is AppVersionOptionalUpdate) {
          _showOptionalUpdateDialog(state.updateUrl);
        } else if (state is AppVersionUpToDate || state is AppVersionError) {
          _navigateNormally();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xfff8c624),
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
