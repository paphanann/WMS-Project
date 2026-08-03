import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle text({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle label() => text(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryBlue,
      );

  static TextStyle hint() => text(
        fontSize: 14,
        color: AppColors.textGray.withValues(alpha: 0.7),
      );

  static TextStyle body({Color? color}) => text(fontSize: 14, color: color);

  static TextStyle title() => text(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryBlue,
      );

  static TextStyle subtitle() => text(
        fontSize: 14,
        color: AppColors.textGray,
      );

  static TextStyle button() => text(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle caption() => text(
        fontSize: 12,
        color: AppColors.textGray,
      );

  static TextStyle link() => text(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryBlue,
      );

  static TextStyle small() => text(
        fontSize: 13,
        color: AppColors.textGray,
      );
}
