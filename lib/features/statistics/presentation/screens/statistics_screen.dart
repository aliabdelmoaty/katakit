import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/entities/batch_entity.dart';
import '../../../../core/models/batch_statistics.dart';
import '../../../../core/usecases/batch_usecases.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  final BatchEntity batch;

  const StatisticsScreen({super.key, required this.batch});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  BatchStatistics? _statistics;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final statisticsUseCase = sl<GetBatchStatisticsUseCase>();
      final statistics = await statisticsUseCase(widget.batch.id);
      setState(() {
        _statistics = statistics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إحصائيات ${widget.batch.name}',
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
            onPressed: _loadStatistics,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث الإحصائيات',
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.primary,
                      strokeWidth: 3.w,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'جاري تحميل الإحصائيات...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
              : _error != null
              ? Center(
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
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: _loadStatistics,
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
              )
              : _statistics == null
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
                        Icons.analytics,
                        size: 64.w,
                        color: AppTheme.textFaint,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'لا توجد إحصائيات',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.textMain,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
              : ListView(
                padding: EdgeInsets.all(20.w),
                children: [
                  _buildOverviewCard(),
                  SizedBox(height: 20.h),
                  _buildFinancialCard(),
                  SizedBox(height: 20.h),
                  _buildDetailsCard(),
                ],
              ),
    );
  }

  Widget _buildOverviewCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader('نظرة عامة', Icons.analytics),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'إجمالي الكتاكيت',
                    '${_statistics!.totalChicks} كتكوت',
                    AppTheme.primary,
                    Icons.pets,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildStatItem(
                    'الوفيات',
                    '${_statistics!.deathsCount} كتكوت',
                    AppTheme.error,
                    Icons.remove_circle_outline,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'المبيعات',
                    '${_statistics!.soldCount} كتكوت',
                    AppTheme.accent,
                    Icons.sell,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildStatItem(
                    'المتبقي',
                    '${_statistics!.remainingCount} كتكوت',
                    AppTheme.success,
                    Icons.inventory,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard() {
    final profitLossColor =
        _statistics!.profitLoss >= 0 ? AppTheme.success : AppTheme.error;
    final profitLossIcon =
        _statistics!.profitLoss >= 0 ? Icons.trending_up : Icons.trending_down;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader('الأمور المالية', Icons.account_balance_wallet),
            SizedBox(height: 20.h),
            _buildFinancialRow(
              'إجمالي الشراء',
              '${_statistics!.totalBuyPrice.toStringAsFixed(2)} جنيه',
              AppTheme.primary,
            ),
            _buildFinancialRow(
              'إجمالي المصروفات',
              '${_statistics!.totalAdditionsCost.toStringAsFixed(2)} جنيه',
              AppTheme.warning,
            ),
            _buildFinancialRow(
              'إجمالي المبيعات',
              '${_statistics!.totalSalesAmount.toStringAsFixed(2)} جنيه',
              AppTheme.accent,
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: profitLossColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: profitLossColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(profitLossIcon, color: profitLossColor, size: 24.w),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'الربح / الخسارة',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textMain,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${_statistics!.profitLoss.toStringAsFixed(2)} جنيه',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: profitLossColor,
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

  Widget _buildDetailsCard() {
    final deathPercentage =
        (_statistics!.deathsCount / _statistics!.totalChicks) * 100;
    final salesPercentage =
        (_statistics!.soldCount / _statistics!.totalChicks) * 100;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader('تفاصيل إضافية', Icons.info_outline),
            SizedBox(height: 20.h),
            _buildDetailRow(
              'التكلفة الفعلية للكتكوت',
              '${_statistics!.actualCostPerChick.toStringAsFixed(2)} جنيه',
              AppTheme.info,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildPercentageItem(
                    'نسبة الوفيات',
                    '${deathPercentage.toStringAsFixed(1)}%',
                    AppTheme.error,
                    Icons.trending_down,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildPercentageItem(
                    'نسبة المبيعات',
                    '${salesPercentage.toStringAsFixed(1)}%',
                    AppTheme.success,
                    Icons.trending_up,
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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

  Widget _buildFinancialRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.attach_money, color: color, size: 20.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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

  Widget _buildPercentageItem(
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
            ).textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
