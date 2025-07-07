import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/entities/sale_entity.dart';
import '../../../../core/entities/batch_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/enhanced_text_field.dart';
import '../../cubit/sales_cubit.dart';
import '../../../deaths/cubit/deaths_cubit.dart';
import 'add_sale_screen.dart';
import 'edit_sale_screen.dart';
import '../../../../core/services/sync_service.dart';

class SalesScreen extends StatefulWidget {
  final BatchEntity batch;
  final Stream<SyncStatus>? syncStatusStream;

  const SalesScreen({super.key, required this.batch, this.syncStatusStream});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isKeyboardVisible = false;

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

    context.read<SalesCubit>().loadSales(widget.batch.id);
    context.read<DeathsCubit>().loadDeaths(widget.batch.id);
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  int _calculateAvailableForSale(int totalSold, int totalDeaths) {
    return widget.batch.chickCount - totalDeaths - totalSold;
  }

  List<SaleEntity> _filterSales(List<SaleEntity> sales) {
    if (_searchQuery.isEmpty) {
      return sales;
    }
    return sales
        .where(
          (sale) =>
              sale.buyerName.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Check if keyboard is visible
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    _isKeyboardVisible = keyboardHeight > 0;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldLight,
      resizeToAvoidBottomInset: true, // Allow resizing when keyboard appears
      appBar: AppBar(
        title: Text(
          'مبيعات ${widget.batch.name}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textLight,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
            ),
          ),
        ),
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
        ],
        child: BlocBuilder<SalesCubit, SalesState>(
          builder: (context, salesState) {
            return BlocBuilder<DeathsCubit, DeathsState>(
              builder: (context, deathsState) {
                if (salesState is SalesLoading ||
                    deathsState is DeathsLoading) {
                  return _buildLoadingState();
                } else if (salesState is SalesLoaded) {
                  int totalDeaths = 0;
                  if (deathsState is DeathsLoaded) {
                    totalDeaths = deathsState.totalDeathsCount;
                  }

                  final availableForSale = _calculateAvailableForSale(
                    salesState.totalSoldCount,
                    totalDeaths,
                  );

                  final filteredSales = _filterSales(salesState.sales);

                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Search Bar - Always visible at top
                        _buildSearchBar(),

                        // Scrollable content
                        Expanded(
                          child: CustomScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            slivers: [
                              // Summary Card (only when not searching and keyboard is hidden)
                              if (_searchQuery.isEmpty && !_isKeyboardVisible)
                                SliverToBoxAdapter(
                                  child: _buildSummaryCard(
                                    salesState.totalSoldCount,
                                    salesState.totalSalesAmount,
                                    totalDeaths,
                                    availableForSale,
                                  ),
                                ),

                              // Sales List or Empty State
                              filteredSales.isEmpty
                                  ? SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: _buildEmptyState(),
                                  )
                                  : SliverPadding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                    ),
                                    sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate((
                                        context,
                                        index,
                                      ) {
                                        final sale = filteredSales[index];
                                        return AnimatedContainer(
                                          duration: Duration(
                                            milliseconds: 300 + (index * 100),
                                          ),
                                          curve: Curves.easeOutBack,
                                          child: SaleCard(
                                            sale: sale,
                                            onDelete: () {
                                              _showDeleteConfirmation(
                                                context,
                                                sale,
                                              );
                                            },
                                            batch: widget.batch,
                                            index: index,
                                            isCompact:
                                                _isKeyboardVisible, // Pass keyboard state
                                          ),
                                        );
                                      }, childCount: filteredSales.length),
                                    ),
                                  ),

                              // Bottom padding - adjust based on keyboard visibility
                              SliverToBoxAdapter(
                                child: SizedBox(
                                  height: _isKeyboardVisible ? 20.h : 80.h,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (salesState is SalesError) {
                  return _buildErrorState(salesState.message);
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
      // Hide FAB when keyboard is visible
      floatingActionButton:
          _isKeyboardVisible ? null : _buildFloatingActionButton(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppTheme.textFaint.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: EnhancedSearchField(
        controller: _searchController,
        hintText: 'البحث عن مشتري...',
        
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        onClear: () {
          setState(() {
            _searchQuery = '';
          });
        },
      ),
    );
  }

  // ...existing code... (keep all other methods unchanged)
  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.scaffoldLight,
            AppTheme.scaffoldLight.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
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
                    color: AppTheme.primary.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 2.5.w,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'جاري التحميل...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    int totalSoldCount,
    double totalSalesAmount,
    int totalDeaths,
    int availableForSale,
  ) {
    final salesPercentage = (totalSoldCount / widget.batch.chickCount) * 100;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.cardLight, AppTheme.cardLight.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textFaint.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accent,
                        AppTheme.accent.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accent.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(Icons.analytics, color: Colors.white, size: 20.w),
                ),
                SizedBox(width: 12.w),
                Text(
                  'ملخص المبيعات',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textMain,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accent.withOpacity(0.1),
                    AppTheme.accent.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: AppTheme.accent,
                    size: 24.w,
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إجمالي المبيعات',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${totalSalesAmount.toStringAsFixed(2)} جنيه',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'المباع',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                        Text(
                          '$totalSoldCount',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: AppTheme.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: _buildModernInfoItem(
                    'المتاح للبيع',
                    '$availableForSale',
                    'كتكوت',
                    availableForSale > 0 ? AppTheme.primary : AppTheme.error,
                    Icons.sell,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildModernInfoItem(
                    'الوفيات',
                    '$totalDeaths',
                    'كتكوت',
                    AppTheme.error,
                    Icons.dangerous,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: _buildModernInfoItem(
                    'نسبة البيع',
                    salesPercentage.toStringAsFixed(1),
                    '%',
                    AppTheme.info,
                    Icons.trending_up,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildModernInfoItem(
                    'المتبقي',
                    '${widget.batch.chickCount - totalSoldCount - totalDeaths}',
                    'كتكوت',
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

  // ...existing methods remain the same...
  Widget _buildModernInfoItem(
    String label,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16.w),
          SizedBox(height: 4.h),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 10.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.scaffoldLight, AppTheme.error.withOpacity(0.05)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.error.withOpacity(0.1),
                      AppTheme.error.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.error.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<SalesCubit>().loadSales(widget.batch.id);
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.info.withOpacity(0.1),
                      AppTheme.info.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.info.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(Icons.search_off, size: 48.w, color: AppTheme.info),
              ),
              SizedBox(height: 16.h),
              Text(
                'لا توجد نتائج',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textMain,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'لم يتم العثور على مشتري باسم "$_searchQuery"',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('مسح البحث'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.info,
                  foregroundColor: AppTheme.textLight,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accent.withOpacity(0.1),
                      AppTheme.accent.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(Icons.sell, size: 48.w, color: AppTheme.accent),
              ),
              SizedBox(height: 16.h),
              Text(
                'لا توجد مبيعات مسجلة',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textMain,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'اضغط على زر الإضافة لتسجيل عملية بيع جديدة',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildFloatingActionButton() {
    return BlocBuilder<SalesCubit, SalesState>(
      builder: (context, salesState) {
        return BlocBuilder<DeathsCubit, DeathsState>(
          builder: (context, deathsState) {
            int totalSold = 0;
            int totalDeaths = 0;

            if (salesState is SalesLoaded) {
              totalSold = salesState.totalSoldCount;
            }

            if (deathsState is DeathsLoaded) {
              totalDeaths = deathsState.totalDeathsCount;
            }

            final availableForSale = _calculateAvailableForSale(
              totalSold,
              totalDeaths,
            );

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.r),
                boxShadow: [
                  BoxShadow(
                    color: (availableForSale > 0
                            ? AppTheme.accent
                            : AppTheme.textFaint)
                        .withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed:
                    availableForSale > 0
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      AddSaleScreen(batch: widget.batch),
                            ),
                          );
                        }
                        : null,
                backgroundColor:
                    availableForSale > 0 ? AppTheme.accent : AppTheme.textFaint,
                foregroundColor:
                    availableForSale > 0
                        ? Colors.white
                        : AppTheme.textSecondary,
                icon: Icon(availableForSale > 0 ? Icons.add : Icons.block),
                label: Text(
                  availableForSale > 0 ? 'بيع جديد' : 'لا يوجد متاح',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, SaleEntity sale) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Row(
              children: [
                Icon(Icons.warning, color: AppTheme.error),
                SizedBox(width: 8.w),
                Text('تأكيد الحذف'),
              ],
            ),
            content: Text(
              'هل تريد حذف عملية البيع للمشتري "${sale.buyerName}"؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<SalesCubit>().deleteSale(
                    sale.id,
                    widget.batch.id,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                ),
                child: Text('حذف', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }
}

class SaleCard extends StatelessWidget {
  final SaleEntity sale;
  final VoidCallback onDelete;
  final BatchEntity batch;
  final int index;
  final bool isCompact; // New parameter for compact mode

  const SaleCard({
    super.key,
    required this.sale,
    required this.onDelete,
    required this.batch,
    required this.index,
    this.isCompact = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: isCompact ? 6.h : 8.h,
      ), // Reduced margin when compact
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.cardLight, AppTheme.cardLight.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textFaint.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(
          isCompact ? 8.w : 10.w,
        ), // Reduced padding when compact
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row - معلومات المشتري والسعر الإجمالي
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(
                      isCompact ? 4.w : 6.w,
                    ), // Smaller padding when compact
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accent,
                          AppTheme.accent.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accent.withOpacity(0.2),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size:
                          isCompact ? 12.w : 14.w, // Smaller icon when compact
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          sale.buyerName,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: AppTheme.textMain,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                isCompact
                                    ? 12.sp
                                    : 14.sp, // Smaller font when compact
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size:
                                  isCompact
                                      ? 8.w
                                      : 10.w, // Smaller icon when compact
                              color: AppTheme.textSecondary,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              _formatDate(sale.date),
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall?.copyWith(
                                color: AppTheme.textSecondary,
                                fontSize:
                                    isCompact
                                        ? 8.sp
                                        : 10.sp, // Smaller font when compact
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          isCompact ? 4.w : 6.w, // Smaller padding when compact
                      vertical: isCompact ? 3.h : 4.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.success.withOpacity(0.12),
                          AppTheme.success.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: AppTheme.success.withOpacity(0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${sale.totalPrice.toStringAsFixed(0)} ج',
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(
                            color: AppTheme.success,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                isCompact
                                    ? 10.sp
                                    : 12.sp, // Smaller font when compact
                          ),
                        ),
                        Text(
                          '${sale.chickCount} كتكوت',
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: AppTheme.textSecondary,
                            fontSize:
                                isCompact
                                    ? 7.sp
                                    : 9.sp, // Smaller font when compact
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: isCompact ? 4.h : 6.h,
              ), // Reduced spacing when compact
              // Details and actions in a flexible layout
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row مدمج للتفاصيل والمبلغ المتبقي
                    Row(
                      children: [
                        // سعر الكتكوت
                        Expanded(
                          flex: 3,
                          child: _buildMiniDetailItem(
                            'سعر الكتكوت',
                            '${sale.pricePerChick.toStringAsFixed(1)} ج',
                            AppTheme.primary,
                            Icons.monetization_on,
                            isCompact,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        // المدفوع
                        Expanded(
                          flex: 3,
                          child: _buildMiniDetailItem(
                            'المدفوع',
                            '${sale.paidAmount.toStringAsFixed(0)} ج',
                            AppTheme.info,
                            Icons.payment,
                            isCompact,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        // المبلغ المتبقي إذا كان موجوداً
                        if (sale.remainingAmount > 0)
                          Expanded(
                            flex: 4,
                            child: _buildMiniDetailItem(
                              'المتبقي',
                              '${sale.remainingAmount.toStringAsFixed(0)} ج',
                              AppTheme.warning,
                              Icons.pending_actions,
                              isCompact,
                            ),
                          )
                        else
                          Expanded(flex: 4, child: SizedBox()),
                      ],
                    ),

                    // الأزرار في صف منفصل دائماً لتجنب المساحة المحدودة
                    SizedBox(
                      height: isCompact ? 3.h : 4.h,
                    ), // Reduced spacing when compact
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildMiniActionButton(
                          icon: Icons.edit,
                          color: AppTheme.info,
                          isCompact: isCompact,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => EditSaleScreen(
                                      sale: sale,
                                      batch: batch,
                                    ),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 4.w),
                        _buildMiniActionButton(
                          icon: Icons.delete_outline,
                          color: AppTheme.error,
                          isCompact: isCompact,
                          onPressed: onDelete,
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
    );
  }

  Widget _buildMiniDetailItem(
    String label,
    String value,
    Color color,
    IconData icon,
    bool isCompact,
  ) {
    return Builder(
      builder:
          (context) => Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 3.w : 4.w, // Smaller padding when compact
              vertical: isCompact ? 3.h : 4.h,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.08), color.withOpacity(0.04)],
              ),
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: color.withOpacity(0.2), width: 0.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: isCompact ? 8.w : 10.w, // Smaller icon when compact
                ),
                SizedBox(height: 1.h),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize:
                        isCompact ? 6.sp : 7.sp, // Smaller font when compact
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize:
                        isCompact ? 7.sp : 8.sp, // Smaller font when compact
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildMiniActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required bool isCompact,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4.r),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4.r),
          child: Container(
            padding: EdgeInsets.all(
              isCompact ? 3.w : 4.w,
            ), // Smaller padding when compact
            child: Icon(
              icon,
              color: color,
              size: isCompact ? 12.w : 14.w, // Smaller icon when compact
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}
