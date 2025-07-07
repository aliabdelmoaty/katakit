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
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final statisticsUseCase = sl<GetBatchStatisticsUseCase>();
      final statistics = await statisticsUseCase(widget.batch.id);

      if (mounted) {
        setState(() {
          _statistics = statistics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
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
            onPressed: _isLoading ? null : _loadStatistics,
            icon:
                _isLoading
                    ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        color: AppTheme.textLight,
                      ),
                    )
                    : const Icon(Icons.refresh),
            tooltip: 'تحديث الإحصائيات',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_statistics == null) {
      return _buildEmptyState();
    }

    return _buildStatisticsContent();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 3.w),
          SizedBox(height: 12.h),
          Text(
            'جاري تحميل الإحصائيات...',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48.w,
                color: AppTheme.error,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'حدث خطأ',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                _error!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 18.h),
            ElevatedButton.icon(
              onPressed: _loadStatistics,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.textLight,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
                  color: AppTheme.textFaint.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.analytics, size: 48.w, color: AppTheme.textFaint),
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد إحصائيات',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textMain,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'لم يتم العثور على أي بيانات لهذه الدفعة',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsContent() {
    return RefreshIndicator(
      onRefresh: _loadStatistics,
      color: AppTheme.primary,
      child: ListView(
        padding: EdgeInsets.all(12.w),
        children: [
          _buildOverviewCard(),
          SizedBox(height: 12.h),
          _buildFinancialCard(),
          SizedBox(height: 12.h),
          _buildDetailsCard(),
          SizedBox(height: 12.h),
          _buildPerformanceCard(),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader('نظرة عامة', Icons.analytics),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'إجمالي الكتاكيت',
                    '${_statistics!.totalChicks}',
                    AppTheme.primary,
                    Icons.pets,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildStatItem(
                    'الوفيات',
                    '${_statistics!.deathsCount}',
                    AppTheme.error,
                    Icons.remove_circle_outline,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'المبيعات',
                    '${_statistics!.soldCount}',
                    AppTheme.accent,
                    Icons.sell,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildStatItem(
                    'المتبقي',
                    '${_statistics!.remainingCount}',
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader('الأمور المالية', Icons.account_balance_wallet),
            SizedBox(height: 12.h),
            _buildFinancialRow(
              'إجمالي الشراء',
              _formatCurrency(_statistics!.totalBuyPrice),
              AppTheme.primary,
            ),
            _buildFinancialRow(
              'إجمالي المصروفات',
              _formatCurrency(_statistics!.totalAdditionsCost),
              AppTheme.warning,
            ),
            _buildFinancialRow(
              'إجمالي المبيعات',
              _formatCurrency(_statistics!.totalSalesAmount),
              AppTheme.accent,
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: profitLossColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: profitLossColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(profitLossIcon, color: profitLossColor, size: 20.w),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      _statistics!.profitLoss >= 0 ? 'الربح' : 'الخسارة',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textMain,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _formatCurrency(_statistics!.profitLoss.abs()),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader('تفاصيل التكلفة', Icons.info_outline),
            SizedBox(height: 16.h),
            _buildDetailRow(
              'التكلفة الفعلية للكتكوت',
              _formatCurrency(_statistics!.actualCostPerChick),
              AppTheme.info,
            ),
            SizedBox(height: 12.h),
            _buildDetailRow(
              'متوسط سعر البيع',
              _formatCurrency(_calculateAverageSellPrice()),
              AppTheme.accent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard() {
    final deathPercentage = _calculatePercentage(
      _statistics!.deathsCount,
      _statistics!.totalChicks,
    );
    final salesPercentage = _calculatePercentage(
      _statistics!.soldCount,
      _statistics!.totalChicks,
    );
    final remainingPercentage = _calculatePercentage(
      _statistics!.remainingCount,
      _statistics!.totalChicks,
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader('مؤشرات الأداء', Icons.assessment),
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
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildPercentageItem(
                    'نسبة المبيعات',
                    '${salesPercentage.toStringAsFixed(1)}%',
                    AppTheme.success,
                    Icons.trending_up,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildPercentageItem(
                    'نسبة المتبقي',
                    '${remainingPercentage.toStringAsFixed(1)}%',
                    AppTheme.primary,
                    Icons.inventory,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildProgressBar('توزيع الدفعة', [
              ProgressSegment('مباع', salesPercentage, AppTheme.success),
              ProgressSegment('متوفي', deathPercentage, AppTheme.error),
              ProgressSegment('متبقي', remainingPercentage, AppTheme.primary),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String title, List<ProgressSegment> segments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 8.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.cardLight,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            children:
                segments.map((segment) {
                  return Expanded(
                    flex: (segment.percentage * 100).round(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: segment.color,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              segments.map((segment) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: segment.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      segment.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ],
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
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.w),
          SizedBox(height: 6.h),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
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
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Container(
        padding: EdgeInsets.all(10.w),
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
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18.w),
          SizedBox(height: 4.h),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} جنيه';
  }

  double _calculatePercentage(int part, int total) {
    if (total == 0) return 0;
    return (part / total) * 100;
  }

  double _calculateAverageSellPrice() {
    if (_statistics!.soldCount == 0) return 0;
    return _statistics!.totalSalesAmount / _statistics!.soldCount;
  }
}
class ProgressSegment {
  final String label;
  final double percentage;
  final Color color;

  ProgressSegment(this.label, this.percentage, this.color);
}
