import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:katakit/core/utils/app_utils.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/enhanced_text_field.dart';
import '../../cubit/auth_cubit.dart';
import '../../../../../features/batches/presentation/screens/batches_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldLight,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            context.showErrorSnackBar(state.message);
          }
          if (state is Authenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const BatchesScreen()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: KeyboardAwareScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 60.h),

                        // Logo and Welcome Section
                        _buildWelcomeSection(),

                        SizedBox(height: 50.h),

                        // Login Form
                        _buildLoginForm(state),

                        SizedBox(height: 32.h),

                        // Action Links
                        _buildActionLinks(),

                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        // App Logo/Icon - كتكوت
        Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.yellow.shade300, Colors.orange.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // جسم الكتكوت
              Container(
                width: 60.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: Colors.yellow.shade400,
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
              // رأس الكتكوت
              Positioned(
                top: 15.h,
                child: Container(
                  width: 40.w,
                  height: 35.w,
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade300,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
              // العين
              Positioned(
                top: 22.h,
                right: 42.w,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: Colors.brown.shade800,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              // المنقار
              Positioned(
                top: 30.h,
                right: 32.w,
                child: Container(
                  width: 0,
                  height: 0,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: 6.w,
                        color: Colors.orange.shade600,
                      ),
                      left: BorderSide(width: 4.w, color: Colors.transparent),
                      right: BorderSide(width: 4.w, color: Colors.transparent),
                    ),
                  ),
                ),
              ),
              // الجناح
              Positioned(
                top: 35.h,
                right: 45.w,
                child: Container(
                  width: 20.w,
                  height: 15.w,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade300,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              // القدم اليسرى
              Positioned(
                bottom: 8.h,
                right: 50.w,
                child: Container(
                  width: 8.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              // القدم اليمنى
              Positioned(
                bottom: 8.h,
                right: 35.w,
                child: Container(
                  width: 8.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24.h),

        // Welcome Text
        Text(
          'مرحباً بك',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textMain,
            height: 1.2,
          ),
        ),

        SizedBox(height: 8.h),

        Text(
          'سجل دخولك للمتابعة',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(AuthState state) {
    return Column(
      children: [
        // Email Field
        EnhancedTextField(
          controller: _emailController,
          label: 'البريد الإلكتروني',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'أدخل البريد الإلكتروني';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'أدخل بريد إلكتروني صحيح';
            }
            return null;
          },
        ),

        SizedBox(height: 20.h),

        // Password Field
        EnhancedTextField(
          controller: _passwordController,
          label: 'كلمة المرور',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: () => _login(),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.textFaint.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppTheme.textSecondary,
                size: 20.w,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'أدخل كلمة المرور';
            }
            if (value.length < 6) {
              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
            }
            return null;
          },
        ),

        SizedBox(height: 32.h),

        // Login Button
        _buildLoginButton(state),
      ],
    );
  }

  Widget _buildLoginButton(AuthState state) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: state is AuthLoading ? null : _login,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            alignment: Alignment.center,
            child:
                state is AuthLoading
                    ? SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.textLight,
                        ),
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.login_rounded,
                          color: AppTheme.textLight,
                          size: 24.w,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            color: AppTheme.textLight,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionLinks() {
    return Column(
      children: [
        // Forgot Password Link
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
            );
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'نسيت كلمة المرور؟',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // Divider
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1.h,
                color: AppTheme.textFaint.withOpacity(0.3),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'أو',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1.h,
                color: AppTheme.textFaint.withOpacity(0.3),
              ),
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // Register Link
        Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            color: AppTheme.cardLight,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppTheme.primary.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.textFaint.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add_outlined,
                      color: AppTheme.primary,
                      size: 24.w,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'إنشاء حساب جديد',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
