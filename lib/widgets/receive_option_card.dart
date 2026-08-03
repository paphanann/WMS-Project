import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ReceiveOptionCard extends StatelessWidget {
  const ReceiveOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isSelected = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor =
        isSelected ? AppColors.accentGreen : AppColors.primaryBlue;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: isSelected ? 0 : 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: AppColors.accentGreen, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: accentColor, size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.text(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.text(
                        fontSize: 13,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primaryBlue,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
