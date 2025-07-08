import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:katakit/core/utils/app_utils.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/enhanced_text_field.dart';
import '../../cubit/auth_cubit.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().resetPassword(_passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              context.showErrorSnackBar(state.message);
            }
            if (state is PasswordResetSuccess) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
              context.showSuccessSnackBar(
                'تم تغيير كلمة المرور بنجاح! يمكنك الآن تسجيل الدخول.',
              );
            }
          },
          builder: (context, state) {
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        children: [
                          SizedBox(height: 40.h),
                          Container(
                            padding: EdgeInsets.all(24.w),
                            decoration: BoxDecoration(
                              color: AppTheme.textLight.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.textLight.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.lock_reset_outlined,
                              size: 64.sp,
                              color: AppTheme.textLight,
                            ),
                          ),
                          SizedBox(height: 32.h),
                          Text(
                            'تغيير كلمة المرور',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textLight,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'أدخل كلمة المرور الجديدة لتأمين حسابك',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppTheme.textLight.withOpacity(0.8),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 48.h),
                          Container(
                            padding: EdgeInsets.all(24.w),
                            decoration: BoxDecoration(
                              color: AppTheme.cardLight,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  EnhancedTextField(
                                    controller: _passwordController,
                                    label: 'كلمة المرور الجديدة',
                                    icon: Icons.lock_outline,
                                    obscureText: true,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال كلمة المرور الجديدة';
                                      }
                                      if (value.length < 6) {
                                        return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20.h),
                                  EnhancedTextField(
                                    controller: _confirmPasswordController,
                                    label: 'تأكيد كلمة المرور',
                                    icon: Icons.lock_outline,
                                    obscureText: true,
                                    textInputAction: TextInputAction.done,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى تأكيد كلمة المرور';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'كلمتا المرور غير متطابقتين';
                                      }
                                      return null;
                                    },
                                    onSubmitted: () => _submit(),
                                  ),
                                  SizedBox(height: 32.h),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56.h,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors:
                                              state is AuthLoading
                                                  ? [
                                                    AppTheme.primary
                                                        .withOpacity(0.5),
                                                    AppTheme.secondary
                                                        .withOpacity(0.5),
                                                  ]
                                                  : AppTheme.primaryGradient,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                        boxShadow:
                                            state is AuthLoading
                                                ? []
                                                : [
                                                  BoxShadow(
                                                    color: AppTheme.primary
                                                        .withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed:
                                            state is AuthLoading
                                                ? null
                                                : _submit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16.r,
                                            ),
                                          ),
                                        ),
                                        child:
                                            state is AuthLoading
                                                ? SizedBox(
                                                  height: 24.h,
                                                  width: 24.w,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color:
                                                            AppTheme.textLight,
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                                : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.lock_reset,
                                                      size: 20.sp,
                                                      color: AppTheme.textLight,
                                                    ),
                                                    SizedBox(width: 8.w),
                                                    Text(
                                                      'تغيير كلمة المرور',
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            AppTheme.textLight,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  
}
