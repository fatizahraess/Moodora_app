// Shared gradients used by headers, cards, buttons, and timer accents.
import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppGradients {
  const AppGradients._();

  static const LinearGradient hero = LinearGradient(
    colors: [AppColors.tomato, AppColors.tomatoSoft],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient timerAccent = LinearGradient(
    colors: [AppColors.tomatoSoft, AppColors.tomato],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cta = LinearGradient(
    colors: [AppColors.tomato, AppColors.tomatoSoft],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient card = LinearGradient(
    colors: [AppColors.surface, AppColors.surfaceDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pageBackground = LinearGradient(
    colors: [
      AppColors.deepBackground,
      AppColors.deepBackgroundAlt,
      AppColors.deepBackground,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient lightPageBackground = LinearGradient(
    colors: [
      AppColors.lightBackground,
      AppColors.lightBackgroundAlt,
      AppColors.lightBackground,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient lightCard = LinearGradient(
    colors: [AppColors.lightSurface, Color(0xFFFFFBF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightButton = LinearGradient(
    colors: [AppColors.tomato, AppColors.tomatoSoft],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
