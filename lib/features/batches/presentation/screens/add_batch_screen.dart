import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/entities/batch_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/enhanced_text_field.dart';
import '../../cubit/batches_cubit.dart';

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppTheme.primary),
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
      );

      context.read<BatchesCubit>().addBatch(batch);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormScaffold(
      appBar: AppBar(
        title: Text(
          'إضافة دفعة جديدة',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textLight,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildSectionTitle('معلومات الدفعة'),
            SizedBox(height: 12.h),
            EnhancedTextField(
              controller: _nameController,
              label: 'اسم الدفعة',
              icon: Icons.label,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال اسم الدفعة';
                }
                return null;
              },
            ),
            SizedBox(height: 12.h),
            EnhancedTextField(
              controller: _supplierController,
              label: 'اسم المورد',
              icon: Icons.person,
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
            ),
            SizedBox(height: 20.h),
            _buildSectionTitle('تفاصيل الكتاكيت'),
            SizedBox(height: 12.h),
            EnhancedTextField(
              controller: _chickCountController,
              label: 'عدد الكتاكيت',
              icon: Icons.pets,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال عدد الكتاكيت';
                }
                final count = int.tryParse(value);
                if (count == null || count <= 0) {
                  return 'يرجى إدخال عدد صحيح موجب';
                }
                return null;
              },
            ),
            SizedBox(height: 12.h),
            EnhancedTextField(
              controller: _chickBuyPriceController,
              label: 'سعر شراء الكتكوت (جنيه)',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال سعر الشراء';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'يرجى إدخال سعر صحيح';
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),
            _buildSectionTitle('ملاحظات إضافية'),
            SizedBox(height: 12.h),
            EnhancedTextField(
              controller: _noteController,
              label: 'ملاحظات (اختياري)',
              icon: Icons.note,
              maxLines: 3,
              textInputAction: TextInputAction.newline,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.textMain,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 20.w),
                    SizedBox(width: 8.w),
                    Text(
                      'إضافة الدفعة',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 1),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppTheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
