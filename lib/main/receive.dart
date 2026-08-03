import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/receive_option_card.dart';
import '../widgets/wms_bottom_nav.dart';
import '../widgets/wms_page_header.dart';
import 'home.dart';

class ReceivePage extends StatefulWidget {
  const ReceivePage({super.key, this.username = 'PASS User'});

  final String username;

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  int _selectedIndex = 0;

  static const _options = [
    (
      Icons.shopping_cart_outlined,
      'Purchase Order',
      'รับสินค้าจากใบสั่งซื้อ',
    ),
    (
      Icons.factory_outlined,
      'Production',
      'รับสินค้าจากการผลิต',
    ),
    (
      Icons.inventory_2_outlined,
      'Receipt',
      'รับสินค้าทั่วไป',
    ),
  ];

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(username: widget.username),
      ),
    );
  }

  void _onNavTap(WmsNavItem item) {
    switch (item) {
      case WmsNavItem.home:
        _goHome();
      case WmsNavItem.receive:
        break;
      case WmsNavItem.stock:
      case WmsNavItem.menu:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Column(
        children: [
          WmsPageHeader(
            title: 'Receive',
            onHome: _goHome,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.primaryBlue,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'เลือกรูปแบบการรับสินค้า',
                          style: AppTextStyles.text(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  for (var i = 0; i < _options.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    ReceiveOptionCard(
                      icon: _options[i].$1,
                      title: _options[i].$2,
                      subtitle: _options[i].$3,
                      isSelected: _selectedIndex == i,
                      onTap: () => setState(() => _selectedIndex = i),
                    ),
                  ],
                ],
              ),
            ),
          ),
          WmsBottomNav(
            current: WmsNavItem.receive,
            onTap: _onNavTap,
          ),
        ],
      ),
    );
  }
}
