// Shared section title with optional action text for premium screens.
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'common_gradient_button.dart';

class CommonSectionTitle extends StatelessWidget {
  const CommonSectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.lightText
                      : AppColors.textWhite,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          CommonGradientButton(
            label: actionLabel!,
            primary: false,
            onPressed: onAction,
            width: 112,
          ),
      ],
    );
  }
}
