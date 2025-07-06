import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/entities/addition_entity.dart';
import '../../../../core/entities/batch_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../cubit/additions_cubit.dart';

class AddAdditionScreen extends StatefulWidget {
  final BatchEntity batch;

  const AddAdditionScreen({super.key, required this.batch});

  @override
  State<AddAdditionScreen> createState() => _AddAdditionScreenState();
}

class _AddAdditionScreenState extends State<AddAdditionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final addition = AdditionEntity(
        id: const Uuid().v4(),
        batchId: widget.batch.id,
        name: _nameController.text.trim(),
        cost: double.parse(_costController.text),
        date: _selectedDate,
      );

      context.read<AdditionsCubit>().addAddition(addition);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إضافة مصروف جديد',
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
        child: ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            _buildSectionTitle('تفاصيل المصروف'),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _nameController,
              label: 'اسم المصروف',
              icon: Icons.receipt_long,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال اسم المصروف';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _costController,
              label: 'التكلفة (جنيه)',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال التكلفة';
                }
                final cost = double.tryParse(value);
                if (cost == null || cost <= 0) {
                  return 'يرجى إدخال تكلفة صحيحة';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            _buildDateField(),
            SizedBox(height: 32.h),
            Container(
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
                      'إضافة المصروف',
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
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.3),
          width: 1,
        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primary),
        filled: true,
        fillColor: AppTheme.cardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppTheme.textFaint),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppTheme.textFaint),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppTheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppTheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppTheme.error, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        labelStyle: TextStyle(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppTheme.cardLight,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.textFaint),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppTheme.primary),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تاريخ المصروف',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textMain,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
