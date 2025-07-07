import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:katakit/features/sales/presentation/screens/edit_sale_screen.dart';

import '../../../../core/entities/batch_entity.dart';
import '../../../../core/entities/sale_entity.dart';
import '../../../../core/theme/app_theme.dart';

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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditSaleScreen(sale: sale, batch: batch),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          bottom: isCompact ? 8.h : 10.h,
        ), // Increased margin
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.cardLight, AppTheme.cardLight.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(14.r), // Slightly more rounded
          boxShadow: [
            BoxShadow(
              color: AppTheme.textFaint.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 10.w : 14.w), // Increased padding
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
                        isCompact ? 6.w : 8.w,
                      ), // Increased padding
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
                            color: AppTheme.accent.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: isCompact ? 16.w : 18.w, // Increased icon size
                      ),
                    ),
                    SizedBox(width: 8.w),
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
                                      ? 14.sp
                                      : 16.sp, // Increased font size
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size:
                                    isCompact
                                        ? 10.w
                                        : 12.w, // Increased icon size
                                color: AppTheme.textSecondary,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                _formatDate(sale.date),
                                style: Theme.of(
                                  context,
                                ).textTheme.labelSmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontSize:
                                      isCompact
                                          ? 10.sp
                                          : 12.sp, // Increased font size
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 6.w : 8.w, // Increased padding
                        vertical: isCompact ? 4.h : 6.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.success.withOpacity(0.12),
                            AppTheme.success.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8.r),
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
                                      ? 12.sp
                                      : 14.sp, // Increased font size
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
                                      ? 9.sp
                                      : 11.sp, // Increased font size
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isCompact ? 6.h : 8.h), // Increased spacing
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
                          SizedBox(width: 6.w), // Increased spacing
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
                          SizedBox(width: 6.w), // Increased spacing
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
                        height: isCompact ? 4.h : 6.h,
                      ), // Increased spacing
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
                          SizedBox(width: 6.w), // Increased spacing
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
              horizontal: isCompact ? 4.w : 6.w, // Increased padding
              vertical: isCompact ? 4.h : 6.h,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.08), color.withOpacity(0.04)],
              ),
              borderRadius: BorderRadius.circular(6.r), // More rounded
              border: Border.all(color: color.withOpacity(0.2), width: 0.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: isCompact ? 10.w : 12.w, // Increased icon size
                ),
                SizedBox(height: 2.h),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: isCompact ? 7.sp : 8.sp, // Increased font size
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
                    fontSize: isCompact ? 8.sp : 10.sp, // Increased font size
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
        borderRadius: BorderRadius.circular(6.r), // More rounded
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6.r),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6.r),
          child: Container(
            padding: EdgeInsets.all(isCompact ? 4.w : 6.w), // Increased padding
            child: Icon(
              icon,
              color: color,
              size: isCompact ? 14.w : 16.w, // Increased icon size
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
