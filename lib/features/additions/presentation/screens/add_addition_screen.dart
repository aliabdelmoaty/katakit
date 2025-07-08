import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:katakit/core/utils/app_utils.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/entities/addition_entity.dart';
import '../../../../core/entities/batch_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../cubit/additions_cubit.dart';
import '../../../auth/cubit/auth_cubit.dart';

class AddAdditionScreen extends StatefulWidget {
  final BatchEntity batch;

  const AddAdditionScreen({super.key, required this.batch});

  @override
  State<AddAdditionScreen> createState() => _AddAdditionScreenState();
}

class _AddAdditionScreenState extends State<AddAdditionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _nameController.dispose();
    _costController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
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
              onPrimary: AppTheme.textLight,
              surface: AppTheme.cardLight,
              onSurface: AppTheme.textMain,
            ),
            dialogTheme: DialogThemeData(backgroundColor: AppTheme.cardLight),
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
      final authState = context.read<AuthCubit>().state;
      String userId = '';
      if (authState is Authenticated) {
        userId = authState.userId;
      }

      final addition = AdditionEntity(
        id: const Uuid().v4(),
        batchId: widget.batch.id,
        name: _nameController.text.trim(),
        cost: double.parse(_costController.text),
        date: _selectedDate,
        userId: userId,
        updatedAt: DateTime.now(),
      );

      context.read<AdditionsCubit>().addAddition(addition);

      // Show success message
      context.showSuccessSnackBar(
        'تم إضافة المصروف بنجاح',
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverFillRemaining(
            hasScrollBody: false,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildBatchInfoCard(),
                        SizedBox(height: 24.h),
                        _buildFormSection(),
                        const Spacer(),
                        _buildSubmitButton(),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppTheme.primaryGradient,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
          ),
          child: Stack(
            children: [
              // Content
              Positioned(
                bottom: 20.h,
                left: 20.w,
                right: 20.w,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.add_business_rounded,
                        color: AppTheme.textLight,
                        size: 24.w,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إضافة مصروف جديد',
                            style: TextStyle(
                              color: AppTheme.textLight,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'تسجيل مصروف جديد للدفعة',
                            style: TextStyle(
                              color: AppTheme.textLight.withOpacity(0.8),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppTheme.textLight,
          size: 18.w,
        ),
      ),
    );
  }

  Widget _buildBatchInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.info.withOpacity(0.1),
            AppTheme.info.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.info.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              color: AppTheme.info,
              size: 24.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الدفعة المحددة',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.batch.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textMain,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${widget.batch.chickCount} كتكوت',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textFaint.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          SizedBox(height: 20.h),
          _buildNameField(),
          SizedBox(height: 16.h),
          _buildCostField(),
          SizedBox(height: 16.h),
          _buildDateField(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: AppTheme.accentGradient),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(Icons.edit_rounded, color: AppTheme.textMain, size: 20.w),
        ),
        SizedBox(width: 12.w),
        Text(
          'تفاصيل المصروف',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textMain,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اسم المصروف *',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textMain,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'مثال: علف، أدوية، صيانة',
            prefixIcon: Container(
              margin: EdgeInsets.all(12.w),
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                color: AppTheme.primary,
                size: 20.w,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppTheme.textFaint.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppTheme.textFaint.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppTheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppTheme.error, width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال اسم المصروف';
            }
            if (value.trim().length < 2) {
              return 'اسم المصروف يجب أن يكون أكثر من حرفين';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCostField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التكلفة *',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textMain,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _costController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            hintText: '0.00',
            prefixIcon: Container(
              margin: EdgeInsets.all(12.w),
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.attach_money_rounded,
                color: AppTheme.accent,
                size: 20.w,
              ),
            ),
            suffixText: 'جنيه',
            suffixStyle: TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppTheme.textFaint.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppTheme.textFaint.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppTheme.accent, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppTheme.error, width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال التكلفة';
            }
            final cost = double.tryParse(value);
            if (cost == null) {
              return 'يرجى إدخال رقم صحيح';
            }
            if (cost <= 0) {
              return 'التكلفة يجب أن تكون أكبر من صفر';
            }
            if (cost > 1000000) {
              return 'التكلفة كبيرة جداً';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تاريخ المصروف',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textMain,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.textFaint.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 8.w),
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: AppTheme.info,
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _formatDate(_selectedDate),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textMain,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: AppTheme.textSecondary,
                  size: 24.w,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          foregroundColor: AppTheme.textMain,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 8,
          shadowColor: AppTheme.accent.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                Icons.add_rounded,
                size: 20.w,
                color: AppTheme.textMain,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'إضافة المصروف',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    const days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'اليوم';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'أمس';
    } else {
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }
}
