import 'package:flutter/material.dart';

import '../models/purchase_order.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PurchaseOrderCard extends StatelessWidget {
  const PurchaseOrderCard({super.key, required this.order, this.onTap});

  final PurchaseOrderSummary order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor =
        order.isClosed ? AppColors.textGray : AppColors.accentGreen;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.poNo,
                      style: AppTextStyles.text(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentGreen,
                      ),
                    ),
                  ),
                  Text(
                    '${order.lineCount} รายการ',
                    style: AppTextStyles.text(fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  order.statusText,
                  style: AppTextStyles.text(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
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
                  Text(order.dateText, style: AppTextStyles.caption()),
                  const Spacer(),
                  Text(
                    order.totalQtyText,
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
