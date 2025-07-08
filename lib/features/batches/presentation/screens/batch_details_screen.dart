import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/entities/batch_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../additions/presentation/screens/additions_screen.dart';
import '../../../deaths/presentation/screens/deaths_screen.dart';
import '../../../sales/presentation/screens/sales_screen.dart';
import '../../../statistics/presentation/screens/statistics_screen.dart';
import '../../../additions/cubit/additions_cubit.dart';
import '../../../deaths/cubit/deaths_cubit.dart';
import '../../../sales/cubit/sales_cubit.dart';

class BatchDetailsScreen extends StatefulWidget {
  final BatchEntity batch;

  const BatchDetailsScreen({super.key, required this.batch});

  @override
  State<BatchDetailsScreen> createState() => _BatchDetailsScreenState();
}

class _BatchDetailsScreenState extends State<BatchDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // تحميل البيانات المطلوبة لعرض الإحصائيات المحدثة
    context.read<SalesCubit>().loadSales(widget.batch.id);
    context.read<DeathsCubit>().loadDeaths(widget.batch.id);
    context.read<AdditionsCubit>().loadAdditions(widget.batch.id);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: MultiBlocListener(
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

                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Padding(
                                padding: EdgeInsets.all(12.w),
                                child: Column(
                                  children: [
                                    _buildInfoCard(),
                                    SizedBox(height: 10.h),
                                    _buildStatisticsCard(
                                      totalSold,
                                      totalDeaths,
                                      remainingCount,
                                      totalAdditionsCost,
                                      totalSalesAmount,
                                      profitLoss,
                                    ),
                                    SizedBox(height: 10.h),
                                    _buildActionsCard(context),
                                    SizedBox(height: 20.h),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180.h,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primary,
      foregroundColor: AppTheme.textLight,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textLight),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.batch.name,
          style: TextStyle(
            color: AppTheme.textLight,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppTheme.primaryGradient,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pets,
                    size: 32.w,
                    color: AppTheme.textLight,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '${widget.batch.chickCount} كتكوت',
                  style: TextStyle(
                    color: AppTheme.textLight.withOpacity(0.9),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(left: 8.w),
          child: IconButton(
            onPressed: () {
              // تحديث البيانات
              context.read<SalesCubit>().loadSales(widget.batch.id);
              context.read<DeathsCubit>().loadDeaths(widget.batch.id);
              context.read<AdditionsCubit>().loadAdditions(widget.batch.id);
            },
            icon: Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(Icons.refresh, size: 16.w),
            ),
            tooltip: 'تحديث البيانات',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      margin: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.cardLight, AppTheme.cardLight.withOpacity(0.8)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader('معلومات الدفعة', Icons.info_outline),
              SizedBox(height: 12.h),
              _buildInfoGrid(),
              if (widget.batch.note != null) ...[
                SizedBox(height: 10.h),
                _buildNoteSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                'المورد',
                widget.batch.supplier,
                Icons.person,
                AppTheme.info,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildInfoItem(
                'التاريخ',
                _formatDate(widget.batch.date),
                Icons.calendar_today,
                AppTheme.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                'العدد',
                '${widget.batch.chickCount}',
                Icons.pets,
                AppTheme.accent,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildInfoItem(
                'السعر',
                '${widget.batch.chickBuyPrice.toStringAsFixed(2)} ج',
                Icons.attach_money,
                AppTheme.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.w, color: color),
              SizedBox(width: 5.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppTheme.textMain,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppTheme.warning.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note, size: 14.w, color: AppTheme.warning),
              SizedBox(width: 5.w),
              Text(
                'ملاحظات',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppTheme.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Text(
            widget.batch.note!,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppTheme.textMain,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      margin: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.cardLight, AppTheme.cardLight.withOpacity(0.8)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader('الإحصائيات المحدثة', Icons.analytics),
              SizedBox(height: 10.h),

              _buildStatsGrid(
                totalSold,
                totalDeaths,
                remainingCount,
                totalAdditionsCost,
              ),
              SizedBox(height: 12.h),
              _buildFinancialSummary(totalSalesAmount, profitLoss),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    int totalSold,
    int totalDeaths,
    int remainingCount,
    double totalAdditionsCost,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'المباع',
                '$totalSold',
                AppTheme.accent,
                Icons.sell,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildStatItem(
                'الوفيات',
                '$totalDeaths',
                AppTheme.error,
                Icons.remove_circle_outline,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'المتبقي',
                '$remainingCount',
                AppTheme.success,
                Icons.inventory,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildStatItem(
                'المصروفات',
                '${totalAdditionsCost.toStringAsFixed(0)} ج',
                AppTheme.warning,
                Icons.account_balance_wallet,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialSummary(double totalSalesAmount, double profitLoss) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            profitLoss >= 0
                ? AppTheme.success.withOpacity(0.1)
                : AppTheme.error.withOpacity(0.1),
            profitLoss >= 0
                ? AppTheme.success.withOpacity(0.05)
                : AppTheme.error.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color:
              profitLoss >= 0
                  ? AppTheme.success.withOpacity(0.3)
                  : AppTheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إجمالي المبيعات',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${totalSalesAmount.toStringAsFixed(2)} جنيه',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إجمالي التكلفة',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(widget.batch.totalBuyPrice).toStringAsFixed(2)} جنيه',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Divider(color: AppTheme.textFaint, height: 1),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    profitLoss >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: profitLoss >= 0 ? AppTheme.success : AppTheme.error,
                    size: 16.w,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    profitLoss >= 0 ? 'الربح' : 'الخسارة',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.textMain,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '${profitLoss.abs().toStringAsFixed(2)} جنيه',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: profitLoss >= 0 ? AppTheme.success : AppTheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      margin: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.cardLight, AppTheme.cardLight.withOpacity(0.8)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader('الإجراءات', Icons.dashboard),
              SizedBox(height: 10.h),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
                childAspectRatio: 2.5,
                children: [
                  _buildActionTile(
                    'المصروفات',
                    Icons.add_card,
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
                  _buildActionTile('المبيعات', Icons.sell, AppTheme.accent, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SalesScreen(batch: widget.batch),
                      ),
                    );
                  }),
                  _buildActionTile(
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
                  _buildActionTile(
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: AppTheme.primaryGradient),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppTheme.textLight, size: 16.w),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textMain,
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
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18.w),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(icon, color: AppTheme.textLight, size: 16.w),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
