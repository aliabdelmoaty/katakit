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

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  BatchStatistics? _statistics;
  bool _isLoading = true;
  String? _error;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadStatistics();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
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
        _fadeController.forward();
        _slideController.forward();
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
    return Scaffold(body: _buildBody());
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

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _buildStatisticsContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primary,
                    strokeWidth: 3.w,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'جاري تحميل الإحصائيات...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'يرجى الانتظار',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textFaint),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(24.w),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppTheme.errorGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.error.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 50.w,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'حدث خطأ',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppTheme.error.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 24.h),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppTheme.primaryGradient),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _loadStatistics,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.textFaint.withOpacity(0.1),
                      AppTheme.textFaint.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.textFaint.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  size: 60.w,
                  color: AppTheme.textFaint,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'لا توجد إحصائيات',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textMain,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'لم يتم العثور على أي بيانات لهذه الدفعة',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsContent() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(),
        SliverPadding(
          padding: EdgeInsets.all(16.w),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildOverviewCard(),
              SizedBox(height: 16.h),
              _buildFinancialCard(),
              SizedBox(height: 16.h),
              _buildDetailsCard(),
              SizedBox(height: 16.h),
              _buildPerformanceCard(),
              SizedBox(height: 24.h),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: false,
      pinned: true,
      title: Text(
        'إحصائيات ${widget.batch.name}',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppTheme.textLight,
          shadows: [
            Shadow(
              offset: const Offset(0, 1),
              blurRadius: 3,
              color: Colors.black.withOpacity(0.3),
            ),
          ],
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textLight),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppTheme.primary,
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8.w),
          child: IconButton(
            onPressed: _isLoading ? null : _loadStatistics,
            icon:
                _isLoading
                    ? SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        color: AppTheme.textLight,
                      ),
                    )
                    : Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.refresh_rounded,
                        color: AppTheme.textLight,
                        size: 20.w,
                      ),
                    ),
            tooltip: 'تحديث الإحصائيات',
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textLight),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text('إحصائيات ${widget.batch.name}'),
      backgroundColor: AppTheme.primary,
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8.w),
          child: IconButton(
            onPressed: _isLoading ? null : _loadStatistics,
            icon:
                _isLoading
                    ? SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        color: AppTheme.textLight,
                      ),
                    )
                    : Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.refresh_rounded,
                        color: AppTheme.textLight,
                        size: 20.w,
                      ),
                    ),
            tooltip: 'تحديث الإحصائيات',
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.cardLight, AppTheme.cardLight.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader('نظرة عامة', Icons.analytics_rounded),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: _buildAnimatedStatItem(
                    'إجمالي الكتاكيت',
                    '${_statistics!.totalChicks}',
                    AppTheme.primaryGradient,
                    Icons.pets_rounded,
                    0,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildAnimatedStatItem(
                    'الوفيات',
                    '${_statistics!.deathsCount}',
                    AppTheme.errorGradient,
                    Icons.remove_circle_outline_rounded,
                    100,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildAnimatedStatItem(
                    'المبيعات',
                    '${_statistics!.soldCount}',
                    AppTheme.accentGradient,
                    Icons.sell_rounded,
                    200,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildAnimatedStatItem(
                    'المتبقي',
                    '${_statistics!.remainingCount}',
                    AppTheme.successGradient,
                    Icons.inventory_rounded,
                    300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedStatItem(
    String label,
    String value,
    List<Color> gradientColors,
    IconData icon,
    int delay,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: animationValue,
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24.w),
                ),
                SizedBox(height: 12.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFinancialCard() {
    final profitLossColor =
        _statistics!.profitLoss >= 0 ? AppTheme.success : AppTheme.error;
    final profitLossIcon =
        _statistics!.profitLoss >= 0
            ? Icons.trending_up_rounded
            : Icons.trending_down_rounded;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.cardLight, AppTheme.cardLight.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(
              'الأمور المالية',
              Icons.account_balance_wallet_rounded,
            ),
            SizedBox(height: 20.h),
            _buildFinancialRow(
              'إجمالي الشراء',
              _formatCurrency(_statistics!.totalBuyPrice),
              AppTheme.primary,
              Icons.shopping_cart_rounded,
            ),
            SizedBox(height: 8.h),
            _buildFinancialRow(
              'إجمالي المصروفات',
              _formatCurrency(_statistics!.totalAdditionsCost),
              AppTheme.warning,
              Icons.receipt_long_rounded,
            ),
            SizedBox(height: 8.h),
            _buildFinancialRow(
              'إجمالي المبيعات',
              _formatCurrency(_statistics!.totalSalesAmount),
              AppTheme.accent,
              Icons.attach_money_rounded,
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      _statistics!.profitLoss >= 0
                          ? AppTheme.successGradient
                          : AppTheme.errorGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: profitLossColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      profitLossIcon,
                      color: Colors.white,
                      size: 24.w,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      _statistics!.profitLoss >= 0 ? 'الربح' : 'الخسارة',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _formatCurrency(_statistics!.profitLoss.abs()),
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: Colors.white,
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.cardLight, AppTheme.cardLight.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader('تفاصيل التكلفة', Icons.info_outline_rounded),
            SizedBox(height: 20.h),
            _buildDetailRow(
              'التكلفة الفعلية للكتكوت',
              _formatCurrency(_statistics!.actualCostPerChick),
              AppTheme.info,
              Icons.calculate_rounded,
            ),
            SizedBox(height: 16.h),
            _buildDetailRow(
              'متوسط سعر البيع',
              _formatCurrency(_calculateAverageSellPrice()),
              AppTheme.accent,
              Icons.trending_up_rounded,
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.cardLight, AppTheme.cardLight.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader('مؤشرات الأداء', Icons.assessment_rounded),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: _buildPercentageItem(
                    'نسبة الوفيات',
                    '${deathPercentage.toStringAsFixed(1)}%',
                    AppTheme.error,
                    Icons.trending_down_rounded,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildPercentageItem(
                    'نسبة المبيعات',
                    '${salesPercentage.toStringAsFixed(1)}%',
                    AppTheme.success,
                    Icons.trending_up_rounded,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildPercentageItem(
                    'نسبة المتبقي',
                    '${remainingPercentage.toStringAsFixed(1)}%',
                    AppTheme.primary,
                    Icons.inventory_rounded,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            _buildAnimatedProgressBar('توزيع الدفعة', [
              ProgressSegment('مباع', salesPercentage, AppTheme.success),
              ProgressSegment('متوفي', deathPercentage, AppTheme.error),
              ProgressSegment('متبقي', remainingPercentage, AppTheme.primary),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedProgressBar(
    String title,
    List<ProgressSegment> segments,
  ) {
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
        SizedBox(height: 12.h),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1200),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeInOut,
          builder: (context, animationValue, child) {
            return Container(
              height: 12.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.cardLight,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: AppTheme.textFaint.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  Row(
                    children:
                        segments.map((segment) {
                          return Expanded(
                            flex:
                                (segment.percentage * animationValue * 100)
                                    .round(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: segment.color,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 16.w,
          runSpacing: 8.h,
          children:
              segments.map((segment) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: segment.color,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${segment.label} (${segment.percentage.toStringAsFixed(1)}%)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
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
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppTheme.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 24.w),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textMain,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialRow(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 20.w),
          ),
          SizedBox(width: 16.w),
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

  Widget _buildDetailRow(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 24.w),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
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
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 20.w),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
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
