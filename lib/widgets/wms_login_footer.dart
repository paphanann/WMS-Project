import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class WmsLoginFooter extends StatelessWidget {
  const WmsLoginFooter({super.key});

  static const double _imageAspectRatio = 1774 / 887;
  static const double _bottomCropRatio = 0.11;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final cacheWidth =
        (screenWidth * MediaQuery.devicePixelRatioOf(context)).round();
    final fullHeight = screenWidth / _imageAspectRatio;
    final visibleHeight = fullHeight * (1 - _bottomCropRatio);

    return ColoredBox(
      color: AppColors.waveBlue,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: visibleHeight,
            width: double.infinity,
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  'picture/Footer.png',
                  width: screenWidth,
                  fit: BoxFit.fitWidth,
                  cacheWidth: cacheWidth,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          ),
          if (bottomInset > 0)
            Container(
              height: bottomInset,
              width: double.infinity,
              color: AppColors.waveBlue,
            ),
        ],
      ),
    );
  }
}
