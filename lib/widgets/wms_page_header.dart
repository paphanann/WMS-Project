import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class WmsPageHeader extends StatelessWidget {
  const WmsPageHeader({
    super.key,
    required this.title,
    this.onHome,
  });

  final String title;
  final VoidCallback? onHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.borderGray.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Image.asset(
                  'picture/wms_logo.jpg',
                  height: 36,
                  fit: BoxFit.contain,
                ),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.text(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onHome,
                  icon: const Icon(
                    Icons.home_outlined,
                    color: AppColors.primaryBlue,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
