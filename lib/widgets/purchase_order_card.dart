import 'package:flutter/material.dart';

import '../models/purchase_order.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PurchaseOrderCard extends StatelessWidget {
  const PurchaseOrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  final PurchaseOrderSummary order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = order.tab == PurchaseOrderTab.complete
        ? AppColors.textGray
        : AppColors.accentGreen;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      order.displayDocNum,
                      style: AppTextStyles.text(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentGreen,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${order.lineCount} รายการ',
                        style: AppTextStyles.text(
                          fontSize: 13,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.statusLabel,
                        style: AppTextStyles.text(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                order.cardName,
                style: AppTextStyles.text(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    order.formattedDate,
                    style: AppTextStyles.text(
                      fontSize: 13,
                      color: AppColors.textGray,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${order.totalQuantity.toStringAsFixed(0)} ชิ้น',
                    style: AppTextStyles.text(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
