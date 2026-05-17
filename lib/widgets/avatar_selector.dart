// Emoji avatar selector without provider dependencies.
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class AvatarSelector extends StatelessWidget {
  const AvatarSelector({
    super.key,
    required this.selectedAvatar,
    required this.onAvatarSelected,
  });

  final String selectedAvatar;
  final ValueChanged<String> onAvatarSelected;

  static const avatars = ['🙂', '😎', '🚀', '😌', '🔥', '🌙', '⭐', '💪', '🧠', '🎯'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: avatars.map((avatar) {
        final selected = avatar == selectedAvatar;
        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => onAvatarSelected(avatar),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.tomato.withValues(alpha: 0.16)
                  : Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selected ? AppColors.tomato : AppColors.lightLine,
                width: selected ? 2 : 1,
              ),
            ),
            child: Text(avatar, style: const TextStyle(fontSize: 26)),
          ),
        );
      }).toList(),
    );
  }
}
