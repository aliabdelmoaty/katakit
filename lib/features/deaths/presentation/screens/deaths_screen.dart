import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/entities/death_entity.dart';
import '../../../../core/entities/batch_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../cubit/deaths_cubit.dart';
import '../../../sales/cubit/sales_cubit.dart';
import 'add_death_screen.dart';

class DeathsScreen extends StatefulWidget {
  final BatchEntity batch;

  const DeathsScreen({super.key, required this.batch});

  @override
  State<DeathsScreen> createState() => _DeathsScreenState();
}

class _DeathsScreenState extends State<DeathsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DeathsCubit>().loadDeaths(widget.batch.id);
    context.read<SalesCubit>().loadSales(widget.batch.id);
  }

  // حساب العدد المتاح لتسجيل الوفيات بناءً على المبيعات السابقة
  int _calculateAvailableForDeaths(int totalSold, int totalDeaths) {
    return widget.batch.chickCount - totalSold - totalDeaths;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'وفيات ${widget.batch.name}',
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
          BlocListener<DeathsCubit, DeathsState>(
            listener: (context, state) {
              if (state is DeathsLoaded) {
                setState(() {});
              }
            },
          ),
          BlocListener<SalesCubit, SalesState>(
            listener: (context, state) {
              if (state is SalesLoaded) {
                setState(() {});
              }
            },
          ),
        ],
        child: BlocBuilder<DeathsCubit, DeathsState>(
          builder: (context, deathsState) {
            return BlocBuilder<SalesCubit, SalesState>(
              builder: (context, salesState) {
                if (deathsState is DeathsLoading || salesState is SalesLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppTheme.primary,
                          strokeWidth: 3.w,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'جاري التحميل...',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (deathsState is DeathsLoaded) {
                  // حساب العدد المتاح لتسجيل الوفيات
                  int totalSold = 0;
                  if (salesState is SalesLoaded) {
                    totalSold = salesState.totalSoldCount;
                  }
                  
                  final availableForDeaths = _calculateAvailableForDeaths(
                    totalSold,
                    deathsState.totalDeathsCount,
                  );

                  return Column(
                    children: [
                      _buildSummaryCard(
                        deathsState.totalDeathsCount,
                        totalSold,
                        availableForDeaths,
                      ),
                      Expanded(
                        child: deathsState.deaths.isEmpty
                            ? Center(
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
                                      child: Icon(
                                        Icons.remove_circle_outline,
                                        size: 64.w,
                                        color: AppTheme.textFaint,
                                      ),
                                    ),
                                    SizedBox(height: 24.h),
                                    Text(
                                      'لا توجد وفيات مسجلة',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: AppTheme.textMain,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'اضغط على زر الإضافة لتسجيل وفيات جديدة',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.all(16.w),
                                itemCount: deathsState.deaths.length,
                                itemBuilder: (context, index) {
                                  final death = deathsState.deaths[index];
                                  return DeathCard(
                                    death: death,
                                    onDelete: () {
                                      context.read<DeathsCubit>().deleteDeath(
                                        death.id,
                                        widget.batch.id,
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                } else if (deathsState is DeathsError) {
                  return Center(
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
                        SizedBox(height: 24.h),
                        Text(
                          'حدث خطأ',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          deathsState.message,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<DeathsCubit>().loadDeaths(widget.batch.id);
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.textLight,
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
      floatingActionButton: BlocBuilder<DeathsCubit, DeathsState>(
        builder: (context, deathsState) {
          return BlocBuilder<SalesCubit, SalesState>(
            builder: (context, salesState) {
              // حساب العدد المتاح لتسجيل الوفيات
              int totalSold = 0;
              int totalDeaths = 0;
              
              if (salesState is SalesLoaded) {
                totalSold = salesState.totalSoldCount;
              }
              
              if (deathsState is DeathsLoaded) {
                totalDeaths = deathsState.totalDeathsCount;
              }
              
              final availableForDeaths = _calculateAvailableForDeaths(totalSold, totalDeaths);

              return FloatingActionButton.extended(
                onPressed: availableForDeaths > 0 ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddDeathScreen(batch: widget.batch),
                    ),
                  );
                } : null,
                backgroundColor: availableForDeaths > 0 ? AppTheme.accent : AppTheme.textFaint,
                foregroundColor: availableForDeaths > 0 ? AppTheme.textMain : AppTheme.textSecondary,
                icon: Icon(Icons.add),
                label: Text(availableForDeaths > 0 ? 'وفاة جديدة' : 'لا يوجد متاح'),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    int totalDeathsCount,
    int totalSold,
    int availableForDeaths,
  ) {
    final deathPercentage = (totalDeathsCount / widget.batch.chickCount) * 100;

    return Card(
      margin: EdgeInsets.all(16.w),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.remove_circle_outline,
                    color: AppTheme.error,
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'ملخص الوفيات',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textMain,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إجمالي الوفيات',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$totalDeathsCount كتكوت',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppTheme.success.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'المتاح للتسجيل',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$availableForDeaths كتكوت',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: availableForDeaths > 0 ? AppTheme.success : AppTheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
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
                    'نسبة الوفيات',
                    '${deathPercentage.toStringAsFixed(1)}%',
                    AppTheme.warning,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'المتبقي',
                    '${widget.batch.chickCount - totalDeathsCount - totalSold} كتكوت',
                    AppTheme.primary,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildInfoItem(
                    'إجمالي الكتاكيت',
                    '${widget.batch.chickCount} كتكوت',
                    AppTheme.info,
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
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
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

class DeathCard extends StatelessWidget {
  final DeathEntity death;
  final VoidCallback onDelete;

  const DeathCard({super.key, required this.death, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.remove_circle_outline,
                color: AppTheme.error,
                size: 24.w,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${death.count} كتكوت',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                        _formatDate(death.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppTheme.error.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${death.count}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
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
                ),
              ],
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
