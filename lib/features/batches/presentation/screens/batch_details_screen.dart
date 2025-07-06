import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/entities/batch_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../additions/presentation/screens/additions_screen.dart';
import '../../../deaths/presentation/screens/deaths_screen.dart';
import '../../../sales/presentation/screens/sales_screen.dart';
import '../../../statistics/presentation/screens/statistics_screen.dart';
import '../../cubit/batches_cubit.dart';
import '../../../additions/cubit/additions_cubit.dart';
import '../../../deaths/cubit/deaths_cubit.dart';
import '../../../sales/cubit/sales_cubit.dart';

class BatchDetailsScreen extends StatefulWidget {
  final BatchEntity batch;

  const BatchDetailsScreen({super.key, required this.batch});

  @override
  State<BatchDetailsScreen> createState() => _BatchDetailsScreenState();
}

class _BatchDetailsScreenState extends State<BatchDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل البيانات المطلوبة لعرض الإحصائيات المحدثة
    context.read<SalesCubit>().loadSales(widget.batch.id);
    context.read<DeathsCubit>().loadDeaths(widget.batch.id);
    context.read<AdditionsCubit>().loadAdditions(widget.batch.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.batch.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textLight,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // تحديث البيانات
              context.read<SalesCubit>().loadSales(widget.batch.id);
              context.read<DeathsCubit>().loadDeaths(widget.batch.id);
              context.read<AdditionsCubit>().loadAdditions(widget.batch.id);
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث البيانات',
          ),
        ],
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
          BlocListener<AdditionsCubit, AdditionsState>(
            listener: (context, state) {
              if (state is AdditionsLoaded) {
                setState(() {});
              }
            },
          ),
        ],
        child: BlocBuilder<SalesCubit, SalesState>(
          builder: (context, salesState) {
            return BlocBuilder<DeathsCubit, DeathsState>(
              builder: (context, deathsState) {
                return BlocBuilder<AdditionsCubit, AdditionsState>(
                  builder: (context, additionsState) {
                    // حساب الإحصائيات المحدثة
                    int totalSold = 0;
                    int totalDeaths = 0;
                    double totalAdditionsCost = 0.0;
                    double totalSalesAmount = 0.0;

                    if (salesState is SalesLoaded) {
                      totalSold = salesState.totalSoldCount;
                      totalSalesAmount = salesState.totalSalesAmount;
                    }

                    if (deathsState is DeathsLoaded) {
                      totalDeaths = deathsState.totalDeathsCount;
                    }

                    if (additionsState is AdditionsLoaded) {
                      totalAdditionsCost = additionsState.totalCost;
                    }

                    final remainingCount =
                        widget.batch.chickCount - totalDeaths - totalSold;
                    final totalCost =
                        widget.batch.totalBuyPrice + totalAdditionsCost;
                    final profitLoss = totalSalesAmount - totalCost;

                    return ListView(
                      padding: EdgeInsets.all(16.w),
                      children: [
                        _buildInfoCard(),
                        SizedBox(height: 16.h),
                        _buildStatisticsCard(
                          totalSold,
                          totalDeaths,
                          remainingCount,
                          totalAdditionsCost,
                          totalSalesAmount,
                          profitLoss,
                        ),
                        SizedBox(height: 16.h),
                        _buildActionsCard(context),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader('معلومات الدفعة', Icons.info_outline),
            SizedBox(height: 16.h),
            _buildInfoRow('اسم الدفعة', widget.batch.name, Icons.label),
            _buildInfoRow('المورد', widget.batch.supplier, Icons.person),
            _buildInfoRow(
              'تاريخ التسجيل',
              _formatDate(widget.batch.date),
              Icons.calendar_today,
            ),
            _buildInfoRow(
              'عدد الكتاكيت',
              '${widget.batch.chickCount} كتكوت',
              Icons.pets,
            ),
            _buildInfoRow(
              'سعر الشراء',
              '${widget.batch.chickBuyPrice.toStringAsFixed(2)} جنيه',
              Icons.attach_money,
            ),
            if (widget.batch.note != null)
              _buildInfoRow('ملاحظات', widget.batch.note!, Icons.note),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(
    int totalSold,
    int totalDeaths,
    int remainingCount,
    double totalAdditionsCost,
    double totalSalesAmount,
    double profitLoss,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader('الإحصائيات المحدثة', Icons.analytics),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'المباع',
                    '$totalSold كتكوت',
                    AppTheme.accent,
                    Icons.sell,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildStatItem(
                    'الوفيات',
                    '$totalDeaths كتكوت',
                    AppTheme.error,
                    Icons.remove_circle_outline,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'المتبقي',
                    '$remainingCount كتكوت',
                    AppTheme.success,
                    Icons.inventory,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildStatItem(
                    'المصروفات',
                    '${totalAdditionsCost.toStringAsFixed(2)} جنيه',
                    AppTheme.warning,
                    Icons.account_balance_wallet,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildStatisticRow(
              'إجمالي سعر الشراء',
              '${widget.batch.totalBuyPrice.toStringAsFixed(2)} جنيه',
              AppTheme.primary,
            ),
            _buildStatisticRow(
              'إجمالي المبيعات',
              '${totalSalesAmount.toStringAsFixed(2)} جنيه',
              AppTheme.accent,
            ),
            _buildStatisticRow(
              'الربح / الخسارة',
              '${profitLoss.toStringAsFixed(2)} جنيه',
              profitLoss >= 0 ? AppTheme.success : AppTheme.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader('الإجراءات', Icons.settings),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'المصروفات',
                    Icons.add,
                    AppTheme.primary,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AdditionsScreen(batch: widget.batch),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'الوفيات',
                    Icons.remove_circle_outline,
                    AppTheme.error,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DeathsScreen(batch: widget.batch),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'المبيعات',
                    Icons.sell,
                    AppTheme.accent,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => SalesScreen(batch: widget.batch),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'الإحصائيات',
                    Icons.analytics,
                    AppTheme.info,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  StatisticsScreen(batch: widget.batch),
                        ),
                      );
                    },
                  ),
                ),
              ],
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
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textMain,
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

  Widget _buildStatItem(
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

  Widget _buildStatisticRow(String label, String value, Color valueColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: valueColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: valueColor.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                color: valueColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      height: 56.h,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20.w),
        label: Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppTheme.textLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
