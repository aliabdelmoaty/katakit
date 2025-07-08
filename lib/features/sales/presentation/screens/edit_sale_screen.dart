import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/entities/sale_entity.dart';
import '../../../../core/entities/batch_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/enhanced_text_field.dart';
import '../../cubit/sales_cubit.dart';

class EditSaleScreen extends StatefulWidget {
  final SaleEntity sale;
  final BatchEntity batch;

  const EditSaleScreen({super.key, required this.sale, required this.batch});

  @override
  State<EditSaleScreen> createState() => _EditSaleScreenState();
}

class _EditSaleScreenState extends State<EditSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _additionalPaymentController = TextEditingController();
  late double _currentPaidAmount;
  late double _remainingAmount;
  double _newPaymentAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _currentPaidAmount = widget.sale.paidAmount;
    _remainingAmount = widget.sale.remainingAmount;

    _additionalPaymentController.addListener(() {
      setState(() {
        _newPaymentAmount =
            double.tryParse(_additionalPaymentController.text) ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _additionalPaymentController.dispose();
    super.dispose();
  }

  void _addPayment() {
    if (_formKey.currentState!.validate()) {
      final additionalPayment = double.parse(_additionalPaymentController.text);
      final newPaidAmount = _currentPaidAmount + additionalPayment;

      if (newPaidAmount > widget.sale.totalPrice) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('المبلغ الإجمالي لا يمكن أن يتجاوز السعر الكلي'),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }

      final updatedSale = widget.sale.copyWith(paidAmount: newPaidAmount);

      context.read<SalesCubit>().updateSale(updatedSale);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textLight,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'تعديل عملية البيع',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textLight,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 55.h, // زيادة من 50.h إلى 55.h
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w), // زيادة من 12.w إلى 16.w
          children: [
            // معلومات العملية مضغوطة
            _buildCompactSaleInfo(),
            SizedBox(height: 16.h), // زيادة من 12.h إلى 16.h
            // حالة الدفع مبسطة
            _buildPaymentStatusCompact(),
            SizedBox(height: 16.h), // زيادة من 12.h إلى 16.h
            // قسم الدفعة الجديدة مدمج
            if (_remainingAmount > 0) ...[
              _buildNewPaymentSection(),
              SizedBox(height: 18.h), // زيادة من 16.h إلى 18.h
              // معاينة الدفعة الجديدة
              if (_newPaymentAmount > 0) ...[
                _buildPaymentPreview(),
                SizedBox(height: 16.h), // زيادة من 12.h إلى 16.h
              ],
            ],

            // زر الحفظ
            _buildSubmitButton(),
            SizedBox(height: 16.h), // زيادة من 12.h إلى 16.h
          ],
        ),
      ),
    );
  }

  Widget _buildCompactSaleInfo() {
    return Container(
      padding: EdgeInsets.all(16.w), // زيادة من 12.w إلى 16.w
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.1),
            AppTheme.accent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r), // زيادة من 12.r إلى 14.r
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w), // زيادة من 6.w إلى 8.w
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    8.r,
                  ), // زيادة من 6.r إلى 8.r
                ),
                child: Icon(
                  Icons.sell,
                  color: AppTheme.primary,
                  size: 20.w,
                ), // زيادة من 16.w إلى 20.w
              ),
              SizedBox(width: 12.w), // زيادة من 8.w إلى 12.w
              Expanded(
                child: Text(
                  widget.sale.buyerName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp, // إضافة حجم خط أكبر
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 6.h,
                ), // زيادة الـ padding
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    8.r,
                  ), // زيادة من 6.r إلى 8.r
                  border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                ),
                child: Text(
                  '${widget.sale.totalPrice.toStringAsFixed(0)} ج',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp, // إضافة حجم خط أكبر
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h), // زيادة من 8.h إلى 12.h
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoChip(
                '${widget.sale.chickCount} كتكوت',
                Icons.pets,
                AppTheme.accent,
              ),
              _buildInfoChip(
                '${widget.sale.pricePerChick.toStringAsFixed(1)} ج/كتكوت',
                Icons.monetization_on,
                AppTheme.info,
              ),
              _buildInfoChip(
                _formatDate(widget.sale.date),
                Icons.calendar_today,
                AppTheme.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8.w,
          vertical: 4.h,
        ), // زيادة الـ padding
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.r), // زيادة من 4.r إلى 6.r
          border: Border.all(color: color.withOpacity(0.3), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 12.w), // زيادة من 10.w إلى 12.w
            SizedBox(width: 4.w), // زيادة من 3.w إلى 4.w
            Flexible(
              child: Text(
                text,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontSize: 10.sp, // زيادة من 9.sp إلى 10.sp
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatusCompact() {
    final isFullyPaid = _remainingAmount <= 0;

    return Container(
      padding: EdgeInsets.all(16.w), // زيادة من 12.w إلى 16.w
      decoration: BoxDecoration(
        color:
            isFullyPaid
                ? AppTheme.success.withOpacity(0.1)
                : AppTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r), // زيادة من 10.r إلى 12.r
        border: Border.all(
          color:
              isFullyPaid
                  ? AppTheme.success.withOpacity(0.3)
                  : AppTheme.warning.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isFullyPaid ? Icons.check_circle : Icons.pending_actions,
                color: isFullyPaid ? AppTheme.success : AppTheme.warning,
                size: 22.w, // زيادة من 18.w إلى 22.w
              ),
              SizedBox(width: 12.w), // زيادة من 8.w إلى 12.w
              Expanded(
                child: Text(
                  isFullyPaid ? 'تم السداد بالكامل' : 'سداد جزئي',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isFullyPaid ? AppTheme.success : AppTheme.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp, // إضافة حجم خط أكبر
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h), // زيادة من 8.h إلى 12.h
          Row(
            children: [
              Expanded(
                child: _buildPaymentStatusItem(
                  'المدفوع',
                  '${_currentPaidAmount.toStringAsFixed(0)} ج',
                  AppTheme.success,
                  Icons.check,
                ),
              ),
              SizedBox(width: 12.w), // زيادة من 8.w إلى 12.w
              Expanded(
                child: _buildPaymentStatusItem(
                  'الباقي',
                  '${_remainingAmount.toStringAsFixed(0)} ج',
                  isFullyPaid ? AppTheme.success : AppTheme.error,
                  isFullyPaid ? Icons.check : Icons.pending,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(10.w), // زيادة من 8.w إلى 10.w
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r), // زيادة من 6.r إلى 8.r
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16.w), // زيادة من 14.w إلى 16.w
          SizedBox(height: 4.h), // زيادة من 3.h إلى 4.h
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 10.sp, // زيادة من 9.sp إلى 10.sp
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp, // زيادة من 11.sp إلى 12.sp
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewPaymentSection() {
    if (_remainingAmount <= 0) {
      return Container(
        padding: EdgeInsets.all(18.w), // زيادة من 16.w إلى 18.w
        decoration: BoxDecoration(
          color: AppTheme.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r), // زيادة من 10.r إلى 12.r
          border: Border.all(color: AppTheme.success.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppTheme.success,
              size: 28.w,
            ), // زيادة من 24.w إلى 28.w
            SizedBox(width: 14.w), // زيادة من 12.w إلى 14.w
            Expanded(
              child: Text(
                'تم السداد بالكامل - لا يمكن إضافة مدفوعات',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp, // إضافة حجم خط أكبر
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16.w), // زيادة من 12.w إلى 16.w
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12.r), // زيادة من 10.r إلى 12.r
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w), // زيادة من 5.w إلى 6.w
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    6.r,
                  ), // زيادة من 5.r إلى 6.r
                ),
                child: Icon(
                  Icons.add_circle,
                  color: AppTheme.accent,
                  size: 18.w, // زيادة من 16.w إلى 18.w
                ),
              ),
              SizedBox(width: 10.w), // زيادة من 8.w إلى 10.w
              Text(
                'إضافة دفعة جديدة',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp, // إضافة حجم خط أكبر
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h), // زيادة من 10.h إلى 12.h
          _buildCompactTextField(
            controller: _additionalPaymentController,
            label: 'المبلغ الإضافي (جنيه)',
            icon: Icons.payment,
            maxAmount: _remainingAmount,
            onSubmitted: () {
              final canSubmit = _remainingAmount > 0 && _newPaymentAmount > 0;
              // Handle the submission logic here
              if (_formKey.currentState!.validate() && canSubmit) {
                _addPayment();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required double maxAmount,
    required void Function() onSubmitted,
  }) {
    return EnhancedTextField(
      onSubmitted: onSubmitted,
      label: label,
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'يرجى إدخال المبلغ';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'يرجى إدخال مبلغ صحيح';
        }
        if (amount > maxAmount) {
          return 'الحد الأقصى: ${maxAmount.toStringAsFixed(0)} ج';
        }
        return null;
      },
      hintText: 'أقصى مبلغ: ${maxAmount.toStringAsFixed(0)} جنيه',
      suffixText: 'جنيه',
      icon: icon,
    );
  }

  Widget _buildPaymentPreview() {
    final newTotal = _currentPaidAmount + _newPaymentAmount;
    final newRemaining = widget.sale.totalPrice - newTotal;

    return Container(
      padding: EdgeInsets.all(12.w), // زيادة من 10.w إلى 12.w
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.info.withOpacity(0.1),
            AppTheme.info.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(10.r), // زيادة من 8.r إلى 10.r
        border: Border.all(color: AppTheme.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: AppTheme.info,
                size: 16.w,
              ), // زيادة من 14.w إلى 16.w
              SizedBox(width: 8.w), // زيادة من 6.w إلى 8.w
              Text(
                'معاينة بعد الدفعة الجديدة',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.info,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp, // إضافة حجم خط أكبر
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h), // زيادة من 6.h إلى 8.h
          Row(
            children: [
              Expanded(
                child: _buildPreviewItem(
                  'إجمالي مدفوع',
                  '${newTotal.toStringAsFixed(0)} ج',
                  AppTheme.success,
                ),
              ),
              SizedBox(width: 8.w), // زيادة من 6.w إلى 8.w
              Expanded(
                child: _buildPreviewItem(
                  'المتبقي',
                  '${newRemaining.toStringAsFixed(0)} ج',
                  newRemaining <= 0 ? AppTheme.success : AppTheme.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(8.w), // زيادة من 6.w إلى 8.w
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r), // زيادة من 4.r إلى 6.r
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 9.sp, // زيادة من 8.sp إلى 9.sp
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11.sp, // زيادة من 10.sp إلى 11.sp
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = _remainingAmount > 0 && _newPaymentAmount > 0;

    return SizedBox(
      width: double.infinity,
      height: 50.h, // زيادة من 45.h إلى 50.h
      child: ElevatedButton.icon(
        onPressed: canSubmit ? _addPayment : null,
        icon: Icon(
          canSubmit
              ? Icons.payment
              : _remainingAmount <= 0
              ? Icons.check_circle
              : Icons.add,
          size: 20.w, // زيادة من 18.w إلى 20.w
        ),
        label: Text(
          canSubmit
              ? 'تأكيد الدفعة (${_newPaymentAmount.toStringAsFixed(0)} ج)'
              : _remainingAmount <= 0
              ? 'تم السداد بالكامل'
              : 'أدخل مبلغ الدفعة',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15.sp, // إضافة حجم خط أكبر
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: canSubmit ? AppTheme.accent : AppTheme.textFaint,
          foregroundColor:
              canSubmit ? AppTheme.textMain : AppTheme.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r), // زيادة من 10.r إلى 12.r
          ),
          elevation: canSubmit ? 4 : 1, // زيادة الـ elevation قليلاً
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
