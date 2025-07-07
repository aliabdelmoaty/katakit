import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/entities/addition_entity.dart';
import '../../../../core/entities/batch_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../cubit/additions_cubit.dart';
import 'add_addition_screen.dart';
import '../../../../core/services/sync_service.dart';

class AdditionsScreen extends StatefulWidget {
  final BatchEntity batch;
  final Stream<SyncStatus>? syncStatusStream;

  const AdditionsScreen({
    super.key,
    required this.batch,
    this.syncStatusStream,
  });

  @override
  State<AdditionsScreen> createState() => _AdditionsScreenState();
}

class _AdditionsScreenState extends State<AdditionsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdditionsCubit>().loadAdditions(widget.batch.id);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مصروفات ${widget.batch.name}',
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
      body: BlocBuilder<AdditionsCubit, AdditionsState>(
        builder: (context, state) {
          if (state is AdditionsLoading) {
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
          } else if (state is AdditionsLoaded) {
            return Column(
              children: [
                _buildSummaryCard(state.totalCost),
                Expanded(
                  child:
                      state.additions.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20.w),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardLight,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.textFaint.withOpacity(
                                          0.1,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.receipt_long,
                                    size: 56.w,
                                    color: AppTheme.textFaint,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'لا توجد مصروفات',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium?.copyWith(
                                    color: AppTheme.textMain,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  'اضغط على زر الإضافة لتسجيل مصروف جديد',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppTheme.textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            padding: EdgeInsets.all(12.w),
                            itemCount: state.additions.length,
                            itemBuilder: (context, index) {
                              final addition = state.additions[index];
                              return AdditionCard(
                                addition: addition,
                                onDelete: () {
                                  context.read<AdditionsCubit>().deleteAddition(
                                    addition.id,
                                    widget.batch.id,
                                  );
                                },
                              );
                            },
                          ),
                ),
              ],
            );
          } else if (state is AdditionsError) {
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
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<AdditionsCubit>().loadAdditions(
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
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAdditionScreen(batch: widget.batch),
            ),
          );
        },
        backgroundColor: AppTheme.accent,
        foregroundColor: AppTheme.textMain,
        icon: const Icon(Icons.add),
        label: const Text('مصروف جديد'),
      ),
    );
  }

  Widget _buildSummaryCard(double totalCost) {
    final actualCostPerChick = _calculateActualCostPerChick(totalCost);
    return Card(
      margin: EdgeInsets.all(12.w),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
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
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: AppTheme.primary,
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'ملخص المصروفات',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textMain,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إجمالي المصروفات',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${totalCost.toStringAsFixed(2)} جنيه',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppTheme.accent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'التكلفة الحقيقية',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${actualCostPerChick.toStringAsFixed(2)} جنيه',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateActualCostPerChick(double totalAdditionsCost) {
    final totalCost = widget.batch.totalBuyPrice + totalAdditionsCost;
    final remainingChicks =
        widget.batch.chickCount; // سيتم تحديثه لاحقاً مع الوفيات والمبيعات
    return remainingChicks > 0 ? totalCost / remainingChicks : 0.0;
  }
}

class AdditionCard extends StatelessWidget {
  final AdditionEntity addition;
  final VoidCallback onDelete;

  const AdditionCard({
    super.key,
    required this.addition,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.receipt, color: AppTheme.primary, size: 24.w),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    addition.name,
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
                        _formatDate(addition.date),
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
                Text(
                  '${addition.cost.toStringAsFixed(2)} جنيه',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.bold,
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
