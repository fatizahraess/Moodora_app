// Text style helpers for the premium dark Moodora interface.
import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const TextStyle heroTitle = TextStyle(
    color: AppColors.textWhite,
    fontSize: 30,
    fontWeight: FontWeight.w900,
    height: 1.05,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.textWhite,
    fontSize: 20,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle muted = TextStyle(
    color: AppColors.textMuted,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
}
