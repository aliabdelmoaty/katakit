import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/entities/sale_entity.dart';
import '../../../../core/entities/batch_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/enhanced_text_field.dart';
import '../../cubit/sales_cubit.dart';
import '../../../deaths/cubit/deaths_cubit.dart';
import '../../../auth/cubit/auth_cubit.dart';

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
      final authState = context.read<AuthCubit>().state;
      String userId = '';
      if (authState is Authenticated) {
        userId = authState.userId;
      }
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
        userId: userId,
        updatedAt: DateTime.now(),
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textLight,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 50.h,
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
                    padding: EdgeInsets.all(8.w),
                    children: [
                      // معلومات الدفعة (مدمجة في الأعلى)
                      _buildBatchInfoHeader(
                        availableForSale,
                        totalSold,
                        totalDeaths,
                      ),
                      SizedBox(height: 12.h),

                      // معلومات المشتري
                      _buildSectionTitle('معلومات المشتري'),
                      SizedBox(height: 8.h),
                      EnhancedTextField(
                        controller: _buyerNameController,
                        label: 'اسم المشتري',
                        icon: Icons.person,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال اسم المشتري';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12.h),

                      // تفاصيل البيع
                      _buildSectionTitle('تفاصيل البيع'),
                      SizedBox(height: 5.h),
                      Expanded(
                        child: EnhancedTextField(
                          controller: _chickCountController,
                          label: 'عدد الكتاكيت',
                          icon: Icons.sell,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى إدخال العدد';
                            }
                            final count = int.tryParse(value);
                            if (count == null || count <= 0) {
                              return 'عدد غير صحيح';
                            }
                            if (count > availableForSale) {
                              return 'تجاوز المتاح ($availableForSale)';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Expanded(
                        child: EnhancedTextField(
                          controller: _pricePerChickController,
                          label: 'السعر (جنيه)',
                          icon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى إدخال السعر';
                            }
                            final price = double.tryParse(value);
                            if (price == null || price <= 0) {
                              return 'سعر غير صحيح';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 10.h),
                      // السعر الإجمالي (مبسط)
                      if (_totalPrice > 0) _buildTotalPriceCard(),
                      if (_totalPrice > 0) SizedBox(height: 10.h),

                      // المبلغ المدفوع
                      EnhancedTextField(
                        controller: _paidAmountController,
                        label: 'المبلغ المدفوع (جنيه)',
                        icon: Icons.payment,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال المبلغ المدفوع';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount < 0) {
                            return 'مبلغ غير صحيح';
                          }
                          if (amount > _totalPrice) {
                            return 'لا يمكن أن يتجاوز السعر الإجمالي';
                          }
                          return null;
                        },
                      ),

                      // حالة الدفع (مبسطة)
                      if (_totalPrice > 0 &&
                          _paidAmountController.text.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        _buildPaymentStatus(),
                      ],

                      SizedBox(height: 10.h),

                      // التاريخ والملاحظات
                      EnhancedDateField(
                        label: 'تاريخ البيع',
                        selectedDate: _selectedDate,
                        onTap: _selectDate,
                      ),
                      SizedBox(height: 10.h),
                      EnhancedTextField(
                        controller: _noteController,
                        label: 'ملاحظات (اختياري)',
                        icon: Icons.note,
                        maxLines: 1,
                        textInputAction: TextInputAction.done,
                      ),

                      SizedBox(height: 20.h),

                      // زر الإضافة
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton.icon(
                          onPressed: availableForSale > 0 ? _submitForm : null,
                          icon: Icon(Icons.add, size: 18.w),
                          label: Text(
                            availableForSale > 0
                                ? 'إضافة عملية البيع'
                                : 'لا يوجد كتاكيت متاحة للبيع',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
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
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 1),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppTheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBatchInfoHeader(
    int availableForSale,
    int totalSold,
    int totalDeaths,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.1),
            AppTheme.accent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoColumn(
            'إجمالي',
            '${widget.batch.chickCount}',
            AppTheme.primary,
            Icons.inventory,
          ),
          _buildInfoColumn(
            'المتاح',
            '$availableForSale',
            availableForSale > 0 ? AppTheme.success : AppTheme.error,
            Icons.shopping_cart,
          ),
          _buildInfoColumn('مباع', '$totalSold', AppTheme.accent, Icons.sell),
          _buildInfoColumn(
            'وفيات',
            '$totalDeaths',
            AppTheme.error,
            Icons.close,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Icon(icon, color: color, size: 16.w),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildTotalPriceCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.calculate, color: AppTheme.accent, size: 16.w),
              SizedBox(width: 8.w),
              Text(
                'السعر الإجمالي',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            '${_totalPrice.toStringAsFixed(2)} جنيه',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatus() {
    final isFullyPaid = _remainingAmount <= 0;
    final color = isFullyPaid ? AppTheme.success : AppTheme.warning;
    final icon = isFullyPaid ? Icons.check_circle : Icons.pending;
    final statusText = isFullyPaid ? 'مدفوع كاملاً' : 'دفع جزئي';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!isFullyPaid)
                  Text(
                    'باقي: ${_remainingAmount.toStringAsFixed(2)} جنيه',
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
}
