import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/entities/sale_entity.dart';
import '../../../../core/entities/batch_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/enhanced_text_field.dart';
import '../../cubit/sales_cubit.dart';
import '../../../deaths/cubit/deaths_cubit.dart';
import 'add_sale_screen.dart';
import 'edit_sale_screen.dart';
import '../../../../core/services/sync_service.dart';

class SalesScreen extends StatefulWidget {
  final BatchEntity batch;
  final Stream<SyncStatus>? syncStatusStream;

  const SalesScreen({super.key, required this.batch, this.syncStatusStream});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<SalesCubit>().loadSales(widget.batch.id);
    context.read<DeathsCubit>().loadDeaths(widget.batch.id);
    SyncService().userNoticeStream.listen((msg) {
      if (mounted && msg.isNotEmpty) {
        Color bgColor = Colors.blue;
        if (msg.contains('خطأ') || msg.contains('error')) {
          bgColor = Colors.red;
        } else if (msg.contains('تمت') ||
            msg.contains('اكتملت') ||
            msg.contains('نجاح')) {
          bgColor = Colors.green;
        } else if (msg.contains('لا يوجد اتصال')) {
          bgColor = Colors.orange;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: bgColor));
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // حساب العدد المتاح للبيع بناءً على الوفيات السابقة
  int _calculateAvailableForSale(int totalSold, int totalDeaths) {
    return widget.batch.chickCount - totalDeaths - totalSold;
  }

  // تصفية المبيعات بناءً على اسم المشتري
  List<SaleEntity> _filterSales(List<SaleEntity> sales) {
    if (_searchQuery.isEmpty) {
      return sales;
    }
    return sales
        .where(
          (sale) =>
              sale.buyerName.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مبيعات ${widget.batch.name}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textLight,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child:
              widget.syncStatusStream != null
                  ? StreamBuilder<SyncStatus>(
                    stream: widget.syncStatusStream,
                    builder: (context, snapshot) {
                      final status = snapshot.data;
                      if (status == null) return const SizedBox(height: 0);
                      IconData icon;
                      String text;
                      Color color;
                      switch (status) {
                        case SyncStatus.synced:
                          icon = Icons.check_circle;
                          text = 'تمت المزامنة';
                          color = AppTheme.success;
                          break;
                        case SyncStatus.syncing:
                          icon = Icons.sync;
                          text = 'جاري المزامنة...';
                          color = AppTheme.info;
                          break;
                        case SyncStatus.offline:
                          icon = Icons.wifi_off;
                          text = 'أوفلاين - في انتظار الاتصال';
                          color = AppTheme.warning;
                          break;
                        case SyncStatus.error:
                          icon = Icons.error;
                          text = 'خطأ في المزامنة';
                          color = AppTheme.error;
                          break;
                        default:
                          icon = Icons.sync;
                          text = '';
                          color = AppTheme.info;
                      }
                      return Container(
                        height: 32,
                        color: color.withOpacity(0.08),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, color: color, size: 18),
                            const SizedBox(width: 8),
                            Text(text, style: TextStyle(color: color)),
                          ],
                        ),
                      );
                    },
                  )
                  : const SizedBox(height: 0),
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
            },
          ),
        ],
        child: BlocBuilder<SalesCubit, SalesState>(
          builder: (context, salesState) {
            return BlocBuilder<DeathsCubit, DeathsState>(
              builder: (context, deathsState) {
                if (salesState is SalesLoading ||
                    deathsState is DeathsLoading) {
                  return SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppTheme.primary,
                            strokeWidth: 3.w,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'جاري التحميل...',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (salesState is SalesLoaded) {
                  // حساب العدد المتاح للبيع
                  int totalDeaths = 0;
                  if (deathsState is DeathsLoaded) {
                    totalDeaths = deathsState.totalDeathsCount;
                  }

                  final availableForSale = _calculateAvailableForSale(
                    salesState.totalSoldCount,
                    totalDeaths,
                  );

                  // تصفية المبيعات بناءً على البحث
                  final filteredSales = _filterSales(salesState.sales);

                  return SafeArea(
                    child: Column(
                      children: [
                        _buildSearchBar(),
                        // إظهار ملخص البيع فقط عندما لا يكون هناك بحث
                        if (_searchQuery.isEmpty)
                          _buildSummaryCard(
                            salesState.totalSoldCount,
                            salesState.totalSalesAmount,
                            totalDeaths,
                            availableForSale,
                          ),
                        Expanded(
                          child:
                              filteredSales.isEmpty
                                  ? _buildEmptyState()
                                  : ListView.builder(
                                    padding: EdgeInsets.only(
                                      left: 16.w,
                                      right: 16.w,
                                      top: _searchQuery.isNotEmpty ? 4.h : 4.h,
                                      bottom:
                                          80.h, // مساحة للـ FloatingActionButton
                                    ),
                                    itemCount: filteredSales.length,
                                    itemBuilder: (context, index) {
                                      final sale = filteredSales[index];
                                      return SaleCard(
                                        sale: sale,
                                        onDelete: () {
                                          context.read<SalesCubit>().deleteSale(
                                            sale.id,
                                            widget.batch.id,
                                          );
                                        },
                                        batch: widget.batch,
                                      );
                                    },
                                  ),
                        ),
                      ],
                    ),
                  );
                } else if (salesState is SalesError) {
                  return SafeArea(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 80.h,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(24.w),
                              decoration: BoxDecoration(
                                color: AppTheme.error.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.error_outline,
                                size: 64.w,
                                color: AppTheme.error,
                              ),
                            ),
                            SizedBox(height: 15.h),
                            Text(
                              'حدث خطأ',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              salesState.message,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppTheme.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24.h),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<SalesCubit>().loadSales(
                                  widget.batch.id,
                                );
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('إعادة المحاولة'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: AppTheme.textLight,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 12.h,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
      floatingActionButton: BlocBuilder<SalesCubit, SalesState>(
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

              return FloatingActionButton.extended(
                onPressed:
                    availableForSale > 0
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      AddSaleScreen(batch: widget.batch),
                            ),
                          );
                        }
                        : null,
                backgroundColor:
                    availableForSale > 0 ? AppTheme.accent : AppTheme.textFaint,
                foregroundColor:
                    availableForSale > 0
                        ? AppTheme.textMain
                        : AppTheme.textSecondary,
                icon: Icon(Icons.add),
                label: Text(availableForSale > 0 ? 'بيع جديد' : 'لا يوجد متاح'),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return EnhancedSearchField(
      controller: _searchController,
      hintText: 'البحث عن مشتري...',
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      onClear: () {
        setState(() {
          _searchQuery = '';
        });
      },
    );
  }

  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty) {
      // حالة عدم وجود نتائج للبحث
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 40.h,
        ), // تقليل المساحة لأن ملخص البيع مخفي
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.search_off, size: 64.w, color: AppTheme.info),
              ),
              SizedBox(height: 24.h),
              Text(
                'لا توجد نتائج',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textMain,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'لم يتم العثور على مشتري باسم "$_searchQuery"',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('مسح البحث'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.info,
                  foregroundColor: AppTheme.textLight,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // حالة عدم وجود مبيعات
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 80.h),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppTheme.cardLight,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.textFaint.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.sell, size: 64.w, color: AppTheme.textFaint),
              ),
              SizedBox(height: 24.h),
              Text(
                'لا توجد مبيعات مسجلة',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textMain,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'اضغط على زر الإضافة لتسجيل عملية بيع جديدة',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildSummaryCard(
    int totalSoldCount,
    double totalSalesAmount,
    int totalDeaths,
    int availableForSale,
  ) {
    final salesPercentage = (totalSoldCount / widget.batch.chickCount) * 100;

    return Card(
      margin: EdgeInsets.all(6.r),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(Icons.sell, color: AppTheme.accent, size: 16.w),
                ),
                SizedBox(width: 8.w),
                Text(
                  'ملخص المبيعات',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إجمالي المبيعات',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${totalSalesAmount.toStringAsFixed(2)} جنيه',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppTheme.success.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'المباع',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 10.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '$totalSoldCount كتكوت',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'المتاح للبيع',
                    '$availableForSale كتكوت',
                    availableForSale > 0 ? AppTheme.primary : AppTheme.error,
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: _buildInfoItem(
                    'الوفيات',
                    '$totalDeaths كتكوت',
                    AppTheme.error,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'نسبة البيع',
                    '${salesPercentage.toStringAsFixed(1)}%',
                    AppTheme.info,
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: _buildInfoItem(
                    'المتبقي',
                    '${widget.batch.chickCount - totalSoldCount - totalDeaths} كتكوت',
                    AppTheme.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 10.sp,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class SaleCard extends StatelessWidget {
  final SaleEntity sale;
  final VoidCallback onDelete;
  final BatchEntity batch;

  const SaleCard({
    super.key,
    required this.sale,
    required this.onDelete,
    required this.batch,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
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
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.person, color: AppTheme.accent, size: 20.w),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sale.buyerName,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textMain,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14.w,
                            color: AppTheme.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _formatDate(sale.date),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${sale.totalPrice.toStringAsFixed(2)} جنيه',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${sale.chickCount} كتكوت',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'سعر الكتكوت',
                    '${sale.pricePerChick.toStringAsFixed(2)} جنيه',
                    AppTheme.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildDetailItem(
                    'المدفوع',
                    '${sale.paidAmount.toStringAsFixed(2)} جنيه',
                    AppTheme.success,
                  ),
                ),
              ],
            ),
            if (sale.remainingAmount > 0) ...[
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8.w),
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
                    Icon(Icons.pending, color: AppTheme.warning, size: 16.w),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'الباقي: ${sale.remainingAmount.toStringAsFixed(2)} جنيه',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // زر تعديل عملية البيع
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                EditSaleScreen(sale: sale, batch: batch),
                      ),
                    );
                  },
                  icon: Icon(Icons.edit, color: AppTheme.info, size: 20.w),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.info.withOpacity(0.1),
                    padding: EdgeInsets.all(8.w),
                  ),
                  tooltip: 'تعديل عملية البيع',
                ),
                SizedBox(width: 8.w),
                // زر حذف عملية البيع
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppTheme.error,
                    size: 20.w,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.error.withOpacity(0.1),
                    padding: EdgeInsets.all(8.w),
                  ),
                  tooltip: 'حذف عملية البيع',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, Color color) {
    return Builder(
      builder:
          (context) => Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
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
          ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
