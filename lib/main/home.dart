import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/home_menu_tile.dart';
import 'login.dart';
import 'receive.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.username = 'PASS User'});

  final String username;

  static const _menuItems = [
    ('picture/Receive.png', 'Receive'),
    ('picture/Put_Away.png', 'Put Away'),
    ('picture/Picking.png', 'Picking'),
    ('picture/Packing.png', 'Packing'),
    ('picture/Delivery.png', 'Delivery'),
    ('picture/Transfer.png', 'Transfer'),
    ('picture/Approval.png', 'Approval'),
    ('picture/Stock_Inquiry.png', 'Stock Inquiry'),
    ('picture/Cycle_Count.png', 'Cycle Count'),
  ];

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const _HomeHeader(),
          Expanded(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.95,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = _menuItems[index];
                        return HomeMenuTile(
                          imagePath: item.$1,
                          label: item.$2,
                          onTap: () {
                            if (item.$2 == 'Receive') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ReceivePage(username: username),
                                ),
                              );
                            }
                          },
                        );
                      },
                      childCount: _menuItems.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                    child: Align(
                      alignment: Alignment.center,
                      child: HomeMenuTile(
                        imagePath: 'picture/Setting.png',
                        label: 'Setting',
                        onTap: () {},
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _HomeBottomBar(
            username: username,
            onLogout: () => _logout(context),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  static const double _imageAspectRatio = 1717 / 916;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (screenWidth * dpr).round();
    final cacheHeight = (cacheWidth / _imageAspectRatio).round();

    return AspectRatio(
      aspectRatio: _imageAspectRatio,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          Image.asset(
            'picture/homepage.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fill,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
            filterQuality: FilterQuality.medium,
            gaplessPlayback: true,
          ),
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 4, right: 8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: AppColors.accentGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBottomBar extends StatelessWidget {
  const _HomeBottomBar({
    required this.username,
    required this.onLogout,
  });

  final String username;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.borderGray.withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.primaryBlue,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome back!',
                  style: AppTextStyles.caption(),
                ),
                Text(
                  username,
                  style: AppTextStyles.text(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
                Text(
                  'Warehouse Team',
                  style: AppTextStyles.caption(),
                ),
              ],
            ),
          ),
          Container(
            height: 44,
            width: 1,
            color: AppColors.borderGray,
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onLogout,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    color: AppColors.primaryBlue,
                    size: 26,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Logout',
                    style: AppTextStyles.text(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
