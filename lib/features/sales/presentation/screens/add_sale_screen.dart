import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/entities/sale_entity.dart';
import '../../../../core/entities/batch_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../cubit/sales_cubit.dart';
import '../../../deaths/cubit/deaths_cubit.dart';

class AddSaleScreen extends StatefulWidget {
  final BatchEntity batch;

  const AddSaleScreen({super.key, required this.batch});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _buyerNameController = TextEditingController();
  final _chickCountController = TextEditingController();
  final _pricePerChickController = TextEditingController();
  final _paidAmountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // متغيرات لحساب السعر الإجمالي والباقي
  double _totalPrice = 0.0;
  double _remainingAmount = 0.0;

  @override
  void initState() {
    super.initState();
    // تحميل البيانات المطلوبة لحساب العدد المتاح
    context.read<SalesCubit>().loadSales(widget.batch.id);
    context.read<DeathsCubit>().loadDeaths(widget.batch.id);

    // إضافة listeners لحساب السعر الإجمالي
    _chickCountController.addListener(_calculateTotalPrice);
    _pricePerChickController.addListener(_calculateTotalPrice);
    _paidAmountController.addListener(_calculateRemainingAmount);
  }

  @override
  void dispose() {
    _buyerNameController.dispose();
    _chickCountController.dispose();
    _pricePerChickController.dispose();
    _paidAmountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // حساب السعر الإجمالي
  void _calculateTotalPrice() {
    final chickCount = int.tryParse(_chickCountController.text) ?? 0;
    final pricePerChick = double.tryParse(_pricePerChickController.text) ?? 0.0;

    setState(() {
      _totalPrice = chickCount * pricePerChick;
      _calculateRemainingAmount();
    });
  }

  // حساب الباقي
  void _calculateRemainingAmount() {
    final paidAmount = double.tryParse(_paidAmountController.text) ?? 0.0;
    setState(() {
      _remainingAmount = _totalPrice - paidAmount;
    });
  }

  // حساب العدد المتاح للبيع بناءً على الوفيات والمبيعات السابقة
  int _calculateAvailableForSale(int totalSold, int totalDeaths) {
    return widget.batch.chickCount - totalDeaths - totalSold;
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
      final sale = SaleEntity(
        id: const Uuid().v4(),
        batchId: widget.batch.id,
        buyerName: _buyerNameController.text.trim(),
        date: _selectedDate,
        chickCount: int.parse(_chickCountController.text),
        pricePerChick: double.parse(_pricePerChickController.text),
        paidAmount: double.parse(_paidAmountController.text),
        note:
            _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
      );

      context.read<SalesCubit>().addSale(sale);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إضافة عملية بيع جديدة',
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
      body: MultiBlocListener(
        listeners: [
          BlocListener<SalesCubit, SalesState>(
            listener: (context, state) {
              if (state is SalesLoaded) {
                // تحديث النموذج عند تغيير البيانات
                setState(() {});
              }
            },
          ),
          BlocListener<DeathsCubit, DeathsState>(
            listener: (context, state) {
              if (state is DeathsLoaded) {
                // تحديث النموذج عند تغيير البيانات
                setState(() {});
              }
            },
          ),
        ],
        child: BlocBuilder<SalesCubit, SalesState>(
          builder: (context, salesState) {
            return BlocBuilder<DeathsCubit, DeathsState>(
              builder: (context, deathsState) {
                // حساب العدد المتاح للبيع
                int totalSold = 0;
                int totalDeaths = 0;

                if (salesState is SalesLoaded) {
                  totalSold = salesState.totalSoldCount;
                }

                if (deathsState is DeathsLoaded) {
                  totalDeaths = deathsState.totalDeathsCount;
                }

                final availableForSale = _calculateAvailableForSale(
                  totalSold,
                  totalDeaths,
                );

                return Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.all(16.w),
                    children: [
                      _buildSectionTitle('معلومات المشتري'),
                      SizedBox(height: 12.h),
                      _buildTextField(
                        controller: _buyerNameController,
                        label: 'اسم المشتري',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال اسم المشتري';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),
                      _buildSectionTitle('تفاصيل البيع'),
                      SizedBox(height: 12.h),
                      _buildTextField(
                        controller: _chickCountController,
                        label: 'عدد الكتاكيت المباعة',
                        icon: Icons.sell,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال عدد الكتاكيت';
                          }
                          final count = int.tryParse(value);
                          if (count == null || count <= 0) {
                            return 'يرجى إدخال عدد صحيح موجب';
                          }
                          if (count > availableForSale) {
                            return 'عدد الكتاكيت لا يمكن أن يتجاوز العدد المتاح للبيع ($availableForSale)';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12.h),
                      _buildTextField(
                        controller: _pricePerChickController,
                        label: 'سعر البيع للكتكوت (جنيه)',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال سعر البيع';
                          }
                          final price = double.tryParse(value);
                          if (price == null || price <= 0) {
                            return 'يرجى إدخال سعر صحيح';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),
                      _buildSectionTitle('المدفوعات'),
                      SizedBox(height: 12.h),
                      _buildTotalPriceCard(),
                      SizedBox(height: 12.h),
                      _buildTextField(
                        controller: _paidAmountController,
                        label: 'المبلغ المدفوع (جنيه)',
                        icon: Icons.payment,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال المبلغ المدفوع';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount < 0) {
                            return 'يرجى إدخال مبلغ صحيح';
                          }
                          if (amount > _totalPrice) {
                            return 'المبلغ المدفوع لا يمكن أن يتجاوز السعر الإجمالي';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12.h),
                      _buildRemainingAmountCard(),
                      SizedBox(height: 12.h),
                      _buildDateField(),
                      SizedBox(height: 20.h),
                      _buildSectionTitle('ملاحظات إضافية'),
                      SizedBox(height: 12.h),
                      _buildTextField(
                        controller: _noteController,
                        label: 'ملاحظات (اختياري)',
                        icon: Icons.note,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                      ),
                      SizedBox(height: 20.h),
                      _buildInfoCard(availableForSale, totalSold, totalDeaths),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: availableForSale > 0 ? _submitForm : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                availableForSale > 0
                                    ? AppTheme.accent
                                    : AppTheme.textFaint,
                            foregroundColor:
                                availableForSale > 0
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
                              Icon(Icons.add, size: 20.w),
                              SizedBox(width: 8.w),
                              Text(
                                availableForSale > 0
                                    ? 'إضافة عملية البيع'
                                    : 'لا يوجد كتاكيت متاحة للبيع',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
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

  Widget _buildTotalPriceCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.calculate, color: AppTheme.accent, size: 24.w),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'السعر الإجمالي',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${_totalPrice.toStringAsFixed(2)} جنيه',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.bold,
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

  Widget _buildRemainingAmountCard() {
    final isFullyPaid = _remainingAmount <= 0;
    final isPartiallyPaid =
        _remainingAmount > 0 && _remainingAmount < _totalPrice;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color:
                        isFullyPaid
                            ? AppTheme.success.withOpacity(0.1)
                            : isPartiallyPaid
                            ? AppTheme.warning.withOpacity(0.1)
                            : AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
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
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'حالة الدفع',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textMain,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildPaymentInfoItem(
                    'المدفوع',
                    '${(double.tryParse(_paidAmountController.text) ?? 0.0).toStringAsFixed(2)} جنيه',
                    AppTheme.success,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildPaymentInfoItem(
                    'الباقي',
                    '${_remainingAmount.toStringAsFixed(2)} جنيه',
                    isFullyPaid ? AppTheme.success : AppTheme.error,
                  ),
                ),
              ],
            ),
            if (isPartiallyPaid) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppTheme.warning.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.warning,
                      size: 16.w,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'يمكن إضافة مدفوعات إضافية لاحقاً من شاشة المبيعات',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoItem(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
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
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
                    'تاريخ البيع',
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

  Widget _buildInfoCard(int availableForSale, int totalSold, int totalDeaths) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.info, size: 20.w),
                SizedBox(width: 8.w),
                Text(
                  'معلومات الدفعة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textMain,
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
                    'إجمالي الكتاكيت',
                    '${widget.batch.chickCount} كتكوت',
                    AppTheme.primary,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildInfoItem(
                    'المتاح للبيع',
                    '$availableForSale كتكوت',
                    availableForSale > 0 ? AppTheme.success : AppTheme.error,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'المباع',
                    '$totalSold كتكوت',
                    AppTheme.accent,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildInfoItem(
                    'الوفيات',
                    '$totalDeaths كتكوت',
                    AppTheme.error,
                  ),
                ),
              ],
            ),
            if (availableForSale <= 0) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppTheme.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppTheme.error, size: 16.w),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'لا يوجد كتاكيت متاحة للبيع',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
