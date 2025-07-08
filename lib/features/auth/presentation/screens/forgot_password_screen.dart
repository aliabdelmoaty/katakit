import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/enhanced_text_field.dart';
import '../../cubit/auth_cubit.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
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
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().sendOtpToEmail(_emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primary,
              AppTheme.primary.withOpacity(0.8),
              AppTheme.scaffoldLight,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppTheme.textLight,
                        size: 24.sp,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'نسيت كلمة المرور',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ),
                    SizedBox(width: 48.w),
                  ],
                ),
              ),

              Expanded(
                child: BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is AuthError) {
                      _showCustomSnackBar(
                        context,
                        state.message,
                        isError: true,
                      );
                    }
                    if (state is OtpSent) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => OtpScreen(email: state.email),
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

                                  // Icon with animation
                                  Container(
                                    padding: EdgeInsets.all(24.w),
                                    decoration: BoxDecoration(
                                      color: AppTheme.textLight.withOpacity(
                                        0.1,
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppTheme.textLight.withOpacity(
                                          0.3,
                                        ),
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

                                  // Title and description
                                  Text(
                                    'إعادة تعيين كلمة المرور',
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textLight,
                                    ),
                                  ),

                                  SizedBox(height: 12.h),

                                  Text(
                                    'أدخل بريدك الإلكتروني وسنرسل لك رابط\nلإعادة تعيين كلمة المرور',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppTheme.textLight.withOpacity(
                                        0.8,
                                      ),
                                      height: 1.5,
                                    ),
                                  ),

                                  SizedBox(height: 48.h),

                                  // Form Card
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
                                          // Enhanced Email Field
                                          EnhancedTextField(
                                            controller: _emailController,
                                            label: 'البريد الإلكتروني',
                                            icon: Icons.email_outlined,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            hintText: 'example@domain.com',
                                            textInputAction:
                                                TextInputAction.done,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'أدخل البريد الإلكتروني';
                                              }
                                              if (!RegExp(
                                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                              ).hasMatch(value)) {
                                                return 'أدخل بريد إلكتروني صحيح';
                                              }
                                              return null;
                                            },
                                            onSubmitted: () => _submit(),
                                          ),

                                          SizedBox(height: 32.h),

                                          // Submit Button with gradient
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
                                                                .withOpacity(
                                                                  0.5,
                                                                ),
                                                            AppTheme.secondary
                                                                .withOpacity(
                                                                  0.5,
                                                                ),
                                                          ]
                                                          : AppTheme
                                                              .primaryGradient,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16.r),
                                                boxShadow:
                                                    state is AuthLoading
                                                        ? []
                                                        : [
                                                          BoxShadow(
                                                            color: AppTheme
                                                                .primary
                                                                .withOpacity(
                                                                  0.3,
                                                                ),
                                                            blurRadius: 8,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  4,
                                                                ),
                                                          ),
                                                        ],
                                              ),
                                              child: ElevatedButton(
                                                onPressed:
                                                    state is AuthLoading
                                                        ? null
                                                        : _submit,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16.r,
                                                        ),
                                                  ),
                                                ),
                                                child:
                                                    state is AuthLoading
                                                        ? SizedBox(
                                                          height: 24.h,
                                                          width: 24.w,
                                                          child: CircularProgressIndicator(
                                                            color:
                                                                AppTheme
                                                                    .textLight,
                                                            strokeWidth: 2,
                                                          ),
                                                        )
                                                        : Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .send_outlined,
                                                              size: 20.sp,
                                                              color:
                                                                  AppTheme
                                                                      .textLight,
                                                            ),
                                                            SizedBox(
                                                              width: 8.w,
                                                            ),
                                                            Text(
                                                              'إرسال رابط إعادة التعيين',
                                                              style: TextStyle(
                                                                fontSize: 16.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    AppTheme
                                                                        .textLight,
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

                                  SizedBox(height: 32.h),

                                  // Back to login link
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.arrow_back,
                                          size: 16.sp,
                                          color: AppTheme.textLight.withOpacity(
                                            0.8,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'العودة لتسجيل الدخول',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: AppTheme.textLight
                                                .withOpacity(0.8),
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
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
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
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
                      : isSuccess
                      ? AppTheme.success.withOpacity(0.2)
                      : AppTheme.info.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              isError
                  ? Icons.error_outline
                  : isSuccess
                  ? Icons.check_circle_outline
                  : Icons.info_outline,
              color:
                  isError
                      ? AppTheme.error
                      : isSuccess
                      ? AppTheme.success
                      : AppTheme.info,
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
              : isSuccess
              ? AppTheme.success.withOpacity(0.9)
              : AppTheme.info.withOpacity(0.9),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      margin: EdgeInsets.all(16.w),
      duration: Duration(seconds: isSuccess ? 3 : 4),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
