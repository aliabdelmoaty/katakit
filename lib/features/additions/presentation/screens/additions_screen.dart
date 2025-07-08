import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:katakit/core/utils/app_utils.dart';
import '../../../../core/entities/addition_entity.dart';
import '../../../../core/entities/batch_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../cubit/additions_cubit.dart';
import '../../../deaths/cubit/deaths_cubit.dart';
import 'add_addition_screen.dart';
import '../../../../core/services/sync_service.dart';
import '../../../auth/cubit/auth_cubit.dart' as auth;

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

class _AdditionsScreenState extends State<AdditionsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  bool _didInitialLoad = false;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _fabAnimationController.forward();
    SyncService().userNoticeStream.listen((msg) {
      if (mounted && msg.isNotEmpty) {
        if (msg.contains('خطأ') || msg.contains('error')) {
          context.showErrorSnackBar(msg);
        } else if (msg.contains('تمت') ||
            msg.contains('اكتملت') ||
            msg.contains('نجاح')) {
          context.showSuccessSnackBar(msg);
          return;
        } else if (msg.contains('لا يوجد اتصال')) {
          context.showWarningSnackBar(
            'لا يوجد اتصال بالإنترنت. سيتم حفظ البيانات محليًا.',
          );
          return;
        }
        context.showInfoSnackBar(msg);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitialLoad) {
      final authState = context.read<auth.AuthCubit>().state;
      if (authState is auth.Authenticated) {
        context.read<AdditionsCubit>().loadAdditionsInitialIfNeeded(
          widget.batch.id,
          authState.userId,
        );
        _didInitialLoad = true;
      }
    }
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: SizedBox(height: 8.h)),
          BlocBuilder<AdditionsCubit, AdditionsState>(
            builder: (context, additionsState) {
              if (additionsState is AdditionsInitialLoading) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppTheme.primary),
                        SizedBox(height: 16),
                        Text('جاري تحميل بياناتك من السحابة...'),
                      ],
                    ),
                  ),
                );
              } else if (additionsState is AdditionsLoading) {
                return SliverFillRemaining(child: _buildLoadingState());
              } else if (additionsState is AdditionsLoaded) {
                // استخدام BlocBuilder للحصول على بيانات الوفيات
                return BlocBuilder<DeathsCubit, DeathsState>(
                  builder: (context, deathsState) {
                    int totalDeaths = 0;
                    if (deathsState is DeathsLoaded) {
                      totalDeaths = deathsState.totalDeathsCount;
                    }

                    return SliverList(
                      delegate: SliverChildListDelegate([
                        _buildEnhancedSummaryCard(
                          additionsState.totalCost,
                          totalDeaths,
                        ),
                        SizedBox(height: 8.h),
                        if (additionsState.additions.isEmpty)
                          _buildEmptyState()
                        else
                          _buildAdditionsList(additionsState.additions),
                        SizedBox(height: 100.h), // Space for FAB
                      ]),
                    );
                  },
                );
              } else if (additionsState is AdditionsError) {
                return SliverFillRemaining(
                  child: _buildErrorState(additionsState.message),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        AddAdditionScreen(batch: widget.batch),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: child,
                  );
                },
              ),
            );
          },
          backgroundColor: AppTheme.accent,
          foregroundColor: AppTheme.textMain,
          icon: const Icon(Icons.add_rounded),
          label: const Text('مصروف جديد'),
          elevation: 8,
          heroTag: "add_addition",
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180.h,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppTheme.primaryGradient,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
          ),
          child: Stack(
            children: [
              // Content
              Positioned(
                bottom: 20.h,
                left: 20.w,
                right: 20.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_rounded,
                            color: AppTheme.textLight,
                            size: 28.w,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مصروفات',
                                style: TextStyle(
                                  color: AppTheme.textLight.withOpacity(0.9),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                widget.batch.name,
                                style: TextStyle(
                                  color: AppTheme.textLight,
                                  fontSize: 20.sp,
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
            ],
          ),
        ),
      ),
      bottom:
          widget.syncStatusStream != null
              ? PreferredSize(
                preferredSize: Size.fromHeight(40.h),
                child: _buildSyncStatusBar(),
              )
              : null,
    );
  }

  Widget _buildSyncStatusBar() {
    return StreamBuilder<SyncStatus>(
      stream: widget.syncStatusStream,
      builder: (context, snapshot) {
        final status = snapshot.data;
        if (status == null) return const SizedBox(height: 0);

        IconData icon;
        String text;
        Color color;

        switch (status) {
          case SyncStatus.synced:
            icon = Icons.check_circle_rounded;
            text = 'تمت المزامنة';
            color = AppTheme.success;
            break;
          case SyncStatus.syncing:
            icon = Icons.sync_rounded;
            text = 'جاري المزامنة...';
            color = AppTheme.info;
            break;
          case SyncStatus.offline:
            icon = Icons.wifi_off_rounded;
            text = 'أوفلاين - في انتظار الاتصال';
            color = AppTheme.warning;
            break;
          case SyncStatus.error:
            icon = Icons.error_rounded;
            text = 'خطأ في المزامنة';
            color = AppTheme.error;
            break;
          default:
            icon = Icons.sync_rounded;
            text = '';
            color = AppTheme.info;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 40.h,
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18.w),
              SizedBox(width: 8.w),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 3.w,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'جاري تحميل المصروفات...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSummaryCard(double totalCost, int totalDeaths) {
    final actualCostPerChick = _calculateActualCostPerChickWithDeaths(
      totalCost,
      totalDeaths,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.cardLight, AppTheme.cardLight.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: AppTheme.accentGradient),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppTheme.textMain,
                    size: 24.w,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    'ملخص المصروفات',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMain,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            // إضافة معلومات عن عدد الكتاكيت
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppTheme.info.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.info, size: 20.w),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'عدد الكتاكيت المتبقية (بعد الوفيات)',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${widget.batch.chickCount - totalDeaths} من أصل ${widget.batch.chickCount}',
                          style: TextStyle(
                            color: AppTheme.info,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'إجمالي المصروفات',
                    '${totalCost.toStringAsFixed(2)} جنيه',
                    Icons.receipt_long_rounded,
                    AppTheme.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildSummaryItem(
                    'التكلفة الحقيقية للكتكوت',
                    '${actualCostPerChick.toStringAsFixed(2)} جنيه',
                    Icons.trending_up_rounded,
                    AppTheme.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.w),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
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

  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textFaint.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.textFaint.withOpacity(0.1),
                  AppTheme.textFaint.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 64.w,
              color: AppTheme.textFaint,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'لا توجد مصروفات بعد',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textMain,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ابدأ بإضافة أول مصروف لهذه الدفعة\nلتتبع التكاليف بدقة',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  color: AppTheme.accent,
                  size: 16.w,
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  AddAdditionScreen(batch: widget.batch),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 1),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                              child: child,
                            );
                          },
                        ),
                      ),
                  child: Text(
                    'اضغط على زر الإضافة أدناه',
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionsList(List<AdditionEntity> additions) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: additions.length,
      itemBuilder: (context, index) {
        return EnhancedAdditionCard(
          addition: additions[index],
          onDelete: () {
            _showDeleteDialog(additions[index]);
          },
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: AppTheme.cardLight,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppTheme.error.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 56.w,
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
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AdditionsCubit>().loadAdditions(widget.batch.id);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.textLight,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(AdditionEntity addition) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: AppTheme.warning,
                  size: 24.w,
                ),
                SizedBox(width: 8.w),
                const Text('تأكيد الحذف'),
              ],
            ),
            content: Text(
              'هل أنت متأكد من حذف مصروف "${addition.name}"؟\nلا يمكن التراجع عن هذا الإجراء.',
              style: TextStyle(height: 1.5, fontSize: 14.sp),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AdditionsCubit>().deleteAddition(
                    addition.id,
                    widget.batch.id,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('حذف'),
              ),
            ],
          ),
    );
  }

  double _calculateActualCostPerChickWithDeaths(
    double totalAdditionsCost,
    int totalDeaths,
  ) {
    final totalCost = widget.batch.totalBuyPrice + totalAdditionsCost;
    final remainingChicks = widget.batch.chickCount - totalDeaths;

    // التأكد من أن عدد الكتاكيت المتبقية أكبر من صفر
    return remainingChicks > 0 ? totalCost / remainingChicks : 0.0;
  }
}

class EnhancedAdditionCard extends StatelessWidget {
  final AdditionEntity addition;
  final VoidCallback onDelete;

  const EnhancedAdditionCard({
    super.key,
    required this.addition,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textFaint.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppTheme.primaryGradient),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.receipt_rounded,
                color: AppTheme.textLight,
                size: 24.w,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    addition.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMain,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14.w,
                          color: AppTheme.info,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          _formatDate(addition.date),
                          style: TextStyle(
                            color: AppTheme.info,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${addition.cost.toStringAsFixed(2)} جنيه',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.error,
                    size: 20.w,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.error.withOpacity(0.1),
                    padding: EdgeInsets.all(8.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
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
    const months = [
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
