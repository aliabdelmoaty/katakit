import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/entities/sale_entity.dart';
import '../../../../core/entities/batch_entity.dart';
import '../../../../core/theme/app_theme.dart';
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

  @override
  void initState() {
    super.initState();
    _currentPaidAmount = widget.sale.paidAmount;
    _remainingAmount = widget.sale.remainingAmount;
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
        title: Text(
          'تعديل عملية البيع',
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
            _buildSaleInfoCard(),
            SizedBox(height: 24.h),
            _buildPaymentStatusCard(),
            SizedBox(height: 24.h),
            _buildAdditionalPaymentSection(),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _remainingAmount > 0 ? _addPayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _remainingAmount > 0
                          ? AppTheme.accent
                          : AppTheme.textFaint,
                  foregroundColor:
                      _remainingAmount > 0
                          ? AppTheme.textMain
                          : AppTheme.textSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payment, size: 20.w),
                    SizedBox(width: 8.w),
                    Text(
                      _remainingAmount > 0 ? 'إضافة دفعة' : 'تم السداد بالكامل',
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

  Widget _buildSaleInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader('معلومات عملية البيع', Icons.sell),
            SizedBox(height: 20.h),
            _buildInfoRow('المشتري', widget.sale.buyerName, Icons.person),
            _buildInfoRow(
              'عدد الكتاكيت',
              '${widget.sale.chickCount} كتكوت',
              Icons.pets,
            ),
            _buildInfoRow(
              'سعر الكتكوت',
              '${widget.sale.pricePerChick.toStringAsFixed(2)} جنيه',
              Icons.attach_money,
            ),
            _buildInfoRow(
              'السعر الإجمالي',
              '${widget.sale.totalPrice.toStringAsFixed(2)} جنيه',
              Icons.calculate,
            ),
            _buildInfoRow(
              'تاريخ البيع',
              _formatDate(widget.sale.date),
              Icons.calendar_today,
            ),
            if (widget.sale.note != null)
              _buildInfoRow('ملاحظات', widget.sale.note!, Icons.note),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatusCard() {
    final isFullyPaid = _remainingAmount <= 0;
    final isPartiallyPaid =
        _remainingAmount > 0 && _remainingAmount < widget.sale.totalPrice;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader('حالة الدفع', Icons.payment),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: _buildPaymentItem(
                    'المدفوع',
                    '${_currentPaidAmount.toStringAsFixed(2)} جنيه',
                    AppTheme.success,
                    Icons.check_circle,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildPaymentItem(
                    'الباقي',
                    '${_remainingAmount.toStringAsFixed(2)} جنيه',
                    isFullyPaid ? AppTheme.success : AppTheme.error,
                    isFullyPaid ? Icons.check_circle : Icons.pending,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color:
                    isFullyPaid
                        ? AppTheme.success.withOpacity(0.1)
                        : isPartiallyPaid
                        ? AppTheme.warning.withOpacity(0.1)
                        : AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color:
                      isFullyPaid
                          ? AppTheme.success.withOpacity(0.3)
                          : isPartiallyPaid
                          ? AppTheme.warning.withOpacity(0.3)
                          : AppTheme.error.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isFullyPaid
                        ? Icons.check_circle
                        : isPartiallyPaid
                        ? Icons.pending
                        : Icons.money_off,
                    color:
                        isFullyPaid
                            ? AppTheme.success
                            : isPartiallyPaid
                            ? AppTheme.warning
                            : AppTheme.error,
                    size: 24.w,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      isFullyPaid
                          ? 'تم السداد بالكامل'
                          : isPartiallyPaid
                          ? 'تم دفع جزء من المبلغ'
                          : 'لم يتم الدفع بعد',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color:
                            isFullyPaid
                                ? AppTheme.success
                                : isPartiallyPaid
                                ? AppTheme.warning
                                : AppTheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalPaymentSection() {
    if (_remainingAmount <= 0) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              Icon(Icons.check_circle, color: AppTheme.success, size: 48.w),
              SizedBox(height: 16.h),
              Text(
                'تم السداد بالكامل',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'لا يمكن إضافة مدفوعات إضافية',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader('إضافة دفعة جديدة', Icons.add_circle),
            SizedBox(height: 20.h),
            _buildTextField(
              controller: _additionalPaymentController,
              label: 'المبلغ الإضافي (جنيه)',
              icon: Icons.payment,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال المبلغ';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'يرجى إدخال مبلغ صحيح';
                }
                if (amount > _remainingAmount) {
                  return 'المبلغ لا يمكن أن يتجاوز الباقي (${_remainingAmount.toStringAsFixed(2)} جنيه)';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppTheme.info.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.info,
                        size: 20.w,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'معلومات الدفعة',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: AppTheme.info,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'المدفوع حالياً',
                          '${_currentPaidAmount.toStringAsFixed(2)} جنيه',
                          AppTheme.success,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildInfoItem(
                          'الباقي',
                          '${_remainingAmount.toStringAsFixed(2)} جنيه',
                          AppTheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20.w),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 16.w, color: AppTheme.textSecondary),
          SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textMain,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.w),
          SizedBox(height: 8.h),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
