import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class HomeMenuTile extends StatelessWidget {
  const HomeMenuTile({
    super.key,
    required this.imagePath,
    required this.label,
    this.onTap,
  });

  final String imagePath;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cacheSize =
        (78 * MediaQuery.devicePixelRatioOf(context)).round();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              cacheWidth: cacheSize,
              cacheHeight: cacheSize,
              filterQuality: FilterQuality.medium,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.text(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}
