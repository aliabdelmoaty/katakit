import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/enhanced_text_field.dart';
import '../../cubit/auth_cubit.dart';
import 'reset_password_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
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
    _otpController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().verifyOtp(
        widget.email,
        _otpController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              _showCustomSnackBar(context, state.message, isError: true);
            }
            if (state is OtpVerified) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ResetPasswordScreen(email: widget.email),
                ),
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
                              Icons.verified_user_outlined,
                              size: 64.sp,
                              color: AppTheme.textLight,
                            ),
                          ),
                          SizedBox(height: 32.h),
                          Text(
                            'أدخل كود التحقق',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textLight,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'تم إرسال كود تحقق إلى بريدك الإلكتروني\n${widget.email}',
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
                                    controller: _otpController,
                                    label: 'كود التحقق',
                                    icon: Icons.lock_open_outlined,
                                    keyboardType: TextInputType.number,
                                    hintText: 'أدخل الكود المكون من 6 أرقام',
                                    textInputAction: TextInputAction.done,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال كود التحقق';
                                      }
                                      if (value.length < 6) {
                                        return 'الكود يجب أن يكون 6 أرقام';
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
                                                      Icons.verified,
                                                      size: 20.sp,
                                                      color: AppTheme.textLight,
                                                    ),
                                                    SizedBox(width: 8.w),
                                                    Text(
                                                      'تحقق',
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

  void _showCustomSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color:
                  isError
                      ? AppTheme.error.withOpacity(0.2)
                      : AppTheme.success.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? AppTheme.error : AppTheme.success,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 14.sp, color: AppTheme.textLight),
            ),
          ),
        ],
      ),
      backgroundColor:
          isError
              ? AppTheme.error.withOpacity(0.9)
              : AppTheme.success.withOpacity(0.9),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      margin: EdgeInsets.all(16.w),
      duration: const Duration(seconds: 4),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
