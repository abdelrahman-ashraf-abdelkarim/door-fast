import 'package:captain_app/core/constants.dart';
import 'package:captain_app/cubits/auth_cubit/auth_cubit.dart';
import 'package:captain_app/cubits/auth_cubit/auth_state.dart';
import 'package:captain_app/models/auth_model.dart';
import 'package:captain_app/views/home_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  DeliveryType _selectedRole = DeliveryType.delivery;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
        _nameController.text.trim(),
        _passwordController.text.trim(),
        _selectedRole,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.loginBackground,
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeShell()),
                );
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        // ─── Header / Logo ──────────────────────────────
                        Container(
                          width: double.infinity,
                          height: 300.h,
                          decoration: BoxDecoration(
                            color: AppColors.loginHeaderBackground,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(45.r),
                              bottomRight: Radius.circular(45.r),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Image(
                            image: AssetImage(
                              'assets/images/logo-removebg-preview.png',
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 32.h),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'اهلاً بك مجدداً ايها الكابتن!',
                                    style: TextStyle(
                                      fontSize: 28.sp,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'سجل دخولك لمتابعة مهام التوصيل اليوميه',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 28.h),

                                // ─── اختيار نوع المندوب ─────────────────
                                _RoleSelector(
                                  selected: _selectedRole,
                                  onChanged: (role) =>
                                      setState(() => _selectedRole = role),
                                ),
                                SizedBox(height: 24.h),

                                // ─── اسم المستخدم ────────────────────────
                                TextFormField(
                                  controller: _nameController,
                                  style: TextStyle(fontSize: 16.sp),
                                  decoration: InputDecoration(
                                    labelText: 'اسم المستخدم',
                                    labelStyle: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 15.sp,
                                    ),
                                    hintText: "أدخل اسم المستخدم",
                                    prefixIcon: Icon(Icons.person),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      borderSide: const BorderSide(
                                        color: AppColors.loginAccent,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'يرجى إدخال اسم المستخدم';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.h),

                                // ─── كلمة المرور ─────────────────────────
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: TextStyle(fontSize: 16.sp),
                                  decoration: InputDecoration(
                                    labelText: 'كلمة المرور',
                                    labelStyle: TextStyle(fontSize: 15.sp),
                                    hintText: "أدخل كلمة المرور",
                                    prefixIcon: Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      borderSide: const BorderSide(
                                        color: AppColors.loginAccent,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'يرجى إدخال كلمة المرور';
                                    }
                                    if (value.length < 4) {
                                      return 'كلمة المرور يجب أن تكون 4 أحرف على الأقل';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 24.h),

                                // ─── زر تسجيل الدخول ─────────────────────
                                BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, state) {
                                    final isLoading = state is AuthLoading;
                                    return GestureDetector(
                                      onTap: isLoading ? null : _login,
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                          vertical: 14.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.loginAccent,
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: isLoading
                                            ? SizedBox(
                                                height: 24.h,
                                                width: 24.w,
                                                child:
                                                    const CircularProgressIndicator(
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : Text(
                                                'تسجيل الدخول',
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Widget: اختيار نوع المندوب ─────────────────────────────────────────────
class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.selected, required this.onChanged});

  final DeliveryType selected;
  final ValueChanged<DeliveryType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.roleSelectorBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          _Tab(
            label: 'مندوب أساسي',
            icon: FontAwesomeIcons.user,
            isSelected: selected == DeliveryType.delivery,
            onTap: () => onChanged(DeliveryType.delivery),
          ),
          _Tab(
            label: 'مندوب احتياطي',
            icon: FontAwesomeIcons.userClock,
            isSelected: selected == DeliveryType.reserve,
            onTap: () => onChanged(DeliveryType.reserve),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final FaIconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.loginAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(9.r),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                icon,
                size: 16.sp,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
