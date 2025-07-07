import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/entities/death_entity.dart';
import '../../../../core/entities/batch_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/enhanced_text_field.dart';
import '../../cubit/deaths_cubit.dart';
import '../../../sales/cubit/sales_cubit.dart';
import '../../../auth/cubit/auth_cubit.dart';

class AddDeathScreen extends StatefulWidget {
  final BatchEntity batch;

  const AddDeathScreen({super.key, required this.batch});

  @override
  State<AddDeathScreen> createState() => _AddDeathScreenState();
}

class _AddDeathScreenState extends State<AddDeathScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _countController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

    // تحميل البيانات المطلوبة لحساب العدد المتاح
    context.read<SalesCubit>().loadSales(widget.batch.id);
    context.read<DeathsCubit>().loadDeaths(widget.batch.id);
  }

  @override
  void dispose() {
    _countController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // حساب العدد المتاح لتسجيل الوفيات بناءً على المبيعات السابقة
  int _calculateAvailableForDeaths(int totalSold, int totalDeaths) {
    return widget.batch.chickCount - totalSold - totalDeaths;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primary,
              surface: Colors.white,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Show loading animation
      HapticFeedback.mediumImpact();

      final authState = context.read<AuthCubit>().state;
      String userId = '';
      if (authState is Authenticated) {
        userId = authState.userId;
      }
      final death = DeathEntity(
        id: const Uuid().v4(),
        batchId: widget.batch.id,
        count: int.parse(_countController.text),
        date: _selectedDate,
        userId: userId,
        updatedAt: DateTime.now(),
      );
      context.read<DeathsCubit>().addDeath(death);

      // Show success message before navigation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20.w),
              SizedBox(width: 8.w),
              Text('تم إضافة الوفيات بنجاح'),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إضافة وفيات جديدة',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.w),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SalesCubit, SalesState>(
            listener: (context, state) {
              if (state is SalesLoaded) {
                setState(() {});
              }
            },
          ),
          BlocListener<DeathsCubit, DeathsState>(
            listener: (context, state) {
              if (state is DeathsLoaded) {
                setState(() {});
              }
              if (state is DeathsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 20.w,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(child: Text(state.message)),
                      ],
                    ),
                    backgroundColor: AppTheme.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                );
              }
            },
          ),
        ],
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: BlocBuilder<SalesCubit, SalesState>(
              builder: (context, salesState) {
                return BlocBuilder<DeathsCubit, DeathsState>(
                  builder: (context, deathsState) {
                    // حساب العدد المتاح لتسجيل الوفيات
                    int totalSold = 0;
                    int totalDeaths = 0;

                    if (salesState is SalesLoaded) {
                      totalSold = salesState.totalSoldCount;
                    }

                    if (deathsState is DeathsLoaded) {
                      totalDeaths = deathsState.totalDeathsCount;
                    }

                    final availableForDeaths = _calculateAvailableForDeaths(
                      totalSold,
                      totalDeaths,
                    );

                    if (salesState is SalesLoading ||
                        deathsState is DeathsLoading) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppTheme.primary),
                            SizedBox(height: 16.h),
                            Text(
                              'جاري تحميل البيانات...',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }

                    return Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBatchHeader(),
                            SizedBox(height: 24.h),
                            _buildStatsOverview(
                              availableForDeaths,
                              totalSold,
                              totalDeaths,
                            ),
                            SizedBox(height: 24.h),
                            _buildFormSection(availableForDeaths),
                            SizedBox(height: 32.h),
                            _buildSubmitButton(availableForDeaths),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBatchHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.1),
            AppTheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.inventory_2, color: Colors.white, size: 24.w),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اسم الدفعة',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.batch.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(
    int availableForDeaths,
    int totalSold,
    int totalDeaths,
  ) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: AppTheme.info, size: 20.w),
              SizedBox(width: 8.w),
              Text(
                'إحصائيات الدفعة',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'إجمالي الكتاكيت',
                  '${widget.batch.chickCount}',
                  Icons.pets,
                  AppTheme.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  'المتاح للتسجيل',
                  '$availableForDeaths',
                  Icons.add_circle_outline,
                  availableForDeaths > 0 ? AppTheme.success : AppTheme.error,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'المباع',
                  '$totalSold',
                  Icons.shopping_cart_outlined,
                  AppTheme.accent,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  'الوفيات',
                  '$totalDeaths',
                  Icons.remove_circle_outline,
                  AppTheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.w),
          SizedBox(height: 8.h),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(int availableForDeaths) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_outlined, color: AppTheme.primary, size: 20.w),
              SizedBox(width: 8.w),
              Text(
                'تفاصيل الوفيات',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          EnhancedTextField(
            controller: _countController,
            label: 'عدد الوفيات',
            icon: Icons.remove_circle_outline,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال عدد الوفيات';
              }
              final count = int.tryParse(value);
              if (count == null || count <= 0) {
                return 'يرجى إدخال عدد صحيح موجب';
              }
              if (count > availableForDeaths) {
                return 'عدد الوفيات لا يمكن أن يتجاوز العدد المتاح ($availableForDeaths)';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          _buildDateSelector(),
          if (availableForDeaths <= 0) ...[
            SizedBox(height: 20.h),
            _buildWarningMessage(),
          ],
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppTheme.primary, size: 20.w),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تاريخ الوفاة',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_drop_down,
              color: AppTheme.textSecondary,
              size: 24.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningMessage() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_rounded, color: AppTheme.error, size: 24.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'لا يوجد كتاكيت متاحة لتسجيل الوفيات',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(int availableForDeaths) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: availableForDeaths > 0 ? _submitForm : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              availableForDeaths > 0 ? AppTheme.accent : AppTheme.textFaint,
          foregroundColor:
              availableForDeaths > 0 ? Colors.white : AppTheme.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: availableForDeaths > 0 ? 8 : 0,
          shadowColor: AppTheme.accent.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              availableForDeaths > 0 ? Icons.add_circle : Icons.block,
              size: 24.w,
            ),
            SizedBox(width: 12.w),
            Text(
              availableForDeaths > 0 ? 'إضافة الوفيات' : 'لا يوجد كتاكيت متاحة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
