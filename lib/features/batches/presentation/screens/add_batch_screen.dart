import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/entities/batch_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/enhanced_text_field.dart';
import '../../cubit/batches_cubit.dart';
import '../../../auth/cubit/auth_cubit.dart';

class AddBatchScreen extends StatefulWidget {
  const AddBatchScreen({super.key});

  @override
  State<AddBatchScreen> createState() => _AddBatchScreenState();
}

class _AddBatchScreenState extends State<AddBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _supplierController = TextEditingController();
  final _chickCountController = TextEditingController();
  final _chickBuyPriceController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _supplierController.dispose();
    _chickCountController.dispose();
    _chickBuyPriceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'اختر تاريخ التسجيل',
      cancelText: 'إلغاء',
      confirmText: 'موافق',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primary,
              onPrimary: AppTheme.textLight,
            ),
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

  void _submitForm() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authState = context.read<AuthCubit>().state;
        String userId = '';
        if (authState is Authenticated) {
          userId = authState.userId;
        }

        final batch = BatchEntity(
          id: const Uuid().v4(),
          name: _nameController.text.trim(),
          date: _selectedDate,
          supplier: _supplierController.text.trim(),
          chickCount: int.parse(_chickCountController.text),
          chickBuyPrice: double.parse(_chickBuyPriceController.text),
          note:
              _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text.trim(),
          userId: userId,
          updatedAt: DateTime.now(),
        );

        context.read<BatchesCubit>().addBatch(batch);

        // إظهار رسالة نجاح
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم إضافة الدفعة بنجاح'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('حدث خطأ أثناء إضافة الدفعة'),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldLight,
      appBar: AppBar(
        title: const Text('إضافة دفعة جديدة'),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textLight,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_isLoading)
            Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Center(
                child: SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.textLight,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // القسم الأول - معلومات أساسية
              _buildSectionCard(
                title: 'المعلومات الأساسية',
                icon: Icons.info_outline,
                children: [
                  EnhancedTextField(
                    controller: _nameController,
                    label: 'اسم الدفعة *',
                    icon: Icons.label_outline,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال اسم الدفعة';
                      }
                      if (value.trim().length < 2) {
                        return 'اسم الدفعة يجب أن يكون حرفين على الأقل';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  EnhancedTextField(
                    controller: _supplierController,
                    label: 'اسم المورد *',
                    icon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال اسم المورد';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  EnhancedDateField(
                    label: 'تاريخ التسجيل',
                    selectedDate: _selectedDate,
                    onTap: _selectDate,
                    icon: Icons.calendar_today_outlined,
                  ),
                ],
              ),

              SizedBox(height: 14.h),

              // القسم الثاني - تفاصيل الكتاكيت
              _buildSectionCard(
                title: 'تفاصيل الكتاكيت',
                icon: Icons.pets_outlined,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: EnhancedTextField(
                          controller: _chickCountController,
                          label: 'العدد *',
                          icon: Icons.format_list_numbered,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'مطلوب';
                            }
                            final count = int.tryParse(value);
                            if (count == null || count <= 0) {
                              return 'رقم غير صحيح';
                            }
                            if (count > 100000) {
                              return 'عدد كبير جداً';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        flex: 3,
                        child: EnhancedTextField(
                          controller: _chickBuyPriceController,
                          label: 'سعر الوحدة (جنيه) *',
                          icon: Icons.attach_money,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'مطلوب';
                            }
                            final price = double.tryParse(value);
                            if (price == null || price <= 0) {
                              return 'سعر غير صحيح';
                            }
                            if (price > 1000) {
                              return 'سعر مرتفع جداً';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  // كارت حساب التكلفة - يظهر فقط عند إدخال العدد والسعر
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _chickCountController,
                    builder: (context, countValue, _) {
                      return ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _chickBuyPriceController,
                        builder: (context, priceValue, _) {
                          final count = int.tryParse(countValue.text) ?? 0;
                          final price = double.tryParse(priceValue.text) ?? 0.0;
                          final shouldShow = count > 0 && price > 0;

                          return AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child:
                                shouldShow
                                    ? Column(
                                      children: [
                                        SizedBox(height: 12.h),
                                        _buildCalculationCard(count, price),
                                      ],
                                    )
                                    : const SizedBox.shrink(),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 14.h),

              // القسم الثالث - ملاحظات (اختياري)
              _buildSectionCard(
                title: 'ملاحظات إضافية',
                icon: Icons.note_outlined,
                isOptional: true,
                children: [
                  EnhancedTextField(
                    controller: _noteController,
                    label: 'ملاحظات (اختياري)',
                    icon: Icons.edit_note,
                    maxLines: 3,
                    textInputAction: TextInputAction.newline,
                    hintText: 'اكتب أي ملاحظات إضافية...',
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // زر الحفظ
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool isOptional = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: AppTheme.primaryGradient),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(icon, color: AppTheme.textLight, size: 18.w),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                if (isOptional)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.textFaint.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'اختياري',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationCard(int count, double price) {
    final total = count * price;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accent.withOpacity(0.08),
            AppTheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate, color: AppTheme.accent, size: 18.w),
              SizedBox(width: 6.w),
              Text(
                'إجمالي التكلفة',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'محسوب تلقائياً',
                  style: TextStyle(
                    color: AppTheme.success,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${total.toStringAsFixed(2)} جنيه',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$count × ${price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 50.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          foregroundColor: AppTheme.textMain,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 4,
          shadowColor: AppTheme.accent.withOpacity(0.3),
        ),
        child:
            _isLoading
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18.w,
                      height: 18.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.textMain,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    const Text('جاري الحفظ...'),
                  ],
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, size: 20.w),
                    SizedBox(width: 8.w),
                    Text(
                      'حفظ الدفعة',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
