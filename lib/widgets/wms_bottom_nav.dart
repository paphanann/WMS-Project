import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum WmsNavItem { home, receive, stock, menu }

class WmsBottomNav extends StatelessWidget {
  const WmsBottomNav({
    super.key,
    required this.current,
    this.onTap,
  });

  final WmsNavItem current;
  final ValueChanged<WmsNavItem>? onTap;

  static const _items = [
    (WmsNavItem.home, Icons.home_outlined, 'Home'),
    (WmsNavItem.receive, Icons.move_to_inbox_outlined, 'Receive'),
    (WmsNavItem.stock, Icons.inventory_2_outlined, 'Stock'),
    (WmsNavItem.menu, Icons.menu_rounded, 'Menu'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
      ),
      child: Row(
        children: _items.map((item) {
          final isActive = item.$1 == current;
          final color = isActive ? AppColors.accentGreen : Colors.white;

          return Expanded(
            child: InkWell(
              onTap: onTap != null ? () => onTap!(item.$1) : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.$2, color: color, size: 26),
                    const SizedBox(height: 4),
                    Text(
                      item.$3,
                      style: AppTextStyles.text(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
