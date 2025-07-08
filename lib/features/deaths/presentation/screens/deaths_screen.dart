import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/entities/death_entity.dart';
import '../../../../core/entities/batch_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../cubit/deaths_cubit.dart';
import '../../../sales/cubit/sales_cubit.dart';
import 'add_death_screen.dart';
import '../../../../core/services/sync_service.dart';
import 'widgets/build_summary_header.dart';
import '../../../auth/cubit/auth_cubit.dart' as auth;

class DeathsScreen extends StatefulWidget {
  final BatchEntity batch;
  final Stream<SyncStatus>? syncStatusStream;

  const DeathsScreen({super.key, required this.batch, this.syncStatusStream});

  @override
  State<DeathsScreen> createState() => _DeathsScreenState();
}

class _DeathsScreenState extends State<DeathsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _didInitialLoad = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _setupSyncListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitialLoad) {
      final authState = context.read<auth.AuthCubit>().state;
      if (authState is auth.Authenticated) {
        context.read<DeathsCubit>().loadDeathsInitialIfNeeded(
          widget.batch.id,
          authState.userId,
        );
        _didInitialLoad = true;
      }
    }
  }

  void _setupSyncListener() {
    SyncService().userNoticeStream.listen((msg) {
      if (mounted && msg.isNotEmpty) {
        _showCustomSnackBar(msg);
      }
    });
  }

  void _showCustomSnackBar(String message) {
    Color bgColor = AppTheme.info;
    IconData icon = Icons.info_outline;

    if (message.contains('خطأ') || message.contains('error')) {
      bgColor = AppTheme.error;
      icon = Icons.error_outline;
    } else if (message.contains('تمت') ||
        message.contains('اكتملت') ||
        message.contains('نجاح')) {
      bgColor = AppTheme.success;
      icon = Icons.check_circle_outline;
    } else if (message.contains('لا يوجد اتصال')) {
      bgColor = AppTheme.warning;
      icon = Icons.wifi_off;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20.w),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  int _calculateAvailableForDeaths(int totalSold, int totalDeaths) {
    return widget.batch.chickCount - totalSold - totalDeaths;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textLight),
        onPressed: () => Navigator.of(context).pop(),
      ),
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
      bottom: _buildSyncStatusBar(),
    );
  }

  PreferredSize? _buildSyncStatusBar() {
    if (widget.syncStatusStream == null) return null;

    return PreferredSize(
      preferredSize: const Size.fromHeight(36),
      child: StreamBuilder<SyncStatus>(
        stream: widget.syncStatusStream,
        builder: (context, snapshot) {
          final status = snapshot.data;
          if (status == null) return const SizedBox(height: 0);

          final statusInfo = _getStatusInfo(status);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 36,
            decoration: BoxDecoration(
              color: statusInfo.color.withOpacity(0.1),
              border: Border(
                top: BorderSide(
                  color: statusInfo.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (status == SyncStatus.syncing)
                  SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(statusInfo.color),
                    ),
                  )
                else
                  Icon(statusInfo.icon, color: statusInfo.color, size: 18.w),
                SizedBox(width: 8.w),
                Text(
                  statusInfo.text,
                  style: TextStyle(
                    color: statusInfo.color,
                    fontWeight: FontWeight.w500,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  ({IconData icon, String text, Color color}) _getStatusInfo(
    SyncStatus status,
  ) {
    switch (status) {
      case SyncStatus.synced:
        return (
          icon: Icons.check_circle,
          text: 'تمت المزامنة',
          color: AppTheme.success,
        );
      case SyncStatus.syncing:
        return (
          icon: Icons.sync,
          text: 'جاري المزامنة...',
          color: AppTheme.info,
        );
      case SyncStatus.offline:
        return (
          icon: Icons.wifi_off,
          text: 'أوفلاين - في انتظار الاتصال',
          color: AppTheme.warning,
        );
      case SyncStatus.error:
        return (
          icon: Icons.error,
          text: 'خطأ في المزامنة',
          color: AppTheme.error,
        );
      default:
        return (icon: Icons.sync, text: '', color: AppTheme.info);
    }
  }

  Widget _buildBody() {
    return BlocBuilder<DeathsCubit, DeathsState>(
      builder: (context, state) {
        if (state is DeathsInitialLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.primary),
                SizedBox(height: 16),
                Text('جاري تحميل بياناتك من السحابة...'),
              ],
            ),
          );
        }
        return MultiBlocListener(
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: BlocBuilder<DeathsCubit, DeathsState>(
              builder: (context, deathsState) {
                return BlocBuilder<SalesCubit, SalesState>(
                  builder: (context, salesState) {
                    if (deathsState is DeathsLoading ||
                        salesState is SalesLoading) {
                      return _buildLoadingState();
                    } else if (deathsState is DeathsLoaded) {
                      return _buildLoadedState(deathsState, salesState);
                    } else if (deathsState is DeathsError) {
                      return _buildErrorState(deathsState);
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
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
              color: AppTheme.cardLight,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 3.w,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'جاري التحميل...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(DeathsState deathsState, SalesState salesState) {
    if (deathsState is! DeathsLoaded) return const SizedBox.shrink();

    int totalSold = 0;
    if (salesState is SalesLoaded) {
      totalSold = salesState.totalSoldCount;
    }

    final availableForDeaths = _calculateAvailableForDeaths(
      totalSold,
      deathsState.totalDeathsCount,
    );

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DeathsCubit>().loadDeaths(widget.batch.id);
        context.read<SalesCubit>().loadSales(widget.batch.id);
      },
      color: AppTheme.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildEnhancedSummaryCard(
              deathsState.totalDeathsCount,
              totalSold,
              availableForDeaths,
            ),
          ),
          if (deathsState.deaths.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final death = deathsState.deaths[index];
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    child: EnhancedDeathCard(
                      death: death,
                      index: index,
                      onDelete: () => _showDeleteDialog(death),
                    ),
                  );
                }, childCount: deathsState.deaths.length),
              ),
            ),
          SliverToBoxAdapter(
            child: SizedBox(height: 50.h), // Space for FAB
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(DeathsError state) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.error.withOpacity(0.3),
                  width: 2,
                ),
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
            SizedBox(height: 12.h),
            Text(
              state.message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () {
                context.read<DeathsCubit>().loadDeaths(widget.batch.id);
                _animationController.reset();
                _animationController.forward();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.textLight,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
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

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primary.withOpacity(0.1),
                    AppTheme.accent.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.textFaint.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.sentiment_satisfied_alt,
                size: 64.w,
                color: AppTheme.success,
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
            SizedBox(height: 12.h),
            Text(
              'هذا أمر جيد! لا توجد وفيات مسجلة في هذه الدفعة',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'يمكنك إضافة وفيات جديدة عند الحاجة',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textFaint),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSummaryCard(
    int totalDeathsCount,
    int totalSold,
    int availableForDeaths,
  ) {
    final deathPercentage =
        widget.batch.chickCount > 0
            ? (totalDeathsCount / widget.batch.chickCount) * 100
            : 0.0;
    final mortalityStatus = _getMortalityStatus(deathPercentage);

    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.cardLight, AppTheme.cardLight.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textFaint.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BuildSummaryHeader(
              color: mortalityStatus.color,
              icon: mortalityStatus.icon,
              status: mortalityStatus.status,
            ),
            SizedBox(height: 24.h),
            _buildMainStats(
              totalDeathsCount,
              availableForDeaths,
              deathPercentage,
              mortalityStatus,
            ),
            SizedBox(height: 20.h),
            _buildDetailedStats(totalSold, totalDeathsCount),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStats(
    int totalDeathsCount,
    int availableForDeaths,
    double deathPercentage,
    ({Color color, String status, IconData icon}) mortalityStatus,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Add this
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إجمالي الوفيات',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
              SizedBox(height: 6.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$totalDeathsCount',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Text(
                      'كتكوت',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                '${deathPercentage.toStringAsFixed(1)}% من الإجمالي',
                style: TextStyle(
                  color: mortalityStatus.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w), // Add some spacing
        Flexible(
          // Change from Container to Flexible
          child: Container(
            padding: EdgeInsets.all(12.w), // Reduce padding
            decoration: BoxDecoration(
              color:
                  availableForDeaths > 0
                      ? AppTheme.success.withOpacity(0.1)
                      : AppTheme.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color:
                    availableForDeaths > 0
                        ? AppTheme.success.withOpacity(0.3)
                        : AppTheme.warning.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Add this
              children: [
                Icon(
                  availableForDeaths > 0 ? Icons.add_circle : Icons.warning,
                  color:
                      availableForDeaths > 0
                          ? AppTheme.success
                          : AppTheme.warning,
                  size: 18.w, // Reduce icon size
                ),
                SizedBox(height: 6.h), // Reduce spacing
                Text(
                  'المتاح للتسجيل',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 10.sp, // Reduce font size
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h), // Reduce spacing
                Text(
                  '$availableForDeaths',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    // Change from titleLarge
                    color:
                        availableForDeaths > 0
                            ? AppTheme.success
                            : AppTheme.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedStats(int totalSold, int totalDeathsCount) {
    return Row(
      children: [
        Expanded(
          child: _buildEnhancedInfoItem(
            'المباع',
            '$totalSold كتكوت',
            AppTheme.accent,
            Icons.sell,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildEnhancedInfoItem(
            'المتبقي',
            '${widget.batch.chickCount - totalDeathsCount - totalSold} كتكوت',
            AppTheme.primary,
            Icons.inventory,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildEnhancedInfoItem(
            'الإجمالي',
            '${widget.batch.chickCount} كتكوت',
            AppTheme.info,
            Icons.apps,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedInfoItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16.w),
          SizedBox(height: 6.h),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary),
          ),
          SizedBox(height: 2.h),
          Text(
            value.split(' ')[0], // Just the number
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  ({Color color, String status, IconData icon}) _getMortalityStatus(
    double percentage,
  ) {
    if (percentage <= 2) {
      return (
        color: AppTheme.success,
        status: 'ممتاز',
        icon: Icons.sentiment_very_satisfied,
      );
    } else if (percentage <= 5) {
      return (
        color: AppTheme.info,
        status: 'جيد',
        icon: Icons.sentiment_satisfied,
      );
    } else if (percentage <= 10) {
      return (
        color: AppTheme.warning,
        status: 'مقبول',
        icon: Icons.sentiment_neutral,
      );
    } else {
      return (
        color: AppTheme.error,
        status: 'مرتفع',
        icon: Icons.sentiment_dissatisfied,
      );
    }
  }

  Widget _buildFloatingActionButton() {
    return BlocBuilder<DeathsCubit, DeathsState>(
      builder: (context, deathsState) {
        return BlocBuilder<SalesCubit, SalesState>(
          builder: (context, salesState) {
            int totalSold = 0;
            int totalDeaths = 0;

            if (salesState is SalesLoaded) {
              totalSold = salesState.totalSoldCount;
            }

            if (deathsState is DeathsLoaded) {
              totalDeaths = deathsState.totalDeathsCount;
            }

            final availableForDeaths = _calculateAvailableForDeaths(
              totalSold,
              totalDeaths,
            );

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: FloatingActionButton.extended(
                onPressed:
                    availableForDeaths > 0
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      AddDeathScreen(batch: widget.batch),
                            ),
                          );
                        }
                        : null,
                backgroundColor:
                    availableForDeaths > 0
                        ? AppTheme.accent
                        : AppTheme.textFaint,
                foregroundColor:
                    availableForDeaths > 0
                        ? AppTheme.textMain
                        : AppTheme.textSecondary,
                icon: Icon(
                  availableForDeaths > 0 ? Icons.add : Icons.block,
                  size: 20.w,
                ),
                label: Text(
                  availableForDeaths > 0 ? 'وفاة جديدة' : 'لا يوجد متاح',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                elevation: availableForDeaths > 0 ? 8 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(DeathEntity death) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Row(
              children: [
                Icon(Icons.warning, color: AppTheme.warning, size: 24.w),
                SizedBox(width: 12.w),
                Text(
                  'تأكيد الحذف',
                  style: TextStyle(
                    color: AppTheme.textMain,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              'هل أنت متأكد من حذف وفاة ${death.count} كتكوت؟',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إلغاء',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<DeathsCubit>().deleteDeath(
                    death.id,
                    widget.batch.id,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: const Text('حذف'),
              ),
            ],
          ),
    );
  }
}

class EnhancedDeathCard extends StatelessWidget {
  final DeathEntity death;
  final int index;
  final VoidCallback onDelete;

  const EnhancedDeathCard({
    super.key,
    required this.death,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textFaint.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: AppTheme.error.withOpacity(0.1), width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              _buildDeathIcon(),
              SizedBox(width: 16.w),
              _buildDeathInfo(context),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeathIcon() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.error.withOpacity(0.1),
            AppTheme.error.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.error.withOpacity(0.2), width: 1),
      ),
      child: Icon(
        Icons.remove_circle_outline,
        color: AppTheme.error,
        size: 24.w,
      ),
    );
  }

  Widget _buildDeathInfo(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${death.count}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textMain,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                'كتكوت',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppTheme.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today, size: 14.w, color: AppTheme.info),
                SizedBox(width: 4.w),
                Text(
                  _formatDate(death.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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
            style: TextStyle(
              color: AppTheme.error,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline, color: AppTheme.error, size: 20.w),
            style: IconButton.styleFrom(
              padding: EdgeInsets.all(8.w),
              minimumSize: Size(40.w, 40.w),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }
}
