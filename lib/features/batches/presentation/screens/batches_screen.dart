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
import '../../../additions/presentation/screens/additions_screen.dart';
import '../../../deaths/presentation/screens/deaths_screen.dart';
import '../../../sales/presentation/screens/sales_screen.dart';
import 'package:katakit/features/auth/cubit/auth_cubit.dart' as auth;

class BatchesScreen extends StatefulWidget {
  final Stream<SyncStatus>? syncStatusStream;
  const BatchesScreen({super.key, this.syncStatusStream});

  @override
  State<BatchesScreen> createState() => _BatchesScreenState();
}

class _BatchesScreenState extends State<BatchesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<BatchEntity> _filteredBatches = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    context.read<BatchesCubit>().loadBatches();
    // إشعار المستخدم عند تحديث البيانات من السحابة
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
  void dispose() {
    _searchController.dispose();
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
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.error,
                size: 24.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'تأكيد الحذف',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textMain,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'هل أنت متأكد من حذف دفعة "${batch.name}"؟\nلا يمكن التراجع عن هذا الإجراء.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<BatchesCubit>().deleteBatch(batch.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف الدفعة بنجاح'),
                    backgroundColor: AppTheme.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: AppTheme.textLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'مزامنة يدوية',
            onPressed: () async {
              await SyncService().processQueue();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم بدء المزامنة اليدوية...')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () {
              context.read<auth.AuthCubit>().logout();
            },
          ),
        ],
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
      body: Column(
        children: [
          // Search Bar
          EnhancedSearchField(
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
          // Batches List
          Expanded(
            child: BlocBuilder<BatchesCubit, BatchesState>(
              builder: (context, state) {
                if (state is BatchesLoading) {
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
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                } else if (state is BatchesLoaded) {
                  // Update filtered batches when data changes
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!_isSearching) {
                      setState(() {
                        _filteredBatches = state.batches;
                      });
                    } else {
                      // Re-filter with current search query
                      _filterBatches(_searchController.text, state.batches);
                    }
                  });

                  // Use current filtered batches for display
                  final batchesToShow =
                      _isSearching ? _filteredBatches : state.batches;

                  if (batchesToShow.isEmpty) {
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
                                  color: AppTheme.textFaint.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isSearching
                                  ? Icons.search_off
                                  : Icons.inbox_outlined,
                              size: 64.w,
                              color: AppTheme.textFaint,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            _isSearching ? 'لا توجد نتائج' : 'لا توجد دفعات',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.textMain,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            _isSearching
                                ? 'جرب البحث بكلمات مختلفة'
                                : 'اضغط على زر الإضافة لإنشاء دفعة جديدة',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(12.w),
                    itemCount: batchesToShow.length,
                    itemBuilder: (context, index) {
                      final batch = batchesToShow[index];
                      return BatchCard(
                        batch: batch,
                        onDelete: () => _showDeleteConfirmation(context, batch),
                      );
                    },
                  );
                } else if (state is BatchesError) {
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
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBatchScreen()),
          );
        },
        backgroundColor: AppTheme.accent,
        foregroundColor: AppTheme.textMain,
        icon: const Icon(Icons.add),
        label: const Text('دفعة جديدة'),
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
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      batch.name,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textMain,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${batch.chickCount} كتكوت',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (onDelete != null) ...[
                    SizedBox(width: 8.w),
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppTheme.error,
                        size: 20.w,
                      ),
                      tooltip: 'حذف الدفعة',
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.error.withOpacity(0.1),
                        padding: EdgeInsets.all(8.w),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 12.h),
              _buildInfoRow(context, Icons.person, 'المورد', batch.supplier),
              SizedBox(height: 6.h),
              _buildInfoRow(
                context,
                Icons.attach_money,
                'سعر الشراء',
                '${batch.chickBuyPrice.toStringAsFixed(2)} جنيه',
              ),
              SizedBox(height: 6.h),
              _buildInfoRow(
                context,
                Icons.calendar_today,
                'التاريخ',
                _formatDate(batch.date),
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
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
                      'إجمالي الشراء',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${batch.totalBuyPrice.toStringAsFixed(2)} جنيه',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: AppTheme.textSecondary),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMain),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
