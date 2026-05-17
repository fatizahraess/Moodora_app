// Shared constants for colors, labels, and application defaults.
import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppConstants {
  const AppConstants._();

  static const Color primaryColor = AppColors.primaryPurple;
  static const Color secondaryColor = AppColors.coral;
  static const Color lightBackground = AppColors.deepBackground;
  static const Color darkBackground = AppColors.deepBackground;
  static const Color successColor = AppColors.success;
  static const Color warningColor = AppColors.warning;
  static const Color dangerColor = AppColors.danger;
  static const Color gradientEnd = AppColors.tomatoSoft;

  static const List<String> priorities = ['low', 'medium', 'high'];
  static const List<String> taskStatuses = ['all', 'active', 'completed'];
  static const List<String> sortOptions = ['priority', 'created', 'dueDate', 'title'];
}
