import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/entities/batch_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/enhanced_text_field.dart';
import '../../cubit/batches_cubit.dart';
import 'add_batch_screen.dart';
import 'batch_details_screen.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../core/services/sync_queue.dart';
import 'package:katakit/features/auth/cubit/auth_cubit.dart' as auth;

class BatchesScreen extends StatefulWidget {
  final Stream<SyncStatus>? syncStatusStream;
  const BatchesScreen({super.key, this.syncStatusStream});

  @override
  State<BatchesScreen> createState() => _BatchesScreenState();
}

class _BatchesScreenState extends State<BatchesScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<BatchEntity> _filteredBatches = [];
  bool _isSearching = false;
  late AnimationController _fabAnimationController;
  late AnimationController _cardsAnimationController;
  late Animation<double> _fabAnimation;
  bool _didInitialLoad = false;

  @override
  void initState() {
    super.initState();
    // لا تحمل الدفعات هنا، سيتم التحميل بعد تسجيل الدخول
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _fabAnimationController.forward();
    _cardsAnimationController.forward();
    SyncService().userNoticeStream.listen((msg) {
      if (mounted && msg.isNotEmpty) {
        _showSyncNotification(msg);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitialLoad) {
      final authState = context.read<auth.AuthCubit>().state;
      if (authState is auth.Authenticated) {
        context.read<BatchesCubit>().loadBatchesInitialIfNeeded(
          authState.userId,
        );
        _didInitialLoad = true;
      }
    }
  }

  void _showSyncNotification(String msg) {
    Color bgColor = AppTheme.info;
    IconData icon = Icons.info;

    if (msg.contains('خطأ') || msg.contains('error')) {
      bgColor = AppTheme.error;
      icon = Icons.error_outline;
    } else if (msg.contains('تمت') ||
        msg.contains('اكتملت') ||
        msg.contains('نجاح')) {
      bgColor = AppTheme.success;
      icon = Icons.check_circle_outline;
    } else if (msg.contains('لا يوجد اتصال')) {
      bgColor = AppTheme.warning;
      icon = Icons.wifi_off;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20.w),
            SizedBox(width: 12.w),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    _cardsAnimationController.dispose();
    super.dispose();
  }

  void _filterBatches(String query, List<BatchEntity> allBatches) {
    if (query.isEmpty) {
      setState(() {
        _filteredBatches = allBatches;
        _isSearching = false;
      });
    } else {
      setState(() {
        _filteredBatches =
            allBatches.where((batch) {
              return batch.name.toLowerCase().contains(query.toLowerCase()) ||
                  batch.supplier.toLowerCase().contains(query.toLowerCase());
            }).toList();
        _isSearching = true;
      });
    }
  }

  void _showDeleteConfirmation(BuildContext context, BatchEntity batch) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: AppTheme.cardLight,
          elevation: 8,
          title: Container(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.error,
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'تأكيد الحذف',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textMain,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: Container(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'هل أنت متأكد من حذف دفعة "${batch.name}"؟',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textMain,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'لا يمكن التراجع عن هذا الإجراء.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<BatchesCubit>().deleteBatch(batch.id);
                _showSyncNotification('تم حذف الدفعة بنجاح');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 2,
              ),
              child: Text(
                'حذف',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) async {
    // Check if there are unsynchronized items
    final queueService = SyncQueueService();
    final pendingItems = await queueService.getQueue();
    final hasPendingSync = pendingItems.isNotEmpty;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: AppTheme.error, size: 24.w),
              SizedBox(width: 12.w),
              Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: AppTheme.textMain,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'هل أنت متأكد من تسجيل الخروج؟',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),
              if (hasPendingSync) ...[
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppTheme.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: AppTheme.warning, size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'لديك ${pendingItems.length} عنصر غير مزامن',
                          style: TextStyle(
                            color: AppTheme.warning,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
              ],
              Text(
                'سيتم حذف جميع البيانات المحلية:\n• الدفعات والإضافات\n• الوفيات والمبيعات\n• طابور المزامنة\n• جميع البيانات المؤقتة',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13.sp,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<auth.AuthCubit>().logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 2,
              ),
              child: Text(
                'تسجيل الخروج',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldLight,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: Text(
          'دفعات الكتاكيت',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textLight,
        elevation: 8,
        shadowColor: AppTheme.primary.withOpacity(0.3),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8.w),
            child: IconButton(
              icon: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(Icons.sync, size: 18),
              ),
              tooltip: 'مزامنة يدوية',
              onPressed: () async {
                await SyncService().processQueue();
                if (context.mounted) {
                  _showSyncNotification('تم بدء المزامنة اليدوية...');
                }
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 8.w),
            child: BlocConsumer<auth.AuthCubit, auth.AuthState>(
              listener: (context, state) {
                if (state is auth.AuthError) {
                  _showSyncNotification(
                    'خطأ في تسجيل الخروج: ${state.message}',
                  );
                } else if (state is auth.Unauthenticated) {
                  _showSyncNotification(
                    'تم تسجيل الخروج وحذف جميع البيانات المحلية بنجاح',
                  );
                }
              },
              builder: (context, state) {
                return IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child:
                        state is auth.AuthLoading
                            ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(Icons.logout, size: 18),
                  ),
                  tooltip: 'تسجيل الخروج',
                  onPressed:
                      state is auth.AuthLoading
                          ? null
                          : () => _showLogoutDialog(context),
                );
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
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
                      }

                      return Container(
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(0.1),
                              color.withOpacity(0.05),
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            status == SyncStatus.syncing
                                ? SizedBox(
                                  width: 14.w,
                                  height: 14.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      color,
                                    ),
                                  ),
                                )
                                : Icon(icon, color: color, size: 14.w),
                            SizedBox(width: 6.w),
                            Text(
                              text,
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w600,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                  : const SizedBox(height: 0),
        ),
      ),
      body: Column(
        children: [
          // Enhanced Search Bar
          Container(
            margin: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.cardLight,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: EnhancedSearchField(
              controller: _searchController,
              hintText: 'البحث في الدفعات...',
              onChanged: (value) {
                final state = context.read<BatchesCubit>().state;
                if (state is BatchesLoaded) {
                  _filterBatches(value, state.batches);
                }
              },
              onClear: () {
                final state = context.read<BatchesCubit>().state;
                if (state is BatchesLoaded) {
                  _filterBatches('', state.batches);
                }
              },
            ),
          ),

          // Batches List
          Expanded(
            child: BlocBuilder<BatchesCubit, BatchesState>(
              builder: (context, state) {
                if (state is BatchesInitialLoading) {
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
                } else if (state is BatchesLoading) {
                  return _buildLoadingState();
                } else if (state is BatchesLoaded) {
                  return _buildLoadedState(state);
                } else if (state is BatchesError) {
                  return _buildErrorState(state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddBatchScreen()),
            );
          },
          backgroundColor: AppTheme.accent,
          foregroundColor: AppTheme.textMain,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          icon: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: const Icon(Icons.add, size: 18),
          ),
          label: Text(
            'دفعة جديدة',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 3.w,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'جاري التحميل...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(BatchesLoaded state) {
    // Update filtered batches when data changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isSearching) {
        setState(() {
          _filteredBatches = state.batches;
        });
      } else {
        _filterBatches(_searchController.text, state.batches);
      }
    });

    final batchesToShow = _isSearching ? _filteredBatches : state.batches;

    if (batchesToShow.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _cardsAnimationController,
      builder: (context, child) {
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 80.h),
          itemCount: batchesToShow.length,
          itemBuilder: (context, index) {
            final batch = batchesToShow[index];
            final animationDelay = index * 0.1;
            final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _cardsAnimationController,
                curve: Interval(
                  animationDelay.clamp(0.0, 1.0),
                  (animationDelay + 0.2).clamp(0.0, 1.0),
                  curve: Curves.easeOutCubic,
                ),
              ),
            );

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: BatchCard(
                  batch: batch,
                  onDelete: () => _showDeleteConfirmation(context, batch),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.1),
                    AppTheme.accent.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                _isSearching ? Icons.search_off : Icons.inventory_2_outlined,
                size: 60.w,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              _isSearching ? 'لا توجد نتائج' : 'لا توجد دفعات',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.textMain,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                _isSearching
                    ? 'جرب البحث بكلمات مختلفة أو تحقق من الإملاء'
                    : 'ابدأ بإضافة دفعة جديدة من الكتاكيت لتتبع مزرعتك',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BatchesError state) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20.w),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.cardLight,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppTheme.error.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
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
            SizedBox(height: 20.h),
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
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                context.read<BatchesCubit>().loadBatches();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.textLight,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BatchCard extends StatelessWidget {
  final BatchEntity batch;
  final VoidCallback? onDelete;

  const BatchCard({super.key, required this.batch, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.cardLight, AppTheme.cardLight.withOpacity(0.9)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BatchDetailsScreen(batch: batch),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppTheme.primaryGradient,
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.pets,
                        color: AppTheme.textLight,
                        size: 20.w,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            batch.name,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              color: AppTheme.textMain,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppTheme.accentGradient,
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Text(
                              '${batch.chickCount} كتكوت',
                              style: Theme.of(
                                context,
                              ).textTheme.labelMedium?.copyWith(
                                color: AppTheme.textMain,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onDelete != null)
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: IconButton(
                          onPressed: onDelete,
                          icon: Icon(
                            Icons.delete_outline,
                            color: AppTheme.error,
                            size: 20.w,
                          ),
                          tooltip: 'حذف الدفعة',
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Info Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        context,
                        Icons.person,
                        'المورد',
                        batch.supplier,
                        AppTheme.info,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildInfoCard(
                        context,
                        Icons.calendar_today,
                        'التاريخ',
                        _formatDate(batch.date),
                        AppTheme.primary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // Price Info
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.success.withOpacity(0.1),
                        AppTheme.success.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppTheme.success.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'سعر الوحدة',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${batch.chickBuyPrice.toStringAsFixed(2)} جنيه',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Divider(color: AppTheme.success.withOpacity(0.3)),
                      SizedBox(height: 6.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'إجمالي الشراء',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: AppTheme.textMain,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${batch.totalBuyPrice.toStringAsFixed(2)} جنيه',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              color: AppTheme.success,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.w, color: color),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMain,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
